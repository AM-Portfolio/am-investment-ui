import 'package:freezed_annotation/freezed_annotation.dart';
import 'trade_holding.dart';

part 'trade_calendar.freezed.dart';

/// Domain entity for trade calendar event (complete trade data for calendar view)
@freezed
class TradeCalendarEvent with _$TradeCalendarEvent {
  const factory TradeCalendarEvent({
    required String tradeId,
    required String portfolioId,
    required DateTime tradeDate,
    String? symbol,
    String? status,
    String? tradePositionType,
    double? profitLoss,
    double? profitLossPercentage,
    int? quantity,
    double? entryPrice,
    double? exitPrice,
    DateTime? entryTimestamp,
    DateTime? exitTimestamp,
    @Default({}) Map<String, dynamic> metadata,
  }) = _TradeCalendarEvent;

}

/// Domain entity for trade calendar with portfolio-indexed trades
@freezed
class TradeCalendar with _$TradeCalendar {
  const factory TradeCalendar({
    required String userId,
    required String portfolioId,
    @Default({}) Map<String, List<TradeHolding>> tradesByPortfolio,
    @Default([]) List<TradeCalendarEvent> events,
    @Default(0) int totalEvents,
    DateTime? startDate,
    DateTime? endDate,
  }) = _TradeCalendar;

  /// Create empty calendar
  factory TradeCalendar.empty(String userId, String portfolioId) =>
      TradeCalendar(
        userId: userId,
        portfolioId: portfolioId,
        events: [],
        totalEvents: 0,
      );
}
