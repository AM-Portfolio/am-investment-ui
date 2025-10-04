import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../shared/widgets/heatmap/configurable_heatmap_widget.dart';

import '../../cubit/portfolio_heatmap_cubit.dart';
import '../../cubit/portfolio_heatmap_state.dart';
import '../../cubit/portfolio_analytics_cubit.dart';

import '../../../../../shared/widgets/selectors/selectors.dart';
import '../../../../../core/utils/logger.dart';

class PortfolioHeatmapWebPage extends ConsumerStatefulWidget {
  final String userId;
  final String portfolioId;
  final String? portfolioName;

  const PortfolioHeatmapWebPage({
    super.key,
    required this.userId,
    required this.portfolioId,
    this.portfolioName,
  });

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
  // Fixed to portfolio type since this is called from portfolio features

  @override
  void initState() {
    super.initState();
    AppLogger.info(
      'PortfolioHeatmapWebPage initialized',
      tag: 'PortfolioHeatmapWebPage',
    );
    AppLogger.debug(
      'Page parameters: userId=${widget.userId}, portfolioId=${widget.portfolioId}, portfolioName=${widget.portfolioName ?? 'null'}',
      tag: 'PortfolioHeatmapWebPage',
    );
    _loadHeatmapData();
  }

  void _loadHeatmapData() {
    AppLogger.methodEntry(
      '_loadHeatmapData',
      tag: 'PortfolioHeatmapWebPage',
      params: {
        'portfolioId': widget.portfolioId,
        'timeFrame': _selectedTimeframe.name,
        'metric': _selectedMetric.name,
        'sector': _selectedSector?.name ?? 'all',
        'marketCap': _selectedMarketCap?.name ?? 'all',
      },
    );

    // Step 1: First call PortfolioAnalyticsCubit.loadAnalytics as required
    AppLogger.info(
      'Step 1: Calling PortfolioAnalyticsCubit.loadAnalytics',
      tag: 'PortfolioHeatmapWebPage',
    );

    final portfolioAnalyticsCubit = context.read<PortfolioAnalyticsCubit>();
    final portfolioHeatmapCubit = context.read<PortfolioHeatmapCubit>();

    // Load analytics data first
    portfolioAnalyticsCubit
        .loadAnalytics(widget.portfolioId)
        .then((_) {
          AppLogger.info(
            'Analytics data loaded, now loading heatmap with real data',
            tag: 'PortfolioHeatmapWebPage',
          );

          // Step 2: Then proceed with heatmap-specific data loading using the loaded analytics
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
            'Failed to load analytics, proceeding with heatmap fallback',
            tag: 'PortfolioHeatmapWebPage',
            error: error,
          );

          // Load heatmap even if analytics fails
          portfolioHeatmapCubit.loadHeatmapData(
            portfolioId: widget.portfolioId,
            timeFrame: _selectedTimeframe,
            metric: _selectedMetric,
            sector: _selectedSector ?? SectorType.all,
            marketCap: _selectedMarketCap ?? MarketCapType.all,
            analyticsCubit: portfolioAnalyticsCubit,
          );
        });

    AppLogger.methodExit('_loadHeatmapData', tag: 'PortfolioHeatmapWebPage');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<PortfolioHeatmapState>(
                stream: context.read<PortfolioHeatmapCubit>().stream,
                initialData: PortfolioHeatmapInitial(),
                builder: (context, snapshot) {
                  final state = snapshot.data ?? PortfolioHeatmapInitial();
                  AppLogger.debug(
                    'UI state update: ${state.runtimeType}',
                    tag: 'PortfolioHeatmapWebPage',
                  );

                  if (state is PortfolioHeatmapLoading) {
                    AppLogger.info(
                      'Displaying loading state',
                      tag: 'PortfolioHeatmapWebPage',
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

                  if (state is PortfolioHeatmapError) {
                    AppLogger.warning(
                      'Displaying error state: ${state.message}',
                      tag: 'PortfolioHeatmapWebPage',
                    );
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
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
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              AppLogger.userAction(
                                'Retry button clicked',
                                tag: 'PortfolioHeatmapWebPage',
                              );
                              _loadHeatmapData();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is PortfolioHeatmapLoaded) {
                    AppLogger.info(
                      'Displaying loaded heatmap data',
                      tag: 'PortfolioHeatmapWebPage',
                    );
                    AppLogger.debug(
                      'Heatmap data details',
                      tag: 'PortfolioHeatmapWebPage',
                    );

                    return ConfigurableHeatmapWidget(
                      data: state.heatmapData,
                      showSelectors:
                          true, // Let ConfigurableHeatmapWidget handle selectors
                      initialTimeFrame: _selectedTimeframe,
                      initialMetric: _selectedMetric,
                      initialSector: _selectedSector,
                      initialMarketCap: _selectedMarketCap,
                      onSelectorsChanged:
                          ({
                            TimeFrame? timeFrame,
                            MetricType? metric,
                            SectorType? sector,
                            MarketCapType? marketCap,
                          }) {
                            // Update local state
                            if (timeFrame != null)
                              _selectedTimeframe = timeFrame;
                            if (metric != null) _selectedMetric = metric;
                            if (sector != null) _selectedSector = sector;
                            if (marketCap != null)
                              _selectedMarketCap = marketCap;

                            // Reload heatmap data with new selections
                            _loadHeatmapData();
                          },
                    );
                  }

                  if (state is PortfolioHeatmapEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.folder_open,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
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

                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.bar_chart_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
