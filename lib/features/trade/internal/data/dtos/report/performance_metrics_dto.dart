import 'package:freezed_annotation/freezed_annotation.dart';

part 'performance_metrics_dto.g.dart';

@JsonSerializable()
class PerformanceMetricsDto {
  final num? avgHoldTime;
  final num? longestTradeDuration;
  final num? maxTradingWeeksDuration;
  final num? avgTradingWeeksDuration;
  final num? avgGrossTradePnL;
  final num? avgLoss;
  final num? avgMaxTradeLoss;
  final num? avgMaxTradeProfit;
  final num? avgTradeWinLossRatio;
  final num? avgWeeklyGrossPnL;
  final num? avgWeeklyWinLossRatio;
  final num? avgWin;
  final num? grossPnL;
  final num? largestLosingTrade;
  final num? largestProfitableTrade;
  final num? profitFactor;
  final num? avgWeeklyGrossDrawdown;
  final num? avgPlannedRMultiple;
  final num? avgRealizedRMultiple;
  final int? breakevenDays;
  final int? breakevenTrades;
  final int? losingDays;
  final num? maxWeeklyGrossDrawdown;
  final num? avgWeeklyWinPercentage;
  final num? longsWinPercentage;
  final int? maxConsecutiveLosingWeeks;
  final int? maxConsecutiveLosses;
  final int? maxConsecutiveWinningWeeks;
  final int? maxConsecutiveWins;
  final num? shortsWinPercentage;
  final num? winPercentage;
  final int? winningDays;

  PerformanceMetricsDto({
    this.avgHoldTime,
    this.longestTradeDuration,
    this.maxTradingWeeksDuration,
    this.avgTradingWeeksDuration,
    this.avgGrossTradePnL,
    this.avgLoss,
    this.avgMaxTradeLoss,
    this.avgMaxTradeProfit,
    this.avgTradeWinLossRatio,
    this.avgWeeklyGrossPnL,
    this.avgWeeklyWinLossRatio,
    this.avgWin,
    this.grossPnL,
    this.largestLosingTrade,
    this.largestProfitableTrade,
    this.profitFactor,
    this.avgWeeklyGrossDrawdown,
    this.avgPlannedRMultiple,
    this.avgRealizedRMultiple,
    this.breakevenDays,
    this.breakevenTrades,
    this.losingDays,
    this.maxWeeklyGrossDrawdown,
    this.avgWeeklyWinPercentage,
    this.longsWinPercentage,
    this.maxConsecutiveLosingWeeks,
    this.maxConsecutiveLosses,
    this.maxConsecutiveWinningWeeks,
    this.maxConsecutiveWins,
    this.shortsWinPercentage,
    this.winPercentage,
    this.winningDays,
  });

  factory PerformanceMetricsDto.fromJson(Map<String, dynamic> json) => _$PerformanceMetricsDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PerformanceMetricsDtoToJson(this);
}
