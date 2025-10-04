import 'package:flutter/material.dart';

import '../heatmap_config.dart' as ui_config;
import '../../selectors/selectors.dart';
import 'types.dart';
import 'universal_heatmap_widget.dart';

/// Convenience widgets for specific investment types with template composition

/// Portfolio-specific heatmap widget
class PortfolioHeatmapWidget extends StatelessWidget {
  const PortfolioHeatmapWidget({
    required this.portfolioData,
    super.key,
    this.config,
    this.title,
    this.compactMode,
    this.showSelectors,
    this.onTilePressed,
    this.onFiltersChanged,
    this.isLoading = false,
    this.error,
    this.templateType = UniversalTemplateType.adaptive,
  });

  final Map<String, dynamic> portfolioData;
  final ui_config.HeatmapConfig? config;
  final String? title;
  final bool? compactMode;
  final bool? showSelectors;
  final VoidCallback? onTilePressed;
  final Function({
    TimeFrame? timeFrame,
    MetricType? metric,
    SectorType? sector,
    MarketCapType? marketCap,
  })?
  onFiltersChanged;
  final bool isLoading;
  final String? error;
  final UniversalTemplateType templateType;

  @override
  Widget build(BuildContext context) => UniversalHeatmapWidget(
    investmentType: InvestmentType.portfolio,
    rawData: portfolioData,
    config: config,
    title: title,
    compactMode: compactMode,
    showSelectors: showSelectors,
    onTilePressed: onTilePressed,
    onFiltersChanged: onFiltersChanged,
    isLoading: isLoading,
    error: error,
    templateType: templateType,
  );
}

/// Index-specific heatmap widget
class IndexHeatmapWidget extends StatelessWidget {
  const IndexHeatmapWidget({
    required this.indexData,
    super.key,
    this.config,
    this.title,
    this.compactMode,
    this.showSelectors,
    this.onTilePressed,
    this.onFiltersChanged,
    this.isLoading = false,
    this.error,
    this.templateType = UniversalTemplateType.adaptive,
  });

  final Map<String, dynamic> indexData;
  final ui_config.HeatmapConfig? config;
  final String? title;
  final bool? compactMode;
  final bool? showSelectors;
  final VoidCallback? onTilePressed;
  final Function({
    TimeFrame? timeFrame,
    MetricType? metric,
    SectorType? sector,
    MarketCapType? marketCap,
  })?
  onFiltersChanged;
  final bool isLoading;
  final String? error;
  final UniversalTemplateType templateType;

  @override
  Widget build(BuildContext context) => UniversalHeatmapWidget(
    investmentType: InvestmentType.indexFund,
    rawData: indexData,
    config: config,
    title: title,
    compactMode: compactMode,
    showSelectors: showSelectors,
    onTilePressed: onTilePressed,
    onFiltersChanged: onFiltersChanged,
    isLoading: isLoading,
    error: error,
    templateType: templateType,
  );
}

/// Mutual funds-specific heatmap widget
class MutualFundsHeatmapWidget extends StatelessWidget {
  const MutualFundsHeatmapWidget({
    required this.fundsData,
    super.key,
    this.config,
    this.title,
    this.compactMode,
    this.showSelectors,
    this.onTilePressed,
    this.onFiltersChanged,
    this.isLoading = false,
    this.error,
    this.templateType = UniversalTemplateType.adaptive,
  });

  final Map<String, dynamic> fundsData;
  final ui_config.HeatmapConfig? config;
  final String? title;
  final bool? compactMode;
  final bool? showSelectors;
  final VoidCallback? onTilePressed;
  final Function({
    TimeFrame? timeFrame,
    MetricType? metric,
    SectorType? sector,
    MarketCapType? marketCap,
  })?
  onFiltersChanged;
  final bool isLoading;
  final String? error;
  final UniversalTemplateType templateType;

  @override
  Widget build(BuildContext context) => UniversalHeatmapWidget(
    investmentType: InvestmentType.mutualFunds,
    rawData: fundsData,
    config: config,
    title: title,
    compactMode: compactMode,
    showSelectors: showSelectors,
    onTilePressed: onTilePressed,
    onFiltersChanged: onFiltersChanged,
    isLoading: isLoading,
    error: error,
    templateType: templateType,
  );
}

/// ETF-specific heatmap widget
class ETFHeatmapWidget extends StatelessWidget {
  const ETFHeatmapWidget({
    required this.etfData,
    super.key,
    this.config,
    this.title,
    this.compactMode,
    this.showSelectors,
    this.onTilePressed,
    this.onFiltersChanged,
    this.isLoading = false,
    this.error,
    this.templateType = UniversalTemplateType.adaptive,
  });

  final Map<String, dynamic> etfData;
  final ui_config.HeatmapConfig? config;
  final String? title;
  final bool? compactMode;
  final bool? showSelectors;
  final VoidCallback? onTilePressed;
  final Function({
    TimeFrame? timeFrame,
    MetricType? metric,
    SectorType? sector,
    MarketCapType? marketCap,
  })?
  onFiltersChanged;
  final bool isLoading;
  final String? error;
  final UniversalTemplateType templateType;

  @override
  Widget build(BuildContext context) => UniversalHeatmapWidget(
    investmentType: InvestmentType.etf,
    rawData: etfData,
    config: config,
    title: title,
    compactMode: compactMode,
    showSelectors: showSelectors,
    onTilePressed: onTilePressed,
    onFiltersChanged: onFiltersChanged,
    isLoading: isLoading,
    error: error,
    templateType: templateType,
  );
}
