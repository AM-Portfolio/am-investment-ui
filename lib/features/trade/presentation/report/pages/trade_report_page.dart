import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../internal/domain/entities/metrics/metrics_filter_request.dart';
import '../../../internal/domain/entities/metrics_filter_config.dart';
import '../../../internal/domain/entities/filter_criteria.dart';
import '../../../providers/trade_report_providers.dart';
import '../../metrics/widgets/glossy_card.dart';
import '../widgets/dynamic_chart_card.dart';
import '../models/chart_config.dart';
import '../cubit/trade_report_cubit.dart';
import '../cubit/trade_report_cubit.dart';
import '../cubit/trade_report_state.dart';
import '../../../../../../shared/core/ui/components/trade/compact_date_range_picker.dart';

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

// ... (imports)

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
  
  ChartTimeFrame _getAutoTimeFrame() {
      final start = _currentConfig.dateRange?.startDate ?? DateTime(DateTime.now().year, 1, 1);
      final end = _currentConfig.dateRange?.endDate ?? DateTime.now();
      final diff = end.difference(start).inDays;
      
      if (diff <= 35) return ChartTimeFrame.dailyLinear; // ~1 month -> Daily
      if (diff <= 100) return ChartTimeFrame.weeklyLinear; // 1-3 months -> Weekly
      return ChartTimeFrame.monthlyLinear; // >3 months -> Monthly
  }

  Future<void> _showDatePicker(BuildContext context) async {
      final picked = await showDialog<DateTimeRange>(
          context: context,
          builder: (context) => CompactDateRangePickerDialog(
            initialDateRange: _currentConfig.dateRange != null 
                ? DateTimeRange(start: _currentConfig.dateRange!.startDate, end: _currentConfig.dateRange!.endDate)
                : null,
          ),
      );
      
      if (picked != null) {
          _applyFilter(MetricsFilterConfig(
              dateRange: DateRangeFilter(startDate: picked.start, endDate: picked.end)
          ));
      }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = ref.watch(tradeReportCubitProvider);

    return Scaffold(
      backgroundColor: Colors.transparent, 
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
            BlocBuilder<TradeReportCubit, TradeReportState>(
              bloc: cubit,
              builder: (context, state) {
                if (state is TradeReportLoading) {
                  return const SizedBox(height: 400, child: Center(child: CircularProgressIndicator()));
                } else if (state is TradeReportError) {
                  return Center(child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)));
                } else if (state is TradeReportLoaded) {
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
        // ... (Title Text)
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
             // ... (Currency Chip)
            _buildFilterChip(context, 'USD', Icons.attach_money),
            const SizedBox(width: 12),

             // Date Range Picker Display
            GestureDetector(
                onTap: () => _showDatePicker(context),
                child: Container(
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
                      Icon(Icons.arrow_drop_down, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                    ],
                  ),
                ),
            ),
             const SizedBox(width: 12),
            _buildFilterChip(context, 'My Trades', Icons.person_outline),
          ],
        ).animate().fadeIn().slideX(begin: 0.2),
      ],
    );
  }

  // ... (keep _buildFilterChip and _buildTabBar)

  Widget _buildPerformanceTab(TradeReportLoaded state) {
    // Determine default timeframe based on date range
    final autoTimeFrame = _getAutoTimeFrame();

    return Column(
      children: [
        // Charts Row
        SizedBox(
          height: 380, 
          child: Row(
            children: [
              Expanded(
                child: DynamicChartCard(
                  key: ValueKey('chart1_$autoTimeFrame'), // Force rebuild on duration change
                  title: 'Chart 1',
                  timingAnalysis: state.timingAnalysis,
                  dailyPerformance: state.dailyPerformance,
                  initialMetric: ChartMetric.winRate,
                  initialTimeFrame: autoTimeFrame,
                )
              ),
              const SizedBox(width: 24),
              Expanded(
                child: DynamicChartCard(
                  key: ValueKey('chart2_$autoTimeFrame'),
                  title: 'Chart 2',
                  timingAnalysis: state.timingAnalysis,
                  dailyPerformance: state.dailyPerformance,
                  initialMetric: ChartMetric.holdTime,
                  initialTimeFrame: autoTimeFrame,
                  isBarChart: true,
                )
              ),
            ],
          ),
        ),
        // ... (Key Stats Row)
        const SizedBox(height: 24),
        SizedBox( // Ensure height constraint for stats
            height: 120,
            child: Row(
            children: [
                Expanded(child: _buildStatCard('Avg daily win %', '${((state.summary.winPercentage > 1 ? state.summary.winPercentage : state.summary.winPercentage * 100)).toStringAsFixed(1)}%', '(${state.summary.winningTrades}/${state.summary.totalTrades})', Icons.pie_chart, Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Avg daily win/loss', (state.summary.profitFactor.isInfinite || state.summary.profitFactor.isNaN) ? 'N/A' : state.summary.profitFactor.toStringAsFixed(2), '', Icons.incomplete_circle, Colors.orange)),
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
