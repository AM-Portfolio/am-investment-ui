import 'package:freezed_annotation/freezed_annotation.dart';

part 'trade_summary.freezed.dart';
part 'trade_summary.g.dart';

/// Domain entity for sector allocation in trade
@freezed
class TradeSectorAllocation with _$TradeSectorAllocation {
  const factory TradeSectorAllocation({
    required String sector,
    required double value,
    required double percentage,
    @Default(0) int holdingsCount,
  }) = _TradeSectorAllocation;

  factory TradeSectorAllocation.fromJson(Map<String, dynamic> json) =>
      _$TradeSectorAllocationFromJson(json);
}

/// Domain entity for trade summary/analysis
@freezed
class TradeSummary with _$TradeSummary {
  const factory TradeSummary({
    required String userId,
    required String portfolioId,
    required String portfolioName,
    @Default(0.0) double totalValue,
    @Default(0.0) double totalInvested,
    @Default(0.0) double totalGainLoss,
    @Default(0.0) double totalGainLossPercentage,
    @Default(0.0) double todayChange,
    @Default(0.0) double todayChangePercentage,
    @Default(0) int totalTrades,
    @Default(0) int winningTrades,
    @Default(0) int losingTrades,
    @Default(0) int breakEvenTrades,
    @Default(0) int openPositions,
    double? winRate,
    double? lossRate,
    double? profitFactor,
    double? expectancy,
    double? totalProfit,
    double? totalLoss,
    double? netProfitLoss,
    double? netProfitLossPercentage,
    double? maxDrawdown,
    double? maxDrawdownPercentage,
    double? sharpeRatio,
    double? sortinoRatio,
    @Default([]) List<TradeSectorAllocation> sectorAllocation,
    @Default([]) List<TradeTopMover> topGainers,
    @Default([]) List<TradeTopMover> topLosers,
    @Default([]) List<String> tradeIds,
  }) = _TradeSummary;

  factory TradeSummary.fromJson(Map<String, dynamic> json) =>
      _$TradeSummaryFromJson(json);

  /// Create empty summary
  factory TradeSummary.empty(
    String userId,
    String portfolioId, [
    String? portfolioName,
  ]) => TradeSummary(
    userId: userId,
    portfolioId: portfolioId,
    portfolioName: portfolioName ?? portfolioId,
  );
}

/// Domain entity for top movers in trade
@freezed
class TradeTopMover with _$TradeTopMover {
  const factory TradeTopMover({
    required String symbol,
    required String name,
    required double change,
    required double changePercentage,
    required double currentPrice,
  }) = _TradeTopMover;

  factory TradeTopMover.fromJson(Map<String, dynamic> json) =>
      _$TradeTopMoverFromJson(json);
}
