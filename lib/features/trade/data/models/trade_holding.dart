import 'package:freezed_annotation/freezed_annotation.dart';

part 'trade_holding.freezed.dart';
part 'trade_holding.g.dart';

@freezed
class TradeHolding with _$TradeHolding {
  const factory TradeHolding({
    required String tradeId,
    required String portfolioId,
    required InstrumentInfo instrumentInfo,
    required String status,
    required String tradePositionType,
    required TradeInfo entryInfo,
    required TradeInfo exitInfo,
    required TradeMetrics metrics,
    required List<TradeExecution> tradeExecutions,
    Map<String, dynamic>? psychologyData,
    Map<String, dynamic>? entryReasoning,
    Map<String, dynamic>? exitReasoning,
    String? tradeEndDate,
    String? tradeDate,
  }) = _TradeHolding;

  factory TradeHolding.fromJson(Map<String, dynamic> json) =>
      _$TradeHoldingFromJson(json);
}

@freezed
class InstrumentInfo with _$InstrumentInfo {
  const factory InstrumentInfo({
    required String symbol,
    String? isin,
    String? rawSymbol,
    required String exchange,
    required String segment,
    String? series,
    String? description,
    String? baseSymbol,
    String? formattedDescription,
    required bool derivative,
    required bool index,
  }) = _InstrumentInfo;

  factory InstrumentInfo.fromJson(Map<String, dynamic> json) =>
      _$InstrumentInfoFromJson(json);
}

@freezed
class TradeInfo with _$TradeInfo {
  const factory TradeInfo({
    required String timestamp,
    required double price,
    required int quantity,
    required double totalValue,
    required double fees,
  }) = _TradeInfo;

  factory TradeInfo.fromJson(Map<String, dynamic> json) =>
      _$TradeInfoFromJson(json);
}

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

  factory TradeMetrics.fromJson(Map<String, dynamic> json) =>
      _$TradeMetricsFromJson(json);
}

@freezed
class TradeExecution with _$TradeExecution {
  const factory TradeExecution({
    required BasicInfo basicInfo,
    required InstrumentInfo instrumentInfo,
    required ExecutionInfo executionInfo,
  }) = _TradeExecution;

  factory TradeExecution.fromJson(Map<String, dynamic> json) =>
      _$TradeExecutionFromJson(json);
}

@freezed
class BasicInfo with _$BasicInfo {
  const factory BasicInfo({
    required String tradeId,
    required String orderId,
    required String tradeDate,
    required String orderExecutionTime,
    required String brokerType,
    required String tradeType,
  }) = _BasicInfo;

  factory BasicInfo.fromJson(Map<String, dynamic> json) =>
      _$BasicInfoFromJson(json);
}

@freezed
class ExecutionInfo with _$ExecutionInfo {
  const factory ExecutionInfo({
    required String tradeType,
    required String auction,
    required int quantity,
    required double price,
  }) = _ExecutionInfo;

  factory ExecutionInfo.fromJson(Map<String, dynamic> json) =>
      _$ExecutionInfoFromJson(json);
}
