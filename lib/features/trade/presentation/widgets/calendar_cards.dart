import 'package:flutter/material.dart';

import '../../internal/domain/entities/trade_calendar.dart' as domain;
import '../models/calendar_view_models.dart';
import 'trade_detail_dialog.dart';

/// Card displaying year-level trade statistics
class YearCard extends StatelessWidget {
  const YearCard({required this.yearData, required this.onTap, super.key, this.isSelected = false});
  final YearlyCalendarData yearData;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isProfitable = yearData.isProfitable;

    return Card(
      elevation: isSelected ? 8 : 2,
      color: isSelected ? theme.colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Year header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${yearData.year}', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  Icon(
                    isProfitable ? Icons.trending_up : Icons.trending_down,
                    color: isProfitable ? Colors.green : Colors.red,
                    size: 28,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // P&L
              _buildMetricRow(
                context,
                'Total P&L',
                _formatCurrency(yearData.totalPnL),
                isProfitable ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 8),

              // Trades
              _buildMetricRow(context, 'Trades', '${yearData.totalTrades}', theme.colorScheme.onSurface),
              const SizedBox(height: 8),

              // Win Rate
              _buildMetricRow(
                context,
                'Win Rate',
                '${yearData.winRate.toStringAsFixed(1)}%',
                yearData.winRate >= 50 ? Colors.green : Colors.orange,
              ),
              const SizedBox(height: 8),

              // Active Months
              _buildMetricRow(context, 'Active Months', '${yearData.activeMonths}/12', theme.colorScheme.onSurface),
              const SizedBox(height: 16),

              // Progress indicator
              LinearProgressIndicator(
                value: yearData.activeMonths / 12,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(isProfitable ? Colors.green : Colors.orange),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricRow(BuildContext context, String label, String value, Color valueColor) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      Text(
        value,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: valueColor, fontWeight: FontWeight.w600),
      ),
    ],
  );

  String _formatCurrency(double value) {
    final abs = value.abs();
    final sign = value >= 0 ? '+' : '-';
    if (abs >= 1000000) {
      return '$sign\$${(abs / 1000000).toStringAsFixed(2)}M';
    } else if (abs >= 1000) {
      return '$sign\$${(abs / 1000).toStringAsFixed(2)}K';
    }
    return '$sign\$${abs.toStringAsFixed(2)}';
  }
}

/// Card displaying month-level trade statistics
class MonthCard extends StatelessWidget {
  const MonthCard({
    required this.monthData,
    required this.onTap,
    super.key,
    this.isSelected = false,
    this.isCurrentMonth = false,
  });
  final MonthSummary monthData;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isCurrentMonth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isProfitable = monthData.isProfitable;
    final hasData = monthData.totalTrades > 0;

    return Card(
      elevation: isSelected ? 8 : (isCurrentMonth ? 4 : 2),
      color: isSelected
          ? theme.colorScheme.primaryContainer
          : (isCurrentMonth ? theme.colorScheme.secondaryContainer : null),
      child: InkWell(
        onTap: hasData ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      monthData.monthName,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (hasData)
                    Icon(
                      isProfitable ? Icons.arrow_upward : Icons.arrow_downward,
                      color: isProfitable ? Colors.green : Colors.red,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 12),

              if (hasData) ...[
                // P&L
                Text(
                  _formatCurrency(monthData.totalPnL),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: isProfitable ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStat(context, 'Trades', '${monthData.totalTrades}'),
                    _buildStat(context, 'Win', '${monthData.winRate.toStringAsFixed(0)}%'),
                    _buildStat(context, 'Days', '${monthData.tradingDays}'),
                  ],
                ),
              ] else ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      'No trades',
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
    ],
  );

  String _formatCurrency(double value) {
    final abs = value.abs();
    final sign = value >= 0 ? '+' : '-';
    if (abs >= 1000000) {
      return '$sign\$${(abs / 1000000).toStringAsFixed(2)}M';
    } else if (abs >= 1000) {
      return '$sign\$${(abs / 1000).toStringAsFixed(1)}K';
    }
    return '$sign\$${abs.toStringAsFixed(0)}';
  }
}

/// Card displaying day-level trade statistics
class DayCard extends StatelessWidget {
  const DayCard({
    required this.dayData,
    super.key,
    this.onTap,
    this.isSelected = false,
    this.isToday = false,
    this.isCurrentMonth = true,
  });
  final DaySummary dayData;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isToday;
  final bool isCurrentMonth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isProfitable = dayData.isProfitable;
    final hasData = dayData.totalTrades > 0;

    Color? backgroundColor;
    if (isSelected) {
      backgroundColor = theme.colorScheme.primaryContainer;
    } else if (isToday) {
      backgroundColor = theme.colorScheme.tertiaryContainer;
    } else if (!isCurrentMonth) {
      backgroundColor = theme.colorScheme.surfaceContainerHighest.withOpacity(0.3);
    }

    return Card(
      elevation: isSelected ? 6 : (isToday ? 3 : 1),
      color: backgroundColor,
      child: InkWell(
        onTap: hasData ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Day number
              Text(
                '${dayData.day}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: isCurrentMonth ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
                ),
              ),

              if (hasData) ...[
                const SizedBox(height: 4),

                // P&L indicator
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isProfitable ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 4),

                // Trades count
                Text(
                  '${dayData.totalTrades}',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact trade detail card for daily view
class TradeDetailCard extends StatelessWidget {
  const TradeDetailCard({required this.trade, super.key, this.onTap});

  final domain.TradeDetail trade;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWin = trade.isProfitable;

    return Card(
      child: InkWell(
        onTap: onTap ?? () => _showTradeDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Symbol and type
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trade.instrumentInfo.symbol,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      trade.tradePositionType.name.toUpperCase(),
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),

              // Quantity
              Expanded(
                child: Text(
                  '${trade.entryInfo.quantity}',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),

              // P&L
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatCurrency(trade.metrics.profitLoss),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: isWin ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${trade.metrics.profitLossPercentage.toStringAsFixed(2)}%',
                      style: theme.textTheme.bodySmall?.copyWith(color: isWin ? Colors.green : Colors.red),
                    ),
                  ],
                ),
              ),

              // Status icon
              const SizedBox(width: 8),
              Icon(isWin ? Icons.check_circle : Icons.cancel, color: isWin ? Colors.green : Colors.red, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showTradeDetails(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => TradeDetailDialog(trade: trade),
    );
  }

  String _formatCurrency(double value) {
    final abs = value.abs();
    final sign = value >= 0 ? '+' : '-';
    return '$sign₹${abs.toStringAsFixed(2)}';
  }
}
