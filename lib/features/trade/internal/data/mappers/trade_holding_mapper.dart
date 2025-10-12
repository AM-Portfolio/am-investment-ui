import '../../domain/entities/trade_holding.dart';
import '../dtos/trade_holding_dto.dart';
import 'instrument_info_mapper.dart';
import 'trade_entry_exit_info_mapper.dart';
import 'trade_metrics_mapper.dart';
import 'trade_execution_mapper.dart';

/// Comprehensive mapper for trade holding with nested structures
class TradeHoldingMapper {
  /// Convert TradeHoldingDto to TradeHolding domain entity
  static TradeHolding fromDto(TradeHoldingDto dto) {
    return TradeHolding(
      tradeId: dto.tradeId,
      portfolioId: dto.portfolioId,
      instrumentInfo: InstrumentInfoMapper.fromDto(dto.instrumentInfo),
      status: dto.status,
      tradePositionType: dto.tradePositionType,
      entryInfo: TradeEntryExitInfoMapper.fromDto(dto.entryInfo),
      exitInfo: TradeEntryExitInfoMapper.fromDto(dto.exitInfo),
      metrics: TradeMetricsMapper.fromDto(dto.metrics),
      tradeExecutions: TradeExecutionMapper.fromDtoList(dto.tradeExecutions),
      psychologyData: dto.psychologyData,
      entryReasoning: dto.entryReasoning,
      exitReasoning: dto.exitReasoning,
      tradeEndDate: dto.tradeEndDate != null
          ? DateTime.tryParse(dto.tradeEndDate!)
          : null,
      tradeDate:
          dto.tradeDate != null ? DateTime.tryParse(dto.tradeDate!) : null,
    );
  }

  /// Convert list of TradeHoldingDtos to list of TradeHolding entities
  static List<TradeHolding> fromDtoList(List<TradeHoldingDto> dtos) {
    return dtos.map((dto) => fromDto(dto)).toList();
  }

  /// Convert TradeHoldingsDto to TradeHoldings domain entity
  static TradeHoldings fromListDto(
    TradeHoldingsDto dto,
    String userId,
    String portfolioId,
  ) {
    return TradeHoldings(
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
  }
}
