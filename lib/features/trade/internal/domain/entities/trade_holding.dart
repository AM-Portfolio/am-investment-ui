import 'package:freezed_annotation/freezed_annotation.dart';
import 'instrument_info.dart';
import 'trade_entry_exit_info.dart';
import 'trade_metrics.dart';
import 'trade_execution.dart';

part 'trade_holding.freezed.dart';

/// Domain entity for individual trade holding with complete lifecycle
@freezed
class TradeHolding with _$TradeHolding {
  const factory TradeHolding({
    required String tradeId,
    required String portfolioId,
    InstrumentInfo? instrumentInfo,
    String? status,
    String? tradePositionType,
    TradeEntryExitInfo? entryInfo,
    TradeEntryExitInfo? exitInfo,
    TradeMetrics? metrics,
    @Default([]) List<TradeExecution> tradeExecutions,
    @Default({}) Map<String, dynamic> psychologyData,
    @Default({}) Map<String, dynamic> entryReasoning,
    @Default({}) Map<String, dynamic> exitReasoning,
    DateTime? tradeEndDate,
    DateTime? tradeDate,
  }) = _TradeHolding;

}

/// Domain entity for paginated trade holdings collection
@freezed
class TradeHoldings with _$TradeHoldings {
  const factory TradeHoldings({
    required String userId,
    required String portfolioId,
    @Default([]) List<TradeHolding> content,
    @Default(0) int totalPages,
    @Default(true) bool last,
    @Default(0) int totalElements,
    @Default(true) bool first,
    @Default(50) int size,
    @Default(0) int number,
    @Default(0) int numberOfElements,
    @Default(false) bool empty,
  }) = _TradeHoldings;


  /// Create empty holdings
  factory TradeHoldings.emptyHoldings(String userId, String portfolioId) =>
      TradeHoldings(
        userId: userId,
        portfolioId: portfolioId,
        content: [],
        totalElements: 0,
      );
}
