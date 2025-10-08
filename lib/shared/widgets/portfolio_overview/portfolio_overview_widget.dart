import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/portfolio/providers/portfolio_providers.dart';
import 'adapters/portfolio_overview_data_adapter.dart';
import 'charts/base/chart_colors.dart';
import 'charts/sector_allocation/sector_donut_chart.dart';
import 'charts/sector_allocation/sector_pie_chart.dart';
import 'charts/sector_allocation/sector_bar_chart.dart';
import 'configs/portfolio_overview_config.dart';
import 'models/portfolio_overview_data.dart';

/// Universal portfolio overview widget
class PortfolioOverviewWidget extends ConsumerStatefulWidget {
  const PortfolioOverviewWidget({
    required this.portfolioId,
    super.key,
    this.config,
    this.onRefresh,
  });

  final String portfolioId;
  final PortfolioOverviewConfig? config;
  final VoidCallback? onRefresh;

  @override
  ConsumerState<PortfolioOverviewWidget> createState() =>
      _PortfolioOverviewWidgetState();
}

class _PortfolioOverviewWidgetState
    extends ConsumerState<PortfolioOverviewWidget> {
  late PortfolioOverviewConfig _config;
  ChartType _selectedChartType = ChartType.donut;

  @override
  void initState() {
    super.initState();
    _config = widget.config ?? PortfolioOverviewConfig.web();
    _selectedChartType = _config.defaultChartType;
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(portfolioSummaryProvider(widget.portfolioId));
    final analyticsAsync = ref.watch(
      portfolioAnalyticsWithDefaultsProvider(widget.portfolioId),
    );
    final holdingsAsync = ref.watch(portfolioHoldingsProvider(widget.portfolioId));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder(
          future: Future.wait([
            summaryAsync.value != null
                ? Future.value(summaryAsync.value!)
                : summaryAsync.asData?.value,
            analyticsAsync.value != null
                ? Future.value(analyticsAsync.value!)
                : analyticsAsync.asData?.value,
            holdingsAsync.value != null
                ? Future.value(holdingsAsync.value!)
                : holdingsAsync.asData?.value,
          ].whereType<Future>().toList()),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error loading overview: ${snapshot.error}'),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No data available'));
            }

            final summary = summaryAsync.value;
            final analytics = analyticsAsync.value;
            final holdings = holdingsAsync.value;

            if (summary == null || analytics == null || holdings == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final adapter = PortfolioOverviewDataAdapter(
              getSummary: (_) async => summary,
              getAnalytics: (_) async => analytics,
              getHoldings: (_) async => holdings,
            );

            return FutureBuilder<PortfolioOverviewData>(
              future: adapter.getOverviewData(widget.portfolioId),
              builder: (context, overviewSnapshot) {
                if (overviewSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (overviewSnapshot.hasError) {
                  return Center(
                    child: Text('Error: ${overviewSnapshot.error}'),
                  );
                }

                final overviewData = overviewSnapshot.data;
                if (overviewData == null) {
                  return const Center(child: Text('No overview data'));
                }

                return _buildOverviewContent(context, overviewData);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildOverviewContent(
    BuildContext context,
    PortfolioOverviewData data,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.dashboard, size: 24),
              const SizedBox(width: 8),
              Text(
                'Portfolio Overview',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              if (_config.enableRefresh)
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    ref.invalidate(portfolioSummaryProvider(widget.portfolioId));
                    ref.invalidate(
                      portfolioAnalyticsWithDefaultsProvider(widget.portfolioId),
                    );
                    ref.invalidate(portfolioHoldingsProvider(widget.portfolioId));
                    widget.onRefresh?.call();
                  },
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Summary Cards
          if (_config.showSummary) _buildSummarySection(context, data.summary),
          if (_config.showSummary) const SizedBox(height: 24),

          // Movers Section
          if (_config.showMovers) _buildMoversSection(context, data),
          if (_config.showMovers) const SizedBox(height: 24),

          // Allocation Charts
          if (_config.showAllocation && _config.showCharts)
            _buildAllocationSection(context, data),
        ],
      ),
    );
  }

  Widget _buildSummarySection(
    BuildContext context,
    OverviewSummaryData summary,
  ) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildSummaryCard(
          context,
          'Total Value',
          '\$${summary.totalValue.toStringAsFixed(2)}',
          Icons.account_balance_wallet,
          Colors.blue,
        ),
        _buildSummaryCard(
          context,
          "Today's Change",
          '\$${summary.todayChange.toStringAsFixed(2)}',
          summary.todayChange >= 0 ? Icons.trending_up : Icons.trending_down,
          summary.todayChange >= 0 ? Colors.green : Colors.red,
          subtitle: '${summary.todayChangePercent.toStringAsFixed(2)}%',
        ),
        _buildSummaryCard(
          context,
          'Total Gain/Loss',
          '\$${summary.totalGainLoss.toStringAsFixed(2)}',
          summary.totalGainLoss >= 0 ? Icons.trending_up : Icons.trending_down,
          summary.totalGainLoss >= 0 ? Colors.green : Colors.red,
          subtitle: '${summary.totalGainLossPercent.toStringAsFixed(2)}%',
        ),
        _buildSummaryCard(
          context,
          'Holdings',
          '${summary.totalHoldings}',
          Icons.list_alt,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoversSection(BuildContext context, PortfolioOverviewData data) {
    return Row(
      children: [
        Expanded(
          child: _buildMoversCard(
            context,
            'Top Gainers',
            data.topGainers,
            ChartColors.positiveColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMoversCard(
            context,
            'Top Losers',
            data.topLosers,
            ChartColors.negativeColor,
          ),
        ),
      ],
    );
  }

  Widget _buildMoversCard(
    BuildContext context,
    String title,
    List<OverviewMoversData> movers,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...movers.take(5).map((mover) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mover.symbol,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (mover.sector != null)
                              Text(
                                mover.sector!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${mover.currentPrice.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${mover.changePercent >= 0 ? '+' : ''}${mover.changePercent.toStringAsFixed(2)}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildAllocationSection(
    BuildContext context,
    PortfolioOverviewData data,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Sector Allocation',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Spacer(),
            SegmentedButton<ChartType>(
              segments: const [
                ButtonSegment(
                  value: ChartType.pie,
                  label: Text('Pie'),
                  icon: Icon(Icons.pie_chart, size: 16),
                ),
                ButtonSegment(
                  value: ChartType.donut,
                  label: Text('Donut'),
                  icon: Icon(Icons.donut_small, size: 16),
                ),
                ButtonSegment(
                  value: ChartType.bar,
                  label: Text('Bar'),
                  icon: Icon(Icons.bar_chart, size: 16),
                ),
              ],
              selected: {_selectedChartType},
              onSelectionChanged: (Set<ChartType> newSelection) {
                setState(() {
                  _selectedChartType = newSelection.first;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: _buildSelectedChart(data.sectorAllocation),
        ),
      ],
    );
  }

  Widget _buildSelectedChart(List<AllocationItem> allocations) {
    switch (_selectedChartType) {
      case ChartType.pie:
        return SectorPieChart(allocations: allocations);
      case ChartType.donut:
        return SectorDonutChart(allocations: allocations);
      case ChartType.bar:
        return SectorBarChart(allocations: allocations);
      case ChartType.table:
        return _buildAllocationTable(allocations);
    }
  }

  Widget _buildAllocationTable(List<AllocationItem> allocations) {
    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Sector')),
          DataColumn(label: Text('Value')),
          DataColumn(label: Text('Percentage')),
          DataColumn(label: Text('Holdings')),
        ],
        rows: allocations.map((item) {
          return DataRow(cells: [
            DataCell(Text(item.label)),
            DataCell(Text('\$${item.value.toStringAsFixed(2)}')),
            DataCell(Text('${item.percentage.toStringAsFixed(1)}%')),
            DataCell(Text('${item.count}')),
          ]);
        }).toList(),
      ),
    );
  }
}
