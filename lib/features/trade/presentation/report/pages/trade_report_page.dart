import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../internal/domain/entities/metrics/metrics_filter_request.dart';
import '../../../internal/domain/entities/metrics_filter_config.dart';
import '../../../internal/domain/entities/filter_criteria.dart';
import '../../../providers/trade_report_providers.dart';
import '../../metrics/widgets/glossy_card.dart';
import '../../metrics/widgets/trade_metrics_filter_panel.dart';
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

class _TradeReportPageState extends ConsumerState<TradeReportPage> {
  MetricsFilterConfig _currentConfig = MetricsFilterConfig.empty();

  @override
  void initState() {
    super.initState();
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Trade Performance Report'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.9),
                Colors.transparent,
              ],
            ),
          ),
        ),
        elevation: 0,
      ),
      body: Container(
         decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.2),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16.0, kToolbarHeight + 16, 16.0, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TradeMetricsFilterPanel(
                userId: widget.userId,
                initialConfig: _currentConfig,
                onApplyFilter: _applyFilter,
                onReset: () => _applyFilter(MetricsFilterConfig.empty()),
                availableMetricTypes: const [],
              ).animate().fade().slideY(begin: -0.1),
              
              const SizedBox(height: 24),

              Builder(
                builder: (context) {
                  if (cubit.state is TradeReportLoading) {
                    return const SizedBox(height: 400, child: Center(child: CircularProgressIndicator()));
                  } else if (cubit.state is TradeReportError) {
                    return Center(child: Text('Error: ${(cubit.state as TradeReportError).message}'));
                  } else if (cubit.state is TradeReportLoaded) {
                    final state = cubit.state as TradeReportLoaded;
                    return _buildDashboard(state);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(TradeReportLoaded state) {
    return Column(
      children: [
        _buildSummarySection(state.summary),
        const SizedBox(height: 24),
        _buildDailySection(state.dailyPerformance),
        const SizedBox(height: 24),
        _buildTimingSection(state.timingAnalysis),
      ],
    );
  }

  Widget _buildSummarySection(dynamic summary) {
    // summary is TradePerformanceSummary
    return GlossyCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Performance Summary', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              _buildStatDetail('Net P&L', '\$${summary.totalProfitLoss.toStringAsFixed(2)}', Colors.green),
              _buildStatDetail('Win Rate', '${(summary.winPercentage * 100).toStringAsFixed(1)}%', Colors.blue),
              _buildStatDetail('Prof. Factor', summary.profitFactor.toStringAsFixed(2), Colors.purple),
              _buildStatDetail('Max DD', '\$${summary.maxDrawdown.toStringAsFixed(2)}', Colors.red),
              _buildStatDetail('Total Trades', '${summary.totalTrades}', Colors.orange),
              _buildStatDetail('Avg Hold (Win)', '${summary.averageHoldingTimeWin.toStringAsFixed(1)} hrs', Colors.teal),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideX();
  }

  Widget _buildStatDetail(String label, String value, Color color) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildDailySection(dynamic dailyList) {
    return GlossyCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Daily Performance', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          // Simple list or chart placeholder
          SizedBox(
            height: 200,
            child: ListView.separated(
              itemCount: (dailyList as List).length > 5 ? 5 : (dailyList as List).length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final day = dailyList[index];
                return ListTile(
                  title: Text(day.date.toString().split(' ')[0]),
                  trailing: Text(
                    '\$${day.totalProfitLoss.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: day.totalProfitLoss >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text('${day.tradeCount} trades'),
                );
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideX();
  }

  Widget _buildTimingSection(dynamic timing) {
    return GlossyCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Timing Analysis', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildTimingBox('Best Hour', '${timing.bestTradingHour ?? "-"}', Icons.access_time),
              const SizedBox(width: 16),
              _buildTimingBox('Best Day', timing.bestTradingDay ?? "-", Icons.calendar_today),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideX();
  }

  Widget _buildTimingBox(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.white70),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.white54)),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
