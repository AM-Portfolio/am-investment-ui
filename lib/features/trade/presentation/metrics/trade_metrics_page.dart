import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'cubit/trade_metrics_cubit.dart';
import 'cubit/trade_metrics_state.dart';
import 'widgets/trade_metrics_filter_panel.dart';
import '../../providers/trade_metrics_providers.dart';
import '../../internal/domain/entities/metrics_filter_config.dart';
import '../../internal/domain/entities/filter_criteria.dart';
import '../../internal/domain/entities/metrics/metrics_filter_request.dart';
import '../../internal/domain/entities/metrics/performance_metrics.dart';
import '../../internal/domain/entities/metrics/risk_metrics.dart';
import '../../internal/domain/entities/metrics/trade_distribution_metrics.dart';
import '../../internal/domain/entities/metrics/trade_metrics_response.dart';
import '../../internal/domain/enums/metric_types.dart';

class TradeMetricsPage extends ConsumerStatefulWidget {
  final String userId;
  final String? portfolioId;

  const TradeMetricsPage({
    required this.userId,
    this.portfolioId,
    super.key,
  });

  @override
  ConsumerState<TradeMetricsPage> createState() => _TradeMetricsPageState();
}

class _TradeMetricsPageState extends ConsumerState<TradeMetricsPage> {
  MetricsFilterConfig _currentConfig = MetricsFilterConfig.empty();

  @override
  void initState() {
    super.initState();

    // Initialize with default date range (1919-01-01) for MetricsFilterConfig if needed,
    // but the initial load uses MetricsFilterRequest which sets it.
    // Here we sync the config state.
    _currentConfig = MetricsFilterConfig(
      dateRange: DateRangeFilter(
        startDate: DateTime(1919, 1, 1),
        endDate: DateTime.now(),
      ),
    );
    
    // Load initial metrics after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialMetrics();
    });
  }

  void _loadInitialMetrics() async {
    // First, trigger the cubit to load metrics
    // The cubit will fetch metric types internally and use them
    _applyFilter(_currentConfig);
  }

  void _applyFilter(MetricsFilterConfig config) async {
    setState(() {
      _currentConfig = config;
    });

    // If no metric types are selected, fetch all available types and use them
    List<MetricTypes>? metricTypesToUse = config.metricTypes;
    
    if (config.metricTypes.isEmpty) {
      try {
        // Fetch available metric types if not already loaded
        final getMetricTypes = ref.read(getMetricTypesUseCaseProvider);
        final availableTypes = await getMetricTypes();
        metricTypesToUse = availableTypes;
      } catch (e) {
        // If fetching fails, pass null (backend will use defaults)
        metricTypesToUse = null;
      }
    }

    final request = MetricsFilterRequest(
      portfolioIds: widget.portfolioId != null ? [widget.portfolioId!] : [],
      startDate: config.dateRange?.startDate ?? DateTime(1919, 1, 1),
      endDate: config.dateRange?.endDate ?? DateTime.now(),
      timePeriod: null,
      metricTypes: metricTypesToUse,
      // Map other config fields to request if needed
      instruments: config.instrumentFilters?.baseSymbols,
    );
    
    ref.read(tradeMetricsCubitProvider).loadMetrics(request);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = ref.watch(tradeMetricsCubitProvider);
    
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Filter Panel
            TradeMetricsFilterPanel(
              userId: widget.userId,
              initialConfig: _currentConfig,
              onApplyFilter: _applyFilter,
              onReset: () => _applyFilter(MetricsFilterConfig.empty()),
              availableMetricTypes: (cubit.state is TradeMetricsLoaded) 
                    ? (cubit.state as TradeMetricsLoaded).availableMetricTypes 
                    : [],
            ),
            
            const SizedBox(height: 16),

            // Content Area
            Builder(
              builder: (context) {
                final state = cubit.state;
                  
                  if (state is TradeMetricsLoading) {
                    return const SizedBox(
                      height: 400,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (state is TradeMetricsError) {
                    return SizedBox(
                      height: 400,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
                            const SizedBox(height: 16),
                            Text('Error loading metrics', style: Theme.of(context).textTheme.titleMedium),
                            Text(state.message, style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: () => _applyFilter(_currentConfig),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (state is TradeMetricsLoaded) {
                    return _buildDashboard(state.metrics);
                  }
                  return const SizedBox(height: 400, child: Center(child: Text('Initialize metrics to view data')));
                },
              ),
            ],
          ),
        ),
      );
    }

  Widget _buildDashboard(TradeMetricsResponse metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Cards Row
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;
            return Flex(
              direction: isWide ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: isWide ? 1 : 0, child: _buildPerformanceCard(metrics.performanceMetrics)),
                if (isWide) const SizedBox(width: 16) else const SizedBox(height: 16),
                Expanded(flex: isWide ? 1 : 0, child: _buildRiskCard(metrics.riskMetrics)),
              ],
            );
          },
        ),
        
        const SizedBox(height: 24),
        
        // Distribution Section
        Text('Distribution Analysis', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildDistributionPlaceholder(metrics.distributionMetrics),
        
        const SizedBox(height: 24),
        
        // Trades Count
        _buildMetricTile(
          title: 'Total Trades Analyzed',
          value: metrics.totalTradesCount.toString(),
          icon: Icons.receipt_long,
          color: Colors.blueAccent,
        ),
      ],
    );
  }

  Widget _buildPerformanceCard(PerformanceMetrics metrics) {
    return _buildGlassCard(
      title: 'Performance',
      icon: Icons.trending_up,
      color: Colors.green,
      child: Column(
        children: [
          _buildMetricRow('Net P&L', metrics.totalProfitLoss.toStringAsFixed(2), isCurrency: true, 
              valueColor: metrics.totalProfitLoss >= 0 ? Colors.green : Colors.red, isBold: true),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(child: _buildCompactMetric('Win Rate', '${(metrics.winRate * 100).toStringAsFixed(1)}%')),
              Expanded(child: _buildCompactMetric('Profit Factor', metrics.profitFactor.toStringAsFixed(2))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildCompactMetric('Avg Win', '\$${metrics.averageWinningTrade.toStringAsFixed(0)}', color: Colors.green)),
              Expanded(child: _buildCompactMetric('Avg Loss', '\$${metrics.averageLosingTrade.toStringAsFixed(0)}', color: Colors.red)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRiskCard(RiskMetrics metrics) {
    return _buildGlassCard(
      title: 'Risk Profile',
      icon: Icons.shield_outlined,
      color: Colors.orange,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildCompactMetric('Max Drawdown', '${metrics.maxDrawdown.toStringAsFixed(2)}%', color: Colors.red)),
              Expanded(child: _buildCompactMetric('Sharpe Ratio', metrics.sharpeRatio.toStringAsFixed(2))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildCompactMetric('Sortino Ratio', metrics.sortinoRatio.toStringAsFixed(2))),
              Expanded(child: _buildCompactMetric('Prob. Ruin', '${(metrics.probabilityOfRuin * 100).toStringAsFixed(2)}%')),
            ],
          ),
          const SizedBox(height: 16),
          _buildMetricRow('Value At Risk (VaR)', metrics.valueAtRisk.toStringAsFixed(2), isCurrency: true),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required String title, required IconData icon, required Color color, required Widget child}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildCompactMetric(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor)),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildDistributionPlaceholder(dynamic distribution) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart_rounded, size: 64, color: Theme.of(context).disabledColor),
            const SizedBox(height: 16),
            Text(
              'Interactive Charts Coming Soon',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).hintColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodySmall),
              Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, {bool isCurrency = false, Color? valueColor, bool isBold = false}) {
    final style = isBold 
      ? Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: valueColor)
      : Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: valueColor);
      
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(isCurrency ? '\$$value' : value, style: style),
      ],
    );
  }
}
