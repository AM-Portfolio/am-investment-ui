import 'package:flutter/material.dart';

import '../../../../shared/models/heatmap.dart';
import '../../../../shared/widgets/heatmap/heatmap_config.dart' as ui_config;
import '../../internal/domain/entities/portfolio_analytics.dart';

/// Utility class to convert portfolio analytics data to generic heatmap data
class SectorHeatmapConverter {
  /// Converts Heatmap data from portfolio analytics to generic HeatmapData
  static HeatmapData convertToHeatmapData({
    required Heatmap? heatmap,
    required bool showSubCards,
    String title = 'Sector Allocation',
    String? subtitle,
    Color? accentColor,
  }) {
    if (heatmap == null || heatmap.sectors.isEmpty) {
      return HeatmapData(
        id: 'sector-heatmap-empty',
        title: title,
        subtitle: subtitle,
        tiles: [],
        metadata: HeatmapMetadata(
          dataSource: 'sector_converter',
          lastUpdated: DateTime.now(),
          additionalInfo: const {},
        ),
        configuration: showSubCards
            ? ui_config.HeatmapConfig.portfolio(
                title: title,
                accentColor: accentColor,
              )
            : ui_config.HeatmapConfig.mobilePortfolio(
                title: title,
                accentColor: accentColor,
              ),
      );
    }

    // Calculate total portfolio value
    final totalValue = _calculateTotalValue(heatmap.sectors);

    // Convert sectors to heatmap tiles
    final tiles = heatmap.sectors
        .map((sector) {
          // Calculate sector value
          final sectorValue = sector.totalValue > 0
              ? sector.totalValue
              : sector.stocks.fold(0.0, (sum, stock) {
                  if (stock.marketValue != null && stock.marketValue! > 0) {
                    return sum + stock.marketValue!;
                  }
                  if (stock.quantity != null && stock.quantity! > 0) {
                    return sum + (stock.quantity! * stock.lastPrice);
                  }
                  return sum;
                });

          // Use sector.weightage if available, otherwise calculate
          final weightage = sector.weightage > 0
              ? sector.weightage
              : (totalValue > 0 ? (sectorValue / totalValue) * 100 : 0);

          final avgPerformance = _calculateSectorPerformance(sector);

          return HeatmapTileData(
            id: sector.sectorName,
            name: sector.sectorName,
            displayName: _getSectorDisplayName(sector.sectorName),
            weightage: weightage.toDouble(),
            performance: avgPerformance,
            value: sectorValue,
            metadata: {
              'sector': sector,
              'stockCount': sector.stockCount,
              'totalReturnAmount': sector.totalReturnAmount,
            },
          );
        })
        .where((tile) => tile.weightage > 0) // Filter out zero-weight sectors
        .toList();

    // Sort by weightage descending
    tiles.sort((a, b) => b.weightage.compareTo(a.weightage));

    return HeatmapData(
      id: 'sector-heatmap-${heatmap.hashCode}',
      title: title,
      subtitle: subtitle,
      tiles: tiles,
      metadata: HeatmapMetadata(
        dataSource: 'sector_converter',
        lastUpdated: DateTime.now(),
        additionalInfo: {'totalValue': totalValue},
      ),
      configuration: showSubCards
          ? ui_config.HeatmapConfig.portfolio(
              title: title,
              accentColor: accentColor,
            )
          : ui_config.HeatmapConfig.mobilePortfolio(
              title: title,
              accentColor: accentColor,
            ),
    );
  }

  static double _calculateTotalValue(List<Sector> sectors) =>
      sectors.fold(0.0, (sum, sector) {
        // Try sector.totalValue first
        if (sector.totalValue > 0) {
          return sum + sector.totalValue;
        }
        // Fallback: calculate from stocks
        final sectorValue = sector.stocks.fold(0.0, (sectorSum, stock) {
          if (stock.marketValue != null && stock.marketValue! > 0) {
            return sectorSum + stock.marketValue!;
          }
          if (stock.quantity != null && stock.quantity! > 0) {
            return sectorSum + (stock.quantity! * stock.lastPrice);
          }
          return sectorSum;
        });
        return sum + sectorValue;
      });

  static double _calculateSectorPerformance(Sector sector) {
    if (sector.stocks.isEmpty) return 0.0;

    final totalPerformance = sector.stocks.fold(
      0.0,
      (sum, stock) => sum + stock.changePercent,
    );
    return totalPerformance / sector.stocks.length;
  }

  static String _getSectorDisplayName(String sectorName) {
    // Shorten long sector names for better display
    final sectorAbbreviations = <String, String>{
      'Information Technology': 'IT',
      'Financial Services': 'Finance',
      'Consumer Durables': 'Consumer Dur.',
      'Consumer Non-Durables': 'Consumer Non-Dur.',
      'Health Technology': 'Health Tech',
      'Electronic Technology': 'Electronic Tech',
      'Technology Services': 'Tech Services',
      'Producer Manufacturing': 'Manufacturing',
      'Process Industries': 'Process Ind.',
      'Transportation': 'Transport',
      'Commercial Services': 'Commercial',
      'Energy Minerals': 'Energy',
      'Non-Energy Minerals': 'Minerals',
    };

    return sectorAbbreviations[sectorName] ??
        (sectorName.length > 12
            ? '${sectorName.substring(0, 12)}...'
            : sectorName);
  }
}
