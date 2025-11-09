import 'package:flutter/material.dart';

import 'calendar_types.dart';

/// Year-at-a-glance calendar widget showing all 12 months
class YearCalendarWidget extends StatelessWidget {
  const YearCalendarWidget({
    required this.year,
    required this.monthsData,
    super.key,
    this.config = const YearCalendarConfig(),
    this.onYearChanged,
  });

  final int year;
  final Map<int, CalendarMonthData> monthsData; // month (1-12) -> data
  final YearCalendarConfig config;
  final Function(int newYear)? onYearChanged;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (config.showHeader) _buildHeader(context),
        if (config.showHeader) const SizedBox(height: 16),
        _buildMonthsGrid(context),
      ],
    ),
  );

  /// Build header with year and summary stats - responsive
  Widget _buildHeader(BuildContext context) {
    // Calculate year-wide statistics
    final yearStats = _calculateYearStats();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    if (isMobile) {
      // Mobile layout - stack vertically
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Year navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: onYearChanged != null ? () => onYearChanged!(year - 1) : null,
                    tooltip: 'Previous Year',
                    iconSize: 20,
                  ),
                  Text(
                    '$year',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: onYearChanged != null ? () => onYearChanged!(year + 1) : null,
                    tooltip: 'Next Year',
                    iconSize: 20,
                  ),
                ],
              ),
              _buildCompactLegend(context),
            ],
          ),
          const SizedBox(height: 12),
          // Year summary stats - scrollable
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSummaryCard(context, 'Trades', '${yearStats['totalTrades']}', Icons.swap_horiz, Colors.blue),
                const SizedBox(width: 8),
                _buildSummaryCard(
                  context,
                  'Win Rate',
                  '${yearStats['winRate'].toStringAsFixed(1)}%',
                  Icons.trending_up,
                  yearStats['winRate'] >= 50 ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                _buildSummaryCard(
                  context,
                  'P&L',
                  '\$${yearStats['totalPnL'] >= 0 ? '+' : ''}${yearStats['totalPnL'].toStringAsFixed(0)}',
                  yearStats['totalPnL'] >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                  yearStats['totalPnL'] >= 0 ? Colors.green : Colors.red,
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Desktop/Tablet layout
    return Row(
      children: [
        // Year navigation
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: onYearChanged != null ? () => onYearChanged!(year - 1) : null,
              tooltip: 'Previous Year',
              iconSize: 20,
            ),
            const SizedBox(width: 8),
            Text('$year', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: onYearChanged != null ? () => onYearChanged!(year + 1) : null,
              tooltip: 'Next Year',
              iconSize: 20,
            ),
          ],
        ),
        const Spacer(),
        // Year summary stats - aligned right
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _buildSummaryCard(context, 'Total Trades', '${yearStats['totalTrades']}', Icons.swap_horiz, Colors.blue),
            _buildSummaryCard(
              context,
              'Win Rate',
              '${yearStats['winRate'].toStringAsFixed(1)}%',
              Icons.trending_up,
              yearStats['winRate'] >= 50 ? Colors.green : Colors.orange,
            ),
            _buildSummaryCard(
              context,
              'Total P&L',
              '\$${yearStats['totalPnL'] >= 0 ? '+' : ''}${yearStats['totalPnL'].toStringAsFixed(0)}',
              yearStats['totalPnL'] >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
              yearStats['totalPnL'] >= 0 ? Colors.green : Colors.red,
            ),
            // Legend
            _buildLegend(context),
          ],
        ),
      ],
    );
  }

  /// Build compact legend for mobile
  Widget _buildCompactLegend(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      _buildLegendDot(Colors.green),
      const SizedBox(width: 4),
      _buildLegendDot(Colors.red),
      const SizedBox(width: 4),
      _buildLegendDot(Colors.grey),
    ],
  );

  Widget _buildLegendDot(Color color) => Container(
    width: 8,
    height: 8,
    decoration: BoxDecoration(
      color: color.withOpacity(0.3),
      border: Border.all(color: color),
      shape: BoxShape.circle,
    ),
  );

  /// Build summary card
  Widget _buildSummaryCard(BuildContext context, String label, String value, IconData icon, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10, color: color.withOpacity(0.8)),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ],
    ),
  );

  /// Calculate year-wide statistics
  Map<String, dynamic> _calculateYearStats() {
    var totalTrades = 0;
    var winningTrades = 0;
    var totalPnL = 0.0;

    for (final monthData in monthsData.values) {
      for (final dayData in monthData.days.values) {
        totalTrades += dayData.tradeCount;
        if (dayData.status == TradeDayStatus.win) {
          winningTrades += dayData.tradeCount;
        }
        totalPnL += dayData.pnl;
      }
    }

    final winRate = totalTrades > 0 ? (winningTrades / totalTrades) * 100 : 0.0;

    return {'totalTrades': totalTrades, 'winRate': winRate, 'totalPnL': totalPnL};
  }

  /// Build compact legend
  Widget _buildLegend(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLegendItem(context, 'Win', Colors.green),
        const SizedBox(width: 12),
        _buildLegendItem(context, 'Loss', Colors.red),
        const SizedBox(width: 12),
        _buildLegendItem(context, 'Breakeven', Colors.grey),
      ],
    ),
  );

  Widget _buildLegendItem(BuildContext context, String label, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          border: Border.all(color: color, width: 1.5),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 4),
      Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11, fontWeight: FontWeight.w500)),
    ],
  );

  /// Build grid of months - responsive
  Widget _buildMonthsGrid(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      // Responsive months per row based on screen width
      final screenWidth = MediaQuery.of(context).size.width;
      int monthsPerRow;
      if (screenWidth < 600) {
        monthsPerRow = 1; // Mobile: 1 column
      } else if (screenWidth < 900) {
        monthsPerRow = 2; // Tablet: 2 columns
      } else if (screenWidth < 1200) {
        monthsPerRow = 3; // Small desktop: 3 columns
      } else {
        monthsPerRow = 4; // Large desktop: 4 columns
      }

      final rows = (12 / monthsPerRow).ceil();
      return Column(
        children: List.generate(rows, (rowIndex) {
          final startMonth = rowIndex * monthsPerRow + 1;

          return Padding(
            padding: EdgeInsets.only(bottom: rowIndex < rows - 1 ? 12 : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(monthsPerRow, (colIndex) {
                final month = startMonth + colIndex;
                if (month > 12) return const Expanded(child: SizedBox());

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: colIndex < monthsPerRow - 1 ? 10 : 0),
                    child: _buildMonthCalendar(context, month),
                  ),
                );
              }),
            ),
          );
        }),
      );
    },
  );

  /// Build individual month calendar
  Widget _buildMonthCalendar(BuildContext context, int month) {
    final monthData = monthsData[month];
    final firstDay = DateTime(year, month);
    final lastDay = DateTime(year, month + 1, 0);
    final daysInMonth = lastDay.day;
    final firstWeekday = firstDay.weekday; // 1 = Monday, 7 = Sunday

    // Calculate month statistics
    final stats = _calculateMonthStats(monthData);

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Month header with stats
            _buildMonthHeader(context, month, monthData, stats),
            const SizedBox(height: 10),

            // Weekday headers
            if (config.showWeekdays) ...[_buildWeekdayHeaders(context), const SizedBox(height: 4)],

            // Calendar grid
            _buildMonthGrid(context, month, daysInMonth, firstWeekday, monthData),
          ],
        ),
      ),
    );
  }

  /// Build month header with name and stats - badges aligned right
  Widget _buildMonthHeader(BuildContext context, int month, CalendarMonthData? monthData, Map<String, dynamic> stats) =>
      Row(
        children: [
          // Month name
          Text(
            monthData?.monthName ?? _getMonthName(month),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Spacer(),
          if (stats['totalTrades'] > 0)
            // Stats badges aligned to the right
            Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _buildStatBadge(context, Icons.calendar_today, '${stats['tradeDays']} days', Colors.purple),
                _buildStatBadge(context, Icons.assessment, '${stats['totalTrades']} trades', Colors.blue),
                _buildStatBadge(
                  context,
                  Icons.trending_up,
                  '${stats['winRate'].toStringAsFixed(1)}%',
                  stats['winRate'] >= 50 ? Colors.green : Colors.orange,
                ),
                _buildStatBadge(
                  context,
                  stats['totalPnL'] >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                  '\$${stats['totalPnL'] >= 0 ? '+' : ''}${stats['totalPnL'].toStringAsFixed(0)}',
                  stats['totalPnL'] >= 0 ? Colors.green : Colors.red,
                ),
              ],
            ),
        ],
      );

  /// Build stat badge - modern design
  Widget _buildStatBadge(BuildContext context, IconData icon, String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 10,
            color: color.withOpacity(0.9),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ],
    ),
  );

  /// Calculate month statistics including trade days
  Map<String, dynamic> _calculateMonthStats(CalendarMonthData? monthData) {
    if (monthData == null) {
      return {'totalTrades': 0, 'winRate': 0.0, 'totalPnL': 0.0, 'tradeDays': 0};
    }

    var totalTrades = 0;
    var winningTrades = 0;
    var totalPnL = 0.0;
    var tradeDays = 0;

    for (final dayData in monthData.days.values) {
      if (dayData.hasTrades) {
        tradeDays++;
      }
      totalTrades += dayData.tradeCount;
      if (dayData.status == TradeDayStatus.win) {
        winningTrades += dayData.tradeCount;
      }
      totalPnL += dayData.pnl;
    }

    final winRate = totalTrades > 0 ? (winningTrades / totalTrades) * 100 : 0.0;

    return {'totalTrades': totalTrades, 'winRate': winRate, 'totalPnL': totalPnL, 'tradeDays': tradeDays};
  }

  /// Build weekday headers
  Widget _buildWeekdayHeaders(BuildContext context) => Row(
    children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
        .map(
          (day) => Expanded(
            child: Center(
              child: Text(
                day,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: config.compactMode ? 9 : 10,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        )
        .toList(),
  );

  /// Build month grid
  Widget _buildMonthGrid(
    BuildContext context,
    int month,
    int daysInMonth,
    int firstWeekday,
    CalendarMonthData? monthData,
  ) {
    final totalCells = daysInMonth + (firstWeekday - 1);
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(
        rows,
        (rowIndex) => Padding(
          padding: EdgeInsets.only(bottom: rowIndex < rows - 1 ? 2 : 0),
          child: Row(
            children: List.generate(7, (colIndex) {
              final cellIndex = rowIndex * 7 + colIndex;
              final dayNumber = cellIndex - (firstWeekday - 1) + 1;

              // Empty cell
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const Expanded(child: SizedBox(height: 20));
              }

              final dayData = monthData?.getDayData(dayNumber);
              return Expanded(child: _buildDayCell(context, dayNumber, dayData));
            }),
          ),
        ),
      ),
    );
  }

  /// Build individual day cell with hover tooltip
  Widget _buildDayCell(BuildContext context, int dayNumber, CalendarDayData? dayData) {
    final hasData = dayData != null && dayData.hasTrades;
    final backgroundColor = hasData ? dayData.getColor(opacity: 0.18) : Colors.transparent;

    final borderColor = hasData
        ? dayData.getColor().withOpacity(0.6)
        : Theme.of(context).colorScheme.outline.withOpacity(0.1);

    final dayCell = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: hasData && config.onDayTap != null ? () => config.onDayTap!(dayData.date, dayData) : null,
        borderRadius: BorderRadius.circular(4),
        hoverColor: hasData ? dayData.getColor().withOpacity(0.25) : Colors.grey.withOpacity(0.05),
        child: Container(
          height: config.compactMode ? 20 : 24,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor, width: hasData ? 1.5 : 0.5),
          ),
          child: Center(
            child: Text(
              '$dayNumber',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: config.compactMode ? 9 : 10,
                fontWeight: hasData ? FontWeight.bold : FontWeight.w500,
                color: hasData
                    ? dayData.getColor().withOpacity(0.95)
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        ),
      ),
    );

    // Add tooltip with trade details on hover
    if (hasData) {
      final status = dayData.status == TradeDayStatus.win
          ? 'Win'
          : dayData.status == TradeDayStatus.loss
          ? 'Loss'
          : 'Breakeven';

      return Tooltip(
        message:
            '${dayData.date.day} ${_getMonthName(dayData.date.month)}\n'
            '${dayData.tradeCount} trade${dayData.tradeCount > 1 ? 's' : ''} • $status\n'
            'P&L: \$${dayData.pnl.toStringAsFixed(2)}',
        preferBelow: false,
        verticalOffset: 20,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2))],
        ),
        textStyle: const TextStyle(fontSize: 11, color: Colors.white, height: 1.4),
        child: dayCell,
      );
    }

    return dayCell;
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
