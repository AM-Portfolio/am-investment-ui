import 'package:flutter/material.dart';

import '../../../core/app_logic/domain/entities/heatmap/heatmap_entities.dart'
    as core_entities;
import '../../../core/utils/logger.dart';
import '../../models/heatmap/heatmap_tile_data.dart';
import '../../models/heatmap/heatmap_ui_data.dart';
import '../selectors/selectors.dart';
import 'configs/selector_config.dart';
import 'heatmap_config.dart' as ui_config;
import 'heatmap_display_template.dart';
import 'heatmap_layout_template.dart';
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
    final buildStartTime = DateTime.now();

    // Log widget initialization
    AppLogger.info(
      'UniversalHeatmapWidget build started for ${investmentType.toString()}',
      tag: 'UniversalHeatmapWidget',
    );

    AppLogger.debug(
      'Widget config: hasConfig=${config != null}, showSelectors=$showSelectors, '
      'title=$title, compactMode=$compactMode, isLoading=$isLoading, '
      'hasError=${error != null}, templateType=${templateType.name}',
      tag: 'UniversalHeatmapWidget',
    );

    // Get effective configuration based on investment type
    final effectiveConfig = _getEffectiveConfig();

    // Convert raw data to heatmap data
    final heatmapData = _convertRawDataToHeatmapData();

    // Create the 3 template components based on config
    final widget = _buildUniversalTemplate(
      context,
      effectiveConfig,
      heatmapData,
    );

    // Log build completion with performance metrics
    final buildDuration = DateTime.now().difference(buildStartTime);
    AppLogger.info(
      'UniversalHeatmapWidget build completed in ${buildDuration.inMilliseconds}ms - '
      'Investment: ${investmentType.name}, Template: ${templateType.name}, '
      'Tiles: ${heatmapData?.tiles.length ?? 0}, Config: ${effectiveConfig.layoutType}',
      tag: 'UniversalHeatmapWidget.Performance',
    );

    return widget;
  }

  /// Build the universal template by composing the 3 separate components
  Widget _buildUniversalTemplate(
    BuildContext context,
    ui_config.HeatmapConfig effectiveConfig,
    HeatmapData? heatmapData,
  ) {
    AppLogger.debug(
      'Building universal template: layout=${effectiveConfig.layoutType}, '
      'tiles=${heatmapData?.tiles.length ?? 0}, isLoading=$isLoading',
      tag: 'UniversalHeatmapWidget.Template',
    );

    // 1. Create Display Template (handles tile rendering)
    final displayTemplate = HeatmapDisplayTemplate(
      data: heatmapData ?? _getEmptyData(),
      isLoading: isLoading,
      error: error,
      onTilePressed: onTilePressed,
      layout: _getDisplayLayout(effectiveConfig),
    );

    AppLogger.debug(
      'Display template created with layout=${_getDisplayLayout(effectiveConfig)}',
      tag: 'UniversalHeatmapWidget.Template',
    );

    // 2. Create Selector Template (handles filter UI)
    Widget? selectorTemplate;
    if (_shouldShowSelectors(effectiveConfig)) {
      AppLogger.debug(
        'Creating selector template with filters: timeFrame=${effectiveConfig.showTimeFrameSelector}, '
        'metric=${effectiveConfig.showMetricSelector}, sector=${effectiveConfig.showSectorSelector}, '
        'marketCap=${effectiveConfig.showMarketCapSelector}',
        tag: 'UniversalHeatmapWidget.Template',
      );

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
        layout:
            effectiveConfig.selectors?.selectorLayout ??
            SelectorLayoutType.compact,
        primaryColor: effectiveConfig.accentColor,
        title: 'Filters',
      );
    } else {
      AppLogger.debug(
        'Skipping selector template creation - no selectors enabled',
        tag: 'UniversalHeatmapWidget.Template',
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
    AppLogger.methodEntry(
      '_createLayoutTemplate',
      tag: 'UniversalHeatmapWidget.Layout',
      params: {
        'templateType': templateType.name,
        'hasSelectors': selectorWidget != null,
        'tilesCount': data.tiles.length,
      },
    );

    Widget result;
    switch (templateType) {
      case UniversalTemplateType.minimal:
        AppLogger.debug(
          'Creating minimal layout template',
          tag: 'UniversalHeatmapWidget.Layout',
        );
        result = HeatmapLayoutTemplate(
          data: data,
          displayWidget: displayWidget,
          title: title ?? _getDefaultTitle(),
          showLegend: false,
          showSelectors: false,
          icon: _getInvestmentIcon(),
        );
        break;

      case UniversalTemplateType.compact:
        AppLogger.debug(
          'Creating compact layout template with selectors=${selectorWidget != null}',
          tag: 'UniversalHeatmapWidget.Layout',
        );
        result = HeatmapLayoutTemplate(
          data: data,
          displayWidget: displayWidget,
          selectorWidget: selectorWidget,
          title: title ?? _getDefaultTitle(),
          showSelectors: selectorWidget != null,
          icon: _getInvestmentIcon(),
          padding: const EdgeInsets.all(12),
        );
        break;

      case UniversalTemplateType.full:
        AppLogger.debug(
          'Creating full layout template with all features enabled',
          tag: 'UniversalHeatmapWidget.Layout',
        );
        result = HeatmapLayoutTemplate(
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
        break;

      case UniversalTemplateType.dashboard:
        AppLogger.debug(
          'Creating dashboard layout template optimized for widget display',
          tag: 'UniversalHeatmapWidget.Layout',
        );
        result = HeatmapLayoutTemplate(
          data: data,
          displayWidget: displayWidget,
          selectorWidget: selectorWidget,
          title: title ?? _getDefaultTitle(),
          showLegend: false,
          showSelectors: selectorWidget != null,
          icon: _getInvestmentIcon(),
          padding: const EdgeInsets.all(8),
        );
        break;

      case UniversalTemplateType.adaptive:
        // Choose template based on screen size and config
        AppLogger.debug(
          'Creating adaptive layout template based on screen constraints',
          tag: 'UniversalHeatmapWidget.Layout',
        );
        result = LayoutBuilder(
          builder: (context, constraints) {
            AppLogger.debug(
              'Adaptive layout constraints: width=${constraints.maxWidth}',
              tag: 'UniversalHeatmapWidget.Layout',
            );

            if (constraints.maxWidth < 600) {
              AppLogger.debug(
                'Using mobile layout (width < 600px)',
                tag: 'UniversalHeatmapWidget.Layout',
              );
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
              AppLogger.debug(
                'Using tablet layout (600px <= width < 1024px)',
                tag: 'UniversalHeatmapWidget.Layout',
              );
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
              AppLogger.debug(
                'Using desktop layout (width >= 1024px)',
                tag: 'UniversalHeatmapWidget.Layout',
              );
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
        break;
    }

    AppLogger.methodExit(
      '_createLayoutTemplate',
      tag: 'UniversalHeatmapWidget.Layout',
      result: 'Layout template created for ${templateType.name}',
    );

    return result;
  }

  /// Get effective configuration based on investment type and overrides
  ui_config.HeatmapConfig _getEffectiveConfig() {
    AppLogger.debug(
      'Determining effective config for ${investmentType.name}',
      tag: 'UniversalHeatmapWidget.Config',
    );

    ui_config.HeatmapConfig baseConfig;

    // Create base config based on investment type using new defaults system
    switch (investmentType) {
      case InvestmentType.portfolio:
        baseConfig = ui_config.HeatmapConfig.portfolio(
          title: title ?? 'Portfolio Heatmap',
        );
        break;
      case InvestmentType.indexFund:
        baseConfig = ui_config.HeatmapConfig.analytics(
          title: title ?? 'Index Heatmap',
        );
        break;
      case InvestmentType.mutualFunds:
        baseConfig = ui_config.HeatmapConfig.analytics(
          title: title ?? 'Mutual Funds Heatmap',
        );
        break;
      case InvestmentType.etf:
        baseConfig = ui_config.HeatmapConfig.trading(
          title: title ?? 'ETF Heatmap',
        );
        break;
    }

    AppLogger.debug(
      'Base config selected: layout=${baseConfig.layoutType}, '
      'selectors enabled, compact=${baseConfig.compactView}',
      tag: 'UniversalHeatmapWidget.Config',
    );

    // Apply user-provided config overrides if available
    if (config != null) {
      AppLogger.debug(
        'Merging user-provided config overrides',
        tag: 'UniversalHeatmapWidget.Config',
      );
      final result = _mergeConfigs(baseConfig, config!);
      AppLogger.info(
        'Final config: layout=${result.layoutType}, compact=${result.compactView}',
        tag: 'UniversalHeatmapWidget.Config',
      );
      return result;
    }

    // Apply simple overrides using modifier methods
    if (showSelectors != null || compactMode != null) {
      AppLogger.debug(
        'Applying simple overrides: showSelectors=$showSelectors, compactMode=$compactMode',
        tag: 'UniversalHeatmapWidget.Config',
      );

      var modifiedConfig = baseConfig;

      if (compactMode != null) {
        modifiedConfig = modifiedConfig.withLayout(compact: compactMode);
      }

      if (showSelectors != null) {
        modifiedConfig = modifiedConfig.withSelectors(
          timeFrame: showSelectors!,
          metric: showSelectors!,
          sector: showSelectors!,
          marketCap: showSelectors!,
        );
      }

      if (title != null) {
        modifiedConfig = modifiedConfig.withLayout(title: title);
      }

      AppLogger.info(
        'Modified config: layout=${modifiedConfig.layoutType}, compact=${modifiedConfig.compactView}',
        tag: 'UniversalHeatmapWidget.Config',
      );
      return modifiedConfig;
    }

    AppLogger.info(
      'Using base config: layout=${baseConfig.layoutType}, compact=${baseConfig.compactView}',
      tag: 'UniversalHeatmapWidget.Config',
    );
    return baseConfig;
  }

  /// Merge user config with base config using new copyWith approach
  ui_config.HeatmapConfig _mergeConfigs(
    ui_config.HeatmapConfig base,
    ui_config.HeatmapConfig user,
  ) {
    // Use the base config and selectively override with user config parts
    return ui_config.HeatmapConfig(
      selectors: user.selectors ?? base.selectors,
      display: user.display ?? base.display,
      layout: user.layout ?? base.layout,
      interactions: user.interactions ?? base.interactions,
      visual: user.visual ?? base.visual,
    );
  }

  /// Convert raw data to heatmap data format
  HeatmapData? _convertRawDataToHeatmapData() {
    if (isLoading || error != null) {
      return null;
    }

    try {
      AppLogger.info(
        'Converting raw data to heatmap format: ${rawData.length} items',
        tag: 'UniversalHeatmapWidget.DataConversion',
      );

      final tiles = _convertRawDataToTiles();

      final heatmapData = HeatmapData(
        id: 'universal-heatmap-${investmentType.name}',
        title: _getDefaultTitle(),
        subtitle: _getSubtitle(),
        tiles: tiles,
        metadata: core_entities.HeatmapMetadata(
          lastUpdated: DateTime.now(),
          dataSource: 'universal_widget',
          additionalInfo: {
            'investmentType': investmentType.name,
            'tilesCount': tiles.length,
          },
        ),
        configuration: _getHeatmapConfiguration(),
      );

      AppLogger.info(
        'Successfully converted ${tiles.length} tiles for ${investmentType.name} heatmap',
        tag: 'UniversalHeatmapWidget.DataConversion',
      );

      return heatmapData;
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to convert raw data to heatmap format',
        tag: 'UniversalHeatmapWidget.DataConversion',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Convert raw data to heatmap tiles based on investment type
  List<HeatmapTileData> _convertRawDataToTiles() {
    AppLogger.debug(
      'Converting raw data to tiles for ${investmentType.name}',
      tag: 'UniversalHeatmapWidget.DataConversion',
    );

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

    AppLogger.debug(
      'Converted ${tiles.length} tiles for ${investmentType.name}',
      tag: 'UniversalHeatmapWidget.DataConversion',
    );
    return tiles;
  }

  /// Convert portfolio specific data
  List<HeatmapTileData> _convertPortfolioData() {
    AppLogger.debug(
      'Converting portfolio data from ${rawData.containsKey('holdings') ? (rawData['holdings'] as List).length : 0} holdings',
      tag: 'UniversalHeatmapWidget.PortfolioData',
    );

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

    AppLogger.debug(
      'Successfully converted ${tiles.length} portfolio holdings to tiles',
      tag: 'UniversalHeatmapWidget.PortfolioData',
    );
    return tiles;
  }

  /// Convert index specific data
  List<HeatmapTileData> _convertIndexData() {
    AppLogger.debug(
      'Converting index data from ${rawData.containsKey('components') ? (rawData['components'] as List).length : 0} components',
      tag: 'UniversalHeatmapWidget.IndexData',
    );

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

    AppLogger.debug(
      'Successfully converted ${tiles.length} index components to tiles',
      tag: 'UniversalHeatmapWidget.IndexData',
    );
    return tiles;
  }

  /// Convert mutual funds specific data
  List<HeatmapTileData> _convertMutualFundsData() {
    AppLogger.debug(
      'Converting mutual funds data from ${rawData.containsKey('funds') ? (rawData['funds'] as List).length : 0} funds',
      tag: 'UniversalHeatmapWidget.MutualFundsData',
    );

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

    AppLogger.debug(
      'Successfully converted ${tiles.length} mutual funds to tiles',
      tag: 'UniversalHeatmapWidget.MutualFundsData',
    );
    return tiles;
  }

  /// Convert ETF specific data
  List<HeatmapTileData> _convertETFData() {
    AppLogger.debug(
      'Converting ETF data from ${rawData.containsKey('etfs') ? (rawData['etfs'] as List).length : 0} ETFs',
      tag: 'UniversalHeatmapWidget.ETFData',
    );

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

    AppLogger.debug(
      'Successfully converted ${tiles.length} ETFs to tiles',
      tag: 'UniversalHeatmapWidget.ETFData',
    );
    return tiles;
  }

  /// Helper methods for template configuration
  bool _shouldShowSelectors(ui_config.HeatmapConfig config) =>
      showSelectors ??
      (config.showTimeFrameSelector ||
          config.showMetricSelector ||
          config.showSectorSelector ||
          config.showMarketCapSelector);

  /// Get display layout type - convert UI config layout to display template layout
  HeatmapLayoutType _getDisplayLayout(ui_config.HeatmapConfig config) {
    // Convert UI config layout type to display template layout type
    switch (config.layoutType) {
      case ui_config.HeatmapLayoutType.treemap:
        return HeatmapLayoutType.treemap;
      case ui_config.HeatmapLayoutType.grid:
        return HeatmapLayoutType.grid;
      case ui_config.HeatmapLayoutType.list:
        return HeatmapLayoutType.list;
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

  ui_config.HeatmapConfig _getHeatmapConfiguration() {
    // Just return the effective config since we're now using HeatmapConfig directly
    return _getEffectiveConfig();
  }

  HeatmapData _getEmptyData() => HeatmapData(
    id: 'empty-heatmap',
    title: _getDefaultTitle(),
    subtitle: 'No data available',
    tiles: [],
    metadata: core_entities.HeatmapMetadata(
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
        AppLogger.userAction(
          'Refresh button pressed in heatmap header',
          tag: 'UniversalHeatmapWidget.Interaction',
          context: {'action': 'refresh_pressed', 'component': 'header'},
        );
      },
      tooltip: 'Refresh Data',
    ),
    IconButton(
      icon: const Icon(Icons.share),
      onPressed: () {
        // Share action
        AppLogger.userAction(
          'Share button pressed in heatmap header',
          tag: 'UniversalHeatmapWidget.Interaction',
          context: {'action': 'share_pressed', 'component': 'header'},
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
