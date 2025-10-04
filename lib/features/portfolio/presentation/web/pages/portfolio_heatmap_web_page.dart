import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../shared/widgets/heatmap/configurable_heatmap_widget.dart';
import '../../../../../shared/widgets/selectors/time_frame_selector.dart';
import '../../../../../shared/widgets/selectors/metric_selector.dart';
import '../../cubit/portfolio_heatmap_cubit.dart';
import '../../cubit/portfolio_heatmap_state.dart';
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
  MetricType _selectedMetric = MetricType.returns;
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

    final portfolioHeatmapCubit = context.read<PortfolioHeatmapCubit>();
    portfolioHeatmapCubit.loadHeatmapData(
      portfolioId: widget.portfolioId,
      timeFrame: _selectedTimeframe,
      metric: _selectedMetric,
      sector: _selectedSector ?? SectorType.all,
      marketCap: _selectedMarketCap ?? MarketCapType.all,
    );

    AppLogger.methodExit('_loadHeatmapData', tag: 'PortfolioHeatmapWebPage');
  }

  void _onMetricChanged(MetricType metric) {
    AppLogger.userAction(
      'Changed metric filter',
      tag: 'PortfolioHeatmapWebPage',
    );
    AppLogger.debug(
      'Metric changed from ${_selectedMetric.name} to ${metric.name}',
      tag: 'PortfolioHeatmapWebPage',
    );

    setState(() {
      _selectedMetric = metric;
    });

    final portfolioHeatmapCubit = context.read<PortfolioHeatmapCubit>();
    portfolioHeatmapCubit.updateMetric(metric);
  }

  void _onTimeframeChanged(TimeFrame timeframe) {
    AppLogger.userAction(
      'Changed timeframe filter',
      tag: 'PortfolioHeatmapWebPage',
    );
    AppLogger.debug(
      'Timeframe changed from ${_selectedTimeframe.name} to ${timeframe.name}',
      tag: 'PortfolioHeatmapWebPage',
    );

    setState(() {
      _selectedTimeframe = timeframe;
    });

    final portfolioHeatmapCubit = context.read<PortfolioHeatmapCubit>();
    portfolioHeatmapCubit.updateTimeFrame(timeframe);
  }

  void _onSectorChanged(SectorType? sector) {
    AppLogger.userAction(
      'Changed sector filter',
      tag: 'PortfolioHeatmapWebPage',
    );
    final oldSector = _selectedSector?.name ?? 'all';
    final newSector = sector?.name ?? 'all';
    AppLogger.debug(
      'Sector changed from $oldSector to $newSector',
      tag: 'PortfolioHeatmapWebPage',
    );

    setState(() {
      _selectedSector = sector;
    });

    final portfolioHeatmapCubit = context.read<PortfolioHeatmapCubit>();
    portfolioHeatmapCubit.updateSector(sector ?? SectorType.all);
  }

  void _onMarketCapChanged(MarketCapType? marketCap) {
    AppLogger.userAction(
      'Changed market cap filter',
      tag: 'PortfolioHeatmapWebPage',
    );
    final oldMarketCap = _selectedMarketCap?.name ?? 'all';
    final newMarketCap = marketCap?.name ?? 'all';
    AppLogger.debug(
      'Market cap changed from $oldMarketCap to $newMarketCap',
      tag: 'PortfolioHeatmapWebPage',
    );

    setState(() {
      _selectedMarketCap = marketCap;
    });

    final portfolioHeatmapCubit = context.read<PortfolioHeatmapCubit>();
    portfolioHeatmapCubit.updateMarketCap(marketCap ?? MarketCapType.all);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio Heatmap'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Controls Row
            Row(
              children: [
                // Metric Type Dropdown (Disabled)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Metric',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<MetricType>(
                        value: _selectedMetric,
                        onChanged: null, // Disabled
                        // onChanged: (MetricType? value) {
                        //   if (value != null) {
                        //     _onMetricChanged(value);
                        //   }
                        // },
                        items: MetricType.values
                            .map<DropdownMenuItem<MetricType>>(
                              (MetricType type) => DropdownMenuItem<MetricType>(
                                value: type,
                                child: Text(type.displayName),
                              ),
                            )
                            .toList(),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Timeframe Dropdown
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Timeframe',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<TimeFrame>(
                        value: _selectedTimeframe,
                        onChanged: (TimeFrame? value) {
                          if (value != null) {
                            _onTimeframeChanged(value);
                          }
                        },
                        items: TimeFrame.values
                            .map<DropdownMenuItem<TimeFrame>>(
                              (TimeFrame timeframe) =>
                                  DropdownMenuItem<TimeFrame>(
                                    value: timeframe,
                                    child: Text(timeframe.displayName),
                                  ),
                            )
                            .toList(),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Heatmap Widget
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
                      showSelectors: false, // Selectors are handled above
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
                          'Portfolio Heatmap',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
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
