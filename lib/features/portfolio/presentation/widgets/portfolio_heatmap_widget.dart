import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/logger.dart';
import '../../../../shared/widgets/heatmap/heatmap_display_template.dart';
import '../../../../shared/widgets/heatmap/helpers/heatmap_refresh_connector.dart';
import '../../../../shared/widgets/heatmap/universal_heatmap.dart';
import '../../../../shared/widgets/selectors/selectors.dart';
import '../adapters/portfolio_heatmap_adapters.dart';
import '../cubit/portfolio_analytics_cubit.dart';
import '../cubit/portfolio_analytics_state.dart';
import '../cubit/portfolio_heatmap_cubit.dart';
import '../cubit/portfolio_heatmap_state.dart';
import '../mappers/sector_heatmap_converter.dart';

/// Configuration class for platform-specific heatmap settings
class PortfolioHeatmapConfig {
  const PortfolioHeatmapConfig({
    required this.defaultLayout,
    required this.compactMode,
    required this.showSelectors,
    required this.templateType,
    required this.showSubCards,
    required this.padding,
    required this.title,
    required this.subtitle,
    this.logTag = 'PortfolioHeatmap',
  });

  final HeatmapLayoutType defaultLayout;
  final bool compactMode;
  final bool showSelectors;
  final UniversalTemplateType templateType;
  final bool showSubCards;
  final EdgeInsets padding;
  final String title;
  final String subtitle;
  final String logTag;

  /// Mobile configuration
  static const mobile = PortfolioHeatmapConfig(
    defaultLayout: HeatmapLayoutType.list,
    compactMode: true,
    showSelectors: false,
    templateType: UniversalTemplateType.compact,
    showSubCards: false,
    padding: EdgeInsets.all(12.0),
    title: 'Mobile: Portfolio Heatmap',
    subtitle: 'Performance by sector',
    logTag: 'PortfolioHeatmap.Mobile',
  );

  /// Web configuration
  static const web = PortfolioHeatmapConfig(
    defaultLayout: HeatmapLayoutType.grid,
    compactMode: false,
    showSelectors: true,
    templateType: UniversalTemplateType.full,
    showSubCards: true,
    padding: EdgeInsets.all(16.0),
    title: 'Web: Portfolio Heatmap',
    subtitle: 'Performance by sector',
    logTag: 'PortfolioHeatmap.Web',
  );
}

/// Common Portfolio Heatmap Widget
/// Shared implementation between web and mobile with configurable behavior
class PortfolioHeatmapWidget extends ConsumerStatefulWidget {
  const PortfolioHeatmapWidget({
    required this.userId,
    required this.portfolioId,
    required this.config,
    super.key,
    this.portfolioName,
  });

  final String userId;
  final String portfolioId;
  final String? portfolioName;
  final PortfolioHeatmapConfig config;

  @override
  ConsumerState<PortfolioHeatmapWidget> createState() =>
      _PortfolioHeatmapWidgetState();
}

class _PortfolioHeatmapWidgetState
    extends ConsumerState<PortfolioHeatmapWidget> {
  // Current selections with config-based defaults
  late MetricType _selectedMetric;
  late TimeFrame _selectedTimeframe;
  SectorType? _selectedSector;
  MarketCapType? _selectedMarketCap;
  late HeatmapLayoutType _selectedLayout;

  // Contract adapters for the new architecture
  PortfolioHeatmapDataAdapter? _dataAdapter;
  PortfolioHeatmapRefreshAdapter? _refreshAdapter;

  @override
  void initState() {
    super.initState();

    AppLogger.info(
      '🚀 PortfolioHeatmapWidget initState started',
      tag: '${widget.config.logTag}.Init',
    );

    // Initialize with config defaults
    _selectedMetric = MetricType.changePercent;
    _selectedTimeframe = TimeFrame.oneYear;
    _selectedLayout = widget.config.defaultLayout;

    AppLogger.info(
      'PortfolioHeatmapWidget initialized with config: ${widget.config.logTag}',
      tag: '${widget.config.logTag}.Init',
    );
    AppLogger.debug(
      'Parameters: userId=${widget.userId}, portfolioId=${widget.portfolioId}, portfolioName=${widget.portfolioName ?? 'null'}',
      tag: '${widget.config.logTag}.Init',
    );
    AppLogger.debug(
      'Initial selections: metric=${_selectedMetric.name}, timeframe=${_selectedTimeframe.name}, layout=${_selectedLayout.name}',
      tag: '${widget.config.logTag}.Init',
    );

    AppLogger.info(
      '📊 About to call _loadHeatmapData()',
      tag: '${widget.config.logTag}.Init',
    );
    _loadHeatmapData();

    AppLogger.info(
      '✅ PortfolioHeatmapWidget initState completed',
      tag: '${widget.config.logTag}.Init',
    );
  }

  @override
  void dispose() {
    // Clean up adapters
    _dataAdapter?.dispose();
    _refreshAdapter?.dispose();
    super.dispose();
  }

  void _loadHeatmapData() {
    AppLogger.methodEntry(
      '_loadHeatmapData',
      tag: '${widget.config.logTag}.Data',
      params: {
        'portfolioId': widget.portfolioId,
        'timeFrame': _selectedTimeframe.name,
        'metric': _selectedMetric.name,
        'sector': _selectedSector?.name ?? 'all',
        'marketCap': _selectedMarketCap?.name ?? 'all',
      },
    );

    final portfolioAnalyticsCubit = context.read<PortfolioAnalyticsCubit>();
    final portfolioHeatmapCubit = context.read<PortfolioHeatmapCubit>();

    // Load analytics data first
    AppLogger.info(
      'Starting analytics loading for portfolio: ${widget.portfolioId}',
      tag: '${widget.config.logTag}.Data',
    );

    portfolioAnalyticsCubit
        .loadAnalytics(widget.portfolioId)
        .then((_) {
          AppLogger.info(
            'Analytics loaded successfully, checking analytics state',
            tag: '${widget.config.logTag}.Data',
          );

          final analyticsState = portfolioAnalyticsCubit.state;
          AppLogger.debug(
            'Analytics state: ${analyticsState.runtimeType}',
            tag: '${widget.config.logTag}.Data',
          );

          if (analyticsState is PortfolioAnalyticsLoaded) {
            AppLogger.info(
              'Analytics data confirmed loaded, proceeding with heatmap data loading',
              tag: '${widget.config.logTag}.Data',
            );
          } else {
            AppLogger.warning(
              'Analytics not in loaded state: ${analyticsState.runtimeType}',
              tag: '${widget.config.logTag}.Data',
            );
          }

          AppLogger.info(
            'Calling portfolioHeatmapCubit.loadHeatmapData with params: '
            'portfolioId=${widget.portfolioId}, timeFrame=${_selectedTimeframe.name}, '
            'metric=${_selectedMetric.name}, sector=${_selectedSector?.name ?? 'all'}, '
            'marketCap=${_selectedMarketCap?.name ?? 'all'}',
            tag: '${widget.config.logTag}.Data',
          );

          portfolioHeatmapCubit.loadHeatmapData(
            portfolioId: widget.portfolioId,
            timeFrame: _selectedTimeframe,
            metric: _selectedMetric,
            sector: _selectedSector ?? SectorType.all,
            marketCap: _selectedMarketCap ?? MarketCapType.all,
            analyticsCubit: portfolioAnalyticsCubit,
          );

          AppLogger.debug(
            'portfolioHeatmapCubit.loadHeatmapData call completed',
            tag: '${widget.config.logTag}.Data',
          );
        })
        .catchError((error) {
          AppLogger.error(
            'Analytics failed, using fallback',
            tag: '${widget.config.logTag}.Data',
            error: error,
          );

          portfolioHeatmapCubit.loadHeatmapData(
            portfolioId: widget.portfolioId,
            timeFrame: _selectedTimeframe,
            metric: _selectedMetric,
            sector: _selectedSector ?? SectorType.all,
            marketCap: _selectedMarketCap ?? MarketCapType.all,
            analyticsCubit: portfolioAnalyticsCubit,
          );
        });

    AppLogger.methodExit(
      '_loadHeatmapData',
      tag: '${widget.config.logTag}.Data',
    );
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.debug(
      '🏗️ PortfolioHeatmapWidget build() called',
      tag: '${widget.config.logTag}.Build',
    );

    return Padding(
      padding: widget.config.padding,
      child: _buildHeatmapContent(),
    );
  }

  /// Main heatmap content with state handling using dual cubit approach
  Widget _buildHeatmapContent() {
    AppLogger.debug(
      'Building heatmap content, getting cubit stream',
      tag: '${widget.config.logTag}.UI',
    );

    return StreamBuilder<PortfolioHeatmapState>(
      stream: context.read<PortfolioHeatmapCubit>().stream,
      initialData: PortfolioHeatmapInitial(),
      builder: (context, snapshot) {
        final state = snapshot.data ?? PortfolioHeatmapInitial();

        AppLogger.debug(
          'Heatmap state update: ${state.runtimeType}',
          tag: '${widget.config.logTag}.State',
        );

        if (state is PortfolioHeatmapLoaded) {
          AppLogger.info(
            'Heatmap loaded with ${state.heatmapData.tiles.length} tiles',
            tag: '${widget.config.logTag}.State',
          );
        } else if (state is PortfolioHeatmapLoading) {
          AppLogger.info(
            'Heatmap loading: ${state.message ?? "no message"}',
            tag: '${widget.config.logTag}.State',
          );
        } else if (state is PortfolioHeatmapError) {
          AppLogger.error(
            'Heatmap error: ${state.message}',
            tag: '${widget.config.logTag}.State',
            error: state.details,
          );
        }

        return _buildStateWidget(state);
      },
    );
  }

  /// Routes to appropriate widget based on current state
  Widget _buildStateWidget(PortfolioHeatmapState state) {
    if (state is PortfolioHeatmapLoading) {
      return _buildLoadingWidget(state);
    }

    if (state is PortfolioHeatmapError) {
      return _buildErrorWidget(state);
    }

    if (state is PortfolioHeatmapLoaded) {
      return _buildLoadedWidget(state);
    }

    if (state is PortfolioHeatmapEmpty) {
      return _buildEmptyWidget(state);
    }

    return _buildDefaultWidget();
  }

  /// Builds loaded state UI with heatmap
  Widget _buildLoadedWidget(PortfolioHeatmapLoaded state) {
    AppLogger.info(
      'Building loaded heatmap widget with ${state.heatmapData.tiles.length} tiles',
      tag: '${widget.config.logTag}.UI',
    );

    AppLogger.debug(
      'Heatmap tiles data: ${state.heatmapData.tiles.map((t) => t.id).take(5).join(", ")}${state.heatmapData.tiles.length > 5 ? "..." : ""}',
      tag: '${widget.config.logTag}.UI',
    );

    // Get analytics data from the cubit
    final portfolioAnalyticsCubit = context.read<PortfolioAnalyticsCubit>();
    final analyticsState = portfolioAnalyticsCubit.state;

    // Check if analytics data is available
    AppLogger.debug(
      'Checking analytics data availability. Analytics state: ${analyticsState.runtimeType}',
      tag: '${widget.config.logTag}.UI',
    );

    if (analyticsState is! PortfolioAnalyticsLoaded) {
      AppLogger.warning(
        'Analytics not in loaded state: ${analyticsState.runtimeType}',
        tag: '${widget.config.logTag}.UI',
      );
      return const Center(child: Text('Analytics data is loading...'));
    }

    if (analyticsState.heatmap == null) {
      AppLogger.warning(
        'Analytics loaded but heatmap data is null',
        tag: '${widget.config.logTag}.UI',
      );
      return const Center(child: Text('Analytics data is loading...'));
    }

    AppLogger.info(
      'Analytics data confirmed available for heatmap display',
      tag: '${widget.config.logTag}.UI',
    );

    // Use sector heatmap converter to convert analytics data
    final convertedHeatmapData = SectorHeatmapConverter.convertToHeatmapData(
      heatmap: analyticsState.heatmap,
      showSubCards: widget.config.showSubCards,
      title: widget.config.title,
      subtitle: widget.config.subtitle,
      accentColor: Theme.of(context).primaryColor,
    );

    AppLogger.debug(
      'Converted heatmap data: ${convertedHeatmapData.tiles.length} tiles',
      tag: '${widget.config.logTag}.UI',
    );

    // Create contract-based heatmap with refresh functionality
    final cubit = context.read<PortfolioHeatmapCubit>();

    AppLogger.debug(
      'Creating heatmap contracts with cubit state: ${cubit.state.runtimeType}',
      tag: '${widget.config.logTag}.UI',
    );

    // Initialize adapters if not already created
    if (_dataAdapter == null) {
      AppLogger.debug(
        'Creating new PortfolioHeatmapDataAdapter',
        tag: '${widget.config.logTag}.UI',
      );
      _dataAdapter = PortfolioHeatmapDataAdapter(cubit);
    }

    if (_refreshAdapter == null) {
      AppLogger.debug(
        'Creating new PortfolioHeatmapRefreshAdapter',
        tag: '${widget.config.logTag}.UI',
      );
      _refreshAdapter = PortfolioHeatmapRefreshAdapter(cubit);
    }

    AppLogger.info(
      'Connecting heatmap with contracts - layout: ${_selectedLayout.name}, sector: ${_selectedSector?.name ?? "all"}',
      tag: '${widget.config.logTag}.UI',
    );

    final core = HeatmapRefreshConnector.connectWithContracts(
      dataContract: _dataAdapter!,
      refreshContract: _refreshAdapter!,
      initialLayout: _selectedLayout,
      initialSelectedSector: _selectedSector,
      onTilePressed: () {
        AppLogger.userAction(
          'Heatmap tile pressed',
          tag: '${widget.config.logTag}.Action',
        );
      },
    );

    AppLogger.debug(
      'HeatmapDisplayTemplate about to be created with core',
      tag: '${widget.config.logTag}.UI',
    );

    return SizedBox(
      width: double.infinity,
      child: HeatmapDisplayTemplate(core: core),
    );
  }

  /// Builds empty state UI
  Widget _buildEmptyWidget(PortfolioHeatmapEmpty state) {
    AppLogger.info(
      'Showing empty state: ${state.message}',
      tag: '${widget.config.logTag}.UI',
    );

    final iconSize = widget.config.compactMode ? 64.0 : 80.0;
    final textSize = widget.config.compactMode ? 16.0 : 18.0;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: iconSize, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              state.message,
              style: TextStyle(color: Colors.orange, fontSize: textSize),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadHeatmapData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds error state UI
  Widget _buildErrorWidget(PortfolioHeatmapError state) {
    AppLogger.warning(
      'Showing error: ${state.message}',
      tag: '${widget.config.logTag}.UI',
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: ${state.message}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            if (state.details != null) ...[
              const SizedBox(height: 8),
              Text(
                state.details!,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadHeatmapData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds loading state UI
  Widget _buildLoadingWidget(PortfolioHeatmapLoading state) {
    AppLogger.info(
      'Showing loading: ${state.message ?? "Loading..."}',
      tag: '${widget.config.logTag}.UI',
    );

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            state.message ?? 'Loading heatmap data...',
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Builds default/fallback state UI
  Widget _buildDefaultWidget() {
    AppLogger.debug(
      'Showing default state (initial)',
      tag: '${widget.config.logTag}.UI',
    );

    final iconSize = widget.config.compactMode ? 48.0 : 64.0;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_outlined, size: iconSize, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Loading ${widget.config.compactMode ? '' : 'portfolio '}data...',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadHeatmapData,
            child: Text(
              'Load ${widget.config.compactMode ? '' : 'Portfolio '}Heatmap',
            ),
          ),
        ],
      ),
    );
  }
}
