import '../../internal/domain/entities/trade_calendar.dart';
import '../../internal/domain/entities/trade_holding.dart';

/// View model for trade calendar event presentation
class TradeCalendarEventViewModel {
  const TradeCalendarEventViewModel({
    required this.id,
    required this.title,
    required this.date,
    required this.type,
    this.description,
    this.symbol,
    this.amount,
    this.status,
    this.profitLoss,
    this.profitLossPercentage,
  });

  /// Factory from domain entity
  factory TradeCalendarEventViewModel.fromEntity(TradeCalendarEvent entity) {
    // Generate title from available data
    var title = entity.symbol ?? 'Trade Event';
    if (entity.status != null) {
      title = '$title - ${entity.status}';
    }

    // Generate type from status or default
    final type = entity.status ?? 'TRADE';

    // Generate description
    String? description;
    if (entity.profitLoss != null && entity.profitLossPercentage != null) {
      description =
          'P&L: \$${entity.profitLoss!.toStringAsFixed(2)} (${entity.profitLossPercentage!.toStringAsFixed(2)}%)';
    }

    return TradeCalendarEventViewModel(
      id: entity.id,
      title: title,
      date: entity.date,
      type: type,
      description: description,
      symbol: entity.symbol,
      amount: entity.amount,
      status: entity.status,
      profitLoss: entity.profitLoss,
      profitLossPercentage: entity.profitLossPercentage,
    );
  }

  /// Convert from TradeHolding to calendar event (for calendar view)
  factory TradeCalendarEventViewModel.fromTradeHolding(TradeHolding holding) {
    final instrument = holding.instrumentInfo;
    final metrics = holding.metrics;

    var title = instrument?.symbol ?? 'Trade';
    if (holding.status != null) {
      title = '$title - ${holding.status}';
    }

    String? description;
    if (metrics?.profitLoss != null && metrics?.profitLossPercentage != null) {
      description =
          'P&L: \$${metrics!.profitLoss!.toStringAsFixed(2)} (${metrics.profitLossPercentage!.toStringAsFixed(2)}%)';
    }

    return TradeCalendarEventViewModel(
      id: holding.tradeId,
      title: title,
      date: holding.tradeDate ?? holding.tradeEndDate ?? DateTime.now(),
      type: holding.status ?? 'TRADE',
      description: description,
      symbol: instrument?.symbol,
      amount: metrics?.profitLoss,
      status: holding.status,
      profitLoss: metrics?.profitLoss,
      profitLossPercentage: metrics?.profitLossPercentage,
    );
  }

  final String id;
  final String title;
  final DateTime date;
  final String type;
  final String? description;
  final String? symbol;
  final double? amount;
  final String? status;
  final double? profitLoss;
  final double? profitLossPercentage;

  /// Computed properties
  String get displayDate => '${date.month}/${date.day}/${date.year}';
  String get displayAmount =>
      amount != null ? '\$${amount!.toStringAsFixed(2)}' : 'N/A';
  String get displayProfitLoss =>
      profitLoss != null ? '\$${profitLoss!.toStringAsFixed(2)}' : 'N/A';
  bool get isProfit => (profitLoss ?? 0) >= 0;

  static List<TradeCalendarEventViewModel> fromEntityList(
    List<TradeCalendarEvent> entities,
  ) => entities.map(TradeCalendarEventViewModel.fromEntity).toList();

  static List<TradeCalendarEventViewModel> fromTradeHoldingList(
    List<TradeHolding> holdings,
  ) => holdings.map(TradeCalendarEventViewModel.fromTradeHolding).toList();
}

/// Trade analytics summary for the calendar
class TradeAnalyticsSummary {
  const TradeAnalyticsSummary({
    required this.totalTrades,
    required this.winningTrades,
    required this.losingTrades,
    required this.breakEvenTrades,
    required this.totalProfitLoss,
    required this.totalRiskAmount,
    required this.totalRewardAmount,
    required this.averageRiskRewardRatio,
    required this.winRate,
    required this.averageHoldingTimeDays,
    required this.averageReturnOnEquity,
    required this.totalTradedValue,
    required this.uniqueSymbolsCount,
    required this.profitableDays,
    required this.losingDays,
  });

  final int totalTrades;
  final int winningTrades;
  final int losingTrades;
  final int breakEvenTrades;
  final double totalProfitLoss;
  final double totalRiskAmount;
  final double totalRewardAmount;
  final double averageRiskRewardRatio;
  final double winRate;
  final double averageHoldingTimeDays;
  final double averageReturnOnEquity;
  final double totalTradedValue;
  final int uniqueSymbolsCount;
  final int profitableDays;
  final int losingDays;

  // Computed properties
  double get lossRate =>
      totalTrades > 0 ? (losingTrades / totalTrades) * 100 : 0;
  double get averageProfitPerTrade =>
      totalTrades > 0 ? totalProfitLoss / totalTrades : 0;
  double get averageWin => winningTrades > 0
      ? totalProfitLoss > 0
            ? totalProfitLoss / winningTrades
            : 0
      : 0;
  double get averageLoss => losingTrades > 0
      ? totalProfitLoss < 0
            ? totalProfitLoss.abs() / losingTrades
            : 0
      : 0;
  double get profitFactor => averageLoss > 0 ? averageWin / averageLoss : 0;

  // Formatting helpers
  String get formattedTotalProfitLoss => totalProfitLoss >= 0
      ? '+₹${totalProfitLoss.toStringAsFixed(2)}'
      : '-₹${totalProfitLoss.abs().toStringAsFixed(2)}';
  String get formattedWinRate => '${winRate.toStringAsFixed(1)}%';
  String get formattedLossRate => '${lossRate.toStringAsFixed(1)}%';
  String get formattedAverageProfit =>
      '₹${averageProfitPerTrade.toStringAsFixed(2)}';
  String get formattedProfitFactor => profitFactor.toStringAsFixed(2);
  String get formattedRiskRewardRatio =>
      '1:${averageRiskRewardRatio.toStringAsFixed(2)}';
}

/// View model for trade calendar
class TradeCalendarViewModel {
  const TradeCalendarViewModel({
    required this.userId,
    required this.portfolioId,
    required this.events,
    required this.analytics,
    this.totalEvents = 0,
    this.startDate,
    this.endDate,
    this.selectedStartDate,
    this.selectedEndDate,
  });

  /// Empty state
  factory TradeCalendarViewModel.empty(String userId, String portfolioId) =>
      TradeCalendarViewModel(
        userId: userId,
        portfolioId: portfolioId,
        events: [],
        analytics: const TradeAnalyticsSummary(
          totalTrades: 0,
          winningTrades: 0,
          losingTrades: 0,
          breakEvenTrades: 0,
          totalProfitLoss: 0,
          totalRiskAmount: 0,
          totalRewardAmount: 0,
          averageRiskRewardRatio: 0,
          winRate: 0,
          averageHoldingTimeDays: 0,
          averageReturnOnEquity: 0,
          totalTradedValue: 0,
          uniqueSymbolsCount: 0,
          profitableDays: 0,
          losingDays: 0,
        ),
      );

  /// Factory from domain entity
  factory TradeCalendarViewModel.fromEntity(
    TradeCalendar entity, {
    String? userId,
    String? portfolioId,
    DateTime? selectedStartDate,
    DateTime? selectedEndDate,
  }) {
    final allEvents = <TradeCalendarEventViewModel>[];
    final allTrades = entity.allTrades;

    // Filter trades by date range if selected
    final filteredTrades =
        (selectedStartDate != null && selectedEndDate != null)
        ? entity.getTradesByDateRange(selectedStartDate, selectedEndDate)
        : allTrades;

    // Convert filtered trades to calendar events
    for (final trade in filteredTrades) {
      // Create event from trade detail
      final event = TradeCalendarEvent.fromTradeDetail(trade);
      allEvents.add(TradeCalendarEventViewModel.fromEntity(event));

      // Create events from individual executions
      for (final execution in trade.tradeExecutions) {
        final executionEvent = TradeCalendarEvent.fromTradeExecution(
          execution,
          trade.portfolioId,
        );
        allEvents.add(TradeCalendarEventViewModel.fromEntity(executionEvent));
      }
    }

    // Sort events by date
    allEvents.sort((a, b) => a.date.compareTo(b.date));

    // Calculate analytics from filtered trades
    final analytics = _calculateAnalytics(filteredTrades);

    // Calculate date range from events
    DateTime? startDate;
    DateTime? endDate;
    if (allEvents.isNotEmpty) {
      startDate = allEvents.first.date;
      endDate = allEvents.last.date;
    }

    return TradeCalendarViewModel(
      userId: userId ?? 'unknown',
      portfolioId: portfolioId ?? 'unknown',
      events: allEvents,
      analytics: analytics,
      totalEvents: allEvents.length,
      startDate: startDate,
      endDate: endDate,
      selectedStartDate: selectedStartDate,
      selectedEndDate: selectedEndDate,
    );
  }

  /// Calculate comprehensive analytics from trades
  static TradeAnalyticsSummary _calculateAnalytics(List<dynamic> trades) {
    if (trades.isEmpty) {
      return const TradeAnalyticsSummary(
        totalTrades: 0,
        winningTrades: 0,
        losingTrades: 0,
        breakEvenTrades: 0,
        totalProfitLoss: 0,
        totalRiskAmount: 0,
        totalRewardAmount: 0,
        averageRiskRewardRatio: 0,
        winRate: 0,
        averageHoldingTimeDays: 0,
        averageReturnOnEquity: 0,
        totalTradedValue: 0,
        uniqueSymbolsCount: 0,
        profitableDays: 0,
        losingDays: 0,
      );
    }

    // Convert to TradeDetail if needed
    final tradeDetails = trades.whereType<dynamic>().toList();

    final totalTrades = tradeDetails.length;
    var winningTrades = 0;
    var losingTrades = 0;
    var breakEvenTrades = 0;
    var totalProfitLoss = 0.0;
    var totalRiskAmount = 0.0;
    var totalRewardAmount = 0.0;
    var totalRiskRewardRatio = 0.0;
    var totalHoldingTimeDays = 0.0;
    var totalReturnOnEquity = 0.0;
    var totalTradedValue = 0.0;
    final uniqueSymbols = <String>{};
    final dailyPnL = <String, double>{};

    for (final trade in tradeDetails) {
      // Access trade properties dynamically to handle TradeDetail
      final metrics = trade.metrics;
      final instrumentInfo = trade.instrumentInfo;
      final entryInfo = trade.entryInfo;

      final profitLoss = metrics.profitLoss as double;

      // Count win/loss/breakeven
      if (profitLoss > 0) {
        winningTrades++;
      } else if (profitLoss < 0) {
        losingTrades++;
      } else {
        breakEvenTrades++;
      }

      // Accumulate totals
      totalProfitLoss += profitLoss;
      totalRiskAmount += metrics.riskAmount as double;
      totalRewardAmount += metrics.rewardAmount as double;
      totalRiskRewardRatio += metrics.riskRewardRatio as double;
      totalHoldingTimeDays += (metrics.holdingTimeDays as int).toDouble();
      totalReturnOnEquity += metrics.returnOnEquity as double;
      totalTradedValue += entryInfo.totalValue as double;

      // Track unique symbols
      uniqueSymbols.add(instrumentInfo.symbol as String);

      // Track daily P&L
      final dateKey = (trade.tradeDate as DateTime).toIso8601String().substring(
        0,
        10,
      );
      dailyPnL[dateKey] = (dailyPnL[dateKey] ?? 0) + profitLoss;
    }

    // Count profitable and losing days
    final profitableDays = dailyPnL.values.where((pnl) => pnl > 0).length;
    final losingDays = dailyPnL.values.where((pnl) => pnl < 0).length;

    return TradeAnalyticsSummary(
      totalTrades: totalTrades,
      winningTrades: winningTrades,
      losingTrades: losingTrades,
      breakEvenTrades: breakEvenTrades,
      totalProfitLoss: totalProfitLoss,
      totalRiskAmount: totalRiskAmount,
      totalRewardAmount: totalRewardAmount,
      averageRiskRewardRatio: totalTrades > 0
          ? totalRiskRewardRatio / totalTrades
          : 0,
      winRate: totalTrades > 0 ? (winningTrades / totalTrades) * 100 : 0,
      averageHoldingTimeDays: totalTrades > 0
          ? totalHoldingTimeDays / totalTrades
          : 0,
      averageReturnOnEquity: totalTrades > 0
          ? totalReturnOnEquity / totalTrades
          : 0,
      totalTradedValue: totalTradedValue,
      uniqueSymbolsCount: uniqueSymbols.length,
      profitableDays: profitableDays,
      losingDays: losingDays,
    );
  }

  final String userId;
  final String portfolioId;
  final List<TradeCalendarEventViewModel> events;
  final TradeAnalyticsSummary analytics;
  final int totalEvents;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;

  /// Computed properties
  int get displayCount => events.length;
  String get displayDateRange {
    if (selectedStartDate != null && selectedEndDate != null) {
      return '${selectedStartDate!.month}/${selectedStartDate!.day} - ${selectedEndDate!.month}/${selectedEndDate!.day}';
    }
    if (startDate != null && endDate != null) {
      return '${startDate!.month}/${startDate!.day} - ${endDate!.month}/${endDate!.day}';
    }
    return 'All Time';
  }

  /// Check if date filter is applied
  bool get hasDateFilter =>
      selectedStartDate != null && selectedEndDate != null;

  /// Get events by date
  List<TradeCalendarEventViewModel> getEventsForDate(DateTime date) => events
      .where(
        (event) =>
            event.date.year == date.year &&
            event.date.month == date.month &&
            event.date.day == date.day,
      )
      .toList();

  /// Get events by type
  List<TradeCalendarEventViewModel> getEventsByType(String type) => events
      .where((event) => event.type.toUpperCase() == type.toUpperCase())
      .toList();

  /// Get profit events
  List<TradeCalendarEventViewModel> get profitEvents =>
      events.where((event) => (event.profitLoss ?? 0) > 0).toList();

  /// Get loss events
  List<TradeCalendarEventViewModel> get lossEvents =>
      events.where((event) => (event.profitLoss ?? 0) < 0).toList();

  /// Create a copy with new date range
  TradeCalendarViewModel copyWithDateRange(
    DateTime? startDate,
    DateTime? endDate,
  ) => TradeCalendarViewModel(
    userId: userId,
    portfolioId: portfolioId,
    events: events,
    analytics: analytics,
    totalEvents: totalEvents,
    startDate: this.startDate,
    endDate: this.endDate,
    selectedStartDate: startDate,
    selectedEndDate: endDate,
  );
}
