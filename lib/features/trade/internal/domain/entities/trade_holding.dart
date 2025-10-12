import 'package:freezed_annotation/freezed_annotation.dart';

part 'trade_holding.freezed.dart';
part 'trade_holding.g.dart';

/// Domain entity for trade holding
@freezed
class TradeHolding with _$TradeHolding {
  const factory TradeHolding({
    required String symbol,
    required String companyName,
    required double quantity,
    required double currentPrice,
    required double avgPrice,
    required double currentValue,
    required double investedAmount,
    required double totalGainLoss,
    required double totalGainLossPercentage,
    required double todayChange,
    required double todayChangePercentage,
    @Default(0.0) double weight,
    String? sector,
    String? industry,
    String? exchange,
  }) = _TradeHolding;

  factory TradeHolding.fromJson(Map<String, dynamic> json) =>
      _$TradeHoldingFromJson(json);
}

/// Domain entity for trade holdings collection
@freezed
class TradeHoldings with _$TradeHoldings {
  const factory TradeHoldings({
    required String userId,
    required String portfolioId,
    required List<TradeHolding> holdings,
    @Default(0) int totalCount,
    double? totalValue,
    double? totalGainLoss,
  }) = _TradeHoldings;

  factory TradeHoldings.fromJson(Map<String, dynamic> json) =>
      _$TradeHoldingsFromJson(json);

  /// Create empty holdings
  factory TradeHoldings.empty(String userId, String portfolioId) =>
      TradeHoldings(
        userId: userId,
        portfolioId: portfolioId,
        holdings: [],
        totalCount: 0,
      );
}
