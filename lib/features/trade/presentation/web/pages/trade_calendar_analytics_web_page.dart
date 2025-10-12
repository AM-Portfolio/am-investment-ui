import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/templates/calendar_analytics_template.dart';
import '../../models/trade_calendar_view_model.dart';
import '../../../providers/trade_internal_providers.dart';

class TradeCalendarAnalyticsWebPage extends ConsumerWidget {
  final String userId;
  final String portfolioId;

  const TradeCalendarAnalyticsWebPage({
    super.key,
    required this.userId,
    required this.portfolioId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = (userId: userId, portfolioId: portfolioId);
    final calendarAsync = ref.watch(tradeCalendarStreamProvider(params));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trade Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(tradeCalendarStreamProvider(params));
            },
          ),
        ],
      ),
      body: calendarAsync.when(
        data: (calendar) => CalendarAnalyticsTemplate(
          calendar: calendar,
          isLoading: false,
          onEventSelected: (event) => _showEventDetails(context, event),
          onRefresh: () {
            ref.invalidate(tradeCalendarStreamProvider(params));
          },
          isWebView: true,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(error.toString(), style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(tradeCalendarStreamProvider(params));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEventDetails(BuildContext context, TradeCalendarEventViewModel event) {
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
