import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../shared/core/cubits/heatmap/heatmap_display_cubit.dart';
import '../../../../../shared/widgets/heatmap/configurable_heatmap_widget.dart';
import '../../../../../shared/widgets/selectors/time_frame_selector.dart';
import '../../../../../shared/widgets/selectors/metric_selector.dart';

class PortfolioHeatmapWebPage extends StatefulWidget {
  const PortfolioHeatmapWebPage({super.key});

  @override
  State<PortfolioHeatmapWebPage> createState() =>
      _PortfolioHeatmapWebPageState();
}

class _PortfolioHeatmapWebPageState extends State<PortfolioHeatmapWebPage> {
  MetricType _selectedMetric = MetricType.returns;
  TimeFrame _selectedTimeframe = TimeFrame.oneYear;
  InvestmentType _selectedInvestmentType = InvestmentType.portfolio;

  @override
  void initState() {
    super.initState();
    _initializeHeatmap();
  }

  void _initializeHeatmap() {
    // Initialize heatmap with portfolio configuration
    final heatmapCubit = context.read<HeatmapDisplayCubit>();
    final config = HeatmapDisplayConfig.portfolio(
      title: 'Portfolio Heatmap',
      compactMode: false,
    );

    // Sample portfolio data - in real app this would come from portfolio service
    final sampleData = <String, dynamic>{
      'holdings': [
        {
          'id': 'AAPL',
          'symbol': 'AAPL',
          'name': 'Apple Inc.',
          'sector': 'Technology',
          'value': 10000,
          'performance': 5.2,
          'weightage': 15.0,
        },
        {
          'id': 'MSFT',
          'symbol': 'MSFT',
          'name': 'Microsoft Corp.',
          'sector': 'Technology',
          'value': 8000,
          'performance': -2.1,
          'weightage': 12.0,
        },
        {
          'id': 'GOOGL',
          'symbol': 'GOOGL',
          'name': 'Alphabet Inc.',
          'sector': 'Technology',
          'value': 6000,
          'performance': 1.8,
          'weightage': 9.0,
        },
      ],
    };

    heatmapCubit.initialize(config: config, rawData: sampleData);
  }

  void _onMetricChanged(MetricType metric) {
    setState(() {
      _selectedMetric = metric;
    });
    final heatmapCubit = context.read<HeatmapDisplayCubit>();
    heatmapCubit.updateMetric(metric);
  }

  void _onTimeframeChanged(TimeFrame timeframe) {
    setState(() {
      _selectedTimeframe = timeframe;
    });
    final heatmapCubit = context.read<HeatmapDisplayCubit>();
    heatmapCubit.updateTimeFrame(timeframe);
  }

  void _onInvestmentTypeChanged(InvestmentType investmentType) {
    setState(() {
      _selectedInvestmentType = investmentType;
    });
    // Would need to reinitialize with different config for different investment types
    _initializeHeatmap();
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
                // Investment Type Dropdown
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Investment Type',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<InvestmentType>(
                        value: _selectedInvestmentType,
                        onChanged: (InvestmentType? value) {
                          if (value != null) {
                            _onInvestmentTypeChanged(value);
                          }
                        },
                        items: InvestmentType.values
                            .map<DropdownMenuItem<InvestmentType>>(
                              (InvestmentType type) =>
                                  DropdownMenuItem<InvestmentType>(
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
                // Metric Type Dropdown
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
                        onChanged: (MetricType? value) {
                          if (value != null) {
                            _onMetricChanged(value);
                          }
                        },
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
              child: BlocBuilder<HeatmapDisplayCubit, HeatmapDisplayState>(
                builder: (context, state) {
                  if (state is HeatmapDisplayLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is HeatmapDisplayError) {
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
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _initializeHeatmap,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is HeatmapDisplayLoaded) {
                    return ConfigurableHeatmapWidget(data: state.data);
                  }

                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bar_chart_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No data available',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Initialize heatmap to see data',
                          style: TextStyle(color: Colors.grey),
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
