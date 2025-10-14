import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/trade_internal_providers.dart';
import '../../models/trade_calendar_view_model.dart';
import '../../widgets/trade_analytics_display.dart';
import '../../widgets/trade_calendar_date_selector.dart';

class TradeCalendarAnalyticsWebPage extends ConsumerStatefulWidget {
  const TradeCalendarAnalyticsWebPage({
    required this.userId,
    required this.portfolioId,
    super.key,
  });
  final String userId;
  final String portfolioId;

  @override
  ConsumerState<TradeCalendarAnalyticsWebPage> createState() =>
      _TradeCalendarAnalyticsWebPageState();
}

class _TradeCalendarAnalyticsWebPageState
    extends ConsumerState<TradeCalendarAnalyticsWebPage> {
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  void _onDateRangeChanged(
    DateTime? startDate,
    DateTime? endDate,
    String description,
  ) {
    setState(() {
      _selectedStartDate = startDate;
      _selectedEndDate = endDate;
    });

    // Refresh data with new date range
    final params = (userId: widget.userId, portfolioId: widget.portfolioId);
    ref.invalidate(tradeCalendarStreamProvider(params));

    // Show selection feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Date filter updated: $description'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final params = (userId: widget.userId, portfolioId: widget.portfolioId);
    final calendarAsync = ref.watch(tradeCalendarStreamProvider(params));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trade Calendar Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(tradeCalendarStreamProvider(params));
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _exportData(context),
          ),
        ],
      ),
      body: calendarAsync.when(
        data: (calendar) => _buildCalendarContent(context, calendar),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, params, error),
      ),
    );
  }

  Widget _buildCalendarContent(
    BuildContext context,
    TradeCalendarViewModel calendar,
  ) => CustomScrollView(
    slivers: [
      // Date selector
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: TradeCalendarDateSelector(
            onDateRangeChanged: _onDateRangeChanged,
            initialStartDate: _selectedStartDate,
            initialEndDate: _selectedEndDate,
          ),
        ),
      ),

      // Analytics display
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TradeAnalyticsDisplay(analytics: calendar.analytics),
        ),
      ),

      // Calendar template
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_view_month,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Trade Events Calendar',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        calendar.displayDateRange,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Events list
                  if (calendar.events.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 32),
                          Icon(
                            Icons.event_busy,
                            size: 64,
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No trade events found',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.6),
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            calendar.hasDateFilter
                                ? 'Try adjusting your date range to find events'
                                : 'No trading activity in this portfolio',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.5),
                                ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: calendar.events.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final event = calendar.events[index];
                        return _buildEventTile(context, event);
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );

  Widget _buildEventTile(
    BuildContext context,
    TradeCalendarEventViewModel event,
  ) {
    final isProfit = event.isProfit;
    final profitColor = isProfit ? Colors.green : Colors.red;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: profitColor.withOpacity(0.1),
        child: Icon(
          event.type.toUpperCase() == 'WIN'
              ? Icons.trending_up
              : event.type.toUpperCase() == 'LOSS'
              ? Icons.trending_down
              : Icons.swap_horiz,
          color: profitColor,
          size: 20,
        ),
      ),
      title: Text(
        event.title,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (event.symbol != null) Text('Symbol: ${event.symbol}'),
          Text('Date: ${event.displayDate}'),
          if (event.description != null)
            Text(
              event.description!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
      trailing: event.amount != null
          ? Text(
              event.displayAmount,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: profitColor,
              ),
            )
          : null,
      onTap: () => _showEventDetails(context, event),
    );
  }

  Widget _buildErrorState(BuildContext context, params, Object error) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 64, color: Colors.red),
        const SizedBox(height: 16),
        Text(
          'Failed to load calendar data',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          error.toString(),
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            ref.invalidate(tradeCalendarStreamProvider(params));
          },
          child: const Text('Retry'),
        ),
      ],
    ),
  );

  void _exportData(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export feature coming soon...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showEventDetails(
    BuildContext context,
    TradeCalendarEventViewModel event,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Type: ${event.type}'),
              if (event.symbol != null) Text('Symbol: ${event.symbol}'),
              if (event.description != null) ...[
                const SizedBox(height: 8),
                Text(event.description!),
              ],
              const Divider(),
              if (event.amount != null)
                Text(
                  'Amount: ${event.displayAmount}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              const SizedBox(height: 8),
              Text('Date: ${event.displayDate}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
