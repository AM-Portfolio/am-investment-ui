import 'package:freezed_annotation/freezed_annotation.dart';
import 'performance_metrics_dto.dart';

part 'daily_performance_dto.g.dart';

@JsonSerializable()
class DailyPerformanceDto {
  final String date; // Using String as per schema format: date
  final double totalProfitLoss;
  final int tradeCount;
  final int winCount;
  final int lossCount;
  final double winRate;
  final String? bestTradeSymbol;
  final double? bestTradePnL;
  final PerformanceMetricsDto metrics;

  DailyPerformanceDto({
    required this.date,
    required this.totalProfitLoss,
    required this.tradeCount,
    required this.winCount,
    required this.lossCount,
    required this.winRate,
    this.bestTradeSymbol,
    this.bestTradePnL,
    required this.metrics,
  });

  factory DailyPerformanceDto.fromJson(Map<String, dynamic> json) => _$DailyPerformanceDtoFromJson(json);
  Map<String, dynamic> toJson() => _$DailyPerformanceDtoToJson(this);
}
