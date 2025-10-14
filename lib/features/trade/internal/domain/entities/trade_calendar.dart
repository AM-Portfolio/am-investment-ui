import 'package:freezed_annotation/freezed_annotation.dart';

part 'trade_calendar.freezed.dart';

/// Trade execution entity for domain logic
@freezed
class TradeExecution with _$TradeExecution {
  const factory TradeExecution({
    required TradeBasicInfo basicInfo,
    required TradeInstrumentInfo instrumentInfo,
    required TradeExecutionInfo executionInfo,
  }) = _TradeExecution;
}

/// Basic trade information entity
@freezed
class TradeBasicInfo with _$TradeBasicInfo {
  const factory TradeBasicInfo({
    required String tradeId,
    required String orderId,
    required DateTime tradeDate,
    required DateTime orderExecutionTime,
    required String brokerType,
    required String tradeType,
  }) = _TradeBasicInfo;
}

/// Trade execution information entity
@freezed
class TradeExecutionInfo with _$TradeExecutionInfo {
  const factory TradeExecutionInfo({
    required String tradeType,
    required bool auction,
    required int quantity,
    required double price,
  }) = _TradeExecutionInfo;
}

/// Instrument information entity
@freezed
class TradeInstrumentInfo with _$TradeInstrumentInfo {
  const factory TradeInstrumentInfo({
    required String symbol,
    required String isin,
    required String exchange,
    required String segment,
    required String series,
    required String baseSymbol,
    required String formattedDescription,
    required bool derivative,
    required bool index,
    String? rawSymbol,
    String? description,
  }) = _TradeInstrumentInfo;
}

/// Trade position information (entry/exit) entity
@freezed
class TradePositionInfo with _$TradePositionInfo {
  const factory TradePositionInfo({
    required DateTime timestamp,
    required double price,
    required int quantity,
    required double totalValue,
    required double fees,
  }) = _TradePositionInfo;
}

/// Trade metrics entity
@freezed
class TradeMetrics with _$TradeMetrics {
  const factory TradeMetrics({
    required double profitLoss,
    required double profitLossPercentage,
    required double returnOnEquity,
    required double riskAmount,
    required double rewardAmount,
    required double riskRewardRatio,
    required int holdingTimeDays,
    required int holdingTimeHours,
    required int holdingTimeMinutes,
    double? maxAdverseExcursion,
    double? maxFavorableExcursion,
  }) = _TradeMetrics;
}

/// Trade status enumeration
enum TradeStatus {
  win,
  loss,
  breakEven;

  static TradeStatus fromString(String status) =>
      switch (status.toUpperCase()) {
        'WIN' => TradeStatus.win,
        'LOSS' => TradeStatus.loss,
        'BREAK_EVEN' => TradeStatus.breakEven,
        _ => TradeStatus.breakEven,
      };
}

/// Trade position type enumeration
enum TradePositionType {
  long,
  short;

  static TradePositionType fromString(String type) =>
      switch (type.toUpperCase()) {
        'LONG' => TradePositionType.long,
        'SHORT' => TradePositionType.short,
        _ => TradePositionType.long,
      };
}

/// Individual trade detail entity
@freezed
class TradeDetail with _$TradeDetail {
  const factory TradeDetail({
    required String tradeId,
    required String portfolioId,
    required TradeInstrumentInfo instrumentInfo,
    required TradeStatus status,
    required TradePositionType tradePositionType,
    required TradePositionInfo entryInfo,
    required TradePositionInfo exitInfo,
    required TradeMetrics metrics,
    required List<TradeExecution> tradeExecutions,
    required DateTime tradeDate,
    required DateTime tradeEndDate,
    @Default({}) Map<String, dynamic> psychologyData,
    @Default({}) Map<String, dynamic> entryReasoning,
    @Default({}) Map<String, dynamic> exitReasoning,
  }) = _TradeDetail;

  const TradeDetail._();

  /// Get the primary execution (usually the first one)
  TradeExecution? get primaryExecution =>
      tradeExecutions.isNotEmpty ? tradeExecutions.first : null;

  /// Get all buy executions
  List<TradeExecution> get buyExecutions => tradeExecutions
      .where((e) => e.executionInfo.tradeType.toUpperCase() == 'BUY')
      .toList();

  /// Get all sell executions
  List<TradeExecution> get sellExecutions => tradeExecutions
      .where((e) => e.executionInfo.tradeType.toUpperCase() == 'SELL')
      .toList();

  /// Calculate total quantity from all executions
  int get totalQuantity =>
      tradeExecutions.fold(0, (sum, e) => sum + e.executionInfo.quantity);

  /// Calculate average entry price
  double get averageEntryPrice => entryInfo.price;

  /// Calculate average exit price
  double get averageExitPrice => exitInfo.price;

  /// Check if this is a profitable trade
  bool get isProfitable => metrics.profitLoss > 0;

  /// Check if this is a loss trade
  bool get isLoss => metrics.profitLoss < 0;

  /// Check if this is a break-even trade
  bool get isBreakEven => metrics.profitLoss == 0;

  /// Get trade duration in readable format
  String get tradeDurationString {
    if (metrics.holdingTimeDays > 0) {
      return '${metrics.holdingTimeDays}d ${metrics.holdingTimeHours}h ${metrics.holdingTimeMinutes}m';
    } else if (metrics.holdingTimeHours > 0) {
      return '${metrics.holdingTimeHours}h ${metrics.holdingTimeMinutes}m';
    } else {
      return '${metrics.holdingTimeMinutes}m';
    }
  }

  /// Get formatted profit/loss string with currency
  String get formattedProfitLoss {
    final sign = metrics.profitLoss >= 0 ? '+' : '';
    return '$sign₹${metrics.profitLoss.toStringAsFixed(2)}';
  }

  /// Get formatted percentage string
  String get formattedProfitLossPercentage {
    final sign = metrics.profitLossPercentage >= 0 ? '+' : '';
    return '$sign${metrics.profitLossPercentage.toStringAsFixed(2)}%';
  }
}

/// Trade calendar entity representing calendar data from the domain perspective
@freezed
class TradeCalendar with _$TradeCalendar {
  const factory TradeCalendar({
    required Map<String, List<TradeDetail>> portfolioTrades,
  }) = _TradeCalendar;

  const TradeCalendar._();

  /// Get all trades from all portfolios as a flat list
  List<TradeDetail> get allTrades {
    final trades = <TradeDetail>[];
    for (final portfolioTradeList in portfolioTrades.values) {
      trades.addAll(portfolioTradeList);
    }
    return trades;
  }

  /// Get trades for a specific portfolio
  List<TradeDetail> getTradesForPortfolio(String portfolioId) =>
      portfolioTrades[portfolioId] ?? [];

  /// Get trades by date range
  List<TradeDetail> getTradesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) => allTrades
      .where(
        (trade) =>
            trade.tradeDate.isAfter(
              startDate.subtract(const Duration(days: 1)),
            ) &&
            trade.tradeDate.isBefore(endDate.add(const Duration(days: 1))),
      )
      .toList();

  /// Get trades by status
  List<TradeDetail> getTradesByStatus(TradeStatus status) =>
      allTrades.where((trade) => trade.status == status).toList();

  /// Get trades by symbol
  List<TradeDetail> getTradesBySymbol(String symbol) => allTrades
      .where(
        (trade) =>
            trade.instrumentInfo.symbol.toUpperCase() == symbol.toUpperCase(),
      )
      .toList();

  /// Get total number of trades
  int get totalTradesCount => allTrades.length;

  /// Get total profit/loss across all trades
  double get totalProfitLoss =>
      allTrades.fold(0.0, (sum, trade) => sum + trade.metrics.profitLoss);

  /// Get winning trades count
  int get winningTradesCount =>
      allTrades.where((trade) => trade.isProfitable).length;

  /// Get losing trades count
  int get losingTradesCount => allTrades.where((trade) => trade.isLoss).length;

  /// Get break-even trades count
  int get breakEvenTradesCount =>
      allTrades.where((trade) => trade.isBreakEven).length;

  /// Calculate win rate percentage
  double get winRate {
    if (totalTradesCount == 0) return 0.0;
    return (winningTradesCount / totalTradesCount) * 100;
  }

  /// Get unique symbols traded
  Set<String> get uniqueSymbols =>
      allTrades.map((trade) => trade.instrumentInfo.symbol).toSet();

  /// Get unique portfolios
  Set<String> get portfolioIds => portfolioTrades.keys.toSet();
}
