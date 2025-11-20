import '../../../../../core/utils/logger.dart';
import '../../domain/entities/trade_calendar.dart';
import '../../domain/entities/trade_controller_entities.dart';
import '../../domain/enums/exchange_types.dart';
import '../../domain/enums/market_segments.dart';
import '../../domain/enums/series_types.dart';
import '../../domain/enums/trade_directions.dart';
import '../../domain/enums/trade_statuses.dart';
import '../dtos/trade_calendar_dto.dart';

/// Mapper for converting trade calendar DTOs to entities
class TradeCalendarMapper {
  /// Convert TradeCalendarDto to TradeCalendar entity
  static TradeCalendar fromDto(TradeCalendarDto dto) {
    AppLogger.info('[Mapper] Converting DTO with ${dto.portfolioTrades.length} portfolios', tag: 'TradeCalendarMapper');

    final portfolioTrades = <String, List<TradeDetails>>{};

    for (final entry in dto.portfolioTrades.entries) {
      final portfolioId = entry.key;
      final tradeDetailDtos = entry.value;

      AppLogger.info(
        '[Mapper] Portfolio $portfolioId has ${tradeDetailDtos.length} trades',
        tag: 'TradeCalendarMapper',
      );

      portfolioTrades[portfolioId] = tradeDetailDtos.map(_mapTradeDetail).toList();
    }

    AppLogger.info(
      '[Mapper] Final entity has ${portfolioTrades.length} portfolios with portfolio IDs: ${portfolioTrades.keys.join(", ")}',
      tag: 'TradeCalendarMapper',
    );

    return TradeCalendar(portfolioTrades: portfolioTrades);
  }

  /// Convert TradeDetailDto to TradeDetails entity
  static TradeDetails _mapTradeDetail(TradeDetailDto dto) => TradeDetails(
    tradeId: dto.tradeId,
    portfolioId: dto.portfolioId,
    instrumentInfo: InstrumentInfo(
      symbol: dto.instrumentInfo.symbol,
      isin: dto.instrumentInfo.isin,
      rawSymbol: dto.instrumentInfo.rawSymbol,
      exchange: _parseExchangeType(dto.instrumentInfo.exchange),
      segment: _parseMarketSegment(dto.instrumentInfo.segment),
      series: _parseSeriesType(dto.instrumentInfo.series),
      description: dto.instrumentInfo.description,
    ),
    status: _parseTradeStatus(dto.status),
    tradePositionType: _parseTradeDirection(dto.tradePositionType),
    entryInfo: EntryExitInfo(
      timestamp: DateTime.tryParse(dto.entryInfo.timestamp),
      price: dto.entryInfo.price,
      quantity: dto.entryInfo.quantity,
      totalValue: dto.entryInfo.totalValue,
      fees: dto.entryInfo.fees,
    ),
    exitInfo: EntryExitInfo(
      timestamp: DateTime.tryParse(dto.exitInfo.timestamp),
      price: dto.exitInfo.price,
      quantity: dto.exitInfo.quantity,
      totalValue: dto.exitInfo.totalValue,
      fees: dto.exitInfo.fees,
    ),
    metrics: TradeMetrics(
      profitLoss: dto.metrics.profitLoss,
      profitLossPercentage: dto.metrics.profitLossPercentage,
      returnOnEquity: dto.metrics.returnOnEquity,
      riskAmount: dto.metrics.riskAmount,
      rewardAmount: dto.metrics.rewardAmount,
      riskRewardRatio: dto.metrics.riskRewardRatio,
      holdingTimeDays: dto.metrics.holdingTimeDays,
      holdingTimeHours: dto.metrics.holdingTimeHours,
      holdingTimeMinutes: dto.metrics.holdingTimeMinutes,
      maxAdverseExcursion: dto.metrics.maxAdverseExcursion,
      maxFavorableExcursion: dto.metrics.maxFavorableExcursion,
    ),
    tradeExecutions: [], // Leave empty for calendar - executions not needed
  );

  // Helper methods to parse enum values
  static TradeStatuses _parseTradeStatus(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return TradeStatuses.open;
      case 'CLOSED':
        return TradeStatuses.closed;
      case 'WIN':
        return TradeStatuses.win;
      case 'LOSS':
        return TradeStatuses.loss;
      case 'BREAKEVEN':
        return TradeStatuses.breakeven;
      case 'CANCELLED':
        return TradeStatuses.cancelled;
      default:
        return TradeStatuses.open;
    }
  }

  static TradeDirections _parseTradeDirection(String type) {
    switch (type.toUpperCase()) {
      case 'LONG':
        return TradeDirections.long;
      case 'SHORT':
        return TradeDirections.short;
      default:
        return TradeDirections.long;
    }
  }

  static ExchangeTypes? _parseExchangeType(String? exchange) {
    if (exchange == null) return null;
    switch (exchange.toUpperCase()) {
      case 'NSE':
        return ExchangeTypes.nse;
      case 'BSE':
        return ExchangeTypes.bse;
      case 'MCX':
        return ExchangeTypes.mcx;
      case 'NCDEX':
        return ExchangeTypes.ncdex;
      default:
        return null;
    }
  }

  static MarketSegments? _parseMarketSegment(String? segment) {
    if (segment == null) return null;
    switch (segment.toUpperCase()) {
      case 'EQUITY':
        return MarketSegments.equity;
      case 'INDEX_SEGMENT':
      case 'INDEXSEGMENT':
        return MarketSegments.indexSegment;
      case 'EQUITY_FUTURES':
      case 'EQUITYFUTURES':
        return MarketSegments.equityFutures;
      case 'INDEX_FUTURES':
      case 'INDEXFUTURES':
        return MarketSegments.indexFutures;
      case 'EQUITY_OPTIONS':
      case 'EQUITYOPTIONS':
        return MarketSegments.equityOptions;
      case 'INDEX_OPTIONS':
      case 'INDEXOPTIONS':
        return MarketSegments.indexOptions;
      default:
        return null;
    }
  }

  static SeriesTypes? _parseSeriesType(String? series) {
    if (series == null) return null;
    switch (series.toUpperCase()) {
      case 'EQ':
        return SeriesTypes.eq;
      case 'BE':
        return SeriesTypes.be;
      case 'BZ':
        return SeriesTypes.bz;
      default:
        return null;
    }
  }
}
