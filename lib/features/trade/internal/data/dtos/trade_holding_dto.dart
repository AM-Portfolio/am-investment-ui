import 'package:freezed_annotation/freezed_annotation.dart';
import 'instrument_info_dto.dart';
import 'entry_exit_info_dto.dart';
import 'trade_metrics_dto.dart';
import 'trade_execution_dto.dart';

part 'trade_holding_dto.freezed.dart';
part 'trade_holding_dto.g.dart';

@freezed
class TradeHoldingDto with _$TradeHoldingDto {
  const factory TradeHoldingDto({
    required String tradeId,
    required String portfolioId,
    InstrumentInfoDto? instrumentInfo,
    String? status,
    String? tradePositionType,
    @JsonKey(name: 'entryInfo') EntryExitInfoDto? entryInfo,
    @JsonKey(name: 'exitInfo') EntryExitInfoDto? exitInfo,
    TradeMetricsDto? metrics,
    @Default([]) List<TradeExecutionDto> tradeExecutions,
    @Default({}) Map<String, dynamic> psychologyData,
    @Default({}) Map<String, dynamic> entryReasoning,
    @Default({}) Map<String, dynamic> exitReasoning,
    String? tradeEndDate,
    String? tradeDate,
  }) = _TradeHoldingDto;

  factory TradeHoldingDto.fromJson(Map<String, dynamic> json) =>
      _$TradeHoldingDtoFromJson(json);
}

@freezed
class PageableDto with _$PageableDto {
  const factory PageableDto({
    @Default(0) int pageNumber,
    @Default(50) int pageSize,
    @Default(0) int offset,
    @Default(true) bool paged,
    @Default(false) bool unpaged,
  }) = _PageableDto;

  factory PageableDto.fromJson(Map<String, dynamic> json) =>
      _$PageableDtoFromJson(json);
}

@freezed
class TradeHoldingsDto with _$TradeHoldingsDto {
  const factory TradeHoldingsDto({
    @Default([]) List<TradeHoldingDto> content,
    PageableDto? pageable,
    @Default(0) int totalPages,
    @Default(true) bool last,
    @Default(0) int totalElements,
    @Default(true) bool first,
    @Default(50) int size,
    @Default(0) int number,
    @Default(0) int numberOfElements,
    @Default(false) bool empty,
  }) = _TradeHoldingsDto;

  factory TradeHoldingsDto.fromJson(Map<String, dynamic> json) =>
      _$TradeHoldingsDtoFromJson(json);
}
