import 'package:flutter/material.dart';

import '../models/calendar_view_models.dart';
import '../widgets/calendar_cards.dart';

/// Yearly calendar view showing all months
class YearlyCalendarView extends StatelessWidget {
  const YearlyCalendarView({
    required this.yearData,
    required this.onMonthTap,
    super.key,
    this.onPreviousYear,
    this.onNextYear,
  });
  final YearlyCalendarData yearData;
  final Function(int month) onMonthTap;
  final VoidCallback? onPreviousYear;
  final VoidCallback? onNextYear;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Year navigation and summary
        _buildYearHeader(context, now),
        const SizedBox(height: 24),

        // Year summary card
        _buildYearSummary(context),
        const SizedBox(height: 24),

        // Months grid
        Expanded(child: _buildMonthsGrid(context, now)),
      ],
    );
  }

  Widget _buildYearHeader(BuildContext context, DateTime now) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('${yearData.year}', style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold)),
        Row(
          children: [
            IconButton(icon: const Icon(Icons.chevron_left), onPressed: onPreviousYear, tooltip: 'Previous year'),
            IconButton(icon: const Icon(Icons.chevron_right), onPressed: onNextYear, tooltip: 'Next year'),
          ],
        ),
      ],
    );
  }

  Widget _buildYearSummary(BuildContext context) {
    final theme = Theme.of(context);
    final isProfitable = yearData.isProfitable;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Year Summary', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildSummaryMetric(
                    context,
                    'Total P&L',
                    _formatCurrency(yearData.totalPnL),
                    isProfitable ? Colors.green : Colors.red,
                    isProfitable ? Icons.trending_up : Icons.trending_down,
                  ),
                ),
                Expanded(
                  child: _buildSummaryMetric(
                    context,
                    'Total Trades',
                    '${yearData.totalTrades}',
                    theme.colorScheme.primary,
                    Icons.show_chart,
                  ),
                ),
                Expanded(
                  child: _buildSummaryMetric(
                    context,
                    'Win Rate',
                    '${yearData.winRate.toStringAsFixed(1)}%',
                    yearData.winRate >= 50 ? Colors.green : Colors.orange,
                    Icons.percent,
                  ),
                ),
                Expanded(
                  child: _buildSummaryMetric(
                    context,
                    'Active Months',
                    '${yearData.activeMonths}/12',
                    theme.colorScheme.secondary,
                    Icons.calendar_month,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryMetric(BuildContext context, String label, String value, Color color, IconData icon) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMonthsGrid(BuildContext context, DateTime now) => GridView.builder(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
    ),
    itemCount: 12,
    itemBuilder: (context, index) {
      final month = index + 1;
      final monthData = yearData.months[index];
      final isCurrentMonth = now.year == yearData.year && now.month == month;

      return MonthCard(monthData: monthData, onTap: () => onMonthTap(month), isCurrentMonth: isCurrentMonth);
    },
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

/// Monthly calendar view showing all days
class MonthlyCalendarView extends StatelessWidget {
  const MonthlyCalendarView({required this.monthData, required this.onDayTap, super.key, this.onBack});
  final MonthlyCalendarData monthData;
  final Function(int day) onDayTap;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month header
        _buildMonthHeader(context),
        const SizedBox(height: 24),

        // Month summary
        _buildMonthSummary(context),
        const SizedBox(height: 24),

        // Days calendar
        Expanded(child: _buildDaysCalendar(context, now)),
      ],
    );
  }

  Widget _buildMonthHeader(BuildContext context) {
    final theme = Theme.of(context);
    final monthName = _getMonthName(monthData.month);

    return Row(
      children: [
        if (onBack != null)
          IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack, tooltip: 'Back to year view'),
        Text(
          '$monthName ${monthData.year}',
          style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildMonthSummary(BuildContext context) {
    final theme = Theme.of(context);
    final isProfitable = monthData.isProfitable;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Month Summary', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildSummaryMetric(
                    context,
                    'Total P&L',
                    _formatCurrency(monthData.totalPnL),
                    isProfitable ? Colors.green : Colors.red,
                    isProfitable ? Icons.trending_up : Icons.trending_down,
                  ),
                ),
                Expanded(
                  child: _buildSummaryMetric(
                    context,
                    'Total Trades',
                    '${monthData.totalTrades}',
                    theme.colorScheme.primary,
                    Icons.show_chart,
                  ),
                ),
                Expanded(
                  child: _buildSummaryMetric(
                    context,
                    'Win Rate',
                    '${monthData.winRate.toStringAsFixed(1)}%',
                    monthData.winRate >= 50 ? Colors.green : Colors.orange,
                    Icons.percent,
                  ),
                ),
                Expanded(
                  child: _buildSummaryMetric(
                    context,
                    'Trading Days',
                    '${monthData.tradingDays}/${monthData.totalDaysInMonth}',
                    theme.colorScheme.secondary,
                    Icons.calendar_today,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryMetric(BuildContext context, String label, String value, Color color, IconData icon) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDaysCalendar(BuildContext context, DateTime now) {
    final theme = Theme.of(context);
    final firstDayOfMonth = DateTime(monthData.year, monthData.month);
    final firstWeekday = firstDayOfMonth.weekday;
    final daysInMonth = monthData.totalDaysInMonth;

    // Calculate grid items (including padding for first week)
    final totalCells = ((firstWeekday - 1 + daysInMonth) / 7).ceil() * 7;

    return Column(
      children: [
        // Weekday headers
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 2),
          itemCount: 7,
          itemBuilder: (context, index) {
            const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
            return Center(
              child: Text(
                weekdays[index],
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),

        // Days grid
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.8,
            ),
            itemCount: totalCells,
            itemBuilder: (context, index) {
              final dayNumber = index - (firstWeekday - 1) + 1;

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox.shrink();
              }

              final dayData = monthData.days[dayNumber - 1];
              final isToday = now.year == monthData.year && now.month == monthData.month && now.day == dayNumber;

              return DayCard(
                dayData: dayData,
                onTap: dayData.totalTrades > 0 ? () => onDayTap(dayNumber) : null,
                isToday: isToday,
              );
            },
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

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

/// Daily calendar view showing trade details
class DailyCalendarView extends StatelessWidget {
  const DailyCalendarView({required this.dayData, super.key, this.onBack});
  final DailyCalendarData dayData;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Day header
      _buildDayHeader(context),
      const SizedBox(height: 24),

      // Day summary
      _buildDaySummary(context),
      const SizedBox(height: 24),

      // Trades list
      Expanded(child: _buildTradesList(context)),
    ],
  );

  Widget _buildDayHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        if (onBack != null)
          IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack, tooltip: 'Back to month view'),
        Text(_formatDate(dayData.date), style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDaySummary(BuildContext context) {
    final theme = Theme.of(context);
    final isProfitable = dayData.isProfitable;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Day Summary', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildSummaryMetric(
                    context,
                    'Total P&L',
                    _formatCurrency(dayData.totalPnL),
                    isProfitable ? Colors.green : Colors.red,
                    isProfitable ? Icons.trending_up : Icons.trending_down,
                  ),
                ),
                Expanded(
                  child: _buildSummaryMetric(
                    context,
                    'Total Trades',
                    '${dayData.totalTrades}',
                    theme.colorScheme.primary,
                    Icons.show_chart,
                  ),
                ),
                Expanded(
                  child: _buildSummaryMetric(
                    context,
                    'Win Rate',
                    '${dayData.winRate.toStringAsFixed(1)}%',
                    dayData.winRate >= 50 ? Colors.green : Colors.orange,
                    Icons.percent,
                  ),
                ),
                Expanded(
                  child: _buildSummaryMetric(
                    context,
                    'Symbols Traded',
                    '${dayData.uniqueSymbols.length}',
                    theme.colorScheme.secondary,
                    Icons.account_balance,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryMetric(BuildContext context, String label, String value, Color color, IconData icon) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTradesList(BuildContext context) {
    if (dayData.trades.isEmpty) {
      return Center(
        child: Text(
          'No trades on this day',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
    }

    return ListView.builder(
      itemCount: dayData.trades.length,
      itemBuilder: (context, index) {
        final trade = dayData.trades[index];
        return TradeDetailCard(trade: trade);
      },
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

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
