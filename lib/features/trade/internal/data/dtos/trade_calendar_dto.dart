import 'package:json_annotation/json_annotation.dart';

part 'trade_calendar_dto.g.dart';

/// DTO for trade execution details from API
@JsonSerializable()
class TradeExecutionDto {
  const TradeExecutionDto({required this.basicInfo, required this.instrumentInfo, required this.executionInfo});

  factory TradeExecutionDto.fromJson(Map<String, dynamic> json) => _$TradeExecutionDtoFromJson(json);

  final TradeBasicInfoDto basicInfo;
  final TradeInstrumentInfoDto instrumentInfo;
  final TradeExecutionInfoDto executionInfo;

  Map<String, dynamic> toJson() => _$TradeExecutionDtoToJson(this);
}

/// DTO for basic trade information
@JsonSerializable()
class TradeBasicInfoDto {
  const TradeBasicInfoDto({
    required this.tradeId,
    required this.orderId,
    required this.tradeDate,
    required this.orderExecutionTime,
    required this.brokerType,
    required this.tradeType,
  });

  factory TradeBasicInfoDto.fromJson(Map<String, dynamic> json) => _$TradeBasicInfoDtoFromJson(json);

  final String tradeId;
  final String orderId;
  final String tradeDate;
  final String orderExecutionTime;
  final String brokerType;
  final String tradeType;

  Map<String, dynamic> toJson() => _$TradeBasicInfoDtoToJson(this);
}

/// DTO for trade execution details
@JsonSerializable()
class TradeExecutionInfoDto {
  const TradeExecutionInfoDto({
    required this.tradeType,
    required this.auction,
    required this.quantity,
    required this.price,
  });

  factory TradeExecutionInfoDto.fromJson(Map<String, dynamic> json) => _$TradeExecutionInfoDtoFromJson(json);

  final String tradeType;
  final String auction;
  final int quantity;
  final double price;

  Map<String, dynamic> toJson() => _$TradeExecutionInfoDtoToJson(this);
}

/// DTO for instrument information
@JsonSerializable()
class TradeInstrumentInfoDto {
  const TradeInstrumentInfoDto({
    required this.symbol,
    required this.isin,
    required this.exchange,
    required this.segment,
    required this.series,
    required this.baseSymbol,
    required this.formattedDescription,
    required this.derivative,
    required this.index,
    this.rawSymbol,
    this.description,
  });

  factory TradeInstrumentInfoDto.fromJson(Map<String, dynamic> json) => _$TradeInstrumentInfoDtoFromJson(json);

  final String symbol;
  final String isin;
  final String exchange;
  final String segment;
  final String series;
  final String baseSymbol;
  final String formattedDescription;
  final bool derivative;
  final bool index;
  final String? rawSymbol;
  final String? description;

  Map<String, dynamic> toJson() => _$TradeInstrumentInfoDtoToJson(this);
}

/// DTO for trade entry/exit information
@JsonSerializable()
class TradePositionInfoDto {
  const TradePositionInfoDto({
    required this.timestamp,
    required this.price,
    required this.quantity,
    required this.totalValue,
    required this.fees,
  });

  factory TradePositionInfoDto.fromJson(Map<String, dynamic> json) => _$TradePositionInfoDtoFromJson(json);

  final String timestamp;
  final double price;
  final int quantity;
  final double totalValue;
  final double fees;

  Map<String, dynamic> toJson() => _$TradePositionInfoDtoToJson(this);
}

/// DTO for trade metrics
@JsonSerializable()
class TradeMetricsDto {
  const TradeMetricsDto({
    required this.profitLoss,
    required this.profitLossPercentage,
    required this.returnOnEquity,
    required this.riskAmount,
    required this.rewardAmount,
    required this.riskRewardRatio,
    required this.holdingTimeDays,
    required this.holdingTimeHours,
    required this.holdingTimeMinutes,
    this.maxAdverseExcursion,
    this.maxFavorableExcursion,
  });

  factory TradeMetricsDto.fromJson(Map<String, dynamic> json) => _$TradeMetricsDtoFromJson(json);

  final double profitLoss;
  final double profitLossPercentage;
  final double returnOnEquity;
  final double riskAmount;
  final double rewardAmount;
  final double riskRewardRatio;
  final int holdingTimeDays;
  final int holdingTimeHours;
  final int holdingTimeMinutes;
  final double? maxAdverseExcursion;
  final double? maxFavorableExcursion;

  Map<String, dynamic> toJson() => _$TradeMetricsDtoToJson(this);
}

/// DTO for individual trade detail from calendar API
@JsonSerializable()
class TradeDetailDto {
  const TradeDetailDto({
    required this.tradeId,
    required this.portfolioId,
    required this.instrumentInfo,
    required this.status,
    required this.tradePositionType,
    required this.entryInfo,
    required this.exitInfo,
    required this.metrics,
    required this.tradeExecutions,
    required this.tradeDate,
    required this.tradeEndDate,
    required this.psychologyData,
    required this.entryReasoning,
    required this.exitReasoning,
  });

  factory TradeDetailDto.fromJson(Map<String, dynamic> json) => _$TradeDetailDtoFromJson(json);

  final String tradeId;
  final String portfolioId;
  final TradeInstrumentInfoDto instrumentInfo;
  final String status;
  final String tradePositionType;
  final TradePositionInfoDto entryInfo;
  final TradePositionInfoDto exitInfo;
  final TradeMetricsDto metrics;
  final List<TradeExecutionDto> tradeExecutions;
  final String tradeDate;
  final String tradeEndDate;
  final Map<String, dynamic> psychologyData;
  final Map<String, dynamic> entryReasoning;
  final Map<String, dynamic> exitReasoning;

  Map<String, dynamic> toJson() => _$TradeDetailDtoToJson(this);
}

/// DTO for trade calendar response from API
/// API returns: { "portfolioId": [TradeDetailDto, ...] }
@JsonSerializable()
class TradeCalendarDto {
  const TradeCalendarDto({required this.portfolioTrades});

  factory TradeCalendarDto.fromJson(Map<String, dynamic> json) {
    final portfolioTrades = <String, List<TradeDetailDto>>{};

    for (final entry in json.entries) {
      final portfolioId = entry.key;
      final tradesJson = entry.value as List<dynamic>;

      portfolioTrades[portfolioId] = tradesJson
          .map((tradeJson) => TradeDetailDto.fromJson(tradeJson as Map<String, dynamic>))
          .toList();
    }

    return TradeCalendarDto(portfolioTrades: portfolioTrades);
  }

  final Map<String, List<TradeDetailDto>> portfolioTrades;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    for (final entry in portfolioTrades.entries) {
      json[entry.key] = entry.value.map((trade) => trade.toJson()).toList();
    }

    return json;
  }
}

/// DTO for trade calendar by month response
/// Uses the same structure as TradeCalendarDto
typedef TradeCalendarMonthDto = TradeCalendarDto;

/// DTO for trade calendar by day response
/// API returns: { "portfolioId": [TradeDetailDto, ...] }
typedef TradeCalendarDayDto = TradeCalendarDto;

/// DTO for trade calendar by date range response
/// API returns: { "portfolioId": [TradeDetailDto, ...] }
typedef TradeCalendarDateRangeDto = TradeCalendarDto;

/// DTO for trade calendar by quarter response
/// API returns: { "portfolioId": [TradeDetailDto, ...] }
typedef TradeCalendarQuarterDto = TradeCalendarDto;

/// DTO for trade calendar by financial year response
/// API returns: { "portfolioId": [TradeDetailDto, ...] }
typedef TradeCalendarFinancialYearDto = TradeCalendarDto;
