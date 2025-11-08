import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../internal/domain/entities/trade_calendar.dart';

/// Comprehensive trade detail dialog showing all trade information
class TradeDetailDialog extends StatelessWidget {
  const TradeDetailDialog({required this.trade, super.key});

  final TradeDetail trade;

  @override
  Widget build(BuildContext context) => Dialog(
    child: Container(
      width: MediaQuery.of(context).size.width * 0.8,
      constraints: const BoxConstraints(maxWidth: 1200),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          const Divider(height: 1),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTradeOverview(context),
                  const SizedBox(height: 24),
                  _buildMetricsSection(context),
                  const SizedBox(height: 24),
                  _buildEntryExitSection(context),
                  const SizedBox(height: 24),
                  _buildExecutionsTimeline(context),
                  if (trade.psychologyData.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildPsychologySection(context),
                  ],
                  if (trade.entryReasoning.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildReasoningSection(context, 'Entry Reasoning', trade.entryReasoning),
                  ],
                  if (trade.exitReasoning.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildReasoningSection(context, 'Exit Reasoning', trade.exitReasoning),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final isProfitable = trade.isProfitable;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
      ),
      child: Row(
        children: [
          // Trade status icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isProfitable ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isProfitable ? Icons.trending_up : Icons.trending_down,
              color: isProfitable ? Colors.green : Colors.red,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),

          // Symbol and basic info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trade.instrumentInfo.symbol,
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  trade.instrumentInfo.formattedDescription,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildChip(context, trade.tradePositionType.name.toUpperCase(), theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    _buildChip(context, trade.status.name.toUpperCase(), _getStatusColor(trade.status)),
                  ],
                ),
              ],
            ),
          ),

          // P&L
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency(trade.metrics.profitLoss),
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: isProfitable ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${trade.metrics.profitLossPercentage.toStringAsFixed(2)}%',
                style: theme.textTheme.titleMedium?.copyWith(color: isProfitable ? Colors.green : Colors.red),
              ),
            ],
          ),

          const SizedBox(width: 16),
          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }

  Widget _buildTradeOverview(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trade Overview', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildInfoRow(context, 'Trade ID', trade.tradeId)),
                Expanded(child: _buildInfoRow(context, 'Portfolio ID', trade.portfolioId)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildInfoRow(context, 'Exchange', trade.instrumentInfo.exchange)),
                Expanded(child: _buildInfoRow(context, 'Segment', trade.instrumentInfo.segment)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildInfoRow(context, 'ISIN', trade.instrumentInfo.isin)),
                Expanded(child: _buildInfoRow(context, 'Holding Time', trade.tradeDurationString)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsSection(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Performance Metrics', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Profit/Loss',
                    _formatCurrency(trade.metrics.profitLoss),
                    Icons.attach_money,
                    trade.isProfitable ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'P&L %',
                    '${trade.metrics.profitLossPercentage.toStringAsFixed(2)}%',
                    Icons.percent,
                    trade.isProfitable ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'ROE',
                    '${trade.metrics.returnOnEquity.toStringAsFixed(2)}%',
                    Icons.trending_up,
                    theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Risk Amount',
                    _formatCurrency(trade.metrics.riskAmount),
                    Icons.warning,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Reward Amount',
                    _formatCurrency(trade.metrics.rewardAmount),
                    Icons.stars,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Risk:Reward',
                    '1:${trade.metrics.riskRewardRatio.toStringAsFixed(2)}',
                    Icons.balance,
                    theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryExitSection(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Entry & Exit Details', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildPositionInfo(context, 'Entry', trade.entryInfo, Colors.blue)),
                const SizedBox(width: 24),
                Expanded(child: _buildPositionInfo(context, 'Exit', trade.exitInfo, Colors.orange)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionInfo(BuildContext context, String label, TradePositionInfo info, Color color) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(label == 'Entry' ? Icons.login : Icons.logout, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                '$label Information',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(context, 'Time', _formatDateTime(info.timestamp)),
          const SizedBox(height: 8),
          _buildInfoRow(context, 'Price', '₹${info.price.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildInfoRow(context, 'Quantity', '${info.quantity}'),
          const SizedBox(height: 8),
          _buildInfoRow(context, 'Total Value', _formatCurrency(info.totalValue)),
          const SizedBox(height: 8),
          _buildInfoRow(context, 'Fees', '₹${info.fees.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  Widget _buildExecutionsTimeline(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Execution Timeline', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...trade.tradeExecutions.asMap().entries.map((entry) {
              final index = entry.key;
              final execution = entry.value;
              final isLast = index == trade.tradeExecutions.length - 1;

              return _buildExecutionItem(context, execution, isLast);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildExecutionItem(BuildContext context, TradeExecution execution, bool isLast) {
    final theme = Theme.of(context);
    final isBuy = execution.executionInfo.tradeType.toUpperCase() == 'BUY';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isBuy ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: isBuy ? Colors.green : Colors.red, width: 2),
                ),
                child: Icon(
                  isBuy ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isBuy ? Colors.green : Colors.red,
                  size: 20,
                ),
              ),
              if (!isLast) Container(width: 2, height: 40, color: theme.dividerColor),
            ],
          ),
          const SizedBox(width: 16),

          // Execution details
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        execution.executionInfo.tradeType.toUpperCase(),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isBuy ? Colors.green : Colors.red,
                        ),
                      ),
                      Text(_formatDateTime(execution.basicInfo.orderExecutionTime), style: theme.textTheme.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _buildInfoRow(context, 'Order ID', execution.basicInfo.orderId)),
                      Expanded(child: _buildInfoRow(context, 'Broker', execution.basicInfo.brokerType)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(child: _buildInfoRow(context, 'Quantity', '${execution.executionInfo.quantity}')),
                      Expanded(
                        child: _buildInfoRow(context, 'Price', '₹${execution.executionInfo.price.toStringAsFixed(2)}'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _buildInfoRow(
                    context,
                    'Total',
                    _formatCurrency(execution.executionInfo.quantity * execution.executionInfo.price),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPsychologySection(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Psychology Data', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ...trade.psychologyData.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _buildInfoRow(context, entry.key, entry.value.toString()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasoningSection(BuildContext context, String title, Map<String, dynamic> data) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ...data.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _buildInfoRow(context, entry.key, entry.value.toString()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(color: color, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        Flexible(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildChip(BuildContext context, String label, Color color) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getStatusColor(TradeStatus status) => switch (status) {
    TradeStatus.win => Colors.green,
    TradeStatus.loss => Colors.red,
    TradeStatus.breakEven => Colors.grey,
  };

  String _formatCurrency(double value) {
    final abs = value.abs();
    final sign = value >= 0 ? '+' : '-';
    return '$sign₹${abs.toStringAsFixed(2)}';
  }

  String _formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('dd MMM yyyy, HH:mm:ss');
    return formatter.format(dateTime);
  }
}
