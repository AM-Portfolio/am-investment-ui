import 'package:flutter/material.dart';
import 'dart:convert';
import '../../internal/domain/entities/portfolio_analytics.dart';
import 'sector_overview_card.dart';
import 'sector_details_card.dart';
import '../../../../core/utils/logger.dart';

/// Widget displaying comprehensive portfolio heatmap visualization
/// Shows sector allocation overview and detailed sector information with expandable stock lists
class HeatmapWidget extends StatelessWidget {
  final Heatmap? heatmap;
  final bool isLoading;
  final String? error;

  const HeatmapWidget({
    super.key,
    this.heatmap,
    this.isLoading = false,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    // Log heatmap data for debugging
    _logHeatmapData();

    // Determine if sub-cards should be shown based on screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final showSubCards =
        screenWidth > 768; // Show sub-cards on web/tablet, hide on mobile

    return SingleChildScrollView(
      child: Column(
        children: [
          // First card: Sector allocation overview with visual heatmap
          SectorOverviewCard(
            heatmap: heatmap,
            isLoading: isLoading,
            error: error,
            showSubCards: showSubCards,
          ),

          const SizedBox(height: 16),

          // Second card: Detailed sector list with expandable stock information
          SectorDetailsCard(
            heatmap: heatmap,
            isLoading: isLoading,
            error: error,
          ),
        ],
      ),
    );
  }

  /// Logs complete heatmap data structure for debugging purposes
  void _logHeatmapData() {
    AppLogger.info(
      'HeatmapWidget build - isLoading: $isLoading, error: $error, hasHeatmap: ${heatmap != null}',
      tag: 'HeatmapWidget',
    );

    if (heatmap != null) {
      try {
        // Convert heatmap to a detailed map for JSON logging
        final heatmapData = {
          'sectors': heatmap!.sectors
              .map(
                (sector) => {
                  'sectorName': sector.sectorName,
                  'totalValue': sector.totalValue,
                  'weightage': sector.weightage,
                  'stocks': sector.stocks
                      .map(
                        (stock) => {
                          'symbol': stock.symbol,
                          'companyName': stock.companyName,
                          'lastPrice': stock.lastPrice,
                          'changeAmount': stock.changeAmount,
                          'changePercent': stock.changePercent,
                          'sector': stock.sector,
                          'quantity': stock.quantity,
                          'avgPrice': stock.avgPrice,
                          'marketValue': stock.marketValue,
                          'totalReturn': stock.totalReturn,
                        },
                      )
                      .toList(),
                },
              )
              .toList(),
        };

        // Log the complete heatmap structure in JSON format
        final jsonString = const JsonEncoder.withIndent(
          '  ',
        ).convert(heatmapData);
        AppLogger.debug(
          'Complete Heatmap Data:\n$jsonString',
          tag: 'HeatmapWidget',
        );

        // Log summary statistics
        AppLogger.info(
          'Heatmap Summary - Total sectors: ${heatmap!.sectors.length}, '
          'Total stocks: ${heatmap!.sectors.fold(0, (sum, sector) => sum + sector.stocks.length)}',
          tag: 'HeatmapWidget',
        );

        // Log sector-wise stock counts and details
        _logSectorDetails();
      } catch (e) {
        AppLogger.error('Error logging heatmap data: $e', tag: 'HeatmapWidget');
      }
    } else {
      AppLogger.warning(
        'Heatmap is null - no data to display',
        tag: 'HeatmapWidget',
      );
    }
  }

  /// Logs detailed information for each sector
  void _logSectorDetails() {
    for (final sector in heatmap!.sectors) {
      AppLogger.debug(
        'Sector: ${sector.sectorName} - '
        'Stocks: ${sector.stocks.length}, '
        'TotalValue: ${sector.totalValue}, '
        'Weightage: ${sector.weightage}',
        tag: 'HeatmapWidget',
      );

      // Log first few stocks in each sector for detailed analysis
      final stocksToLog = sector.stocks.take(3).toList();
      for (int i = 0; i < stocksToLog.length; i++) {
        final stock = stocksToLog[i];
        AppLogger.debug(
          'Stock ${i + 1} in ${sector.sectorName}: ${stock.symbol} - '
          'LastPrice: ${stock.lastPrice}, '
          'MarketValue: ${stock.marketValue}, '
          'Quantity: ${stock.quantity}, '
          'AvgPrice: ${stock.avgPrice}, '
          'ChangeAmount: ${stock.changeAmount}, '
          'ChangePercent: ${stock.changePercent}',
          tag: 'HeatmapWidget',
        );
      }
    }
  }
}
