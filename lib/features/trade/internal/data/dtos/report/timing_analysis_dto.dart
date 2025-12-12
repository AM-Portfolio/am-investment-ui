import 'package:freezed_annotation/freezed_annotation.dart';
import 'performance_metrics_dto.dart';

part 'timing_analysis_dto.g.dart';

@JsonSerializable()
class TimingAnalysisDto {
  final List<HourlyPerformanceDto> hourlyPerformance;
  final List<DayOfWeekPerformanceDto> dayOfWeekPerformance;
  final List<MonthlyPerformanceDto> monthlyPerformance;
  final List<YearlyPerformanceDto> yearlyPerformance;
  final List<WeeklyPerformanceDto> weeklyPerformance;
  final int? bestTradingHour;
  final int? worstTradingHour;
  final String? bestTradingDay;
  final String? worstTradingDay;
  final String? bestTradingMonth;
  final String? worstTradingMonth;

  TimingAnalysisDto({
    required this.hourlyPerformance,
    required this.dayOfWeekPerformance,
    required this.monthlyPerformance,
    required this.yearlyPerformance,
    required this.weeklyPerformance,
    this.bestTradingHour,
    this.worstTradingHour,
    this.bestTradingDay,
    this.worstTradingDay,
    this.bestTradingMonth,
    this.worstTradingMonth,
  });

  factory TimingAnalysisDto.fromJson(Map<String, dynamic> json) => _$TimingAnalysisDtoFromJson(json);
  Map<String, dynamic> toJson() => _$TimingAnalysisDtoToJson(this);
}

@JsonSerializable()
class HourlyPerformanceDto {
  final int hour;
  final int tradeCount;
  final int winCount;
  final int lossCount;
  final double winRate;
  final double totalProfitLoss;
  final double averageWinAmount;
  final double averageLossAmount;
  final double averageHoldingTime;
  final PerformanceMetricsDto metrics;

  HourlyPerformanceDto({
    required this.hour,
    required this.tradeCount,
    required this.winCount,
    required this.lossCount,
    required this.winRate,
    required this.totalProfitLoss,
    required this.averageWinAmount,
    required this.averageLossAmount,
    required this.averageHoldingTime,
    required this.metrics,
  });

  factory HourlyPerformanceDto.fromJson(Map<String, dynamic> json) => _$HourlyPerformanceDtoFromJson(json);
  Map<String, dynamic> toJson() => _$HourlyPerformanceDtoToJson(this);
}

@JsonSerializable()
class DayOfWeekPerformanceDto {
  final String dayOfWeek;
  final int dayOrder;
  final int tradeCount;
  final int winCount;
  final int lossCount;
  final double winRate;
  final double totalProfitLoss;
  final double averageWinAmount;
  final double averageLossAmount;
  final double averageHoldingTime;
  final PerformanceMetricsDto metrics;

  DayOfWeekPerformanceDto({
    required this.dayOfWeek,
    required this.dayOrder,
    required this.tradeCount,
    required this.winCount,
    required this.lossCount,
    required this.winRate,
    required this.totalProfitLoss,
    required this.averageWinAmount,
    required this.averageLossAmount,
    required this.averageHoldingTime,
    required this.metrics,
  });

  factory DayOfWeekPerformanceDto.fromJson(Map<String, dynamic> json) => _$DayOfWeekPerformanceDtoFromJson(json);
  Map<String, dynamic> toJson() => _$DayOfWeekPerformanceDtoToJson(this);
}

@JsonSerializable()
class MonthlyPerformanceDto {
  final String month;
  final int monthOrder;
  final int tradeCount;
  final int winCount;
  final int lossCount;
  final double winRate;
  final double totalProfitLoss;
  final double averageWinAmount;
  final double averageLossAmount;
  final double averageHoldingTime;
  final PerformanceMetricsDto metrics;

  MonthlyPerformanceDto({
    required this.month,
    required this.monthOrder,
    required this.tradeCount,
    required this.winCount,
    required this.lossCount,
    required this.winRate,
    required this.totalProfitLoss,
    required this.averageWinAmount,
    required this.averageLossAmount,
    required this.averageHoldingTime,
    required this.metrics,
  });

  factory MonthlyPerformanceDto.fromJson(Map<String, dynamic> json) => _$MonthlyPerformanceDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MonthlyPerformanceDtoToJson(this);
}

@JsonSerializable()
class YearlyPerformanceDto {
  final int year;
  final int tradeCount;
  final int winCount;
  final int lossCount;
  final double winRate;
  final double totalProfitLoss;
  final double averageWinAmount;
  final double averageLossAmount;
  final double averageHoldingTime;
  final PerformanceMetricsDto metrics;

  YearlyPerformanceDto({
    required this.year,
    required this.tradeCount,
    required this.winCount,
    required this.lossCount,
    required this.winRate,
    required this.totalProfitLoss,
    required this.averageWinAmount,
    required this.averageLossAmount,
    required this.averageHoldingTime,
    required this.metrics,
  });

  factory YearlyPerformanceDto.fromJson(Map<String, dynamic> json) => _$YearlyPerformanceDtoFromJson(json);
  Map<String, dynamic> toJson() => _$YearlyPerformanceDtoToJson(this);
}

@JsonSerializable()
class WeeklyPerformanceDto {
  final String weekId;
  final int tradeCount;
  final int winCount;
  final int lossCount;
  final double winRate;
  final double totalProfitLoss;
  final PerformanceMetricsDto metrics;

  WeeklyPerformanceDto({
    required this.weekId,
    required this.tradeCount,
    required this.winCount,
    required this.lossCount,
    required this.winRate,
    required this.totalProfitLoss,
    required this.metrics,
  });

  factory WeeklyPerformanceDto.fromJson(Map<String, dynamic> json) => _$WeeklyPerformanceDtoFromJson(json);
  Map<String, dynamic> toJson() => _$WeeklyPerformanceDtoToJson(this);
}
