import 'package:flutter/material.dart';
import '../../../core/app_logic/domain/entities/heatmap/heatmap_entities.dart';
import '../../models/heatmap/heatmap_ui_data.dart';
import '../../models/heatmap/heatmap_tile_data.dart';
import '../../widgets/selectors/selectors.dart';

/// Enum for different investment filter types
enum InvestmentFilterType {
  portfolio('Portfolio', 'Holdings-based analysis'),
  indexFund('Index', 'Market index tracking'),
  mutualFunds('Mutual Funds', 'Fund performance analysis'),
  etf('ETF', 'Exchange-traded funds'),
  stocks('Stocks', 'Individual stock analysis'),
  sectors('Sectors', 'Sector-wise breakdown');

  const InvestmentFilterType(this.displayName, this.description);

  final String displayName;
  final String description;
}

/// Configuration for different investment types
class InvestmentTypeConfig {
  final InvestmentFilterType type;
  final HeatmapConfigurationEntity heatmapConfig;
  final List<TimeFrame> availableTimeFrames;
  final List<MetricType> availableMetrics;
  final List<SectorType>? availableSectors;
  final List<MarketCapType>? availableMarketCaps;
  final bool showSelectors;
  final bool compactView;
  final String title;
  final IconData icon;
  final Color? accentColor;

  const InvestmentTypeConfig({
    required this.type,
    required this.heatmapConfig,
    required this.availableTimeFrames,
    required this.availableMetrics,
    this.availableSectors,
    this.availableMarketCaps,
    this.showSelectors = true,
    this.compactView = false,
    required this.title,
    required this.icon,
    this.accentColor,
  });

  /// Factory constructor for portfolio type
  factory InvestmentTypeConfig.portfolio({
    bool compactView = false,
    Color? accentColor,
  }) {
    return InvestmentTypeConfig(
      type: InvestmentFilterType.portfolio,
      heatmapConfig: HeatmapConfigurationEntity(
        showPerformance: true,
        showWeightage: true,
        showValue: true,
        layout: compactView
            ? HeatmapLayoutType.grid
            : HeatmapLayoutType.treemap,
        colorScheme: HeatmapColorSchemeType.performance,
        defaultSorting: HeatmapSortingType.weightage,
      ),
      availableTimeFrames: TimeFrame.portfolioTimeFrames,
      availableMetrics: [
        MetricType.changePercent,
        MetricType.changeAmount,
        MetricType.totalReturn,
        MetricType.dayReturn,
      ],
      availableSectors: SectorType.values,
      availableMarketCaps: MarketCapType.values,
      showSelectors: true,
      compactView: compactView,
      title: 'Portfolio Heatmap',
      icon: Icons.pie_chart,
      accentColor: accentColor ?? Colors.blue,
    );
  }

  /// Factory constructor for index type
  factory InvestmentTypeConfig.index({
    bool compactView = false,
    Color? accentColor,
  }) {
    return InvestmentTypeConfig(
      type: InvestmentFilterType.indexFund,
      heatmapConfig: HeatmapConfigurationEntity(
        showPerformance: true,
        showWeightage: true,
        showValue: false, // Less relevant for index
        layout: HeatmapLayoutType.grid,
        colorScheme: HeatmapColorSchemeType.performance,
        defaultSorting: HeatmapSortingType.performance,
      ),
      availableTimeFrames: TimeFrame.heatmapTimeFrames,
      availableMetrics: [
        MetricType.changePercent,
        MetricType.changeAmount,
        MetricType.dayReturn,
      ],
      availableSectors: SectorType.values,
      availableMarketCaps: MarketCapType.values,
      showSelectors: true,
      compactView: compactView,
      title: 'Index Heatmap',
      icon: Icons.trending_up,
      accentColor: accentColor ?? Colors.green,
    );
  }

  /// Factory constructor for mutual funds type
  factory InvestmentTypeConfig.mutualFunds({
    bool compactView = false,
    Color? accentColor,
  }) {
    return InvestmentTypeConfig(
      type: InvestmentFilterType.mutualFunds,
      heatmapConfig: HeatmapConfigurationEntity(
        showPerformance: true,
        showWeightage: true,
        showValue: true,
        layout: HeatmapLayoutType.grid,
        colorScheme: HeatmapColorSchemeType.performance,
        defaultSorting: HeatmapSortingType.performance,
      ),
      availableTimeFrames: [
        TimeFrame.oneMonth,
        TimeFrame.threeMonths,
        TimeFrame.sixMonths,
        TimeFrame.oneYear,
        TimeFrame.threeYears,
        TimeFrame.fiveYears,
      ],
      availableMetrics: [
        MetricType.changePercent,
        MetricType.returns,
        MetricType.marketValue,
        MetricType.volume,
      ],
      availableSectors: null, // Funds may not have sector breakdown
      availableMarketCaps: null,
      showSelectors: true,
      compactView: compactView,
      title: 'Mutual Funds Heatmap',
      icon: Icons.account_balance,
      accentColor: accentColor ?? Colors.orange,
    );
  }

  /// Factory constructor for ETF type
  factory InvestmentTypeConfig.etf({
    bool compactView = false,
    Color? accentColor,
  }) {
    return InvestmentTypeConfig(
      type: InvestmentFilterType.etf,
      heatmapConfig: HeatmapConfigurationEntity(
        showPerformance: true,
        showWeightage: true,
        showValue: true,
        layout: HeatmapLayoutType.treemap,
        colorScheme: HeatmapColorSchemeType.performance,
        defaultSorting: HeatmapSortingType.performance,
      ),
      availableTimeFrames: TimeFrame.heatmapTimeFrames,
      availableMetrics: [
        MetricType.changePercent,
        MetricType.returns,
        MetricType.volume,
        MetricType.marketValue,
      ],
      availableSectors: SectorType.values,
      availableMarketCaps: MarketCapType.values,
      showSelectors: true,
      compactView: compactView,
      title: 'ETF Heatmap',
      icon: Icons.savings,
      accentColor: accentColor ?? Colors.purple,
    );
  }

  /// Factory constructor for stocks type
  factory InvestmentTypeConfig.stocks({
    bool compactView = false,
    Color? accentColor,
  }) {
    return InvestmentTypeConfig(
      type: InvestmentFilterType.stocks,
      heatmapConfig: HeatmapConfigurationEntity(
        showPerformance: true,
        showWeightage: false, // Less relevant for individual stocks
        showValue: true,
        layout: HeatmapLayoutType.grid,
        colorScheme: HeatmapColorSchemeType.performance,
        defaultSorting: HeatmapSortingType.performance,
      ),
      availableTimeFrames: TimeFrame.heatmapTimeFrames,
      availableMetrics: [
        MetricType.changePercent,
        MetricType.returns,
        MetricType.volume,
        MetricType.marketValue,
      ],
      availableSectors: SectorType.values,
      availableMarketCaps: MarketCapType.values,
      showSelectors: true,
      compactView: compactView,
      title: 'Stocks Heatmap',
      icon: Icons.show_chart,
      accentColor: accentColor ?? Colors.red,
    );
  }

  /// Factory constructor for sectors type
  factory InvestmentTypeConfig.sectors({
    bool compactView = false,
    Color? accentColor,
  }) {
    return InvestmentTypeConfig(
      type: InvestmentFilterType.sectors,
      heatmapConfig: HeatmapConfigurationEntity(
        showPerformance: true,
        showWeightage: true,
        showValue: true,
        layout: HeatmapLayoutType.treemap,
        colorScheme: HeatmapColorSchemeType.performance,
        defaultSorting: HeatmapSortingType.weightage,
      ),
      availableTimeFrames: TimeFrame.heatmapTimeFrames,
      availableMetrics: [
        MetricType.changePercent,
        MetricType.returns,
        MetricType.marketValue,
      ],
      availableSectors: null, // Sectors themselves are the focus
      availableMarketCaps: MarketCapType.values,
      showSelectors: true,
      compactView: compactView,
      title: 'Sectors Heatmap',
      icon: Icons.pie_chart_outline,
      accentColor: accentColor ?? Colors.teal,
    );
  }

  /// Get configuration for a specific investment type
  static InvestmentTypeConfig getConfig(
    InvestmentFilterType type, {
    bool compactView = false,
    Color? accentColor,
  }) {
    switch (type) {
      case InvestmentFilterType.portfolio:
        return InvestmentTypeConfig.portfolio(
          compactView: compactView,
          accentColor: accentColor,
        );
      case InvestmentFilterType.indexFund:
        return InvestmentTypeConfig.index(
          compactView: compactView,
          accentColor: accentColor,
        );
      case InvestmentFilterType.mutualFunds:
        return InvestmentTypeConfig.mutualFunds(
          compactView: compactView,
          accentColor: accentColor,
        );
      case InvestmentFilterType.etf:
        return InvestmentTypeConfig.etf(
          compactView: compactView,
          accentColor: accentColor,
        );
      case InvestmentFilterType.stocks:
        return InvestmentTypeConfig.stocks(
          compactView: compactView,
          accentColor: accentColor,
        );
      case InvestmentFilterType.sectors:
        return InvestmentTypeConfig.sectors(
          compactView: compactView,
          accentColor: accentColor,
        );
    }
  }
}

/// Base input data interface for different investment types
abstract class InvestmentInputData {
  String get id;
  String get name;
  double get currentValue;
  double get changeAmount;
  double get changePercent;
  DateTime get lastUpdated;
  Map<String, dynamic> get additionalData;

  /// Convert to heatmap tile data
  HeatmapTileData toHeatmapTile();
}

/// Portfolio input data
class PortfolioInputData extends InvestmentInputData {
  @override
  final String id;
  @override
  final String name;
  @override
  final double currentValue;
  @override
  final double changeAmount;
  @override
  final double changePercent;
  @override
  final DateTime lastUpdated;

  final double weightage;
  final String? sector;
  final String? marketCap;
  final int? quantity;
  final double? averagePrice;

  @override
  final Map<String, dynamic> additionalData;

  PortfolioInputData({
    required this.id,
    required this.name,
    required this.currentValue,
    required this.changeAmount,
    required this.changePercent,
    required this.lastUpdated,
    required this.weightage,
    this.sector,
    this.marketCap,
    this.quantity,
    this.averagePrice,
    this.additionalData = const {},
  });

  @override
  HeatmapTileData toHeatmapTile() {
    return HeatmapTileData(
      id: id,
      name: name,
      displayName: name,
      performance: changePercent,
      weightage: weightage,
      value: currentValue,
      metadata: {
        'sector': sector,
        'marketCap': marketCap,
        'quantity': quantity,
        'averagePrice': averagePrice,
        'lastUpdated': lastUpdated.toIso8601String(),
        ...additionalData,
      },
    );
  }
}

/// Index input data
class IndexInputData extends InvestmentInputData {
  @override
  final String id;
  @override
  final String name;
  @override
  final double currentValue;
  @override
  final double changeAmount;
  @override
  final double changePercent;
  @override
  final DateTime lastUpdated;

  final double marketCap;
  final String? sector;
  final int? constituents;

  @override
  final Map<String, dynamic> additionalData;

  IndexInputData({
    required this.id,
    required this.name,
    required this.currentValue,
    required this.changeAmount,
    required this.changePercent,
    required this.lastUpdated,
    required this.marketCap,
    this.sector,
    this.constituents,
    this.additionalData = const {},
  });

  @override
  HeatmapTileData toHeatmapTile() {
    // Calculate weightage based on market cap (relative to total)
    final weightage = (marketCap / 1000000).clamp(
      0.1,
      100.0,
    ); // Simple calculation

    return HeatmapTileData(
      id: id,
      name: name,
      displayName: name,
      performance: changePercent,
      weightage: weightage,
      value: currentValue,
      metadata: {
        'marketCap': marketCap,
        'sector': sector,
        'constituents': constituents,
        'lastUpdated': lastUpdated.toIso8601String(),
        ...additionalData,
      },
    );
  }
}

/// Mutual fund input data
class MutualFundInputData extends InvestmentInputData {
  @override
  final String id;
  @override
  final String name;
  @override
  final double currentValue; // NAV
  @override
  final double changeAmount;
  @override
  final double changePercent;
  @override
  final DateTime lastUpdated;

  final double aum; // Assets under management
  final String category;
  final double? expenseRatio;
  final int? holdings;

  @override
  final Map<String, dynamic> additionalData;

  MutualFundInputData({
    required this.id,
    required this.name,
    required this.currentValue,
    required this.changeAmount,
    required this.changePercent,
    required this.lastUpdated,
    required this.aum,
    required this.category,
    this.expenseRatio,
    this.holdings,
    this.additionalData = const {},
  });

  @override
  HeatmapTileData toHeatmapTile() {
    // Calculate weightage based on AUM
    final weightage = (aum / 1000000000).clamp(
      0.1,
      100.0,
    ); // Relative to billions

    return HeatmapTileData(
      id: id,
      name: name,
      displayName: name,
      performance: changePercent,
      weightage: weightage,
      value: currentValue,
      metadata: {
        'aum': aum,
        'category': category,
        'expenseRatio': expenseRatio,
        'holdings': holdings,
        'lastUpdated': lastUpdated.toIso8601String(),
        ...additionalData,
      },
    );
  }
}

/// ETF input data
class EtfInputData extends InvestmentInputData {
  @override
  final String id;
  @override
  final String name;
  @override
  final double currentValue; // NAV
  @override
  final double changeAmount;
  @override
  final double changePercent;
  @override
  final DateTime lastUpdated;

  final double volume;
  final String trackingIndex;
  final double? trackingError;
  final String? sector;

  @override
  final Map<String, dynamic> additionalData;

  EtfInputData({
    required this.id,
    required this.name,
    required this.currentValue,
    required this.changeAmount,
    required this.changePercent,
    required this.lastUpdated,
    required this.volume,
    required this.trackingIndex,
    this.trackingError,
    this.sector,
    this.additionalData = const {},
  });

  @override
  HeatmapTileData toHeatmapTile() {
    // Calculate weightage based on volume
    final weightage = (volume / 1000000).clamp(
      0.1,
      100.0,
    ); // Relative to millions

    return HeatmapTileData(
      id: id,
      name: name,
      displayName: name,
      performance: changePercent,
      weightage: weightage,
      value: currentValue,
      metadata: {
        'volume': volume,
        'trackingIndex': trackingIndex,
        'trackingError': trackingError,
        'sector': sector,
        'lastUpdated': lastUpdated.toIso8601String(),
        ...additionalData,
      },
    );
  }
}
