import 'package:flutter/material.dart';

import '../calendar_types.dart';
import 'stat_badge.dart';

/// Month header with name and statistics badges
class MonthHeader extends StatelessWidget {
  const MonthHeader({required this.month, required this.monthData, required this.stats, super.key});

  final int month;
  final CalendarMonthData? monthData;
  final Map<String, dynamic> stats;

  @override
  Widget build(BuildContext context) => Row(
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
            StatBadge(icon: Icons.calendar_today, label: '${stats['tradeDays']} days', color: Colors.purple),
            StatBadge(icon: Icons.assessment, label: '${stats['totalTrades']} trades', color: Colors.blue),
            StatBadge(
              icon: Icons.trending_up,
              label: '${stats['winRate'].toStringAsFixed(1)}%',
              color: stats['winRate'] >= 50 ? Colors.green : Colors.orange,
            ),
            StatBadge(
              icon: stats['totalPnL'] >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
              label: '\$${stats['totalPnL'] >= 0 ? '+' : ''}${stats['totalPnL'].toStringAsFixed(0)}',
              color: stats['totalPnL'] >= 0 ? Colors.green : Colors.red,
            ),
          ],
        ),
    ],
  );

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
