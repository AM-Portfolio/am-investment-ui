import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/utils/logger.dart';
import '../../../../../shared/widgets/heatmap/universal_heatmap.dart';
import '../../../../../shared/widgets/selectors/selectors.dart';
import '../../cubit/portfolio_analytics_cubit.dart';
import '../../cubit/portfolio_analytics_state.dart';
import '../../cubit/portfolio_heatmap_cubit.dart';
import '../../cubit/portfolio_heatmap_state.dart';
import '../../mappers/sector_heatmap_converter.dart';

/// Portfolio Heatmap Mobile Page
/// Optimized for mobile devices with touch-friendly controls and responsive design
class PortfolioHeatmapMobilePage extends ConsumerStatefulWidget {
  const PortfolioHeatmapMobilePage({
    required this.userId,
    required this.portfolioId,
    super.key,
    this.portfolioName,
  });

  final String userId;

  final String portfolioId;
  final String? portfolioName;

  @override
  ConsumerState<PortfolioHeatmapMobilePage> createState() =>
      _PortfolioHeatmapMobilePageState();
}

class _PortfolioHeatmapMobilePageState
    extends ConsumerState<PortfolioHeatmapMobilePage> {
  // Current selections - mobile optimized defaults
  MetricType _selectedMetric = MetricType.changePercent;
  TimeFrame _selectedTimeframe = TimeFrame.oneYear;
  SectorType? _selectedSector;
  MarketCapType? _selectedMarketCap;
  HeatmapLayoutType _selectedLayout =
      HeatmapLayoutType.list; // Default to list for mobile

  @override
  void initState() {
    super.initState();

    AppLogger.info(
      'PortfolioHeatmapMobilePage initialized',
      tag: 'PortfolioHeatmap.Mobile.Init',
    );
    AppLogger.debug(
      'Mobile page parameters: userId=${widget.userId}, portfolioId=${widget.portfolioId}, portfolioName=${widget.portfolioName ?? 'null'}',
      tag: 'PortfolioHeatmap.Mobile.Init',
    );
    _loadHeatmapData();
  }

  void _loadHeatmapData() {
    AppLogger.methodEntry(
      '_loadHeatmapData',
      tag: 'PortfolioHeatmap.Mobile.Data',
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
            'Analytics loaded, proceeding with mobile heatmap data',
            tag: 'PortfolioHeatmap.Mobile.Data',
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
            'Analytics failed, using mobile fallback',
            tag: 'PortfolioHeatmap.Mobile.Data',
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
      tag: 'PortfolioHeatmap.Mobile.Data',
    );
  }

  @override
  Widget build(BuildContext context) => _buildHeatmapContent();

  /// Main heatmap content with mobile-optimized state handling using dual cubit approach
  Widget _buildHeatmapContent() => StreamBuilder<PortfolioHeatmapState>(
    stream: context.read<PortfolioHeatmapCubit>().stream,
    initialData: PortfolioHeatmapInitial(),
    builder: (context, snapshot) {
      final state = snapshot.data ?? PortfolioHeatmapInitial();

      AppLogger.debug(
        'Mobile state update: ${state.runtimeType}',
        tag: 'PortfolioHeatmap.Mobile.State',
      );

      return _buildMobileStateWidget(state);
    },
  );

  /// Routes to appropriate mobile widget based on current state
  Widget _buildMobileStateWidget(PortfolioHeatmapState state) {
    if (state is PortfolioHeatmapLoading) {
      return _buildMobileLoadingWidget(state);
    }

    if (state is PortfolioHeatmapError) {
      return _buildMobileErrorWidget(state);
    }

    if (state is PortfolioHeatmapLoaded) {
      return _buildMobileLoadedWidget(state);
    }

    if (state is PortfolioHeatmapEmpty) {
      return _buildMobileEmptyWidget(state);
    }

    return _buildMobileDefaultWidget();
  }

  /// Builds mobile loading state UI
  Widget _buildMobileLoadingWidget(PortfolioHeatmapLoading state) {
    AppLogger.info(
      'Mobile showing loading: ${state.message ?? "Loading..."}',
      tag: 'PortfolioHeatmap.Mobile.UI',
    );

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            state.message ?? 'Loading mobile heatmap data...',
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Builds mobile error state UI
  Widget _buildMobileErrorWidget(PortfolioHeatmapError state) {
    AppLogger.warning(
      'Mobile showing error: ${state.message}',
      tag: 'PortfolioHeatmap.Mobile.UI',
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

  /// Builds mobile loaded state UI with heatmap
  Widget _buildMobileLoadedWidget(PortfolioHeatmapLoaded state) {
    AppLogger.info(
      'Mobile showing heatmap: ${state.heatmapData.tiles.length} tiles',
      tag: 'PortfolioHeatmap.Mobile.UI',
    );

    // Get analytics data from the cubit
    final portfolioAnalyticsCubit = context.read<PortfolioAnalyticsCubit>();
    final analyticsState = portfolioAnalyticsCubit.state;

    // Check if analytics data is available
    if (analyticsState is! PortfolioAnalyticsLoaded ||
        analyticsState.heatmap == null) {
      AppLogger.warning(
        'Analytics data not available for mobile heatmap display',
        tag: 'PortfolioHeatmap.Mobile.UI',
      );
      return const Center(child: Text('Analytics data is loading...'));
    }

    // Use sector heatmap converter to convert analytics data with mobile configuration
    final convertedHeatmapData = SectorHeatmapConverter.convertToHeatmapData(
      heatmap: analyticsState.heatmap,
      showSubCards: false, // Use compact mode for mobile
      title: 'Heatmap',
      subtitle: 'Performance by sector',
      accentColor: Theme.of(context).primaryColor,
    );

    AppLogger.debug(
      'Mobile converted heatmap data: ${convertedHeatmapData.tiles.length} tiles',
      tag: 'PortfolioHeatmap.Mobile.UI',
    );

    // Create mobile-optimized configuration
    final mobileConfig = convertedHeatmapData.configuration.copyWith(
      layout: convertedHeatmapData.configuration.layout?.copyWith(
        layoutType: _selectedLayout,
      ),
    );

    // Return UniversalHeatmapWidget with mobile configuration
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: UniversalHeatmapWidget(
        investmentType: InvestmentType.portfolio,
        heatmapData: convertedHeatmapData,
        config: mobileConfig,
        title: 'Heatmap',
        showSelectors: false, // Hide selectors as we have custom mobile ones
        compactMode: true, // Use compact mode for mobile
        selectedSector: _selectedSector,
        onTilePressed: () {
          AppLogger.userAction(
            'Mobile heatmap tile pressed',
            tag: 'PortfolioHeatmap.Mobile.Action',
          );
        },
        onFiltersChanged: ({timeFrame, metric, sector, marketCap, layout}) {
          _onMobileFiltersChanged(
            timeFrame: timeFrame,
            metric: metric,
            sector: sector,
            marketCap: marketCap,
            layout: layout,
          );
        },
        templateType:
            UniversalTemplateType.compact, // Use compact template for mobile
      ),
    );
  }

  /// Builds mobile empty state UI
  Widget _buildMobileEmptyWidget(PortfolioHeatmapEmpty state) {
    AppLogger.info(
      'Mobile showing empty state: ${state.message}',
      tag: 'PortfolioHeatmap.Mobile.UI',
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder_open, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            Text(
              state.message,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Add some investments to see the mobile heatmap',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds mobile default/fallback state UI
  Widget _buildMobileDefaultWidget() {
    AppLogger.debug(
      'Mobile showing default state (initial)',
      tag: 'PortfolioHeatmap.Mobile.UI',
    );

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bar_chart_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Loading mobile portfolio data...',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadHeatmapData,
            child: const Text('Load Mobile Heatmap'),
          ),
        ],
      ),
    );
  }

  /// Handles mobile filter changes from heatmap selectors
  void _onMobileFiltersChanged({
    TimeFrame? timeFrame,
    MetricType? metric,
    SectorType? sector,
    MarketCapType? marketCap,
    HeatmapLayoutType? layout,
  }) {
    AppLogger.debug(
      'Mobile filters: timeFrame=${timeFrame?.code}, metric=${metric?.name}, sector=${sector?.name}, marketCap=${marketCap?.name}, layout=${layout?.name}',
      tag: 'PortfolioHeatmap.Mobile.Filter',
    );

    // Update local state
    if (timeFrame != null) {
      _selectedTimeframe = timeFrame;
    }
    if (metric != null) {
      _selectedMetric = metric;
    }
    if (sector != null) {
      _selectedSector = sector;
    }
    if (marketCap != null) {
      _selectedMarketCap = marketCap;
    }
    if (layout != null) {
      setState(() {
        _selectedLayout = layout;
      });
      AppLogger.info(
        'Mobile layout changed to: ${layout.name}',
        tag: 'PortfolioHeatmap.Mobile.Layout',
      );
    }

    // Reload heatmap data with new selections
  }
}
