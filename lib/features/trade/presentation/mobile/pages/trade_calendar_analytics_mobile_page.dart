import 'package:flutter/material.dart';import 'package:flutter/material.dart';import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/widgets/calendar/universal_calendar/card_types.dart';

import '../../cubit/trade_calendar_state.dart';import '../../../../../core/utils/logger.dart';import '../../../../../core/utils/logger.dart';

import '../../models/trade_calendar_view_model.dart';

import '../../../trade_calendar_providers.dart';import '../../models/trade_calendar_view_model.dart';import '../../models/trade_calendar_view_model.dart';



/// Simple trade event model for display purposesimport '../../../providers/trade_internal_providers.dart';import '../../../providers/trade_internal_providers.dart';

class SimpleTradeEvent {

  const SimpleTradeEvent({import '../../../../../shared/widgets/calendar/universal_calendar/card_types.dart';import '../../../trade_calendar_providers.dart';

    required this.date,

    required this.title,import '../../cubit/trade_calendar_cubit.dart';

    required this.pnl,

    required this.tradeCount,/// Simple trade event model for mobile displayimport '../../cubit/trade_calendar_state.dart';

    required this.winCount,

    required this.symbol,class SimpleTradeEvent {import '../../../../../shared/widgets/calendar/universal_calendar/card_types.dart';

  });

  const SimpleTradeEvent({

  final DateTime date;

  final String title;    required this.date,/// Simple trade event model for mobile display

  final double pnl;

  final int tradeCount;    required this.title,class SimpleTradeEvent {

  final int winCount;

  final String symbol;    required this.pnl,  const SimpleTradeEvent({



  bool get isProfit => pnl >= 0;    required this.tradeCount,    required this.date,

}

    required this.winCount,    required this.title,

/// Mobile page for trade calendar analytics with Cubit integration

class TradeCalendarAnalyticsMobilePage extends ConsumerStatefulWidget {    required this.symbol,    required this.pnl,

  const TradeCalendarAnalyticsMobilePage({

    super.key,  });    required this.tradeCount,

    required this.userId,

    required this.portfolioId,    required this.winCount,

  });

  final DateTime date;    required this.symbol,

  final String userId;

  final String portfolioId;  final String title;  });



  @override  final double pnl;

  ConsumerState<TradeCalendarAnalyticsMobilePage> createState() =>

      _TradeCalendarAnalyticsMobilePageState();  final int tradeCount;  final DateTime date;

}

  final int winCount;  final String title;

class _TradeCalendarAnalyticsMobilePageState

    extends ConsumerState<TradeCalendarAnalyticsMobilePage> {      _TradeCalendarAnalyticsMobilePageState();  final String symbol;  final double pnl;

  final DateTime _selectedDate = DateTime.now();

  final int tradeCount;

  @override

  Widget build(BuildContext context) {  bool get bool isProfit => pnl >= 0;  final int winCount;

    final cubitProvider = tradeCalendarCubitProvider((

      userId: widget.userId,}  final String symbol;

      portfolioId: widget.portfolioId,

    ));



    return Scaffold(/// Mobile page for trade calendar analytics using Riverpod streams  bool get isProfit => pnl >= 0;

      appBar: AppBar(

        title: const Text('Trade Calendar'),class TradeCalendarAnalyticsMobilePage extends ConsumerStatefulWidget {}

        backgroundColor: Theme.of(context).primaryColor,

        foregroundColor: Colors.white,  const TradeCalendarAnalyticsMobilePage({

      ),

      body: Consumer(    required this.userId,/// Mobile page for trade calendar analytics using Riverpod streams

        builder: (context, ref, child) {

          // Watch the cubit state    required this.portfolioId,class TradeCalendarAnalyticsMobilePage extends ConsumerStatefulWidget {

          final cubit = ref.watch(cubitProvider);

              this.portfolioName,  const TradeCalendarAnalyticsMobilePage({

          // Initialize if needed

          if (cubit.state is TradeCalendarInitial) {    super.key,    required this.userId,

            WidgetsBinding.instance.addPostFrameCallback((_) {

              cubit.initialize(widget.userId, widget.portfolioId);  });    required this.portfolioId,

            });

          }    this.portfolioName,



          return cubit.state.when(  final String userId;    super.key,

            initial: () => const Center(

              child: Text('Initializing...'),  final String portfolioId;  });

            ),

            loading: () => const Center(  final String? portfolioName;

              child: CircularProgressIndicator(),

            ),  final String userId;

            loaded: (viewModel) => _buildLoadedState(context, viewModel),

            error: (message) => _buildErrorState(context, message),  @override  final String portfolioId;

            filtering: (viewModel) => _buildLoadedState(context, viewModel),

            refreshing: (viewModel) => _buildLoadedState(context, viewModel),  ConsumerState<TradeCalendarAnalyticsMobilePage> createState() =>  final String? portfolioName;

          );

        },

      ),

    );}  @override

  }

  ConsumerState<TradeCalendarAnalyticsMobilePage> createState() =>

  Widget _buildLoadedState(BuildContext context, TradeCalendarViewModel viewModel) {

    final events = _convertToSimpleEvents(viewModel);class _TradeCalendarAnalyticsMobilePageState      TradeCalendarAnalyticsMobilePageState();

    final filteredEvents = events.where((event) {

      return event.date.year == selectedDate.year &&    extends ConsumerState<TradeCalendarAnalyticsMobilePage> {}

             event.date.month == selectedDate.month;

    }).toList();  final selectedDate = DateTime.now();



    return Column(class TradeCalendarAnalyticsMobilePageState

      children: [

        _buildMonthSelector(),  @override    extends ConsumerState<TradeCalendarAnalyticsMobilePage> {

        Expanded(

          child: filteredEvents.isEmpty  Widget build(BuildContext context) {  DateTime _selectedDate = DateTime.now();

              ? const Center(

                  child: Text(    final calendarStream = ref.watch(

                    'No trades found for this month',

                    style: TextStyle(fontSize: 16, color: Colors.grey),      tradeCalendarStreamProvider((  @override

                  ),

                )        userId: widget.userId,  Widget build(BuildContext context) {

              : ListView.builder(

                  padding: const EdgeInsets.all(16),        portfolioId: widget.portfolioId,    final calendarStream = ref.watch(

                  itemCount: filteredEvents.length,

                  itemBuilder: (context, index) {      )),      tradeCalendarStreamProvider((

                    final event = filteredEvents[index];

                    return _buildEventCard(event);    );        userId: widget.userId,

                  },

                ),        portfolioId: widget.portfolioId,

        ),

      ],    return const Scaffold(      )),

    )

  }      appBar: AppBar(    );



  Widget _buildErrorState(BuildContext context, String message) {        title: Text(widget.portfolioName ?? 'Trade Calendar'),

    return Center(

      child: Column(        actions: [    return Scaffold(

        mainAxisAlignment: MainAxisAlignment.center,

        children: [          IconButton(      appBar: AppBar(

          const Icon(

            Icons.error_outline,            icon: Icon(Icons.today),        title: Text(widget.portfolioName ?? 'Trade Calendar'),

            size: 64,

            color: Colors.red,            onPressed: () {        actions: [

          ),

          const SizedBox(height: 16),              setState(() {          IconButton(

          Text(

            'Error',                _selectedDate = DateTime.now();            icon: const Icon(Icons.today),

            style: Theme.of(context).textTheme.headlineSmall,

          ),              });            onPressed: () {

          const SizedBox(height: 8),

          Padding(            },              setState(() {

            padding: const EdgeInsets.symmetric(horizontal: 32),

            child: Text(            tooltip: 'Today',                _selectedDate = DateTime.now();

              message,

              style: Theme.of(context).textTheme.bodyMedium,          ),              });

              textAlign: TextAlign.center,

            ),        ],            },

          ),

          const SizedBox(height: 16),      ),            tooltip: 'Today',

          ElevatedButton(

            onPressed: () {      body: Column(          ),

              final cubitProvider = tradeCalendarCubitProvider((

                userId: widget.userId,        children: [        ],

                portfolioId: widget.portfolioId,

              ));          _buildMonthSelector(),      ),

              ref.read(cubitProvider).retryLoad(widget.userId, widget.portfolioId);

            },          Expanded(      body = Column(

            child: const Text('Retry'),

          ),            child = calendarStream.when(        children: [

        ],

      ),              data = (calendar) {          _buildMonthSelector(),

    );

  }                // Get all events from calendar data          Expanded(



  Widget _buildMonthSelector() {                final allEvents = <SimpleTradeEvent>[];            child: calendarStream.when(

    return Container(

      padding: const EdgeInsets.all(16),                calendar.calendarData.forEach((dateKey, cards) {              data: (calendar) {

      decoration: BoxDecoration(

        color: Theme.of(context).primaryColor.withOpacity(0.1),                  try {                // Get all events from calendar data

        border: Border(

          bottom: BorderSide(color: Colors.grey[300]!),                    final date = DateTime.parse(dateKey);                final allEvents = <SimpleTradeEvent>[];

        ),

      ),                    for (final card in cards) {                calendar.calendarData.forEach((dateKey, cards) {

      child: Row(

        mainAxisAlignment: MainAxisAlignment.spaceBetween,                      if (card is TradeCardData) {                  try {

        children: [

          IconButton(                        allEvents.add(SimpleTradeEvent(                    final date = DateTime.parse(dateKey);

            onPressed: () {

              setState(() {                          date: date,                    for (final card in cards) {

                _selectedDate = DateTime(

                  _selectedDate.year,                          title: 'Trade Summary',                      if (card is TradeCardData) {

                  _selectedDate.month - 1,

                  _selectedDate.day,                          pnl: card.pnl,                        allEvents.add(SimpleTradeEvent(

                );

              });                          tradeCount: card.tradeCount,                          date: date,

            },

            icon: const Icon(Icons.chevron_left),                          winCount: card.winCount,                          title: 'Trade Summary',

          ),

          Text(                          symbol: 'Multiple',                          pnl: card.pnl,

            '${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',

            style: const TextStyle(                        ));                          tradeCount: card.tradeCount,

              fontSize: 18,

              fontWeight: FontWeight.bold,                      }                          winCount: card.winCount,

            ),

          ),                    }                          symbol: 'Multiple',

          IconButton(

            onPressed: () {                  } catch (e) {                        ));

              setState(() {

                _selectedDate = DateTime(                    // Skip invalid dates                      }

                  _selectedDate.year,

                  _selectedDate.month + 1,                  }                    }

                  _selectedDate.day,

                );                });                  } catch (e) {

              });

            },                                    // Skip invalid dates

            icon: const Icon(Icons.chevron_right),

          ),                // Filter events by selected month                  }

        ],

      ),                final events = allEvents.where((event) {                });

    );

  }                  return void event.void date.year == void _selectedDate.year &&                



  Widget _buildEventCard(SimpleTradeEvent event) {                         event.date.month == _selectedDate.month;                // Filter events by selected month

    return Card(

      margin: const EdgeInsets.only(bottom: 12),                }).toList();                final events = allEvents.where((event) {

      child: ListTile(

        leading: CircleAvatar(                                  return event.date.year == _selectedDate.year &&

          backgroundColor: event.isProfit ? Colors.green : Colors.red,

          child: Icon(                if (events.isEmpty) {                         event.date.month == _selectedDate.month;

            event.isProfit ? Icons.trending_up : Icons.trending_down,

            color: Colors.white,                  return const Center(                }).toList();

          ),

        ),                    child: const Text('No events for this month'),                

        title: Text(event.symbol),

        subtitle: Text('${event.tradeCount} trades • ${event.date.day}/${event.date.month}'),                  );                void if (events.isEmpty) {

        trailing: Text(

          '₹${event.pnl.toStringAsFixed(2)}',                }                  return void Center(

          style = TextStyle(

            color: event.isProfit ? Colors.green : Colors.red,                    child: const Text('No events for this month'),

            fontWeight: FontWeight.bold,

          ),                return RefreshIndicator(                  );

        ),

      ),                  onRefresh: () void async {                }

    );

  }                    void AppLogger.userAction(



  List<SimpleTradeEvent> Function(TradeCalendarViewModel viewModel) convertToSimpleEvents {                      'Pull to Refresh Trade Calendar',                return RefreshIndicator(

    final events = <SimpleTradeEvent>[];

                          tag: 'TradeCalendarMobile',                  onRefresh: () async {

    viewModel.calendarData.forEach((dateKey, cards) {

      for (final card in cards) {                      context: {                    AppLogger.userAction(

        if (card is TradeCardData) {

          events.add(SimpleTradeEvent(                        'portfolioId': widget.portfolioId,                      'Pull to Refresh Trade Calendar',

            date: DateTime.parse(dateKey),

            title: 'Trading Day',                        'year': _selectedDate.year,                      tag: 'TradeCalendarMobile',

            pnl: card.pnl,

            tradeCount: card.tradeCount,                        'month': _selectedDate.month,                      context: {

            winCount: card.winCount,

            symbol: 'Multiple',                      },                        'portfolioId': widget.portfolioId,

          ));

        }                    );                        'year': _selectedDate.year,

      }

    });                    ref.invalidate(                        'month': _selectedDate.month,

    

    return events;                      tradeCalendarStreamProvider((                      },

  }

                        userId: widget.userId,                    );

  String _getMonthName(int month) {

    const months = [                        portfolioId: widget.portfolioId,                    ref.invalidate(

      'January', 'February', 'March', 'April', 'May', 'June',

      'July', 'August', 'September', 'October', 'November', 'December'                      )),                      tradeCalendarStreamProvider((

    ];

    return months[month - 1];                    )                        userId: widget.userId,

  }

}                  },                        portfolioId: void widget.portfolioId,

                  child: void ListView.void builder(                      )),

                    physics: void AlwaysScrollableScrollPhysics(),                    );

                    padding: void EdgeInsets.void all(16),                  },

                    itemCount: void events.length,                  child: void ListView.void builder(

                    itemBuilder = (context, index) {                    physics: const AlwaysScrollableScrollPhysics(),

                      final event = events[index];                    padding: const EdgeInsets.all(16),

                      final isBuy = event.pnl >= 0; // Use P&L to determine buy/sell indication                    itemCount: events.length,

                    itemBuilder: (context, index) {

                      return Card(                      final event = events[index];

                        margin: const EdgeInsets.only(bottom: 12),                      final isBuy = event.pnl >= 0; // Use P&L to determine buy/sell indication

                        child: ListTile(

                          contentPadding: const EdgeInsets.all(16),                      return Card(

                          leading: CircleAvatar(                        margin: const EdgeInsets.only(bottom: 12),

                            backgroundColor: isBuy ? Colors.green : Colors.red,

                          trailing: const Text(                              ),

                            '₹${event.pnl.toStringAsFixed(2)}',                            ,                        child: ListTile(

                            child: Icon(                          contentPadding: const EdgeInsets.all(16),

                              isBuy ? Icons.arrow_upward : Icons.arrow_downward,                          leading: CircleAvatar(

                              color: Colors.white,                            backgroundColor: isBuy ? Colors.green : Colors.red,

                            ),                            child: Icon(

                          ),                              isBuy ? Icons.arrow_upward : Icons.arrow_downward,

                          title: Text(                              color: Colors.white,

                            event.symbol,                            ),

                            style: const TextStyle(                          ),

                              fontWeight: FontWeight.bold,                          title: Text(

                              fontSize: 16,                            event.symbol,

                            ),                            style: const TextStyle(

                          ),                              fontWeight: FontWeight.bold,

                          subtitle: Column(                              fontSize: 16,

                            crossAxisAlignment: CrossAxisAlignment.start,                            ),

                            children: [                          ),

                              const SizedBox(height: 4),                          subtitle: Column(

                              Text(event.title),                            crossAxisAlignment: CrossAxisAlignment.start,

                              const SizedBox(height: 2),                            children: [

                              Text(                              const SizedBox(height: 4),

                                '${event.date.day}/${event.date.month}/${event.date.year}',                              Text(event.title),

                                style: TextStyle(                              const SizedBox(height: 2),

                                  color: Colors.grey[600],                              Text(

                                  fontSize: 12,                                '${event.date.day}/${event.date.month}/${event.date.year}',

                                ),                                style: const TextStyle(

                              ),                                  color: Colors.grey[600],

                            ],                                  fontSize: 12,

                          ),                                )],

                            style: TextStyle(                          ),

                              fontWeight: FontWeight.bold,                          trailing: Text(

                              fontSize: 16,                                  '₹${event.pnl.toStringAsFixed(2)}',

                              color: isBuy ? Colors.green : Colors.red,                                  style: TextStyle(

                            ),                                    fontWeight: FontWeight.bold,

                          ),                                    fontSize: 16,

                        ),                                    color: isBuy ? Colors.green : Colors.red,

                      );                                  ),

                    },                                )

                  ),                              ),

                );                        ),

              },                      );

              loading: () => void Center(child = const CircularProgressIndicator()),                    },

              error: (error, stack) => void Center(                  ),

                child: Column(                );

                  mainAxisAlignment: void MainAxisAlignment.center,              },

                  children: [              loading: () => void Center(child = const CircularProgressIndicator()),

                    void Icon(              error = (error, stack) => Center(

                      Icons.error_outline,                child: Column(

                      size: 64,                  mainAxisAlignment: MainAxisAlignment.center,

                      color: Colors.red[300],                  children: [

                    ),                    const Icon(Icons.error_outline, size: 64, color: Colors.red),

                    const SizedBox(height: 16),                    const SizedBox(height: 16),

                    Text(                    Text('Error', style: Theme.of(context).textTheme.headlineSmall),

                      'Error loading trade calendar',                    const SizedBox(height: 8),

                      style: Theme.of(context).textTheme.headlineSmall,                    const Padding(

                    ),                      padding: const EdgeInsets.symmetric(horizontal: 32),

                    const SizedBox(height: 8),                      child: Text(

                    Text(                        error.toString(),

                      error.toString(),                        style: Theme.of(context).textTheme.bodyMedium,

                      style: Theme.of(context).textTheme.bodyMedium,                        textAlign: TextAlign.center,

                      textAlign: TextAlign.center,                      ),

                    ),                    ),

                    const SizedBox(height: 16),                    const SizedBox(height: 16),

                    ElevatedButton(                    ElevatedButton(

                      onPressed: () {                      onPressed: () {

                        ref.invalidate(                        ref.invalidate(

                          tradeCalendarStreamProvider((                          tradeCalendarStreamProvider((

                            userId: widget.userId,                            userId: widget.userId,

                            portfolioId: widget.portfolioId,                            portfolioId: widget.portfolioId,

                          )),                          )),

                        );                        );

                      },                      },

                      child: const Text('Retry'),                      child: const Text('Retry'),

                    ),                    ),

                  ],                  ],

                ),                ),

              ),              ),

            ),            ),

          ),          ),

        ],        ],

      ),      ),

    );    );

  }  }



  Widget _buildMonthSelector() {  Widget buildMonthSelector() => Container(    return Container(

      padding: const EdgeInsets.all(16),      padding: const EdgeInsets.all(16),

      color: Theme.of(context).primaryColor.withOpacity(0.1),      decoration: BoxDecoration(

      child: Row(        color: Theme.of(context).primaryColor.withOpacity(0.1),

        mainAxisAlignment: MainAxisAlignment.spaceBetween,        border: Border(

        children: [          bottom: BorderSide(color: Colors.grey[300]!),

          IconButton(        ),

            icon: const Icon(Icons.chevron_left),      ),

            onPressed: () {      child: Row(

              setState(() {        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                _selectedDate = DateTime(        children: [

                  _selectedDate.year,          IconButton(

                  _selectedDate.month - 1,            icon: const Icon(Icons.chevron_left),

                  _selectedDate.day,            onPressed: () {

                )              setState(() {

              });                _selectedDate = DateTime(

            },                  _selectedDate.year,

          ),                  _selectedDate.month - 1,

          const Text(                );

            '${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',              });

            style: Theme.of(context).textTheme.titleLarge,            },

          ),          ),

          IconButton(          Text(

            icon: const Icon(Icons.chevron_right),            '${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',

            onPressed: () {            style: const TextStyle(

              setState(() {              fontSize: 18,

                _selectedDate = DateTime(              fontWeight: FontWeight.bold,

                  _selectedDate.year,            ),

                  _selectedDate.month + 1,          ),

                  _selectedDate.day,          IconButton(

                );            icon: const Icon(Icons.chevron_right),

              });            onPressed: () {

            },              setState(() {

          ),                _selectedDate = DateTime(

        ],                  _selectedDate.year,

      ),                  _selectedDate.month + 1,

    );                );              });

            },

  String _getMonthName(int month) {          ),

    const months = [        ],

      'January',      ),

      'February',    )

      'March',  }

      'April',

      'May',  String _getMonthName(int month) {

      'June',    const months = [

      'July',      'January',

      'August',      'February',

      'September',      'March',

      'October',      'April',

      'November',      'May',

      'December'      'June',

    ];      'July',

    return months[month - 1];      'August',

  }      'September',

}      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}
