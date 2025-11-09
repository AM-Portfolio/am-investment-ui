import 'package:flutter/material.dart';

import '../calendar_types.dart';

/// Individual calendar day cell component
class CalendarDayCell extends StatelessWidget {
  const CalendarDayCell({
    required this.dayNumber,
    required this.dayData,
    required this.month,
    super.key,
    this.compactMode = false,
    this.onTap,
  });

  final int dayNumber;
  final CalendarDayData? dayData;
  final int month;
  final bool compactMode;
  final Function(DateTime date, CalendarDayData dayData)? onTap;

  @override
  Widget build(BuildContext context) {
    final hasData = dayData?.hasTrades ?? false;
    final backgroundColor = hasData ? dayData!.getColor(opacity: 0.18) : Colors.transparent;
    final borderColor = hasData
        ? dayData!.getColor().withOpacity(0.6)
        : Theme.of(context).colorScheme.outline.withOpacity(0.1);

    final dayCell = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: hasData && onTap != null ? () => onTap!(dayData!.date, dayData!) : null,
        borderRadius: BorderRadius.circular(4),
        hoverColor: hasData ? dayData!.getColor().withOpacity(0.25) : Colors.grey.withOpacity(0.05),
        child: Container(
          height: compactMode ? 20 : 24,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor, width: hasData ? 1.5 : 0.5),
          ),
          child: Center(
            child: Text(
              '$dayNumber',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: compactMode ? 9 : 10,
                fontWeight: hasData ? FontWeight.bold : FontWeight.w500,
                color: hasData
                    ? dayData!.getColor().withOpacity(0.95)
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        ),
      ),
    );

    // Add tooltip with trade details on hover
    if (hasData && dayData != null) {
      final status = dayData!.status == TradeDayStatus.win
          ? 'Win'
          : dayData!.status == TradeDayStatus.loss
          ? 'Loss'
          : 'Breakeven';

      return Tooltip(
        message:
            '${dayData!.date.day} ${_getMonthName(month)}\n'
            '${dayData!.tradeCount} trade${dayData!.tradeCount > 1 ? 's' : ''} • $status\n'
            'P&L: \$${dayData!.pnl.toStringAsFixed(2)}',
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
    const monthNames = [
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
    return monthNames[month - 1];
  }
}
