import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Web page for displaying trade calendar for a selected portfolio
class TradeCalendarWebPage extends ConsumerStatefulWidget {
  const TradeCalendarWebPage({
    required this.portfolioId,
    required this.portfolioName,
    super.key,
  });

  final String portfolioId;
  final String portfolioName;

  @override
  ConsumerState<TradeCalendarWebPage> createState() => _TradeCalendarWebPageState();
}

/// Calendar view format options
enum CalendarFormat { month, week, day }

class _TradeCalendarWebPageState extends ConsumerState<TradeCalendarWebPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Portfolio Info
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.calendar_today,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trade Calendar',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                widget.portfolioName,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  widget.portfolioId,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Calendar Controls
                    Row(
                      children: [
                        // Filter Dropdown
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: Theme.of(context).colorScheme.surface,
                          ),
                          child: DropdownButton<String>(
                            value: _selectedFilter,
                            underline: const SizedBox(),
                            icon: const Icon(Icons.filter_list),
                            items: const [
                              DropdownMenuItem(value: 'all', child: Text('All Trades')),
                              DropdownMenuItem(value: 'buy', child: Text('Buy Orders')),
                              DropdownMenuItem(value: 'sell', child: Text('Sell Orders')),
                              DropdownMenuItem(value: 'high_volume', child: Text('High Volume')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedFilter = value ?? 'all';
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Calendar Format Toggle
                        SegmentedButton<CalendarFormat>(
                          segments: const [
                            ButtonSegment(
                              value: CalendarFormat.month,
                              label: Text('Month'),
                              icon: Icon(Icons.calendar_view_month),
                            ),
                            ButtonSegment(
                              value: CalendarFormat.week,
                              label: Text('Week'),
                              icon: Icon(Icons.calendar_view_week),
                            ),
                            ButtonSegment(
                              value: CalendarFormat.day,
                              label: Text('Day'),
                              icon: Icon(Icons.view_day),
                            ),
                          ],
                          selected: {_calendarFormat},
                          onSelectionChanged: (Set<CalendarFormat> newSelection) {
                            setState(() {
                              _calendarFormat = newSelection.first;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Calendar and Trade Details
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Calendar Section
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Calendar Widget
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: _buildSimpleCalendar(context),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Trade Summary for Selected Month
                        _buildTradeSummaryCard(context),
                      ],
                    ),
                  ),
                ),

                // Trade Details Panel
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: Border(
                        left: BorderSide(
                          color: Theme.of(context).dividerColor,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Theme.of(context).dividerColor,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.event_note,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _selectedDay != null
                                    ? 'Trades on ${_formatSelectedDate(_selectedDay!)}'
                                    : 'Select a date',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: _buildTradeDetails(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Handle day selection
  void _onDaySelected(DateTime selectedDay) {
    if (!_isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = selectedDay;
      });
    }
  }

  /// Get events for a specific day
  List<_MockTradeEvent> _getEventsForDay(DateTime day) {
    return _getMockTradeEvents()
        .where((event) => _isSameDay(event.date, day))
        .toList();
  }

  /// Check if two dates are the same day
  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Build simple calendar widget
  Widget _buildSimpleCalendar(BuildContext context) {
    return Column(
      children: [
        // Calendar Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
                  });
                },
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                _getMonthYearString(_focusedDay),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
                  });
                },
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        
        // Days of week header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                .map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),

        // Calendar grid
        _buildCalendarGrid(context),
      ],
    );
  }

  /// Build calendar grid
  Widget _buildCalendarGrid(BuildContext context) {
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    // Calculate number of weeks needed
    final totalDays = daysInMonth + (firstDayWeekday - 1);
    final weeks = (totalDays / 7).ceil();

    return Column(
      children: List.generate(weeks, (weekIndex) {
        return Row(
          children: List.generate(7, (dayIndex) {
            final dayNumber = (weekIndex * 7) + dayIndex - (firstDayWeekday - 1) + 1;
            
            if (dayNumber < 1 || dayNumber > daysInMonth) {
              return const Expanded(child: SizedBox(height: 40));
            }

            final currentDate = DateTime(_focusedDay.year, _focusedDay.month, dayNumber);
            final isSelected = _isSameDay(_selectedDay, currentDate);
            final isToday = _isSameDay(DateTime.now(), currentDate);
            final hasEvents = _getEventsForDay(currentDate).isNotEmpty;

            return Expanded(
              child: GestureDetector(
                onTap: () => _onDaySelected(currentDate),
                child: Container(
                  height: 40,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : isToday
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: hasEvents
                        ? Border.all(
                            color: Theme.of(context).colorScheme.secondary,
                            width: 2,
                          )
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$dayNumber',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : isToday
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface,
                        fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  /// Get month year string for display
  String _getMonthYearString(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  /// Build trade summary card
  Widget _buildTradeSummaryCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  context,
                  title: 'Total Trades',
                  value: '45',
                  icon: Icons.swap_horiz,
                  color: Colors.blue,
                ),
                _buildSummaryItem(
                  context,
                  title: 'Buy Orders',
                  value: '28',
                  icon: Icons.trending_up,
                  color: Colors.green,
                ),
                _buildSummaryItem(
                  context,
                  title: 'Sell Orders',
                  value: '17',
                  icon: Icons.trending_down,
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build summary item
  Widget _buildSummaryItem(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  /// Build trade details panel
  Widget _buildTradeDetails(BuildContext context) {
    if (_selectedDay == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('Select a date to view trades'),
          ],
        ),
      );
    }

    final dayEvents = _getEventsForDay(_selectedDay!);
    
    if (dayEvents.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('No trades on this date'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dayEvents.length,
      itemBuilder: (context, index) {
        final event = dayEvents[index];
        return _buildTradeEventCard(context, event);
      },
    );
  }

  /// Build trade event card
  Widget _buildTradeEventCard(BuildContext context, _MockTradeEvent event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: event.type == 'BUY' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    event.type == 'BUY' ? Icons.trending_up : Icons.trending_down,
                    color: event.type == 'BUY' ? Colors.green : Colors.red,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${event.type} ${event.symbol}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        event.companyName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatTime(event.date),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quantity',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      '${event.quantity}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      '\$${event.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total Value',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      '\$${(event.quantity * event.price).toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Format selected date
  String _formatSelectedDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Format time
  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Get mock trade events
  List<_MockTradeEvent> _getMockTradeEvents() {
    final now = DateTime.now();
    return [
      _MockTradeEvent(
        symbol: 'AAPL',
        companyName: 'Apple Inc.',
        type: 'BUY',
        quantity: 100,
        price: 173.50,
        date: DateTime(now.year, now.month, now.day, 9, 30),
      ),
      _MockTradeEvent(
        symbol: 'MSFT',
        companyName: 'Microsoft Corporation',
        type: 'SELL',
        quantity: 50,
        price: 332.89,
        date: DateTime(now.year, now.month, now.day, 14, 15),
      ),
      _MockTradeEvent(
        symbol: 'GOOGL',
        companyName: 'Alphabet Inc.',
        type: 'BUY',
        quantity: 25,
        price: 2287.44,
        date: DateTime(now.year, now.month, now.day - 1, 11, 0),
      ),
      _MockTradeEvent(
        symbol: 'TSLA',
        companyName: 'Tesla, Inc.',
        type: 'SELL',
        quantity: 75,
        price: 891.23,
        date: DateTime(now.year, now.month, now.day - 2, 16, 45),
      ),
      _MockTradeEvent(
        symbol: 'AMZN',
        companyName: 'Amazon.com Inc.',
        type: 'BUY',
        quantity: 10,
        price: 3089.11,
        date: DateTime(now.year, now.month, now.day - 3, 10, 30),
      ),
    ];
  }
}

/// Mock trade event model
class _MockTradeEvent {
  final String symbol;
  final String companyName;
  final String type;
  final double quantity;
  final double price;
  final DateTime date;

  const _MockTradeEvent({
    required this.symbol,
    required this.companyName,
    required this.type,
    required this.quantity,
    required this.price,
    required this.date,
  });
}