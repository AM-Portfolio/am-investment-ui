import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/utils/logger.dart';
import '../../cubit/unified_trade_cubit.dart';

class TradeCalendarAnalyticsMobilePage extends StatefulWidget {
  const TradeCalendarAnalyticsMobilePage({
    required this.portfolioId,
    this.portfolioName,
    super.key,
  });

  final String portfolioId;
  final String? portfolioName;

  @override
  State<TradeCalendarAnalyticsMobilePage> createState() =>
      _TradeCalendarAnalyticsMobilePageState();
}

class _TradeCalendarAnalyticsMobilePageState
    extends State<TradeCalendarAnalyticsMobilePage> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCalendar();
    });
  }

  void _loadCalendar() {
    context.read<UnifiedTradeCubit>().loadMonthlyCalendar(
          widget.portfolioId,
          _selectedDate.year,
          _selectedDate.month,
        );
  }

  @override
  Widget build(BuildContext context) {
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
              _loadCalendar();
            },
            tooltip: 'Today',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildMonthSelector(),
          Expanded(
            child: BlocBuilder<UnifiedTradeCubit, UnifiedTradeState>(
              builder: (context, state) {
                return state.when(
                  initial: () => const Center(
                    child: Text('Select a month to view calendar'),
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (message) => _buildErrorWidget(message),
                  portfoliosLoaded: (_) => const SizedBox(),
                  portfolioSummaryLoaded: (_) => const SizedBox(),
                  holdingsLoaded: (_) => const SizedBox(),
                  tradeDetailsLoaded: (_) => const SizedBox(),
                  calendarLoaded: (calendar) => _buildCalendarView(calendar),
                );
              },
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
              _loadCalendar();
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
              _loadCalendar();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
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
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadCalendar,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarView(dynamic calendar) {
    final trades = calendar.trades ?? [];

    if (trades.isEmpty) {
      return const Center(
        child: Text('No trades for this month'),
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
        _loadCalendar();
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: trades.length,
        itemBuilder: (context, index) {
          final trade = trades[index];
          final isBuy = trade.tradeType?.toLowerCase() == 'buy';

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
                trade.symbol ?? 'N/A',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    '${trade.tradeType?.toUpperCase() ?? 'N/A'} ${trade.quantity ?? 0} @ \$${trade.price?.toStringAsFixed(2) ?? '0.00'}',
                  ),
                  if (trade.tradeDate != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      trade.tradeDate!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
              trailing: Text(
                '\$${(trade.totalAmount ?? 0).toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isBuy ? Colors.green : Colors.red,
                ),
              ),
            ),
          );
        },
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
