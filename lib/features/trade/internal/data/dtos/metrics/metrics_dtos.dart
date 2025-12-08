import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/metrics/performance_metrics.dart';
import '../../../domain/entities/metrics/risk_metrics.dart';
import '../../../domain/entities/metrics/trade_distribution_metrics.dart';
import '../../../domain/entities/metrics/trade_timing_metrics.dart';
import '../../../domain/entities/metrics/trade_pattern_metrics.dart';
import '../../../domain/entities/metrics/strategy_performance_metrics.dart';
import '../../../domain/entities/metrics/trade_details.dart';
import '../../../domain/entities/metrics/trade_metrics_response.dart';
import '../../../domain/entities/metrics/metrics_filter_request.dart';
import '../../../domain/enums/metric_types.dart';

part 'metrics_dtos.g.dart';

@JsonSerializable()
class PerformanceMetricsDto {
  final double? totalProfitLoss;
  final double? totalProfitLossPercentage;
  final double? winRate;
  final double? profitFactor;
  final double? expectancy;
  final double? annualizedReturn;
  final double? averageWinningTrade;
  final double? averageLosingTrade;
  final double? largestWinningTrade;
  final double? largestLosingTrade;
  final double? winLossRatio;
  final double? maxDrawdown;
  final int? longestWinningStreak;
  final int? longestLosingStreak;
  final double? returnOnCapital;
  final double? tradesPerDay;

  PerformanceMetricsDto({
    this.totalProfitLoss,
    this.totalProfitLossPercentage,
    this.winRate,
    this.profitFactor,
    this.expectancy,
    this.annualizedReturn,
    this.averageWinningTrade,
    this.averageLosingTrade,
    this.largestWinningTrade,
    this.largestLosingTrade,
    this.winLossRatio,
    this.maxDrawdown,
    this.longestWinningStreak,
    this.longestLosingStreak,
    this.returnOnCapital,
    this.tradesPerDay,
  });

  factory PerformanceMetricsDto.fromJson(Map<String, dynamic> json) => _$PerformanceMetricsDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PerformanceMetricsDtoToJson(this);

  PerformanceMetrics toEntity() => PerformanceMetrics(
    totalProfitLoss: totalProfitLoss ?? 0.0,
    totalProfitLossPercentage: totalProfitLossPercentage ?? 0.0,
    winRate: winRate ?? 0.0,
    profitFactor: profitFactor ?? 0.0,
    expectancy: expectancy ?? 0.0,
    annualizedReturn: annualizedReturn ?? 0.0,
    averageWinningTrade: averageWinningTrade ?? 0.0,
    averageLosingTrade: averageLosingTrade ?? 0.0,
    largestWinningTrade: largestWinningTrade ?? 0.0,
    largestLosingTrade: largestLosingTrade ?? 0.0,
    winLossRatio: winLossRatio ?? 0.0,
    maxDrawdown: maxDrawdown ?? 0.0,
    longestWinningStreak: longestWinningStreak ?? 0,
    longestLosingStreak: longestLosingStreak ?? 0,
    returnOnCapital: returnOnCapital ?? 0.0,
    tradesPerDay: tradesPerDay ?? 0.0,
  );
}

@JsonSerializable()
class RiskMetricsDto {
  final double? maxDrawdown;
  final double? sharpeRatio;
  final double? sortinoRatio;
  final double? valueAtRisk;
  final double? probabilityOfRuin;

  RiskMetricsDto({
    this.maxDrawdown,
    this.sharpeRatio,
    this.sortinoRatio,
    this.valueAtRisk,
    this.probabilityOfRuin,
  });

  factory RiskMetricsDto.fromJson(Map<String, dynamic> json) => _$RiskMetricsDtoFromJson(json);
  Map<String, dynamic> toJson() => _$RiskMetricsDtoToJson(this);

  RiskMetrics toEntity() => RiskMetrics(
    maxDrawdown: maxDrawdown ?? 0.0,
    sharpeRatio: sharpeRatio ?? 0.0,
    sortinoRatio: sortinoRatio ?? 0.0,
    valueAtRisk: valueAtRisk ?? 0.0,
    probabilityOfRuin: probabilityOfRuin ?? 0.0,
  );
}

@JsonSerializable()
class TradeDistributionMetricsDto {
  final Map<String, int> tradesByDay;
  final Map<String, double> profitByDay;
  final Map<String, int> tradesByHour;
  final Map<String, double> profitByHour;
  final Map<String, int> tradeCountByAssetClass;
  final Map<String, int> tradeCountByStrategy;

  TradeDistributionMetricsDto({
    required this.tradesByDay,
    required this.profitByDay,
    required this.tradesByHour,
    required this.profitByHour,
    required this.tradeCountByAssetClass,
    required this.tradeCountByStrategy,
  });

  factory TradeDistributionMetricsDto.fromJson(Map<String, dynamic> json) => _$TradeDistributionMetricsDtoFromJson(json);
  Map<String, dynamic> toJson() => _$TradeDistributionMetricsDtoToJson(this);

  TradeDistributionMetrics toEntity() => TradeDistributionMetrics(
    tradesByDay: tradesByDay,
    profitByDay: profitByDay,
    tradesByHour: tradesByHour,
    profitByHour: profitByHour,
    tradeCountByAssetClass: tradeCountByAssetClass,
    tradeCountByStrategy: tradeCountByStrategy,
  );
}

@JsonSerializable()
class TradeTimingMetricsDto {
  final double entryTimingScore;
  final double exitTimingScore;
  final Map<String, int> earlyEntries;
  final Map<String, int> optimalEntries;

  TradeTimingMetricsDto({
    required this.entryTimingScore,
    required this.exitTimingScore,
    required this.earlyEntries,
    required this.optimalEntries,
  });

  factory TradeTimingMetricsDto.fromJson(Map<String, dynamic> json) => _$TradeTimingMetricsDtoFromJson(json);
  Map<String, dynamic> toJson() => _$TradeTimingMetricsDtoToJson(this);

  TradeTimingMetrics toEntity() => TradeTimingMetrics(
    entryTimingScore: entryTimingScore,
    exitTimingScore: exitTimingScore,
    earlyEntries: earlyEntries,
    optimalEntries: optimalEntries,
  );
}

@JsonSerializable()
class TradePatternMetricsDto {
  final double emotionalControlScore;
  final double disciplineScore;
  final double patternConsistencyScore;
  final Map<String, int> patternFrequency;

  TradePatternMetricsDto({
    required this.emotionalControlScore,
    required this.disciplineScore,
    required this.patternConsistencyScore,
    required this.patternFrequency,
  });

  factory TradePatternMetricsDto.fromJson(Map<String, dynamic> json) => _$TradePatternMetricsDtoFromJson(json);
  Map<String, dynamic> toJson() => _$TradePatternMetricsDtoToJson(this);

  TradePatternMetrics toEntity() => TradePatternMetrics(
    emotionalControlScore: emotionalControlScore,
    disciplineScore: disciplineScore,
    patternConsistencyScore: patternConsistencyScore,
    patternFrequency: patternFrequency,
  );
}

@JsonSerializable()
class StrategyPerformanceMetricsDto {
  final String strategyName;
  final double totalProfitLoss;
  final double winRate;
  final double sharpeRatio;

  StrategyPerformanceMetricsDto({
    required this.strategyName,
    required this.totalProfitLoss,
    required this.winRate,
    required this.sharpeRatio,
  });

  factory StrategyPerformanceMetricsDto.fromJson(Map<String, dynamic> json) => _$StrategyPerformanceMetricsDtoFromJson(json);
  Map<String, dynamic> toJson() => _$StrategyPerformanceMetricsDtoToJson(this);

  StrategyPerformanceMetrics toEntity() => StrategyPerformanceMetrics(
    strategyName: strategyName,
    totalProfitLoss: totalProfitLoss,
    winRate: winRate,
    sharpeRatio: sharpeRatio,
  );
}

@JsonSerializable()
class TradeDetailsDto {
  final String? tradeId;
  final String? symbol;
  final String? strategy;
  final String? status;
  final String? tradePositionType;
  final String? notes;
  final List<String>? tags;

  TradeDetailsDto({
    this.tradeId,
    this.symbol,
    this.strategy,
    this.status,
    this.tradePositionType,
    this.notes,
    this.tags,
  });

  factory TradeDetailsDto.fromJson(Map<String, dynamic> json) => _$TradeDetailsDtoFromJson(json);
  Map<String, dynamic> toJson() => _$TradeDetailsDtoToJson(this);

  TradeDetails toEntity() => TradeDetails(
    tradeId: tradeId,
    symbol: symbol,
    strategy: strategy,
    status: status,
    tradePositionType: tradePositionType,
    notes: notes,
    tags: tags,
  );
}

@JsonSerializable()
class TradeMetricsResponseDto {
  final List<String> portfolioIds;
  final DateTime startDate;
  final DateTime endDate;
  final int totalTradesCount;
  final List<TradeDetailsDto>? tradeDetails;
  final PerformanceMetricsDto performanceMetrics;
  final RiskMetricsDto riskMetrics;
  final TradeDistributionMetricsDto distributionMetrics;
  final TradeTimingMetricsDto timingMetrics;
  final TradePatternMetricsDto patternMetrics;
  final Map<String, StrategyPerformanceMetricsDto> strategyMetrics;
  final Map<String, Map<String, dynamic>> groupedMetrics;
  final Map<String, dynamic> metadata;

  TradeMetricsResponseDto({
    required this.portfolioIds,
    required this.startDate,
    required this.endDate,
    required this.totalTradesCount,
    this.tradeDetails,
    required this.performanceMetrics,
    required this.riskMetrics,
    required this.distributionMetrics,
    required this.timingMetrics,
    required this.patternMetrics,
    required this.strategyMetrics,
    required this.groupedMetrics,
    required this.metadata,
  });

  factory TradeMetricsResponseDto.fromJson(Map<String, dynamic> json) => _$TradeMetricsResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$TradeMetricsResponseDtoToJson(this);

  TradeMetricsResponse toEntity() => TradeMetricsResponse(
    portfolioIds: portfolioIds,
    startDate: startDate,
    endDate: endDate,
    totalTradesCount: totalTradesCount,
    tradeDetails: tradeDetails?.map((e) => e.toEntity()).toList(),
    performanceMetrics: performanceMetrics.toEntity(),
    riskMetrics: riskMetrics.toEntity(),
    distributionMetrics: distributionMetrics.toEntity(),
    timingMetrics: timingMetrics.toEntity(),
    patternMetrics: patternMetrics.toEntity(),
    strategyMetrics: strategyMetrics.map((k, v) => MapEntry(k, v.toEntity())),
    groupedMetrics: groupedMetrics,
    metadata: metadata,
  );
}

@JsonSerializable()
class DateRangeDto {
  final DateTime startDate;
  final DateTime endDate;

  DateRangeDto({required this.startDate, required this.endDate});

  factory DateRangeDto.fromJson(Map<String, dynamic> json) => _$DateRangeDtoFromJson(json);
  Map<String, dynamic> toJson() => _$DateRangeDtoToJson(this);
}



@JsonSerializable()
class MetricsFilterRequestDto {
  final List<String> portfolioIds;
  final DateRangeDto dateRange;
  final String? timePeriod;
  final List<MetricTypes>? metricTypes;
  final List<String>? instruments;
  final List<String>? groupBy;
  final bool includeTradeDetails;
  final Map<String, dynamic>? customFilters;

  MetricsFilterRequestDto({
    required this.portfolioIds,
    required this.dateRange,
    this.timePeriod,
    this.metricTypes,
    this.instruments,
    this.groupBy,
    this.includeTradeDetails = false,
    this.customFilters,
  });

  factory MetricsFilterRequestDto.fromJson(Map<String, dynamic> json) => _$MetricsFilterRequestDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MetricsFilterRequestDtoToJson(this);

  factory MetricsFilterRequestDto.fromEntity(MetricsFilterRequest entity) => MetricsFilterRequestDto(
    portfolioIds: entity.portfolioIds,
    dateRange: DateRangeDto(
      startDate: entity.startDate,
      endDate: entity.endDate,
    ),
    timePeriod: entity.timePeriod,
    metricTypes: entity.metricTypes,
    instruments: entity.instruments,
    groupBy: entity.groupBy,
    includeTradeDetails: entity.includeTradeDetails,
    customFilters: entity.customFilters,
  );
}
