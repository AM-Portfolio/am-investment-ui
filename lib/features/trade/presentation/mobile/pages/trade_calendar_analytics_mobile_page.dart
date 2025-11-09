import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/trade_internal_providers.dart';

/// Trade Calendar Analytics Mobile Page with Year/Month Selection
class TradeCalendarAnalyticsMobilePage extends ConsumerStatefulWidget {
  const TradeCalendarAnalyticsMobilePage({required this.userId, required this.portfolioId, super.key});

  final String userId;
  final String portfolioId;

  @override
  ConsumerState<TradeCalendarAnalyticsMobilePage> createState() => _TradeCalendarAnalyticsMobilePageState();
}

class _TradeCalendarAnalyticsMobilePageState extends ConsumerState<TradeCalendarAnalyticsMobilePage> {
  int _selectedYear = 2020; // Default to 2020
  int _selectedMonth = 0; // 0 means all months

  List<String> get _monthNames => [
    'All Months',
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

  @override
  Widget build(BuildContext context) {
    final calendarAsync = ref.watch(
      tradeCalendarStreamProvider((userId: widget.userId, portfolioId: widget.portfolioId)),
    );

    return calendarAsync.when(
      data: (viewModel) => _buildCalendarView(context, viewModel.events),
      loading: () => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Loading calendar...')],
        ),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(tradeCalendarStreamProvider((userId: widget.userId, portfolioId: widget.portfolioId)));
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarView(BuildContext context, List<Map<String, dynamic>> allEvents) {
    // Filter events by selected year and month
    final filteredEvents = allEvents.where((event) {
      final date = event['date'] as DateTime?;
      if (date == null) return false;

      // Filter by year
      if (date.year != _selectedYear) return false;

      // Filter by month if specific month is selected
      if (_selectedMonth > 0 && date.month != _selectedMonth) return false;

      return true;
    }).toList();

    // Calculate summary stats from filtered events
    final totalTrades = filteredEvents.fold<int>(
      0,
      (sum, event) => sum + ((event['tradeCount'] as num?)?.toInt() ?? 0),
    );
    final totalPnl = filteredEvents.fold<double>(0, (sum, event) => sum + ((event['pnl'] as num?)?.toDouble() ?? 0));
    final winningDays = filteredEvents.where((e) => ((e['pnl'] as num?)?.toDouble() ?? 0) > 0).length;
    final totalDays = filteredEvents.length;

    return Column(
      children: [
        // Year and Month Selection
        _buildYearMonthSelector(context),

        // Summary stats
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).cardColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(context, 'Trades', totalTrades.toString(), Icons.swap_horiz),
              _buildStatItem(
                context,
                'P&L',
                totalPnl >= 0 ? '+₹${totalPnl.toStringAsFixed(0)}' : '-₹${totalPnl.abs().toStringAsFixed(0)}',
                Icons.trending_up,
                color: totalPnl >= 0 ? Colors.green : Colors.red,
              ),
              _buildStatItem(
                context,
                'Win Rate',
                totalDays > 0 ? '${((winningDays / totalDays) * 100).toStringAsFixed(0)}%' : '0%',
                Icons.pie_chart,
              ),
            ],
          ),
        ),

        // Event list
        Expanded(
          child: filteredEvents.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Trade Events',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedMonth > 0
                            ? 'No trades in ${_monthNames[_selectedMonth]} $_selectedYear'
                            : 'No trades in $_selectedYear',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: filteredEvents.length,
                  itemBuilder: (context, index) {
                    final event = filteredEvents[index];
                    final pnl = (event['pnl'] as num?)?.toDouble() ?? 0;
                    final tradeCount = (event['tradeCount'] as num?)?.toInt() ?? 0;
                    final symbol = event['symbol'] as String? ?? 'Unknown';
                    final date = event['date'] as DateTime?;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: (pnl >= 0 ? Colors.green : Colors.red).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            pnl >= 0 ? Icons.trending_up : Icons.trending_down,
                            color: pnl >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                        title: Text(symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          date != null
                              ? '${date.day}/${date.month}/${date.year} • $tradeCount trade${tradeCount > 1 ? 's' : ''}'
                              : '$tradeCount trade${tradeCount > 1 ? 's' : ''}',
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              pnl >= 0 ? '+₹${pnl.toStringAsFixed(2)}' : '-₹${pnl.abs().toStringAsFixed(2)}',
                              style: TextStyle(
                                color: pnl >= 0 ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildYearMonthSelector(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
    ),
    child: Row(
      children: [
        // Year Selector
        Expanded(
          child: InkWell(
            onTap: () => _showYearPicker(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 18, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Year: $_selectedYear',
                        style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                  Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.primary),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Month Selector
        Expanded(
          child: InkWell(
            onTap: () => _showMonthPicker(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.05),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      children: [
                        Icon(Icons.event, size: 18, color: Theme.of(context).colorScheme.secondary),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _monthNames[_selectedMonth],
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.secondary),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );

  void _showYearPicker(BuildContext context) {
    final currentYear = DateTime.now().year;
    final years = List.generate(10, (index) => currentYear - index); // Last 10 years

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Year',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            const Divider(),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: years.length,
                itemBuilder: (context, index) {
                  final year = years[index];
                  final isSelected = year == _selectedYear;

                  return ListTile(
                    leading: Icon(
                      Icons.calendar_today,
                      color: isSelected ? Theme.of(context).colorScheme.primary : null,
                    ),
                    title: Text(
                      year.toString(),
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Theme.of(context).colorScheme.primary : null,
                      ),
                    ),
                    trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
                    selected: isSelected,
                    onTap: () {
                      setState(() {
                        _selectedYear = year;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMonthPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Month',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            const Divider(),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _monthNames.length,
                itemBuilder: (context, index) {
                  final monthName = _monthNames[index];
                  final isSelected = index == _selectedMonth;

                  return ListTile(
                    leading: Icon(
                      index == 0 ? Icons.view_agenda : Icons.event,
                      color: isSelected ? Theme.of(context).colorScheme.secondary : null,
                    ),
                    title: Text(
                      monthName,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Theme.of(context).colorScheme.secondary : null,
                      ),
                    ),
                    trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).colorScheme.secondary) : null,
                    selected: isSelected,
                    onTap: () {
                      setState(() {
                        _selectedMonth = index;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon, {Color? color}) => Column(
    children: [
      Icon(icon, size: 20, color: color ?? Theme.of(context).colorScheme.primary),
      const SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
      ),
      Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11)),
    ],
  );
}
