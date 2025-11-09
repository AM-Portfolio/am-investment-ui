import 'package:flutter/material.dart';

import 'calendar_types.dart';

/// Year-at-a-glance calendar widget showing all 12 months
class YearCalendarWidget extends StatelessWidget {
  const YearCalendarWidget({
    required this.year,
    required this.monthsData,
    super.key,
    this.config = const YearCalendarConfig(),
  });

  final int year;
  final Map<int, CalendarMonthData> monthsData; // month (1-12) -> data
  final YearCalendarConfig config;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (config.showHeader) _buildHeader(context),
          if (config.showHeader) const SizedBox(height: 24),
          _buildMonthsGrid(context),
        ],
      ),
    ),
  );

  /// Build header
  Widget _buildHeader(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        '$year Trading Calendar',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
      _buildLegend(context),
    ],
  );

  /// Build legend
  Widget _buildLegend(BuildContext context) => Row(
    children: [
      _buildLegendItem(context, 'Win', Colors.green),
      const SizedBox(width: 16),
      _buildLegendItem(context, 'Loss', Colors.red),
      const SizedBox(width: 16),
      _buildLegendItem(context, 'Breakeven', Colors.grey),
    ],
  );

  Widget _buildLegendItem(BuildContext context, String label, Color color) => Row(
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color.withOpacity(0.3),
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 4),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ],
  );

  /// Build grid of months
  Widget _buildMonthsGrid(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final rows = (12 / config.monthsPerRow).ceil();
      return Column(
        children: List.generate(rows, (rowIndex) {
          final startMonth = rowIndex * config.monthsPerRow + 1;

          return Padding(
            padding: EdgeInsets.only(bottom: rowIndex < rows - 1 ? 16 : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(config.monthsPerRow, (colIndex) {
                final month = startMonth + colIndex;
                if (month > 12) return const Expanded(child: SizedBox());

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: colIndex < config.monthsPerRow - 1 ? 12 : 0),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month name
        Text(
          monthData?.monthName ?? _getMonthName(month),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // Weekday headers
        if (config.showWeekdays) ...[_buildWeekdayHeaders(context), const SizedBox(height: 4)],

        // Calendar grid
        _buildMonthGrid(context, month, daysInMonth, firstWeekday, monthData),
      ],
    );
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
                  fontSize: config.compactMode ? 8 : 10,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
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

  /// Build individual day cell
  Widget _buildDayCell(BuildContext context, int dayNumber, CalendarDayData? dayData) {
    final hasData = dayData != null && dayData.hasTrades;
    final backgroundColor = hasData ? dayData.getColor(opacity: 0.2) : Colors.transparent;

    final borderColor = hasData
        ? dayData.getColor(opacity: 0.8)
        : Theme.of(context).colorScheme.outline.withOpacity(0.1);

    return InkWell(
      onTap: hasData && config.onDayTap != null ? () => config.onDayTap!(dayData.date, dayData) : null,
      borderRadius: BorderRadius.circular(4),
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
              fontSize: config.compactMode ? 8 : 10,
              fontWeight: hasData ? FontWeight.bold : FontWeight.normal,
              color: hasData ? dayData.getColor() : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
