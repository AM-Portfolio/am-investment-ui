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
    required double totalValue,
    required double totalInvested,
    required double totalGainLoss,
    required double totalGainLossPercentage,
    required double todayChange,
    required double todayChangePercentage,
    @Default([]) List<TradeSectorAllocation> sectorAllocation,
    @Default([]) List<TradeTopMover> topGainers,
    @Default([]) List<TradeTopMover> topLosers,
    int? holdingsCount,
  }) = _TradeSummary;

  factory TradeSummary.fromJson(Map<String, dynamic> json) =>
      _$TradeSummaryFromJson(json);

  /// Create empty summary
  factory TradeSummary.empty(String userId, String portfolioId) =>
      TradeSummary(
        userId: userId,
        portfolioId: portfolioId,
        totalValue: 0,
        totalInvested: 0,
        totalGainLoss: 0,
        totalGainLossPercentage: 0,
        todayChange: 0,
        todayChangePercentage: 0,
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
