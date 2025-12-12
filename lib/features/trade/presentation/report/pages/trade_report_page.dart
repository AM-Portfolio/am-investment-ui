import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../internal/domain/entities/metrics/metrics_filter_request.dart';
import '../../../internal/domain/entities/metrics_filter_config.dart';
import '../../../internal/domain/entities/filter_criteria.dart';
import '../../../providers/trade_report_providers.dart';
import '../../metrics/widgets/glossy_card.dart';
import '../cubit/trade_report_cubit.dart';
import '../cubit/trade_report_state.dart';

class TradeReportPage extends ConsumerStatefulWidget {
  final String userId;
  final String? portfolioId;

  const TradeReportPage({
    required this.userId,
    this.portfolioId,
    super.key,
  });

  @override
  ConsumerState<TradeReportPage> createState() => _TradeReportPageState();
}

class _TradeReportPageState extends ConsumerState<TradeReportPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  MetricsFilterConfig _currentConfig = MetricsFilterConfig.empty();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _currentConfig = MetricsFilterConfig(
      dateRange: DateRangeFilter(
        startDate: DateTime(DateTime.now().year, 1, 1),
        endDate: DateTime.now(),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyFilter(_currentConfig);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _applyFilter(MetricsFilterConfig config) {
    setState(() {
      _currentConfig = config;
    });

    final request = MetricsFilterRequest(
      portfolioIds: widget.portfolioId != null ? [widget.portfolioId!] : [],
      startDate: config.dateRange?.startDate ?? DateTime(DateTime.now().year, 1, 1),
      endDate: config.dateRange?.endDate ?? DateTime.now(),
    );

    ref.read(tradeReportCubitProvider).loadReport(request);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = ref.watch(tradeReportCubitProvider);

    return Scaffold(
      backgroundColor: Colors.transparent, // Let background show through
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeader(context),
            const SizedBox(height: 24),

            // Tab Bar
            _buildTabBar(context),
            const SizedBox(height: 24),

            // Main Content Area
            Builder(
              builder: (context) {
                if (cubit.state is TradeReportLoading) {
                  return const SizedBox(height: 400, child: Center(child: CircularProgressIndicator()));
                } else if (cubit.state is TradeReportError) {
                  return Center(child: Text('Error: ${(cubit.state as TradeReportError).message}', style: const TextStyle(color: Colors.red)));
                } else if (cubit.state is TradeReportLoaded) {
                  final state = cubit.state as TradeReportLoaded;
                  return _buildPerformanceTab(state);
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Reports',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ).animate().fadeIn().slideX(begin: -0.2),

        // Filters Row
        Row(
          children: [
            // Currency Selector (Mock)
            _buildFilterChip(context, 'USD', Icons.attach_money),
            const SizedBox(width: 12),

             // Date Range Picker Display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    '${dateFormat.format(_currentConfig.dateRange?.startDate ?? DateTime.now())} - ${dateFormat.format(_currentConfig.dateRange?.endDate ?? DateTime.now())}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                        // TODO: Open date picker properly
                        _applyFilter(MetricsFilterConfig.empty()); // Reset for valid mock feel
                    },
                    child: Icon(Icons.close, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                  ),
                ],
              ),
            ),
             const SizedBox(width: 12),
            _buildFilterChip(context, 'My Trades', Icons.person_outline),
          ],
        ).animate().fadeIn().slideX(begin: 0.2),
      ],
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, IconData icon) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.7)),
          const SizedBox(width: 8),
          Text(label, style: theme.textTheme.bodyMedium),
          const SizedBox(width: 4),
          Icon(Icons.arrow_drop_down, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.5)),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.2))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: const Color(0xFF6C5DD3), // Primary color
              unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              indicatorColor: const Color(0xFF6C5DD3),
              indicatorWeight: 3,
              labelPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              tabs: const [
                Text('Performance'),
                Text('Overview'),
                Text('Reports'),
                Text('Compare'),
                Text('Calendar'),
              ],
            ),
          ),
           ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download, size: 16),
            label: const Text('Export PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              elevation: 0,
              side: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildPerformanceTab(TradeReportLoaded state) {
    return Column(
      children: [
        // Charts Row
        SizedBox(
          height: 350,
          child: Row(
            children: [
              Expanded(child: _buildChartCard('Avg daily win %', state.timingAnalysis.yearlyPerformance)), // Using yearly as dummy source for chart
              const SizedBox(width: 24),
              Expanded(child: _buildChartCard('Avg hold time', state.timingAnalysis.hourlyPerformance, isBar: true)),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Key Stats Row
        SizedBox( // Ensure height constraint for stats
            height: 120,
            child: Row(
            children: [
                Expanded(child: _buildStatCard('Avg daily win %', '${(state.summary.winPercentage * 100).toStringAsFixed(1)}%', '(${state.summary.winningTrades}/${state.summary.totalTrades})', Icons.pie_chart, Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Avg daily win/loss', state.summary.profitFactor.toStringAsFixed(2), '', Icons.incomplete_circle, Colors.orange)),
                 const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Largest profit', '\$${state.summary.largestWin.toStringAsFixed(0)}', '', Icons.arrow_upward, Colors.green)),
                 const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Total P&L', '\$${state.summary.totalProfitLoss.toStringAsFixed(0)}', '', Icons.attach_money, state.summary.totalProfitLoss >= 0 ? Colors.green : Colors.red)),
            ],
            ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildChartCard(String title, dynamic data, {bool isBar = false}) {
    return GlossyCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                   children: [
                       Icon(Icons.bar_chart, size: 20, color: Theme.of(context).colorScheme.primary),
                       const SizedBox(width: 8),
                       Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                   ]
                ),
                 Container(
                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                     decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(8),
                         border: Border.all(color: Colors.white24),
                     ),
                     child: const Row(children: [Text('Day', style: TextStyle(fontSize: 12)), Icon(Icons.arrow_drop_down, size: 14)]),
                 ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: isBar 
                  ? BarChart(
                      BarChartData(
                        gridData: const FlGridData(show: true, drawVerticalLine: false),
                        titlesData: const FlTitlesData(
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: [
                           for(int i=0; i<7; i++)
                            BarChartGroupData(
                                x: i,
                                barRods: [BarChartRodData(toY: (i*10 + 20).toDouble(), color: i.isEven ? const Color(0xFF6C5DD3) : Colors.orange, width: 8, borderRadius: BorderRadius.circular(4))]
                            ),
                        ],
                      ),
                    )
                  : LineChart(
                      LineChartData(
                         gridData: const FlGridData(show: true, drawVerticalLine: false),
                         titlesData: const FlTitlesData(
                             rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                             topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                         ),
                         borderData: FlBorderData(show: false),
                         lineBarsData: [
                            LineChartBarData(
                                spots: const [FlSpot(0, 1), FlSpot(1, 1.5), FlSpot(2, 1.4), FlSpot(3, 3.4), FlSpot(4, 2), FlSpot(5, 2.2), FlSpot(6, 1.8)],
                                isCurved: true,
                                color: const Color(0xFF6C5DD3),
                                barWidth: 3,
                                dotData: const FlDotData(show: true),
                                belowBarData: BarAreaData(show: true, color: const Color(0xFF6C5DD3).withOpacity(0.1)),
                            ),
                             LineChartBarData(
                                spots: const [FlSpot(0, 0), FlSpot(1, 0), FlSpot(2, 0), FlSpot(3, 0), FlSpot(4, 0), FlSpot(5, 0), FlSpot(6, 0)],
                                isCurved: false,
                                color: Colors.orange,
                                barWidth: 2,
                                dotData: const FlDotData(show: true),
                            ),
                         ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon, Color color) {
    return GlossyCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
           Text(title, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 13)),
           Row(
               crossAxisAlignment: CrossAxisAlignment.end,
               children: [
                   Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
                   if (subtitle.isNotEmpty) ...[
                       const SizedBox(width: 8),
                       Padding(
                         padding: const EdgeInsets.only(bottom: 4),
                         child: Text(subtitle, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
                       ),
                   ]
               ],
           ),
        ],
      ),
    );
  }
}

