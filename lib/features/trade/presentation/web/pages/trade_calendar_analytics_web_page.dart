import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/widgets/calendar/universal_calendar/card_types.dart';
import '../../../../../shared/widgets/calendar/universal_calendar/data_provider.dart';
import '../../../../../shared/widgets/calendar/universal_calendar/types.dart';
import '../../../../../shared/widgets/calendar/universal_calendar/universal_calendar_widget.dart';
import '../../../trade_calendar_providers.dart';
import '../../cubit/trade_calendar_cubit.dart';
import '../../cubit/trade_calendar_state.dart';
import '../../models/trade_calendar_view_model.dart';

/// Simple trade event model for display purposes
class SimpleTradeEvent {
  const SimpleTradeEvent({
    required this.date,
    required this.title,
    required this.pnl,
    required this.tradeCount,
    required this.winCount,
    required this.symbol,
  });

  final DateTime date;
  final String title;
  final double pnl;
  final int tradeCount;
  final int winCount;
  final String symbol;

  bool get isProfit => pnl >= 0;
  double get winRate => tradeCount > 0 ? winCount / tradeCount : 0.0;
}

/// Enhanced Trade Calendar Analytics Web Page using Cubit and Universal Templates
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
    extends ConsumerState<TradeCalendarAnalyticsWebPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  DateSelection? _currentDateSelection;
  bool _isCalendarExpanded = true;
  String _eventFilter = 'all'; // 'all', 'profitable', 'losses'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize cubit after the frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTradeCalendar();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Initialize trade calendar with optimal settings
  void _initializeTradeCalendar() {
    final params = (userId: widget.userId, portfolioId: widget.portfolioId);
    final cubit = ref.read(tradeCalendarCubitProvider(params));

    cubit.initialize(userId: widget.userId, portfolioId: widget.portfolioId);
  }

  /// Handle date selection changes through Cubit
  void _onDateSelectionChanged(
    DateSelection selection,
    TradeCalendarCubit cubit,
  ) {
    setState(() {
      _currentDateSelection = selection;
    });

    // Apply filter through Cubit
    cubit.applyDateFilter(
      userId: widget.userId,
      portfolioId: widget.portfolioId,
      dateSelection: selection,
    );

    // Show user feedback
    _showDateSelectionFeedback(selection);
  }

  /// Show date selection feedback to user
  void _showDateSelectionFeedback(DateSelection selection) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Date filter updated: ${selection.description}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final params = (userId: widget.userId, portfolioId: widget.portfolioId);
    final cubit = ref.watch(tradeCalendarCubitProvider(params));

    return Scaffold(
      appBar: _buildAppBar(context, cubit),
      body: BlocBuilder<TradeCalendarCubit, TradeCalendarState>(
        bloc: cubit,
        builder: (context, state) => switch (state) {
          TradeCalendarLoading() => _buildLoadingState(
            context,
            state.isRefresh,
          ),
          TradeCalendarLoaded() => _buildMainContent(
            context,
            state.viewModel,
            cubit,
          ),
          TradeCalendarError() => _buildErrorState(
            context,
            cubit,
            state.message,
          ),
          TradeCalendarFiltering() => _buildFilteringState(
            context,
            state.currentData.viewModel,
            cubit,
          ),
          TradeCalendarRefreshing() => _buildRefreshingState(
            context,
            state.currentData.viewModel,
            cubit,
          ),
          _ => _buildInitialState(context, cubit),
        },
      ),
    );
  }

  /// Build enhanced app bar with actions
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    TradeCalendarCubit cubit,
  ) => AppBar(
    title: const Text('Trade Calendar Analytics'),
    elevation: 0,
    backgroundColor: Theme.of(context).colorScheme.surface,
    foregroundColor: Theme.of(context).colorScheme.onSurface,
    actions: [
      IconButton(
        icon: Icon(_isCalendarExpanded ? Icons.compress : Icons.expand),
        onPressed: () {
          setState(() {
            _isCalendarExpanded = !_isCalendarExpanded;
          });
        },
        tooltip: _isCalendarExpanded ? 'Collapse Calendar' : 'Expand Calendar',
      ),
      IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: () => _handleRefresh(cubit),
        tooltip: 'Refresh Data',
      ),
      IconButton(
        icon: const Icon(Icons.download),
        onPressed: () => _exportData(context),
        tooltip: 'Export Data',
      ),
      const SizedBox(width: 8),
    ],
  );

  /// Handle refresh with user feedback
  void _handleRefresh(TradeCalendarCubit cubit) {
    cubit.refresh(
      userId: widget.userId,
      portfolioId: widget.portfolioId,
      forceReload: true,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Refreshing trade calendar data...'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Build loading state with progress indication
  Widget _buildLoadingState(BuildContext context, bool isRefresh) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(
          isRefresh ? 'Refreshing trade data...' : 'Loading trade calendar...',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Analyzing your trading patterns',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    ),
  );

  /// Build main content with universal calendar integration
  Widget _buildMainContent(
    BuildContext context,
    TradeCalendarViewModel viewModel,
    TradeCalendarCubit cubit,
  ) => Column(
    children: [
      if (_isCalendarExpanded) ...[
        _buildUniversalCalendarSection(context, cubit),
        const Divider(height: 1),
      ],
      Expanded(child: _buildTabContent(context, viewModel)),
    ],
  );

  /// Build universal calendar section with enhanced templates
  Widget _buildUniversalCalendarSection(
    BuildContext context,
    TradeCalendarCubit cubit,
  ) => Container(
    height: _isCalendarExpanded ? 400 : 0,
    padding: const EdgeInsets.all(16),
    child: Card(
      elevation: 2,
      child: UniversalCalendarWidget(
        onDateSelectionChanged: (selection) =>
            _onDateSelectionChanged(selection, cubit),
        context: 'trade_analytics',
        templateType: CalendarTemplateType.full,
        title: 'Trading Analytics Period',
        enableCardView: true,
        initialSelection: _currentDateSelection,
        cardConfigs: cubit.getUniversalCardConfigs(),
        dataProvider: TradeCalendarDataProvider(
          portfolioId: widget.portfolioId,
          mockData: _buildMockDataFromViewModel(cubit.currentViewModel),
        ),
      ),
    ),
  );

  /// Build tab content with analytics, events, and insights
  Widget _buildTabContent(
    BuildContext context,
    TradeCalendarViewModel viewModel,
  ) => Column(
    children: [
      TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Analytics', icon: Icon(Icons.analytics, size: 18)),
          Tab(text: 'Events', icon: Icon(Icons.event, size: 18)),
          Tab(text: 'Insights', icon: Icon(Icons.lightbulb, size: 18)),
        ],
      ),
      Expanded(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildAnalyticsTab(context, viewModel),
            _buildEventsTab(context, viewModel),
            _buildInsightsTab(context, viewModel),
          ],
        ),
      ),
    ],
  );

  /// Build comprehensive analytics tab
  Widget _buildAnalyticsTab(
    BuildContext context,
    TradeCalendarViewModel viewModel,
  ) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        _buildAnalyticsCards(context, viewModel),
        const SizedBox(height: 24),
        _buildPerformanceChart(context, viewModel),
        const SizedBox(height: 24),
        _buildTradingSummary(context, viewModel),
      ],
    ),
  );

  /// Build analytics summary cards
  Widget _buildAnalyticsCards(
    BuildContext context,
    TradeCalendarViewModel viewModel,
  ) => Row(
    children: [
      Expanded(
        child: _buildAnalyticsCard(
          context,
          'Total P&L',
          _formatCurrency(viewModel.totalPnL),
          viewModel.totalPnL >= 0 ? Colors.green : Colors.red,
          Icons.trending_up,
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: _buildAnalyticsCard(
          context,
          'Total Trades',
          '${viewModel.totalTradeCount}',
          Theme.of(context).colorScheme.primary,
          Icons.show_chart,
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: _buildAnalyticsCard(
          context,
          'Win Rate',
          '${(viewModel.overallWinRate * 100).toStringAsFixed(1)}%',
          viewModel.overallWinRate >= 0.5 ? Colors.green : Colors.orange,
          Icons.gps_fixed,
        ),
      ),
    ],
  );

  /// Build individual analytics card
  Widget _buildAnalyticsCard(
    BuildContext context,
    String title,
    String value,
    Color color,
    IconData icon,
  ) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );

  /// Build performance chart section
  Widget _buildPerformanceChart(
    BuildContext context,
    TradeCalendarViewModel viewModel,
  ) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Performance Overview',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.fullscreen),
                onPressed: () => _showFullscreenChart(context),
                tooltip: 'Expand Chart',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.show_chart, size: 48),
                  SizedBox(height: 8),
                  Text('Performance Chart'),
                  Text('Coming Soon', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );

  /// Build trading summary section
  Widget _buildTradingSummary(
    BuildContext context,
    TradeCalendarViewModel viewModel,
  ) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trading Summary',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
            context,
            'Total Trade Days',
            '${viewModel.totalTradeDays}',
            null,
          ),
          _buildSummaryRow(
            context,
            'Available Dates',
            '${viewModel.availableDates.length}',
            null,
          ),
          _buildSummaryRow(
            context,
            'Date Range',
            _formatDateRange(viewModel.dateRange),
            null,
          ),
          _buildSummaryRow(
            context,
            'Last Updated',
            _formatLastUpdated(viewModel.lastUpdated),
            null,
          ),
          _buildSummaryRow(
            context,
            'Portfolio ID',
            viewModel.portfolioId,
            null,
          ),
          _buildSummaryRow(
            context,
            'Data Points',
            '${viewModel.calendarData.length}',
            null,
          ),
        ],
      ),
    ),
  );

  /// Build summary row with color coding
  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value,
    Color? valueColor,
  ) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w600, color: valueColor),
        ),
      ],
    ),
  );

  /// Build events tab with enhanced filtering
  Widget _buildEventsTab(
    BuildContext context,
    TradeCalendarViewModel viewModel,
  ) {
    final events = _extractEventsFromCalendarData(viewModel.calendarData);
    final filteredEvents = _filterEvents(events);

    if (events.isEmpty) {
      return _buildEmptyEventsState(context, viewModel);
    }

    return Column(
      children: [
        _buildEventsFilter(context),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filteredEvents.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) =>
                _buildEventTile(context, filteredEvents[index]),
          ),
        ),
      ],
    );
  }

  /// Build events filter bar
  Widget _buildEventsFilter(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
    ),
    child: Row(
      children: [
        const Icon(Icons.filter_list, size: 20),
        const SizedBox(width: 8),
        const Text('Filters:'),
        const SizedBox(width: 16),
        FilterChip(
          label: const Text('All'),
          selected: _eventFilter == 'all',
          onSelected: (_) => setState(() => _eventFilter = 'all'),
        ),
        const SizedBox(width: 8),
        FilterChip(
          label: const Text('Profitable'),
          selected: _eventFilter == 'profitable',
          onSelected: (_) => setState(() => _eventFilter = 'profitable'),
        ),
        const SizedBox(width: 8),
        FilterChip(
          label: const Text('Losses'),
          selected: _eventFilter == 'losses',
          onSelected: (_) => setState(() => _eventFilter = 'losses'),
        ),
      ],
    ),
  );

  /// Filter events based on current filter
  List<SimpleTradeEvent> _filterEvents(List<SimpleTradeEvent> events) =>
      switch (_eventFilter) {
        'profitable' => events.where((e) => e.isProfit).toList(),
        'losses' => events.where((e) => !e.isProfit).toList(),
        _ => events,
      };

  /// Extract events from calendar data with enhanced processing
  List<SimpleTradeEvent> _extractEventsFromCalendarData(
    Map<String, List<CardData>> calendarData,
  ) {
    final events = <SimpleTradeEvent>[];

    calendarData.forEach((dateKey, cards) {
      final date = DateTime.parse(dateKey);

      for (final card in cards) {
        if (card is TradeCardData) {
          events.add(
            SimpleTradeEvent(
              date: date,
              title: 'Trade Summary - ${_formatDate(date)}',
              pnl: card.pnl,
              tradeCount: card.tradeCount,
              winCount: card.winCount,
              symbol: 'Multiple',
            ),
          );
        }
      }
    });

    events.sort((a, b) => b.date.compareTo(a.date));
    return events;
  }

  /// Build enhanced event tile
  Widget _buildEventTile(BuildContext context, SimpleTradeEvent event) {
    final isProfit = event.pnl >= 0;
    final profitColor = isProfit ? Colors.green : Colors.red;
    final winRate = event.tradeCount > 0
        ? event.winCount / event.tradeCount
        : 0.0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: profitColor.withOpacity(0.1),
          child: Icon(
            isProfit ? Icons.trending_up : Icons.trending_down,
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
            Text('Symbol: ${event.symbol}'),
            Text(
              'Trades: ${event.tradeCount} (${(winRate * 100).toStringAsFixed(1)}% win rate)',
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatCurrency(event.pnl),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: profitColor,
              ),
            ),
            Text(
              '${event.tradeCount} trades',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        onTap: () => _showEventDetails(context, event),
      ),
    );
  }

  /// Build insights tab with AI-powered recommendations
  Widget _buildInsightsTab(
    BuildContext context,
    TradeCalendarViewModel viewModel,
  ) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        _buildInsightCard(
          context,
          'Performance Insight',
          'Your win rate has improved by 5% this month compared to last month.',
          Icons.trending_up,
          Colors.green,
        ),
        const SizedBox(height: 16),
        _buildInsightCard(
          context,
          'Risk Management',
          'Consider reducing position size on losing streaks to preserve capital.',
          Icons.shield,
          Colors.orange,
        ),
        const SizedBox(height: 16),
        _buildInsightCard(
          context,
          'Pattern Recognition',
          'Your best trading days tend to be Tuesdays and Wednesdays.',
          Icons.psychology,
          Colors.blue,
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(Icons.lightbulb, size: 48, color: Colors.amber),
                const SizedBox(height: 16),
                Text(
                  'AI-Powered Insights',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Advanced analytics and personalized trading recommendations will be available here.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _showInsightDetails(context),
                  child: const Text('Learn More'),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  /// Build insight card
  Widget _buildInsightCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
  ) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
            onPressed: () => _showInsightDetails(context),
          ),
        ],
      ),
    ),
  );

  /// Build filtering state with overlay
  Widget _buildFilteringState(
    BuildContext context,
    TradeCalendarViewModel viewModel,
    TradeCalendarCubit cubit,
  ) => Stack(
    children: [
      _buildMainContent(context, viewModel, cubit),
      Container(
        color: Colors.black.withOpacity(0.1),
        child: const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Applying filter...'),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );

  /// Build refreshing state with indicator
  Widget _buildRefreshingState(
    BuildContext context,
    TradeCalendarViewModel viewModel,
    TradeCalendarCubit cubit,
  ) => Stack(
    children: [
      _buildMainContent(context, viewModel, cubit),
      Positioned(
        top: 16,
        right: 16,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Updating...'),
              ],
            ),
          ),
        ),
      ),
    ],
  );

  /// Build initial state
  Widget _buildInitialState(BuildContext context, TradeCalendarCubit cubit) =>
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Trade Calendar Analytics',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('Initialize calendar to view your trading analytics'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _initializeTradeCalendar,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Load Calendar'),
            ),
          ],
        ),
      );

  /// Build error state with retry option
  Widget _buildErrorState(
    BuildContext context,
    TradeCalendarCubit cubit,
    String message,
  ) => Center(
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
          message,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => cubit.retryLoad(
            userId: widget.userId,
            portfolioId: widget.portfolioId,
          ),
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      ],
    ),
  );

  /// Build empty events state
  Widget _buildEmptyEventsState(
    BuildContext context,
    TradeCalendarViewModel viewModel,
  ) => Center(
    child: Column(
      children: [
        const SizedBox(height: 32),
        Icon(
          Icons.event_busy,
          size: 64,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
        ),
        const SizedBox(height: 16),
        Text(
          'No trade events found',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          viewModel.dateFilter != null
              ? 'Try adjusting your date range to find events'
              : 'No trading activity in this portfolio',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 32),
      ],
    ),
  );

  /// Show enhanced event details dialog
  void _showEventDetails(BuildContext context, SimpleTradeEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              event.isProfit ? Icons.trending_up : Icons.trending_down,
              color: event.isProfit ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(event.title)),
          ],
        ),
        content: SizedBox(
          width: 350,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Date', _formatDate(event.date)),
              _buildDetailRow('Symbol', event.symbol),
              _buildDetailRow('Total Trades', '${event.tradeCount}'),
              _buildDetailRow('Winning Trades', '${event.winCount}'),
              _buildDetailRow(
                'Win Rate',
                '${(event.winRate * 100).toStringAsFixed(1)}%',
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'P&L:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    _formatCurrency(event.pnl),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: event.isProfit ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to detailed trade view
            },
            child: const Text('View Details'),
          ),
        ],
      ),
    );
  }

  /// Build detail row for dialog
  Widget _buildDetailRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    ),
  );

  /// Show fullscreen chart
  void _showFullscreenChart(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Performance Chart'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.show_chart, size: 96),
                SizedBox(height: 16),
                Text('Full-screen Performance Chart'),
                Text('Coming Soon', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Show insight details
  void _showInsightDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Insights'),
        content: const Text(
          'Detailed insights and recommendations will be available soon.',
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

  /// Export data functionality
  void _exportData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.table_chart),
              title: Text('Export to CSV'),
              subtitle: Text('Download trade data as spreadsheet'),
            ),
            ListTile(
              leading: Icon(Icons.picture_as_pdf),
              title: Text('Export to PDF'),
              subtitle: Text('Generate comprehensive report'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Build mock data from view model for universal calendar data provider
  Map<String, dynamic> _buildMockDataFromViewModel(
    TradeCalendarViewModel? viewModel,
  ) {
    if (viewModel == null) {
      return <String, List<Map<String, dynamic>>>{};
    }

    final mockData = <String, List<Map<String, dynamic>>>{};
    final trades = <Map<String, dynamic>>[];

    // Extract data from calendar data map
    viewModel.calendarData.forEach((dateKey, cards) {
      for (final card in cards) {
        if (card is TradeCardData) {
          trades.add({
            'tradeId': dateKey.hashCode.toString(),
            'portfolioId': widget.portfolioId,
            'status': card.pnl >= 0 ? 'WIN' : 'LOSS',
            'tradePositionType': 'LONG',
            'entryInfo': {'quantity': 100, 'price': 50.0, 'fees': 2.0},
            'exitInfo': {
              'quantity': 100,
              'price': card.pnl >= 0 ? 55.0 : 45.0,
              'fees': 2.0,
            },
            'metrics': {
              'totalPnL': card.pnl,
              'returnPercent': card.pnl >= 0 ? 5.0 : -5.0,
            },
            'tradeDate': dateKey,
            'tradeEndDate': dateKey,
            'symbol': 'Multiple',
            'description': 'Trade summary for $dateKey',
          });
        }
      }
    });

    mockData[widget.portfolioId] = trades;
    return mockData;
  }

  /// Format currency value with proper symbols
  String _formatCurrency(double value) {
    final isNegative = value < 0;
    final absValue = value.abs();
    final sign = isNegative ? '-' : '+';
    return '$sign\$${absValue.toStringAsFixed(2)}';
  }

  /// Format date for display
  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  /// Format date range for display
  String _formatDateRange(DateSelection? dateRange) {
    if (dateRange == null) return 'No data';
    final startDate = dateRange.startDate;
    final endDate = dateRange.endDate;
    if (startDate == null || endDate == null) return 'Invalid range';
    return '${_formatDate(startDate)} - ${_formatDate(endDate)}';
  }

  /// Format last updated time
  String _formatLastUpdated(DateTime? lastUpdated) {
    if (lastUpdated == null) return 'Never';
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}
