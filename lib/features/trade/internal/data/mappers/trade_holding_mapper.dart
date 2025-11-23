import '../../domain/entities/trade_controller_entities.dart';
import '../../domain/entities/trade_holding.dart';
import '../../domain/enums/exchange_types.dart';
import '../../domain/enums/market_segments.dart';
import '../../domain/enums/series_types.dart';
import '../../domain/enums/trade_directions.dart';
import '../../domain/enums/trade_statuses.dart';
import '../dtos/trade_holding_dto.dart';
import 'instrument_info_mapper.dart';
import 'trade_entry_exit_info_mapper.dart';
import 'trade_metrics_mapper.dart';

/// Comprehensive mapper for trade holding with nested structures
/// Now uses TradeDetails from trade_controller_entities as the core model
class TradeHoldingMapper {
  /// Convert TradeHoldingDto to TradeDetails domain entity
  static TradeDetails fromDto(TradeHoldingDto dto) {
    // Map old entities to new structure
    final oldInstrumentInfo = InstrumentInfoMapper.fromDto(dto.instrumentInfo);
    final oldEntryInfo = TradeEntryExitInfoMapper.fromDto(dto.entryInfo);
    final oldExitInfo = TradeEntryExitInfoMapper.fromDto(dto.exitInfo);
    final oldMetrics = TradeMetricsMapper.fromDto(dto.metrics);

    return TradeDetails(
      tradeId: dto.tradeId,
      portfolioId: dto.portfolioId,
      instrumentInfo: oldInstrumentInfo != null
          ? InstrumentInfo(
              symbol: oldInstrumentInfo.symbol,
              isin: oldInstrumentInfo.isin,
              rawSymbol: oldInstrumentInfo.rawSymbol,
              exchange: _parseExchangeType(oldInstrumentInfo.exchange),
              segment: _parseMarketSegment(oldInstrumentInfo.segment),
              series: _parseSeriesType(oldInstrumentInfo.series),
              description: oldInstrumentInfo.description,
            )
          : InstrumentInfo.empty(),
      status: _parseTradeStatus(dto.status),
      tradePositionType: _parseTradeDirection(dto.tradePositionType),
      entryInfo: oldEntryInfo != null
          ? EntryExitInfo(
              timestamp: oldEntryInfo.timestamp,
              price: oldEntryInfo.price,
              quantity: oldEntryInfo.quantity,
              totalValue: oldEntryInfo.totalValue,
              fees: oldEntryInfo.fees,
            )
          : EntryExitInfo.empty(),
      exitInfo: oldExitInfo != null
          ? EntryExitInfo(
              timestamp: oldExitInfo.timestamp,
              price: oldExitInfo.price,
              quantity: oldExitInfo.quantity,
              totalValue: oldExitInfo.totalValue,
              fees: oldExitInfo.fees,
            )
          : null,
      metrics: oldMetrics != null
          ? TradeMetrics(
              profitLoss: oldMetrics.profitLoss,
              profitLossPercentage: oldMetrics.profitLossPercentage,
              returnOnEquity: oldMetrics.returnOnEquity,
              riskAmount: oldMetrics.riskAmount,
              rewardAmount: oldMetrics.rewardAmount,
              riskRewardRatio: oldMetrics.riskRewardRatio,
              holdingTimeDays: oldMetrics.holdingTimeDays,
              holdingTimeHours: oldMetrics.holdingTimeHours,
              holdingTimeMinutes: oldMetrics.holdingTimeMinutes,
              maxAdverseExcursion: oldMetrics.maxAdverseExcursion,
              maxFavorableExcursion: oldMetrics.maxFavorableExcursion,
            )
          : null,
      tradeExecutions: [], // TradeExecutionDto structure doesn't match TradeModel - leave empty for now
    );
  }

  /// Convert list of TradeHoldingDtos to list of TradeDetails entities
  static List<TradeDetails> fromDtoList(List<TradeHoldingDto> dtos) => dtos.map(fromDto).toList();

  /// Convert TradeHoldingsDto to TradeHoldings domain entity
  static TradeHoldings fromListDto(TradeHoldingsDto dto, String userId, String portfolioId) => TradeHoldings(
    userId: userId,
    portfolioId: portfolioId,
    content: fromDtoList(dto.content),
    totalPages: dto.totalPages,
    last: dto.last,
    totalElements: dto.totalElements,
    first: dto.first,
    size: dto.size,
    number: dto.number,
    numberOfElements: dto.numberOfElements,
    empty: dto.empty,
  );

  // Helper methods to parse enum values
  static TradeStatuses _parseTradeStatus(String? status) {
    if (status == null) return TradeStatuses.open;
    switch (status.toUpperCase()) {
      case 'OPEN':
        return TradeStatuses.open;
      case 'WIN':
        return TradeStatuses.win;
      case 'LOSS':
        return TradeStatuses.loss;
      case 'BREAKEVEN':
      case 'BREAK_EVEN':
        return TradeStatuses.breakeven;
      default:
        return TradeStatuses.open;
    }
  }

  static TradeDirections _parseTradeDirection(String? type) {
    if (type == null) return TradeDirections.long;
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
