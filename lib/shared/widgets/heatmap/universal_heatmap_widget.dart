import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/cubits/heatmap/heatmap_display_cubit.dart';
import '../../widgets/heatmap/configurable_heatmap_widget.dart';
import 'heatmap_logger.dart';

/// Universal heatmap widget that integrates with any investment type using cubit state management
/// This is the main widget that should be used for displaying heatmaps across the app
class UniversalHeatmapWidget extends StatelessWidget {
  const UniversalHeatmapWidget({
    required this.investmentType,
    required this.rawData,
    super.key,
    this.config,
    this.initialFilters,
    this.onTilePressed,
    this.onFiltersChanged,
    this.showSelectors,
    this.title,
    this.compactMode,
  });

  /// Investment type (portfolio, index, mutual funds, ETF)
  final InvestmentType investmentType;

  /// Raw data to be converted to heatmap format
  final Map<String, dynamic> rawData;

  /// Optional configuration overrides
  final HeatmapDisplayConfig? config;

  /// Optional initial filters
  final HeatmapFilters? initialFilters;

  /// Callback when a tile is pressed
  final Function(String tileId, Map<String, dynamic>? metadata)? onTilePressed;

  /// Callback when filters change
  final Function(HeatmapFilters filters)? onFiltersChanged;

  /// Whether to show selectors (can override config)
  final bool? showSelectors;

  /// Custom title (can override config)
  final String? title;

  /// Whether to use compact mode (can override config)
  final bool? compactMode;

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
        'hasInitialFilters': initialFilters != null,
        'showSelectors': showSelectors,
        'title': title,
        'compactMode': compactMode,
      },
    );

    return BlocProvider(
      create: (context) => HeatmapDisplayCubit(),
      child: _UniversalHeatmapContent(
        investmentType: investmentType,
        rawData: rawData,
        config: config,
        initialFilters: initialFilters,
        onTilePressed: onTilePressed,
        onFiltersChanged: onFiltersChanged,
        showSelectors: showSelectors,
        title: title,
        compactMode: compactMode,
      ),
    );
  }
}

class _UniversalHeatmapContent extends StatefulWidget {
  const _UniversalHeatmapContent({
    required this.investmentType,
    required this.rawData,
    this.config,
    this.initialFilters,
    this.onTilePressed,
    this.onFiltersChanged,
    this.showSelectors,
    this.title,
    this.compactMode,
  });
  final InvestmentType investmentType;
  final Map<String, dynamic> rawData;
  final HeatmapDisplayConfig? config;
  final HeatmapFilters? initialFilters;
  final Function(String tileId, Map<String, dynamic>? metadata)? onTilePressed;
  final Function(HeatmapFilters filters)? onFiltersChanged;
  final bool? showSelectors;
  final String? title;
  final bool? compactMode;

  @override
  State<_UniversalHeatmapContent> createState() =>
      _UniversalHeatmapContentState();
}

class _UniversalHeatmapContentState extends State<_UniversalHeatmapContent> {
  @override
  void initState() {
    super.initState();
    _initializeHeatmap();
  }

  void _initializeHeatmap() {
    final cubit = context.read<HeatmapDisplayCubit>();
    final effectiveConfig = _getEffectiveConfig();

    HeatmapLogger.logDataLoading(
      operation: 'initialize_heatmap',
      dataSize: widget.rawData.length,
      source: 'raw_data',
    );

    try {
      cubit.initialize(
        config: effectiveConfig,
        rawData: widget.rawData,
        initialFilters: widget.initialFilters,
      );

      HeatmapLogger.logDataLoadingSuccess(
        operation: 'initialize_heatmap',
        processingInfo: 'Config applied successfully',
      );
    } catch (error, stackTrace) {
      HeatmapLogger.logDataLoadingError(
        operation: 'initialize_heatmap',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  HeatmapDisplayConfig _getEffectiveConfig() {
    HeatmapDisplayConfig baseConfig;

    // Create base config based on investment type
    switch (widget.investmentType) {
      case InvestmentType.portfolio:
        baseConfig = HeatmapDisplayConfig.portfolio(
          title: widget.title,
          compactMode: widget.compactMode ?? false,
        );
        break;
      case InvestmentType.indexFund:
        baseConfig = HeatmapDisplayConfig.index(
          title: widget.title,
          compactMode: widget.compactMode ?? false,
        );
        break;
      case InvestmentType.mutualFunds:
        baseConfig = HeatmapDisplayConfig.mutualFunds(
          title: widget.title,
          compactMode: widget.compactMode ?? false,
        );
        break;
      case InvestmentType.etf:
        baseConfig = HeatmapDisplayConfig.etf(
          title: widget.title,
          compactMode: widget.compactMode ?? false,
        );
        break;
    }

    // Apply overrides from widget parameters
    if (widget.config != null) {
      baseConfig = baseConfig.copyWith(
        showSelectors: widget.showSelectors ?? widget.config!.showSelectors,
        title: widget.title ?? widget.config!.title,
        compactMode: widget.compactMode ?? widget.config!.compactMode,
      );
    } else if (widget.showSelectors != null) {
      baseConfig = baseConfig.copyWith(showSelectors: widget.showSelectors);
    }

    return baseConfig;
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<HeatmapDisplayCubit, HeatmapDisplayState>(
        listener: (context, state) {
          // Log state changes
          HeatmapLogger.logStateChange(
            component: 'UniversalHeatmapWidget',
            fromState: 'previous_state',
            toState: state.runtimeType.toString(),
          );

          if (state is HeatmapDisplayLoaded) {
            widget.onFiltersChanged?.call(state.filters);
          } else if (state is HeatmapDisplayError) {
            HeatmapLogger.logError(
              message: 'Heatmap display error',
              error: state.message,
              component: 'UniversalHeatmapWidget',
            );
          }
        },
        builder: (context, state) {
          if (state is HeatmapDisplayInitial) {
            return const Center(child: Text('Initializing heatmap...'));
          }

          if (state is HeatmapDisplayLoading) {
            return _buildLoadingState();
          }

          if (state is HeatmapDisplayError) {
            return _buildErrorState(state);
          }

          if (state is HeatmapDisplayLoaded) {
            return _buildLoadedState(state);
          }

          return const Center(child: Text('Unknown state'));
        },
      );

  Widget _buildLoadingState() {
    final config = _getEffectiveConfig();

    if (config.compactMode) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading heatmap...'),
          ],
        ),
      );
    }

    return ConfigurableHeatmapWidget(
      isLoading: true,
      title: config.title,
      showSelectors: config.showSelectors,
      compact: config.compactMode,
    );
  }

  Widget _buildErrorState(HeatmapDisplayError state) {
    final config = _getEffectiveConfig();

    return ConfigurableHeatmapWidget(
      error: state.message,
      title: config.title,
      showSelectors: config.showSelectors,
      compact: config.compactMode,
    );
  }

  Widget _buildLoadedState(HeatmapDisplayLoaded state) =>
      ConfigurableHeatmapWidget(
        data: state.data,
        title: state.config.title,
        showSelectors: state.config.showSelectors,
        compact: state.config.compactMode,
        initialTimeFrame: state.filters.timeFrame,
        initialMetric: state.filters.metric,
        initialSector: state.filters.sector,
        initialMarketCap: state.filters.marketCap,
        onTilePressed: () {
          // Log tile interaction
          HeatmapLogger.logTileInteraction(
            action: 'tile_pressed',
            tileId: 'tile-id',
            component: 'UniversalHeatmapWidget',
          );

          // Handle tile press - you could pass tile-specific data here
          widget.onTilePressed?.call('tile-id', null);
        },
        onSelectorsChanged: ({timeFrame, metric, sector, marketCap}) {
          final cubit = context.read<HeatmapDisplayCubit>();

          if (timeFrame != null && timeFrame != state.filters.timeFrame) {
            HeatmapLogger.logFilterChange(
              filterType: 'timeFrame',
              oldValue: state.filters.timeFrame,
              newValue: timeFrame,
              component: 'UniversalHeatmapWidget',
            );
            cubit.updateTimeFrame(timeFrame);
          }
          if (metric != null && metric != state.filters.metric) {
            HeatmapLogger.logFilterChange(
              filterType: 'metric',
              oldValue: state.filters.metric,
              newValue: metric,
              component: 'UniversalHeatmapWidget',
            );
            cubit.updateMetric(metric);
          }
          if (sector != null && sector != state.filters.sector) {
            HeatmapLogger.logFilterChange(
              filterType: 'sector',
              oldValue: state.filters.sector,
              newValue: sector,
              component: 'UniversalHeatmapWidget',
            );
            cubit.updateSector(sector);
          }
          if (marketCap != null && marketCap != state.filters.marketCap) {
            HeatmapLogger.logFilterChange(
              filterType: 'marketCap',
              oldValue: state.filters.marketCap,
              newValue: marketCap,
              component: 'UniversalHeatmapWidget',
            );
            cubit.updateMarketCap(marketCap);
          }
        },
      );
}

/// Convenience widgets for specific investment types

/// Portfolio-specific heatmap widget
class PortfolioHeatmapWidget extends StatelessWidget {
  const PortfolioHeatmapWidget({
    required this.portfolioData,
    super.key,
    this.title = 'Portfolio Heatmap',
    this.compactMode = false,
    this.onTilePressed,
    this.onFiltersChanged,
  });
  final Map<String, dynamic> portfolioData;
  final String? title;
  final bool compactMode;
  final Function(String tileId, Map<String, dynamic>? metadata)? onTilePressed;
  final Function(HeatmapFilters filters)? onFiltersChanged;

  @override
  Widget build(BuildContext context) => UniversalHeatmapWidget(
    investmentType: InvestmentType.portfolio,
    rawData: portfolioData,
    title: title,
    compactMode: compactMode,
    onTilePressed: onTilePressed,
    onFiltersChanged: onFiltersChanged,
  );
}

/// Index-specific heatmap widget
class IndexHeatmapWidget extends StatelessWidget {
  const IndexHeatmapWidget({
    required this.indexData,
    super.key,
    this.title = 'Index Heatmap',
    this.compactMode = false,
    this.onTilePressed,
    this.onFiltersChanged,
  });
  final Map<String, dynamic> indexData;
  final String? title;
  final bool compactMode;
  final Function(String tileId, Map<String, dynamic>? metadata)? onTilePressed;
  final Function(HeatmapFilters filters)? onFiltersChanged;

  @override
  Widget build(BuildContext context) => UniversalHeatmapWidget(
    investmentType: InvestmentType.indexFund,
    rawData: indexData,
    title: title,
    compactMode: compactMode,
    onTilePressed: onTilePressed,
    onFiltersChanged: onFiltersChanged,
  );
}

/// Mutual funds-specific heatmap widget
class MutualFundsHeatmapWidget extends StatelessWidget {
  const MutualFundsHeatmapWidget({
    required this.fundsData,
    super.key,
    this.title = 'Mutual Funds Heatmap',
    this.compactMode = false,
    this.onTilePressed,
    this.onFiltersChanged,
  });
  final Map<String, dynamic> fundsData;
  final String? title;
  final bool compactMode;
  final Function(String tileId, Map<String, dynamic>? metadata)? onTilePressed;
  final Function(HeatmapFilters filters)? onFiltersChanged;

  @override
  Widget build(BuildContext context) => UniversalHeatmapWidget(
    investmentType: InvestmentType.mutualFunds,
    rawData: fundsData,
    title: title,
    compactMode: compactMode,
    onTilePressed: onTilePressed,
    onFiltersChanged: onFiltersChanged,
  );
}

/// ETF-specific heatmap widget
class ETFHeatmapWidget extends StatelessWidget {
  const ETFHeatmapWidget({
    required this.etfData,
    super.key,
    this.title = 'ETF Heatmap',
    this.compactMode = false,
    this.onTilePressed,
    this.onFiltersChanged,
  });
  final Map<String, dynamic> etfData;
  final String? title;
  final bool compactMode;
  final Function(String tileId, Map<String, dynamic>? metadata)? onTilePressed;
  final Function(HeatmapFilters filters)? onFiltersChanged;

  @override
  Widget build(BuildContext context) => UniversalHeatmapWidget(
    investmentType: InvestmentType.etf,
    rawData: etfData,
    title: title,
    compactMode: compactMode,
    onTilePressed: onTilePressed,
    onFiltersChanged: onFiltersChanged,
  );
}
