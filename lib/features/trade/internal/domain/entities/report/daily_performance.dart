import 'package:freezed_annotation/freezed_annotation.dart';
import 'performance_metrics.dart';

part 'daily_performance.freezed.dart';

@freezed
class DailyPerformance with _$DailyPerformance {
  const factory DailyPerformance({
    required DateTime date,
    required double totalProfitLoss,
    required int tradeCount,
    required int winCount,
    required int lossCount,
    required double winRate,
    String? bestTradeSymbol,
    double? bestTradePnL,
    required PerformanceMetrics metrics,
  }) = _DailyPerformance;
}
