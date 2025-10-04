import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../shared/widgets/heatmap/configurable_heatmap_widget.dart';
import '../../../../../shared/widgets/selectors/time_frame_selector.dart';
import '../../../../../shared/widgets/selectors/metric_selector.dart';
import '../../cubit/portfolio_heatmap_cubit.dart';
import '../../cubit/portfolio_heatmap_state.dart';
import '../../../../../shared/widgets/selectors/selectors.dart';

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
    _loadHeatmapData();
  }

  void _loadHeatmapData() {
    final portfolioHeatmapCubit = context.read<PortfolioHeatmapCubit>();
    portfolioHeatmapCubit.loadHeatmapData(
      portfolioId: widget.portfolioId,
      timeFrame: _selectedTimeframe,
      metric: _selectedMetric,
      sector: _selectedSector,
      marketCap: _selectedMarketCap,
    );
  }

  void _onMetricChanged(MetricType metric) {
    setState(() {
      _selectedMetric = metric;
    });
    final portfolioHeatmapCubit = context.read<PortfolioHeatmapCubit>();
    portfolioHeatmapCubit.updateMetric(
      portfolioId: widget.portfolioId,
      metric: metric,
    );
  }

  void _onTimeframeChanged(TimeFrame timeframe) {
    setState(() {
      _selectedTimeframe = timeframe;
    });
    final portfolioHeatmapCubit = context.read<PortfolioHeatmapCubit>();
    portfolioHeatmapCubit.updateTimeFrame(
      portfolioId: widget.portfolioId,
      timeFrame: timeframe,
    );
  }

  void _onSectorChanged(SectorType? sector) {
    setState(() {
      _selectedSector = sector;
    });
    final portfolioHeatmapCubit = context.read<PortfolioHeatmapCubit>();
    portfolioHeatmapCubit.updateSector(
      portfolioId: widget.portfolioId,
      sector: sector,
    );
  }

  void _onMarketCapChanged(MarketCapType? marketCap) {
    setState(() {
      _selectedMarketCap = marketCap;
    });
    final portfolioHeatmapCubit = context.read<PortfolioHeatmapCubit>();
    portfolioHeatmapCubit.updateMarketCap(
      portfolioId: widget.portfolioId,
      marketCap: marketCap,
    );
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
              child: BlocBuilder<PortfolioHeatmapCubit, PortfolioHeatmapState>(
                builder: (context, state) {
                  if (state is PortfolioHeatmapLoading) {
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
                            onPressed: _loadHeatmapData,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is PortfolioHeatmapLoaded) {
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
