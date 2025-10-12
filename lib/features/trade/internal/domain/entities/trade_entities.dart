import 'package:freezed_annotation/freezed_annotation.dart';

part 'trade_entities.freezed.dart';

// Trade Portfolio Summary Entity (following portfolio summary pattern)
@freezed
class TradePortfolioSummary with _$TradePortfolioSummary {
  const factory TradePortfolioSummary({
    required String portfolioId,
    required String portfolioName,
    required String ownerId,
    required double totalValue,
    required double totalReturn,
    required double totalReturnPercentage,
    required int totalTrades,
    required int activeTrades,
    required DateTime lastUpdated,
  }) = _TradePortfolioSummary;

  const TradePortfolioSummary._();

  // Business logic methods (same pattern as portfolio)
  bool get isPositiveReturn => totalReturn > 0;
  bool get hasActiveTrades => activeTrades > 0;
  String get performanceStatus => isPositiveReturn ? 'Profit' : 'Loss';
  double get averageTradeValue => totalTrades > 0 ? totalValue / totalTrades : 0;
}

// Trade Holding Entity (following portfolio holding pattern)
@freezed
class TradeHolding with _$TradeHolding {
  const factory TradeHolding({
    required String tradeId,
    required String portfolioId,
    required String symbol,
    required String instrumentName,
    required TradeType tradeType,
    required double quantity,
    required double entryPrice,
    double? exitPrice,
    required DateTime entryDate,
    DateTime? exitDate,
    required TradeStatus status,
    required double currentValue,
    required double unrealizedPnL,
    required double realizedPnL,
  }) = _TradeHolding;

  const TradeHolding._();

  // Business logic methods (same pattern as portfolio holdings)
  double get totalPnL => unrealizedPnL + realizedPnL;
  double get returnPercentage => (totalPnL / (entryPrice * quantity)) * 100;
  bool get isProfitable => totalPnL > 0;
  bool get isOpenTrade => status == TradeStatus.open;
  Duration get holdingPeriod => (exitDate ?? DateTime.now()).difference(entryDate);
}

// Enums (following portfolio enum patterns)
enum TradeType { buy, sell, short, cover }
enum TradeStatus { open, closed, pending, cancelled }
  }) = _RiskMetrics;

  void RiskMetrics._();

  bool get isHighRisk => riskLevel == 'HIGH' || var95 > 0.05;
  bool get isLowRisk => riskLevel == 'LOW' && var95 < 0.02;
}

// Asset Allocation Entity
@freezed
class AssetAllocation with _$AssetAllocation {
  const factory AssetAllocation({
    required String name,
    required double value,
    required double percentage,
    required AllocationCategory category,
    String? color,
  }) = _AssetAllocation;

  const AssetAllocation._();

  bool get isSignificantAllocation => percentage > 5.0;
  String get displayPercentage => '${percentage.toStringAsFixed(1)}%';
}

// Allocation Category Enum
enum AllocationCategory { sector, assetClass, geography, marketCap }

// Trade Holding Entity
@freezed
class TradeHolding with _$TradeHolding {
  const factory TradeHolding({
    required String tradeId,
    required String portfolioId,
    required String symbol,
    required String instrumentName,
    required TradeType tradeType,
    required double quantity,
    required double entryPrice,
    required DateTime entryDate,
    required TradeStatus status,
    required double currentValue,
    required double unrealizedPnL,
    required double realizedPnL,
    required InstrumentDetails instrumentDetails,
    required List<ExecutionDetail> executionDetails,
    double? exitPrice,
    DateTime? exitDate,
  }) = _TradeHolding;

  const TradeHolding._();

  // Business logic methods
  double get totalPnL => unrealizedPnL + realizedPnL;
  double get returnPercentage => (totalPnL / (entryPrice * quantity)) * 100;
  bool get isProfitable => totalPnL > 0;
  bool get isOpenTrade => status == TradeStatus.open;
  Duration get holdingPeriod =>
      (exitDate ?? DateTime.now()).difference(entryDate);
  double get averageExecutionPrice => executionDetails.isNotEmpty
      ? executionDetails
                .map((e) => e.price * e.quantity)
                .reduce((a, b) => a + b) /
            executionDetails.map((e) => e.quantity).reduce((a, b) => a + b)
      : entryPrice;
}

// Trade Type Enum
enum TradeType { buy, sell, short, cover }

// Trade Status Enum
enum TradeStatus { open, closed, pending, cancelled }

// Instrument Details Value Object
@freezed
class InstrumentDetails with _$InstrumentDetails {
  const factory InstrumentDetails({
    required String symbol,
    required String name,
    required String sector,
    required String exchange,
    required String currency,
    required InstrumentType instrumentType,
    required MarketData marketData,
    FundamentalData? fundamentalData,
  }) = _InstrumentDetails;
}

// Instrument Type Enum
enum InstrumentType { stock, bond, etf, option, future, crypto }

// Market Data Value Object
@freezed
class MarketData with _$MarketData {
  const factory MarketData({
    required double currentPrice,
    required double dayChange,
    required double dayChangePercentage,
    required double volume,
    required double marketCap,
    required DateTime lastUpdated,
  }) = _MarketData;
}

// Fundamental Data Value Object
@freezed
class FundamentalData with _$FundamentalData {
  const factory FundamentalData({
    double? peRatio,
    double? pbRatio,
    double? dividendYield,
    double? epsGrowth,
    double? debtToEquity,
  }) = _FundamentalData;
}

// Execution Detail Entity
@freezed
class ExecutionDetail with _$ExecutionDetail {
  const factory ExecutionDetail({
    required String executionId,
    required String tradeId,
    required DateTime executionDate,
    required ExecutionType executionType,
    required double quantity,
    required double price,
    required double commission,
    required double fees,
    required String venue,
    Map<String, dynamic>? executionMetadata,
  }) = _ExecutionDetail;

  const ExecutionDetail._();

  double get totalCost => (price * quantity) + commission + fees;
  double get netAmount => (price * quantity) - commission - fees;
}

// Execution Type Enum
enum ExecutionType { buy, sell, partialFill, fullFill }

// Calendar Trade Entity
@freezed
class CalendarTrade with _$CalendarTrade {
  const factory CalendarTrade({
    required String tradeId,
    required DateTime date,
    required String symbol,
    required TradeType type,
    required double quantity,
    required double price,
    required TradeStatus status,
    Map<String, dynamic>? metadata,
  }) = _CalendarTrade;

  const CalendarTrade._();

  double get tradeValue => quantity * price;
  bool get isSignificantTrade => tradeValue > 10000; // Configurable threshold
}

// Calendar Data Entity
@freezed
class CalendarData with _$CalendarData {
  const factory CalendarData({
    required Map<String, List<CalendarTrade>> portfolioTrades,
    required DateTime startDate,
    required DateTime endDate,
    required CalendarViewType viewType,
    required CalendarSummary summary,
  }) = _CalendarData;

  const CalendarData._();

  List<CalendarTrade> getTradesForDate(DateTime date) {
    final dateKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return portfolioTrades[dateKey] ?? [];
  }

  int get totalTradesInPeriod =>
      portfolioTrades.values.expand((trades) => trades).length;

  double get totalVolumeInPeriod => portfolioTrades.values
      .expand((trades) => trades)
      .map((trade) => trade.tradeValue)
      .fold(0, (sum, value) => sum + value);
}

// Calendar View Type Enum
enum CalendarViewType { month, day, quarter, financialYear }

// Calendar Summary Value Object
@freezed
class CalendarSummary with _$CalendarSummary {
  const factory CalendarSummary({
    required int totalTrades,
    required double totalVolume,
    required double averageTradeSize,
    required int tradingDays,
    required double dailyAverageVolume,
  }) = _CalendarSummary;
}

// Portfolio List Entity (for discovery)
@freezed
class PortfolioList with _$PortfolioList {
  const factory PortfolioList({
    required List<PortfolioSummary> portfolios,
    required int totalCount,
    required String ownerId,
    required AggregateMetrics aggregateMetrics,
  }) = _PortfolioList;
}

// Portfolio Summary Entity (for discovery)
@freezed
class PortfolioSummary with _$PortfolioSummary {
  const factory PortfolioSummary({
    required String portfolioId,
    required String portfolioName,
    required String description,
    required double totalValue,
    required double totalReturn,
    required double totalReturnPercentage,
    required int tradeCount,
    required DateTime lastTradeDate,
    required RiskLevel riskLevel,
    required Map<String, double> keyMetrics,
  }) = _PortfolioSummary;

  const PortfolioSummary._();

  bool get isActivePortfolio =>
      DateTime.now().difference(lastTradeDate).inDays <= 30;
  String get performanceIndicator => totalReturn > 0 ? '↗' : '↘';
}

// Risk Level Enum
enum RiskLevel { low, medium, high, veryHigh }

// Aggregate Metrics Value Object
@freezed
class AggregateMetrics with _$AggregateMetrics {
  const factory AggregateMetrics({
    required double totalAUM,
    required double totalReturn,
    required double averageReturn,
    required int totalTrades,
    required int activePortfolios,
  }) = _AggregateMetrics;
}
