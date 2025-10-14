import '../dtos/trade_calendar_dto.dart';
import '../../domain/entities/trade_calendar.dart';

/// Mapper for converting trade calendar DTOs to entities
class TradeCalendarMapper {
  /// Convert TradeCalendarDto to TradeCalendar entity
  static TradeCalendar fromDto(TradeCalendarDto dto) {
    final Map<String, List<TradeDetail>> portfolioTrades = {};
    
    for (final entry in dto.portfolioTrades.entries) {
      final portfolioId = entry.key;
      final tradeDetailDtos = entry.value;
      
      portfolioTrades[portfolioId] = tradeDetailDtos
          .map(_mapTradeDetail)
          .toList();
    }
    
    return TradeCalendar(portfolioTrades: portfolioTrades);
  }

  /// Convert TradeDetailDto to TradeDetail entity
  static TradeDetail _mapTradeDetail(TradeDetailDto dto) {
    return TradeDetail(
      tradeId: dto.tradeId,
      portfolioId: dto.portfolioId,
      instrumentInfo: _mapInstrumentInfo(dto.instrumentInfo),
      status: TradeStatus.fromString(dto.status),
      tradePositionType: TradePositionType.fromString(dto.tradePositionType),
      entryInfo: _mapPositionInfo(dto.entryInfo),
      exitInfo: _mapPositionInfo(dto.exitInfo),
      metrics: _mapMetrics(dto.metrics),
      tradeExecutions: dto.tradeExecutions.map(_mapExecution).toList(),
      tradeDate: DateTime.parse(dto.tradeDate),
      tradeEndDate: DateTime.parse(dto.tradeEndDate),
      psychologyData: dto.psychologyData,
      entryReasoning: dto.entryReasoning,
      exitReasoning: dto.exitReasoning,
    );
  }

  /// Convert TradeInstrumentInfoDto to TradeInstrumentInfo entity
  static TradeInstrumentInfo _mapInstrumentInfo(TradeInstrumentInfoDto dto) {
    return TradeInstrumentInfo(
      symbol: dto.symbol,
      isin: dto.isin,
      exchange: dto.exchange,
      segment: dto.segment,
      series: dto.series,
      baseSymbol: dto.baseSymbol,
      formattedDescription: dto.formattedDescription,
      derivative: dto.derivative,
      index: dto.index,
      rawSymbol: dto.rawSymbol,
      description: dto.description,
    );
  }

  /// Convert TradePositionInfoDto to TradePositionInfo entity
  static TradePositionInfo _mapPositionInfo(TradePositionInfoDto dto) {
    return TradePositionInfo(
      timestamp: DateTime.parse(dto.timestamp),
      price: dto.price,
      quantity: dto.quantity,
      totalValue: dto.totalValue,
      fees: dto.fees,
    );
  }

  /// Convert TradeMetricsDto to TradeMetrics entity
  static TradeMetrics _mapMetrics(TradeMetricsDto dto) {
    return TradeMetrics(
      profitLoss: dto.profitLoss,
      profitLossPercentage: dto.profitLossPercentage,
      returnOnEquity: dto.returnOnEquity,
      riskAmount: dto.riskAmount,
      rewardAmount: dto.rewardAmount,
      riskRewardRatio: dto.riskRewardRatio,
      holdingTimeDays: dto.holdingTimeDays,
      holdingTimeHours: dto.holdingTimeHours,
      holdingTimeMinutes: dto.holdingTimeMinutes,
      maxAdverseExcursion: dto.maxAdverseExcursion,
      maxFavorableExcursion: dto.maxFavorableExcursion,
    );
  }

  /// Convert TradeExecutionDto to TradeExecution entity
  static TradeExecution _mapExecution(TradeExecutionDto dto) {
    return TradeExecution(
      basicInfo: _mapBasicInfo(dto.basicInfo),
      instrumentInfo: _mapInstrumentInfo(dto.instrumentInfo),
      executionInfo: _mapExecutionInfo(dto.executionInfo),
    );
  }

  /// Convert TradeBasicInfoDto to TradeBasicInfo entity
  static TradeBasicInfo _mapBasicInfo(TradeBasicInfoDto dto) {
    return TradeBasicInfo(
      tradeId: dto.tradeId,
      orderId: dto.orderId,
      tradeDate: DateTime.parse(dto.tradeDate),
      orderExecutionTime: DateTime.parse(dto.orderExecutionTime),
      brokerType: dto.brokerType,
      tradeType: dto.tradeType,
    );
  }

  /// Convert TradeExecutionInfoDto to TradeExecutionInfo entity
  static TradeExecutionInfo _mapExecutionInfo(TradeExecutionInfoDto dto) {
    return TradeExecutionInfo(
      tradeType: dto.tradeType,
      auction: dto.auction.toLowerCase() == 'true',
      quantity: dto.quantity,
      price: dto.price,
    );
  }

  /// Convert TradeCalendar entity back to DTO (if needed)
  static TradeCalendarDto toDto(TradeCalendar entity) {
    final Map<String, List<TradeDetailDto>> portfolioTrades = {};
    
    for (final entry in entity.portfolioTrades.entries) {
      final portfolioId = entry.key;
      final tradeDetails = entry.value;
      
      portfolioTrades[portfolioId] = tradeDetails
          .map(_mapTradeDetailToDto)
          .toList();
    }
    
    return TradeCalendarDto(portfolioTrades: portfolioTrades);
  }

  /// Convert TradeDetail entity back to DTO
  static TradeDetailDto _mapTradeDetailToDto(TradeDetail entity) {
    return TradeDetailDto(
      tradeId: entity.tradeId,
      portfolioId: entity.portfolioId,
      instrumentInfo: _mapInstrumentInfoToDto(entity.instrumentInfo),
      status: entity.status.name.toUpperCase(),
      tradePositionType: entity.tradePositionType.name.toUpperCase(),
      entryInfo: _mapPositionInfoToDto(entity.entryInfo),
      exitInfo: _mapPositionInfoToDto(entity.exitInfo),
      metrics: _mapMetricsToDto(entity.metrics),
      tradeExecutions: entity.tradeExecutions.map(_mapExecutionToDto).toList(),
      tradeDate: entity.tradeDate.toIso8601String().substring(0, 10),
      tradeEndDate: entity.tradeEndDate.toIso8601String().substring(0, 10),
      psychologyData: entity.psychologyData,
      entryReasoning: entity.entryReasoning,
      exitReasoning: entity.exitReasoning,
    );
  }

  /// Convert TradeInstrumentInfo entity back to DTO
  static TradeInstrumentInfoDto _mapInstrumentInfoToDto(TradeInstrumentInfo entity) {
    return TradeInstrumentInfoDto(
      symbol: entity.symbol,
      isin: entity.isin,
      exchange: entity.exchange,
      segment: entity.segment,
      series: entity.series,
      baseSymbol: entity.baseSymbol,
      formattedDescription: entity.formattedDescription,
      derivative: entity.derivative,
      index: entity.index,
      rawSymbol: entity.rawSymbol,
      description: entity.description,
    );
  }

  /// Convert TradePositionInfo entity back to DTO
  static TradePositionInfoDto _mapPositionInfoToDto(TradePositionInfo entity) {
    return TradePositionInfoDto(
      timestamp: entity.timestamp.toIso8601String(),
      price: entity.price,
      quantity: entity.quantity,
      totalValue: entity.totalValue,
      fees: entity.fees,
    );
  }

  /// Convert TradeMetrics entity back to DTO
  static TradeMetricsDto _mapMetricsToDto(TradeMetrics entity) {
    return TradeMetricsDto(
      profitLoss: entity.profitLoss,
      profitLossPercentage: entity.profitLossPercentage,
      returnOnEquity: entity.returnOnEquity,
      riskAmount: entity.riskAmount,
      rewardAmount: entity.rewardAmount,
      riskRewardRatio: entity.riskRewardRatio,
      holdingTimeDays: entity.holdingTimeDays,
      holdingTimeHours: entity.holdingTimeHours,
      holdingTimeMinutes: entity.holdingTimeMinutes,
      maxAdverseExcursion: entity.maxAdverseExcursion,
      maxFavorableExcursion: entity.maxFavorableExcursion,
    );
  }

  /// Convert TradeExecution entity back to DTO
  static TradeExecutionDto _mapExecutionToDto(TradeExecution entity) {
    return TradeExecutionDto(
      basicInfo: _mapBasicInfoToDto(entity.basicInfo),
      instrumentInfo: _mapInstrumentInfoToDto(entity.instrumentInfo),
      executionInfo: _mapExecutionInfoToDto(entity.executionInfo),
    );
  }

  /// Convert TradeBasicInfo entity back to DTO
  static TradeBasicInfoDto _mapBasicInfoToDto(TradeBasicInfo entity) {
    return TradeBasicInfoDto(
      tradeId: entity.tradeId,
      orderId: entity.orderId,
      tradeDate: entity.tradeDate.toIso8601String().substring(0, 10),
      orderExecutionTime: entity.orderExecutionTime.toIso8601String(),
      brokerType: entity.brokerType,
      tradeType: entity.tradeType,
    );
  }

  /// Convert TradeExecutionInfo entity back to DTO
  static TradeExecutionInfoDto _mapExecutionInfoToDto(TradeExecutionInfo entity) {
    return TradeExecutionInfoDto(
      tradeType: entity.tradeType,
      auction: entity.auction ? 'TRUE' : 'FALSE',
      quantity: entity.quantity,
      price: entity.price,
    );
  }
}