import 'package:freezed_annotation/freezed_annotation.dart';

part 'trade_metrics_dto.freezed.dart';
part 'trade_metrics_dto.g.dart';

@freezed
class TradeMetricsDto with _$TradeMetricsDto {
  const factory TradeMetricsDto({
    double? profitLoss,
    double? profitLossPercentage,
    double? returnOnEquity,
    double? riskAmount,
    double? rewardAmount,
    double? riskRewardRatio,
    @Default(0) int holdingTimeDays,
    @Default(0) int holdingTimeHours,
    @Default(0) int holdingTimeMinutes,
    double? maxAdverseExcursion,
    double? maxFavorableExcursion,
  }) = _TradeMetricsDto;

  factory TradeMetricsDto.fromJson(Map<String, dynamic> json) =>
      _$TradeMetricsDtoFromJson(json);
}
