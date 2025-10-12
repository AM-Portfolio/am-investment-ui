import 'package:freezed_annotation/freezed_annotation.dart';

part 'trade_calendar.freezed.dart';
part 'trade_calendar.g.dart';

/// Domain entity for trade calendar event
@freezed
class TradeCalendarEvent with _$TradeCalendarEvent {
  const factory TradeCalendarEvent({
    required String id,
    required String type,
    required String title,
    required DateTime date,
    String? description,
    String? symbol,
    double? amount,
    Map<String, dynamic>? metadata,
  }) = _TradeCalendarEvent;

  factory TradeCalendarEvent.fromJson(Map<String, dynamic> json) =>
      _$TradeCalendarEventFromJson(json);
}

/// Domain entity for trade calendar analytics
@freezed
class TradeCalendar with _$TradeCalendar {
  const factory TradeCalendar({
    required String userId,
    required String portfolioId,
    required List<TradeCalendarEvent> events,
    @Default(0) int totalEvents,
    DateTime? startDate,
    DateTime? endDate,
  }) = _TradeCalendar;

  factory TradeCalendar.fromJson(Map<String, dynamic> json) =>
      _$TradeCalendarFromJson(json);

  /// Create empty calendar
  factory TradeCalendar.empty(String userId, String portfolioId) =>
      TradeCalendar(
        userId: userId,
        portfolioId: portfolioId,
        events: [],
        totalEvents: 0,
      );
}
