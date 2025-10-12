import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/unified_trade_cubit.dart';
import '../../components/templates/calendar_analytics_template.dart';
import '../../../data/models/trade_portfolio.dart';

class TradeCalendarAnalyticsWebPage extends StatefulWidget {
  final TradePortfolio portfolio;

  const TradeCalendarAnalyticsWebPage({
    super.key,
    required this.portfolio,
  });

  @override
  State<TradeCalendarAnalyticsWebPage> createState() => _TradeCalendarAnalyticsWebPageState();
}

class _TradeCalendarAnalyticsWebPageState extends State<TradeCalendarAnalyticsWebPage> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadCalendar();
  }

  void _loadCalendar() {
    context.read<UnifiedTradeCubit>().loadMonthlyCalendar(
      widget.portfolio.portfolioId,
      selectedDate.year,
      selectedDate.month,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar - ${widget.portfolio.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() => selectedDate = DateTime.now());
              _loadCalendar();
            },
          ),
        ],
      ),
      body: BlocBuilder<UnifiedTradeCubit, UnifiedTradeState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: Text('Ready to load calendar')),
            loading: () => const Center(child: CircularProgressIndicator()),
            portfoliosLoaded: (_) => const Center(child: Text('Portfolios loaded')),
            portfolioSummaryLoaded: (_) => const Center(child: Text('Portfolio summary loaded')),
            holdingsLoaded: (_) => const Center(child: Text('Holdings loaded')),
            tradeDetailsLoaded: (_) => const Center(child: Text('Trade details loaded')),
            calendarLoaded: (calendar) => CalendarAnalyticsTemplate(
              calendar: calendar,
              isLoading: false,
              onDateSelected: (date) {
                setState(() => selectedDate = date);
                _loadCalendar();
              },
              isWebView: true,
            ),
            error: (message) => CalendarAnalyticsTemplate(
              calendar: null,
              isLoading: false,
              errorMessage: message,
              onDateSelected: (_) {},
              isWebView: true,
            ),
          );
        },
      ),
    );
  }
}
