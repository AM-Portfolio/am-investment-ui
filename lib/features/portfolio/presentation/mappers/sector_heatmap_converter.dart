import 'package:flutter/material.dart';

import '../../../../shared/models/heatmap.dart';
import '../../../../shared/widgets/heatmap/configs/selector_config.dart';
import '../../../../shared/widgets/heatmap/heatmap_config.dart' as ui_config;
import '../../internal/domain/entities/portfolio_analytics.dart';

/// Utility class to convert portfolio analytics data to generic heatmap data
class SectorHeatmapConverter {
  /// Converts Heatmap data from portfolio analytics to generic HeatmapData
  static HeatmapData convertToHeatmapData({
    required Heatmap? heatmap,
    required bool showSubCards,
    String title = 'Portfolio Heatmap',
    String? subtitle,
    Color? accentColor,
  }) {
    if (heatmap == null || heatmap.sectors.isEmpty) {
      return _createEmptyHeatmapData(
        title: title,
        subtitle: subtitle,
        showSubCards: showSubCards,
        accentColor: accentColor,
      );
    }

    final totalValue = _calculateTotalValue(heatmap.sectors);
    final tiles = _createHierarchicalTiles(heatmap.sectors, totalValue);

    return _buildHeatmapData(
      heatmap: heatmap,
      title: title,
      subtitle: subtitle,
      tiles: tiles,
      totalValue: totalValue,
      showSubCards: showSubCards,
      accentColor: accentColor,
    );
  }

  /// Creates empty heatmap data for null or empty input
  static HeatmapData _createEmptyHeatmapData({
    required String title,
    required bool showSubCards,
    String? subtitle,
    Color? accentColor,
  }) => HeatmapData(
    id: 'portfolio-heatmap-empty',
    title: title,
    subtitle: subtitle,
    tiles: [],
    metadata: HeatmapMetadata(
      dataSource: 'sector_converter',
      lastUpdated: DateTime.now(),
      additionalInfo: const {},
    ),
    configuration: _getHeatmapConfig(
      title: title,
      showSubCards: showSubCards,
      accentColor: accentColor,
    ),
  );

  /// Creates hierarchical tiles with sectors and their stocks as children
  static List<HeatmapTileData> _createHierarchicalTiles(
    List<Sector> sectors,
    double totalValue,
  ) {
    final tiles = <HeatmapTileData>[];

    for (final sector in sectors) {
      final sectorTile = _createSectorTile(sector, totalValue);
      if (sectorTile != null) {
        tiles.add(sectorTile);
      }
    }

    // Sort sectors by weightage descending (largest sectors first)
    tiles.sort((a, b) => b.weightage.compareTo(a.weightage));
    return tiles;
  }

  /// Creates a single sector tile with its stock children
  static HeatmapTileData? _createSectorTile(Sector sector, double totalValue) {
    final sectorValue = _calculateSectorValue(sector);
    final sectorWeightage = totalValue > 0
        ? (sectorValue / totalValue) * 100
        : 0.0;

    if (sectorWeightage <= 0) return null;

    final stockTiles = _createStockTiles(sector, sectorValue);
    final avgPerformance = _calculateSectorPerformance(sector);

    return HeatmapTileData(
      id: sector.sectorName,
      name: sector.sectorName,
      displayName: _getSectorDisplayName(sector.sectorName),
      weightage: sectorWeightage.toDouble(),
      performance: avgPerformance,
      value: sectorValue,
      children: stockTiles.isNotEmpty ? stockTiles : null,
      metadata: {
        'type': 'sector',
        'sector': sector,
        'stockCount': sector.stockCount,
        'totalReturnAmount': sector.totalReturnAmount,
        'color': sector.color,
      },
    );
  }

  /// Creates stock tiles for a given sector
  static List<HeatmapTileData> _createStockTiles(
    Sector sector,
    double sectorValue,
  ) {
    final stockTiles = <HeatmapTileData>[];

    for (final stock in sector.stocks) {
      final stockTile = _createStockTile(stock, sector, sectorValue);
      if (stockTile != null) {
        stockTiles.add(stockTile);
      }
    }

    // Sort stocks within sector by weightage
    stockTiles.sort((a, b) => b.weightage.compareTo(a.weightage));
    return stockTiles;
  }

  /// Creates a single stock tile
  static HeatmapTileData? _createStockTile(
    Stock stock,
    Sector sector,
    double sectorValue,
  ) {
    final stockValue = _calculateStockValue(stock);
    final stockSectorWeightage = sectorValue > 0
        ? (stockValue / sectorValue) * 100
        : 0.0;

    if (stockSectorWeightage <= 0) return null;

    return HeatmapTileData(
      id: '${sector.sectorName}_${stock.symbol}',
      name: stock.symbol,
      displayName: _getStockDisplayName(stock),
      weightage: stockSectorWeightage.toDouble(),
      performance: stock.changePercent,
      value: stockValue,
      metadata: {
        'type': 'stock',
        'stock': stock,
        'parentSector': sector.sectorName,
        'sectorColor': sector.color,
        'companyName': stock.companyName,
        'lastPrice': stock.lastPrice,
        'changeAmount': stock.changeAmount,
        'quantity': stock.quantity,
        'avgPrice': stock.avgPrice,
        'totalReturn': stock.totalReturn,
      },
    );
  }

  /// Builds the final HeatmapData object
  static HeatmapData _buildHeatmapData({
    required Heatmap heatmap,
    required String title,
    required List<HeatmapTileData> tiles,
    required double totalValue,
    required bool showSubCards,
    String? subtitle,
    Color? accentColor,
  }) => HeatmapData(
    id: 'portfolio-heatmap-${heatmap.hashCode}',
    title: title,
    subtitle: subtitle ?? 'Sector allocation and individual stock performance',
    tiles: tiles,
    metadata: HeatmapMetadata(
      dataSource: 'sector_converter',
      lastUpdated: DateTime.now(),
      additionalInfo: {
        'totalValue': totalValue,
        'totalSectors': tiles.length,
        'totalStocks': tiles.fold<int>(
          0,
          (sum, tile) => sum + (tile.children?.length ?? 0),
        ),
        'hierarchicalData': true,
        'hasChildren': tiles.any((tile) => tile.hasChildren),
      },
    ),
    configuration: _getHeatmapConfig(
      title: title,
      showSubCards: showSubCards,
      accentColor: accentColor,
    ),
  );

  /// Gets the appropriate heatmap configuration
  static ui_config.HeatmapConfig _getHeatmapConfig({
    required String title,
    required bool showSubCards,
    Color? accentColor,
  }) {
    // Load platform-specific default configuration
    final defaultConfig = _loadPlatformDefaultConfig();
    
    // Apply portfolio-specific customizations
    return _applyPortfolioConfig(
      defaultConfig: defaultConfig,
      title: title,
      showSubCards: showSubCards,
      accentColor: accentColor,
    );
  }

  /// Loads platform-specific default configuration
  static ui_config.HeatmapConfig _loadPlatformDefaultConfig() {
    // Start with base web defaults or mobile defaults based on platform
    // For now, using web defaults as base - this can be enhanced with platform detection
    return ui_config.HeatmapConfig.webDefaults();
  }

  /// Applies portfolio-specific configuration on top of platform defaults
  static ui_config.HeatmapConfig _applyPortfolioConfig({
    required ui_config.HeatmapConfig defaultConfig,
    required String title,
    required bool showSubCards,
    Color? accentColor,
  }) {
    if (showSubCards) {
      // Desktop/Web portfolio configuration
      return _applyDesktopPortfolioConfig(
        defaultConfig: defaultConfig,
        title: title,
        accentColor: accentColor,
      );
    } else {
      // Mobile portfolio configuration
      return _applyMobilePortfolioConfig(
        defaultConfig: defaultConfig,
        title: title,
        accentColor: accentColor,
      );
    }
  }

  /// Applies desktop/web portfolio specific configuration
  static ui_config.HeatmapConfig _applyDesktopPortfolioConfig({
    required ui_config.HeatmapConfig defaultConfig,
    required String title,
    Color? accentColor,
  }) {
    return defaultConfig.copyWith(
      displayConfig: defaultConfig.displayConfig.copyWith(
        title: title,
        accentColor: accentColor,
      ),
      selectorConfig: defaultConfig.selectorConfig.copyWith(
        layout: SelectorLayoutType.compact,
        // Keep other selector defaults from platform config
      ),
      // Additional desktop-specific overrides can be added here
    );
  }

  /// Applies mobile portfolio specific configuration
  static ui_config.HeatmapConfig _applyMobilePortfolioConfig({
    required ui_config.HeatmapConfig defaultConfig,
    required String title,
    Color? accentColor,
  }) {
    return defaultConfig.copyWith(
      displayConfig: defaultConfig.displayConfig.copyWith(
        title: title,
        accentColor: accentColor,
        // Mobile-specific display adjustments
      ),
      selectorConfig: defaultConfig.selectorConfig.copyWith(
        layout: SelectorLayoutType.compact,
        // Mobile-specific selector adjustments
      ),
      layoutConfig: defaultConfig.layoutConfig.copyWith(
        // Mobile-specific layout adjustments (smaller tiles, different spacing, etc.)
      ),
    );
  }

  /// Calculates the total value for a sector
  static double _calculateSectorValue(Sector sector) => sector.totalValue > 0
      ? sector.totalValue
      : sector.stocks.fold(
          0.0,
          (sum, stock) => sum + _calculateStockValue(stock),
        );

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

  /// Calculate the market value of a stock
  static double _calculateStockValue(Stock stock) {
    // Priority order: marketValue > calculated value from quantity * lastPrice > fallback to lastPrice
    if (stock.marketValue != null && stock.marketValue! > 0) {
      return stock.marketValue!;
    }

    if (stock.quantity != null && stock.quantity! > 0) {
      return stock.quantity! * stock.lastPrice;
    }

    // Fallback - return last price (assuming 1 share)
    return stock.lastPrice;
  }

  /// Get display name for a stock (symbol with optional company name shortening)
  static String _getStockDisplayName(Stock stock) {
    // For most stocks, the symbol is sufficient
    // But for very long symbols or when we want to show company name, we can modify this
    if (stock.symbol.length > 6) {
      return stock.symbol.substring(0, 6);
    }
    return stock.symbol;
  }

  /// Calculate average performance for a sector
  static double _calculateSectorPerformance(Sector sector) {
    if (sector.stocks.isEmpty) return sector.performance;

    final totalPerformance = sector.stocks.fold(
      0.0,
      (sum, stock) => sum + stock.changePercent,
    );
    return totalPerformance / sector.stocks.length;
  }

  /// Get display name for a sector (with abbreviations for long names)
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
