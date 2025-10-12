import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/utils/logger.dart';
import '../../models/trade_calendar_view_model.dart';
import '../../../providers/trade_internal_providers.dart';

/// Mobile page for trade calendar analytics using Riverpod streams
class TradeCalendarAnalyticsMobilePage extends ConsumerStatefulWidget {
  const TradeCalendarAnalyticsMobilePage({
    required this.userId,
    required this.portfolioId,
    this.portfolioName,
    super.key,
  });

  final String userId;
  final String portfolioId;
  final String? portfolioName;

  @override
  ConsumerState<TradeCalendarAnalyticsMobilePage> createState() =>
      _TradeCalendarAnalyticsMobilePageState();
}

class _TradeCalendarAnalyticsMobilePageState
    extends ConsumerState<TradeCalendarAnalyticsMobilePage> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final calendarStream = ref.watch(
      tradeCalendarStreamProvider((
        userId: widget.userId,
        portfolioId: widget.portfolioId,
      )),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.portfolioName ?? 'Trade Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime.now();
              });
            },
            tooltip: 'Today',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildMonthSelector(),
          Expanded(
            child: calendarStream.when(
              data: (calendar) {
                final allEvents = calendar.events;
                
                // Filter events by selected month
                final events = allEvents.where((event) {
                  return event.date.year == _selectedDate.year &&
                         event.date.month == _selectedDate.month;
                }).toList();
                
                if (events.isEmpty) {
                  return const Center(
                    child: Text('No events for this month'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    AppLogger.userAction(
                      'Pull to Refresh Trade Calendar',
                      tag: 'TradeCalendarMobile',
                      context: {
                        'portfolioId': widget.portfolioId,
                        'year': _selectedDate.year,
                        'month': _selectedDate.month,
                      },
                    );
                    ref.invalidate(
                      tradeCalendarStreamProvider((
                        userId: widget.userId,
                        portfolioId: widget.portfolioId,
                      )),
                    );
                  },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      final isBuy = event.type.toUpperCase() == 'BUY';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: isBuy ? Colors.green : Colors.red,
                            child: Icon(
                              isBuy ? Icons.arrow_upward : Icons.arrow_downward,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            event.symbol ?? event.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(event.title),
                              const SizedBox(height: 4),
                              Text(
                                event.displayDate,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          trailing: event.amount != null
                              ? Text(
                                  event.displayAmount,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isBuy ? Colors.green : Colors.red,
                                  ),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        error.toString(),
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(
                          tradeCalendarStreamProvider((
                            userId: widget.userId,
                            portfolioId: widget.portfolioId,
                          )),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month - 1,
                );
              });
            },
          ),
          Text(
            '${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month + 1,
                );
              });
            },
          ),
        ],
      ),
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
}
