import 'package:flutter/material.dart';

import '../../../core/app_logic/domain/entities/heatmap/heatmap_configuration_entity.dart'
    as config_entity;
import '../../../core/app_logic/domain/entities/heatmap/heatmap_entities.dart'
    as core_entities;
import '../../models/heatmap/heatmap_tile_data.dart';
import '../../models/heatmap/heatmap_ui_data.dart';
import '../selectors/selectors.dart';
import 'heatmap_config.dart' as ui_config;
import 'heatmap_display_template.dart';
import 'heatmap_layout_template.dart';
import 'heatmap_logger.dart';
import 'heatmap_selector_template.dart';

/// Universal heatmap widget template that orchestrates 3 separate components based on config
/// This is the main widget that should be used for displaying heatmaps across the app
/// Creates: DisplayTemplate + SelectorTemplate + LayoutTemplate based on configuration
class UniversalHeatmapWidget extends StatelessWidget {
  const UniversalHeatmapWidget({
    required this.investmentType,
    required this.rawData,
    super.key,
    this.config,
    this.onTilePressed,
    this.onFiltersChanged,
    this.showSelectors,
    this.title,
    this.compactMode,
    this.isLoading = false,
    this.error,
    this.templateType = UniversalTemplateType.adaptive,
  });

  /// Investment type (portfolio, index, mutual funds, ETF)
  final InvestmentType investmentType;

  /// Raw data to be converted to heatmap format
  final Map<String, dynamic> rawData;

  /// Optional configuration overrides
  final ui_config.HeatmapConfig? config;

  /// Callback when a tile is pressed
  final VoidCallback? onTilePressed;

  /// Callback when filters change
  final Function({
    TimeFrame? timeFrame,
    MetricType? metric,
    SectorType? sector,
    MarketCapType? marketCap,
  })?
  onFiltersChanged;

  /// Whether to show selectors (can override config)
  final bool? showSelectors;

  /// Custom title (can override config)
  final String? title;

  /// Whether to use compact mode (can override config)
  final bool? compactMode;

  /// Loading state
  final bool isLoading;

  /// Error message
  final String? error;

  /// Template composition type
  final UniversalTemplateType templateType;

  @override
  Widget build(BuildContext context) {
    // Initialize logger
    HeatmapLogger.initialize();

    // Log widget initialization
    HeatmapLogger.logInitialization(
      component: 'UniversalHeatmapWidget',
      investmentType: investmentType.toString(),
      config: {
        'hasConfig': config != null,
        'showSelectors': showSelectors,
        'title': title,
        'compactMode': compactMode,
        'isLoading': isLoading,
        'hasError': error != null,
        'templateType': templateType.name,
      },
    );

    // Get effective configuration based on investment type
    final effectiveConfig = _getEffectiveConfig();

    // Convert raw data to heatmap data
    final heatmapData = _convertRawDataToHeatmapData();

    // Create the 3 template components based on config
    return _buildUniversalTemplate(context, effectiveConfig, heatmapData);
  }

  /// Build the universal template by composing the 3 separate components
  Widget _buildUniversalTemplate(
    BuildContext context,
    ui_config.HeatmapConfig effectiveConfig,
    HeatmapData? heatmapData,
  ) {
    // 1. Create Display Template (handles tile rendering)
    final displayTemplate = HeatmapDisplayTemplate(
      data: heatmapData ?? _getEmptyData(),
      isLoading: isLoading,
      error: error,
      onTilePressed: onTilePressed,
      layout: _getDisplayLayout(effectiveConfig),
    );

    // 2. Create Selector Template (handles filter UI)
    Widget? selectorTemplate;
    if (_shouldShowSelectors(effectiveConfig)) {
      selectorTemplate = HeatmapSelectorTemplate(
        initialTimeFrame: _getInitialTimeFrame(),
        initialMetric: _getInitialMetric(),
        initialSector: _getInitialSector(),
        initialMarketCap: _getInitialMarketCap(),
        onFiltersChanged: onFiltersChanged,
        showTimeFrame: effectiveConfig.showTimeFrameSelector,
        showMetric: effectiveConfig.showMetricSelector,
        showSector: effectiveConfig.showSectorSelector,
        showMarketCap: effectiveConfig.showMarketCapSelector,
        layout: _getSelectorLayout(effectiveConfig),
        primaryColor: effectiveConfig.accentColor,
        title: 'Filters',
      );
    }

    // 3. Create Layout Template (handles overall structure)
    return _createLayoutTemplate(
      context,
      effectiveConfig,
      heatmapData ?? _getEmptyData(),
      displayTemplate,
      selectorTemplate,
    );
  }

  /// Create the appropriate layout template based on template type and config
  Widget _createLayoutTemplate(
    BuildContext context,
    ui_config.HeatmapConfig config,
    HeatmapData data,
    Widget displayWidget,
    Widget? selectorWidget,
  ) {
    switch (templateType) {
      case UniversalTemplateType.minimal:
        return HeatmapLayoutTemplate(
          data: data,
          displayWidget: displayWidget,
          title: title ?? _getDefaultTitle(),
          showLegend: false,
          showSelectors: false,
          icon: _getInvestmentIcon(),
        );

      case UniversalTemplateType.compact:
        return HeatmapLayoutTemplate(
          data: data,
          displayWidget: displayWidget,
          selectorWidget: selectorWidget,
          title: title ?? _getDefaultTitle(),
          showSelectors: selectorWidget != null,
          icon: _getInvestmentIcon(),
          padding: const EdgeInsets.all(12),
        );

      case UniversalTemplateType.full:
        return HeatmapLayoutTemplate(
          data: data,
          displayWidget: displayWidget,
          selectorWidget: selectorWidget,
          title: title ?? _getDefaultTitle(),
          subtitle: _getSubtitle(),
          showSelectors: selectorWidget != null,
          icon: _getInvestmentIcon(),
          headerActions: _getHeaderActions(context),
          padding: const EdgeInsets.all(16),
        );

      case UniversalTemplateType.dashboard:
        return HeatmapLayoutTemplate(
          data: data,
          displayWidget: displayWidget,
          selectorWidget: selectorWidget,
          title: title ?? _getDefaultTitle(),
          showLegend: false,
          showSelectors: selectorWidget != null,
          icon: _getInvestmentIcon(),
          padding: const EdgeInsets.all(8),
        );

      case UniversalTemplateType.adaptive:
        // Choose template based on screen size and config
        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return HeatmapLayoutTemplate(
                data: data,
                displayWidget: displayWidget,
                selectorWidget: selectorWidget,
                title: title ?? _getDefaultTitle(),
                showLegend: false,
                showSelectors: selectorWidget != null,
                icon: _getInvestmentIcon(),
                padding: const EdgeInsets.all(8),
              );
            } else if (constraints.maxWidth < 1024) {
              return HeatmapLayoutTemplate(
                data: data,
                displayWidget: displayWidget,
                selectorWidget: selectorWidget,
                title: title ?? _getDefaultTitle(),
                subtitle: _getSubtitle(),
                showSelectors: selectorWidget != null,
                icon: _getInvestmentIcon(),
                padding: const EdgeInsets.all(12),
              );
            } else {
              return HeatmapLayoutTemplate(
                data: data,
                displayWidget: displayWidget,
                selectorWidget: selectorWidget,
                title: title ?? _getDefaultTitle(),
                subtitle: _getSubtitle(),
                showSelectors: selectorWidget != null,
                icon: _getInvestmentIcon(),
                headerActions: _getHeaderActions(context),
                padding: const EdgeInsets.all(16),
              );
            }
          },
        );
    }
  }

  /// Get effective configuration based on investment type and overrides
  ui_config.HeatmapConfig _getEffectiveConfig() {
    ui_config.HeatmapConfig baseConfig;

    // Create base config based on investment type
    switch (investmentType) {
      case InvestmentType.portfolio:
        baseConfig = HeatmapConfig(
          customTitle: title ?? 'Portfolio Heatmap',
          compactView: compactMode ?? false,
          showTimeFrameSelector: true,
          showMetricSelector: true,
          showSectorSelector: true,
          showMarketCapSelector: false,
        );
        break;
      case InvestmentType.indexFund:
        baseConfig = HeatmapConfig(
          customTitle: title ?? 'Index Heatmap',
          compactView: compactMode ?? false,
          showTimeFrameSelector: true,
          showMetricSelector: true,
          showSectorSelector: false,
          showMarketCapSelector: false,
        );
        break;
      case InvestmentType.mutualFunds:
        baseConfig = HeatmapConfig(
          customTitle: title ?? 'Mutual Funds Heatmap',
          compactView: compactMode ?? false,
          showTimeFrameSelector: true,
          showMetricSelector: true,
          showSectorSelector: true,
          showMarketCapSelector: true,
        );
        break;
      case InvestmentType.etf:
        baseConfig = HeatmapConfig(
          customTitle: title ?? 'ETF Heatmap',
          compactView: compactMode ?? false,
          showTimeFrameSelector: true,
          showMetricSelector: true,
          showSectorSelector: true,
          showMarketCapSelector: false,
        );
        break;
    }

    // Apply user-provided config overrides if available
    if (config != null) {
      return _mergeConfigs(baseConfig, config);
    }

    // Apply simple overrides
    if (showSelectors != null || compactMode != null) {
      return baseConfig.copyWith(
        showTimeFrameSelector:
            showSelectors ?? baseConfig.showTimeFrameSelector,
        showMetricSelector: showSelectors ?? baseConfig.showMetricSelector,
        compactView: compactMode ?? baseConfig.compactView,
        customTitle: title ?? baseConfig.customTitle,
      );
    }

    return baseConfig;
  }

  /// Merge user config with base config
  HeatmapConfig _mergeConfigs(
    HeatmapConfig base,
    HeatmapConfig user,
  ) => ui_config.HeatmapConfig(
    showTimeFrameSelector: showSelectors ?? user.showTimeFrameSelector,
    showMetricSelector: showSelectors ?? user.showMetricSelector,
    showSectorSelector: user.showSectorSelector,
    showMarketCapSelector: user.showMarketCapSelector,
    availableTimeFrames: user.availableTimeFrames ?? base.availableTimeFrames,
    availableMetrics: user.availableMetrics ?? base.availableMetrics,
    availableSectors: user.availableSectors ?? base.availableSectors,
    availableMarketCaps: user.availableMarketCaps ?? base.availableMarketCaps,
    showSubCards: user.showSubCards,
    showPerformance: user.showPerformance,
    showWeightage: user.showWeightage,
    showValue: user.showValue,
    showLegend: user.showLegend,
    showHeader: user.showHeader,
    showRefreshButton: user.showRefreshButton,
    layoutType: user.layoutType,
    compactView: compactMode ?? user.compactView,
    showTitle: user.showTitle,
    customTitle: title ?? user.customTitle,
    enableTileInteraction: user.enableTileInteraction,
    enableSelectorInteraction: user.enableSelectorInteraction,
    showLoadingStates: user.showLoadingStates,
    showErrorStates: user.showErrorStates,
    selectorPadding: user.selectorPadding,
    cardPadding: user.cardPadding,
    selectorSpacing: user.selectorSpacing,
    accentColor: user.accentColor,
  );

  /// Convert raw data to heatmap data format
  HeatmapData? _convertRawDataToHeatmapData() {
    if (isLoading || error != null) {
      return null;
    }

    try {
      HeatmapLogger.logDataLoading(
        operation: 'convert_raw_data',
        dataSize: rawData.length,
        source: 'raw_data',
      );

      final tiles = _convertRawDataToTiles();

      final heatmapData = HeatmapData(
        id: 'universal-heatmap-${investmentType.name}',
        title: _getDefaultTitle(),
        subtitle: _getSubtitle(),
        tiles: tiles,
        metadata: HeatmapMetadata(
          lastUpdated: DateTime.now(),
          dataSource: 'universal_widget',
          additionalInfo: {
            'investmentType': investmentType.name,
            'tilesCount': tiles.length,
          },
        ),
        configuration: _getHeatmapConfiguration(),
      );

      HeatmapLogger.logDataLoadingSuccess(
        operation: 'convert_raw_data',
        processingInfo: 'Converted ${tiles.length} tiles successfully',
      );

      return heatmapData;
    } catch (error, stackTrace) {
      HeatmapLogger.logDataLoadingError(
        operation: 'convert_raw_data',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Convert raw data to heatmap tiles based on investment type
  List<HeatmapTileData> _convertRawDataToTiles() {
    final tiles = <HeatmapTileData>[];

    switch (investmentType) {
      case InvestmentType.portfolio:
        tiles.addAll(_convertPortfolioData());
        break;
      case InvestmentType.indexFund:
        tiles.addAll(_convertIndexData());
        break;
      case InvestmentType.mutualFunds:
        tiles.addAll(_convertMutualFundsData());
        break;
      case InvestmentType.etf:
        tiles.addAll(_convertETFData());
        break;
    }

    return tiles;
  }

  /// Convert portfolio specific data
  List<HeatmapTileData> _convertPortfolioData() {
    final tiles = <HeatmapTileData>[];

    if (rawData.containsKey('holdings')) {
      final holdings = rawData['holdings'] as List<dynamic>? ?? [];

      for (final holding in holdings) {
        if (holding is Map<String, dynamic>) {
          tiles.add(
            HeatmapTileData(
              id: holding['id']?.toString() ?? '',
              name: holding['name']?.toString() ?? 'Unknown',
              displayName:
                  holding['displayName']?.toString() ??
                  holding['name']?.toString() ??
                  'Unknown',
              performance: (holding['performance'] as num?)?.toDouble() ?? 0.0,
              weightage: (holding['weightage'] as num?)?.toDouble() ?? 0.0,
              value: (holding['value'] as num?)?.toDouble(),
            ),
          );
        }
      }
    }

    return tiles;
  }

  /// Convert index specific data
  List<HeatmapTileData> _convertIndexData() {
    final tiles = <HeatmapTileData>[];

    if (rawData.containsKey('components')) {
      final components = rawData['components'] as List<dynamic>? ?? [];

      for (final component in components) {
        if (component is Map<String, dynamic>) {
          tiles.add(
            HeatmapTileData(
              id: component['id']?.toString() ?? '',
              name: component['name']?.toString() ?? 'Unknown',
              displayName:
                  component['displayName']?.toString() ??
                  component['name']?.toString() ??
                  'Unknown',
              performance: (component['change'] as num?)?.toDouble() ?? 0.0,
              weightage: (component['weight'] as num?)?.toDouble() ?? 0.0,
              value: (component['marketValue'] as num?)?.toDouble(),
            ),
          );
        }
      }
    }

    return tiles;
  }

  /// Convert mutual funds specific data
  List<HeatmapTileData> _convertMutualFundsData() {
    final tiles = <HeatmapTileData>[];

    if (rawData.containsKey('funds')) {
      final funds = rawData['funds'] as List<dynamic>? ?? [];

      for (final fund in funds) {
        if (fund is Map<String, dynamic>) {
          tiles.add(
            HeatmapTileData(
              id: fund['id']?.toString() ?? '',
              name: fund['fundName']?.toString() ?? 'Unknown',
              displayName:
                  fund['displayName']?.toString() ??
                  fund['fundName']?.toString() ??
                  'Unknown',
              performance: (fund['returns'] as num?)?.toDouble() ?? 0.0,
              weightage: (fund['allocation'] as num?)?.toDouble() ?? 0.0,
              value: (fund['nav'] as num?)?.toDouble(),
            ),
          );
        }
      }
    }

    return tiles;
  }

  /// Convert ETF specific data
  List<HeatmapTileData> _convertETFData() {
    final tiles = <HeatmapTileData>[];

    if (rawData.containsKey('etfs')) {
      final etfs = rawData['etfs'] as List<dynamic>? ?? [];

      for (final etf in etfs) {
        if (etf is Map<String, dynamic>) {
          tiles.add(
            HeatmapTileData(
              id: etf['id']?.toString() ?? '',
              name: etf['name']?.toString() ?? 'Unknown',
              displayName:
                  etf['displayName']?.toString() ??
                  etf['name']?.toString() ??
                  'Unknown',
              performance: (etf['performance'] as num?)?.toDouble() ?? 0.0,
              weightage: (etf['weight'] as num?)?.toDouble() ?? 0.0,
              value: (etf['price'] as num?)?.toDouble(),
            ),
          );
        }
      }
    }

    return tiles;
  }

  /// Helper methods for template configuration
  bool _shouldShowSelectors(ui_config.HeatmapConfig config) =>
      showSelectors ??
      (config.showTimeFrameSelector ||
          config.showMetricSelector ||
          config.showSectorSelector ||
          config.showMarketCapSelector);

  ui_config.HeatmapLayoutType _getDisplayLayout(
    ui_config.HeatmapConfig config,
  ) => config.layoutType;

  SelectorLayoutType _getSelectorLayout(HeatmapConfig config) {
    if (config.compactView) {
      return SelectorLayoutType.compact;
    } else if (templateType == UniversalTemplateType.minimal) {
      return SelectorLayoutType.pills;
    } else {
      return SelectorLayoutType.expanded;
    }
  }

  IconData _getInvestmentIcon() {
    switch (investmentType) {
      case InvestmentType.portfolio:
        return Icons.pie_chart;
      case InvestmentType.indexFund:
        return Icons.trending_up;
      case InvestmentType.mutualFunds:
        return Icons.account_balance;
      case InvestmentType.etf:
        return Icons.show_chart;
    }
  }

  String _getDefaultTitle() {
    if (title != null) return title!;

    switch (investmentType) {
      case InvestmentType.portfolio:
        return 'Portfolio Heatmap';
      case InvestmentType.indexFund:
        return 'Index Heatmap';
      case InvestmentType.mutualFunds:
        return 'Mutual Funds Heatmap';
      case InvestmentType.etf:
        return 'ETF Heatmap';
    }
  }

  String? _getSubtitle() {
    switch (investmentType) {
      case InvestmentType.portfolio:
        return 'Your investment performance overview';
      case InvestmentType.indexFund:
        return 'Index components performance';
      case InvestmentType.mutualFunds:
        return 'Mutual funds performance comparison';
      case InvestmentType.etf:
        return 'ETF performance overview';
    }
  }

  HeatmapConfiguration _getHeatmapConfiguration() {
    final effectiveConfig = _getEffectiveConfig();

    // Map config layout type to entity layout type
    HeatmapLayoutType entityLayoutType;
    switch (effectiveConfig.layoutType.toString()) {
      case 'HeatmapLayoutType.treemap':
        entityLayoutType = HeatmapLayoutType.treemap;
        break;
      case 'HeatmapLayoutType.grid':
        entityLayoutType = HeatmapLayoutType.grid;
        break;
      case 'HeatmapLayoutType.list':
        entityLayoutType = HeatmapLayoutType.list;
        break;
      default:
        entityLayoutType = HeatmapLayoutType.treemap;
    }

    return HeatmapConfiguration(
      layout: entityLayoutType,
      colorScheme: HeatmapColorSchemeType.performance,
      defaultSorting: HeatmapSortingType.performance,
      showPerformance: effectiveConfig.showPerformance,
      showWeightage: effectiveConfig.showWeightage,
      showValue: effectiveConfig.showValue,
      enabledFilters: const [
        HeatmapFilterType.performance,
        HeatmapFilterType.weightage,
      ],
    );
  }

  HeatmapData _getEmptyData() => HeatmapData(
    id: 'empty-heatmap',
    title: _getDefaultTitle(),
    subtitle: 'No data available',
    tiles: [],
    metadata: HeatmapMetadata(
      lastUpdated: DateTime.now(),
      dataSource: 'universal_widget',
      additionalInfo: const {'status': 'empty'},
    ),
    configuration: _getHeatmapConfiguration(),
  );

  TimeFrame _getInitialTimeFrame() {
    switch (investmentType) {
      case InvestmentType.portfolio:
        return TimeFrame.oneMonth;
      case InvestmentType.indexFund:
        return TimeFrame.oneDay;
      case InvestmentType.mutualFunds:
        return TimeFrame.oneYear;
      case InvestmentType.etf:
        return TimeFrame.oneMonth;
    }
  }

  MetricType _getInitialMetric() {
    switch (investmentType) {
      case InvestmentType.portfolio:
      case InvestmentType.etf:
        return MetricType.changePercent;
      case InvestmentType.indexFund:
        return MetricType.changePercent;
      case InvestmentType.mutualFunds:
        return MetricType.returns;
    }
  }

  SectorType _getInitialSector() => SectorType.all;

  MarketCapType _getInitialMarketCap() => MarketCapType.all;

  List<Widget> _getHeaderActions(BuildContext context) => [
    IconButton(
      icon: const Icon(Icons.refresh),
      onPressed: () {
        // Refresh action - could trigger onFiltersChanged or custom callback
        HeatmapLogger.logTileInteraction(
          action: 'refresh_pressed',
          tileId: 'header_action',
          component: 'UniversalHeatmapWidget',
        );
      },
      tooltip: 'Refresh Data',
    ),
    IconButton(
      icon: const Icon(Icons.share),
      onPressed: () {
        // Share action
        HeatmapLogger.logTileInteraction(
          action: 'share_pressed',
          tileId: 'header_action',
          component: 'UniversalHeatmapWidget',
        );
      },
      tooltip: 'Share Heatmap',
    ),
  ];
}

/// Investment type enumeration
enum InvestmentType { portfolio, indexFund, mutualFunds, etf }

/// Universal template composition types
enum UniversalTemplateType {
  minimal, // DisplayTemplate only, minimal layout
  compact, // DisplayTemplate + compact selectors
  full, // All components with full features
  dashboard, // Optimized for dashboard widgets
  adaptive, // Adapts based on screen size and config
}

/// Convenience widgets for specific investment types with template composition

/// Portfolio-specific heatmap widget
class PortfolioHeatmapWidget extends StatelessWidget {
  const PortfolioHeatmapWidget({
    required this.portfolioData,
    super.key,
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
