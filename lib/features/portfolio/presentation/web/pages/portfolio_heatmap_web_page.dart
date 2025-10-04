import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/utils/logger.dart';
import '../../../../../shared/widgets/heatmap/configurable_heatmap_widget.dart';
import '../../../../../shared/widgets/heatmap/templates/web_heatmap_defaults.dart';
import '../../../../../shared/widgets/selectors/selectors.dart';
import '../../cubit/portfolio_analytics_cubit.dart';
import '../../cubit/portfolio_heatmap_cubit.dart';
import '../../cubit/portfolio_heatmap_state.dart';

class PortfolioHeatmapWebPage extends ConsumerStatefulWidget {
  const PortfolioHeatmapWebPage({
    required this.userId,
    required this.portfolioId,
    super.key,
    this.portfolioName,
  });

  final String userId;
  final String portfolioId;
  final String? portfolioName;

  @override
  ConsumerState<PortfolioHeatmapWebPage> createState() =>
      _PortfolioHeatmapWebPageState();
}

class _PortfolioHeatmapWebPageState
    extends ConsumerState<PortfolioHeatmapWebPage> {
  MetricType _selectedMetric = MetricType.changePercent;
  TimeFrame _selectedTimeframe = TimeFrame.oneYear;
  SectorType? _selectedSector;
  MarketCapType? _selectedMarketCap;

  late WebHeatmapDefaults _webHeatmapDefaults;

  @override
  void initState() {
    super.initState();

    // Initialize web-optimized heatmap configuration
    _webHeatmapDefaults = WebHeatmapDefaults();

    AppLogger.info(
      'PortfolioHeatmapWebPage initialized with config: $_webHeatmapDefaults',
      tag: 'PortfolioHeatmap.Init',
    );
    AppLogger.debug(
      'Page parameters: userId=${widget.userId}, portfolioId=${widget.portfolioId}, portfolioName=${widget.portfolioName ?? 'null'}',
      tag: 'PortfolioHeatmap.Init',
    );
    _loadHeatmapData();
  }

  void _loadHeatmapData() {
    AppLogger.methodEntry(
      '_loadHeatmapData',
      tag: 'PortfolioHeatmap.Data',
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
    portfolioAnalyticsCubit
        .loadAnalytics(widget.portfolioId)
        .then((_) {
          AppLogger.info(
            'Analytics loaded, proceeding with heatmap data',
            tag: 'PortfolioHeatmap.Data',
          );

          portfolioHeatmapCubit.loadHeatmapData(
            portfolioId: widget.portfolioId,
            timeFrame: _selectedTimeframe,
            metric: _selectedMetric,
            sector: _selectedSector ?? SectorType.all,
            marketCap: _selectedMarketCap ?? MarketCapType.all,
            analyticsCubit: portfolioAnalyticsCubit,
          );
        })
        .catchError((error) {
          AppLogger.error(
            'Analytics failed, using fallback',
            tag: 'PortfolioHeatmap.Data',
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

    AppLogger.methodExit('_loadHeatmapData', tag: 'PortfolioHeatmap.Data');
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.debug(
      'Building UI: timeframe=${_selectedTimeframe.code}, metric=${_selectedMetric.shortName}',
      tag: 'PortfolioHeatmap.UI',
    );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [Expanded(child: _buildHeatmapStreamBuilder())],
        ),
      ),
    );
  }

  /// Builds the main StreamBuilder for heatmap state management
  Widget _buildHeatmapStreamBuilder() => StreamBuilder<PortfolioHeatmapState>(
    stream: context.read<PortfolioHeatmapCubit>().stream,
    initialData: PortfolioHeatmapInitial(),
    builder: (context, snapshot) {
      final state = snapshot.data ?? PortfolioHeatmapInitial();

      AppLogger.debug(
        'State update: ${state.runtimeType}',
        tag: 'PortfolioHeatmap.State',
      );

      return _buildStateWidget(state);
    },
  );

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

  /// Builds loading state UI
  Widget _buildLoadingWidget(PortfolioHeatmapLoading state) {
    AppLogger.info(
      'Showing loading: ${state.message ?? "Loading..."}',
      tag: 'PortfolioHeatmap.UI',
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
          ),
        ],
      ),
    );
  }

  /// Builds error state UI
  Widget _buildErrorWidget(PortfolioHeatmapError state) {
    AppLogger.warning(
      'Showing error: ${state.message}',
      tag: 'PortfolioHeatmap.UI',
    );

    return Center(
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
            onPressed: _onRetryPressed,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  /// Builds loaded state UI with heatmap
  Widget _buildLoadedWidget(PortfolioHeatmapLoaded state) {
    AppLogger.info(
      'Showing heatmap: ${state.heatmapData.tiles.length} tiles',
      tag: 'PortfolioHeatmap.UI',
    );

    return ConfigurableHeatmapWidget(
      data: state.heatmapData,
      config: _webHeatmapDefaults,
      initialTimeFrame: _selectedTimeframe,
      initialMetric: _selectedMetric,
      initialSector: _selectedSector,
      initialMarketCap: _selectedMarketCap,
      onSelectorsChanged: _onFiltersChanged,
    );
  }

  /// Builds empty state UI
  Widget _buildEmptyWidget(PortfolioHeatmapEmpty state) {
    AppLogger.info(
      'Showing empty state: ${state.message}',
      tag: 'PortfolioHeatmap.UI',
    );

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder_open, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            state.message,
            style: const TextStyle(fontSize: 18, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Add some investments to see the heatmap',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// Builds default/fallback state UI
  Widget _buildDefaultWidget() {
    AppLogger.debug(
      'Showing default state (initial)',
      tag: 'PortfolioHeatmap.UI',
    );

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bar_chart_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Loading portfolio data...',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadHeatmapData,
            child: const Text('Load Heatmap'),
          ),
        ],
      ),
    );
  }

  /// Handles retry button press
  void _onRetryPressed() {
    AppLogger.userAction(
      'Retry button clicked',
      tag: 'PortfolioHeatmap.Action',
    );
    _loadHeatmapData();
  }

  /// Handles filter changes from heatmap selectors
  void _onFiltersChanged({
    TimeFrame? timeFrame,
    MetricType? metric,
    SectorType? sector,
    MarketCapType? marketCap,
  }) {
    AppLogger.debug(
      'Filters: timeFrame=${timeFrame?.code}, metric=${metric?.shortName}, sector=${sector?.name}, marketCap=${marketCap?.name}',
      tag: 'PortfolioHeatmap.Filter',
    );

    // Update local state
    if (timeFrame != null) _selectedTimeframe = timeFrame;
    if (metric != null) _selectedMetric = metric;
    if (sector != null) _selectedSector = sector;
    if (marketCap != null) _selectedMarketCap = marketCap;

    // Reload heatmap data with new selections
    _loadHeatmapData();
  }
}
