import '../../domain/entities/trade_calendar.dart';
import '../dtos/trade_calendar_dto.dart';

/// Mapper for trade calendar between DTO and domain entity
class TradeCalendarMapper {
  /// Convert TradeCalendarEventDto to TradeCalendarEvent domain entity
  static TradeCalendarEvent fromEventDto(TradeCalendarEventDto dto) {
    return TradeCalendarEvent(
      id: dto.id,
      type: dto.type,
      title: dto.title,
      date: DateTime.parse(dto.date),
      description: dto.description,
      symbol: dto.symbol,
      amount: dto.amount,
      metadata: dto.metadata,
    );
  }

  /// Convert TradeCalendarDto to TradeCalendar domain entity
  static TradeCalendar fromDto(
    TradeCalendarDto dto,
    String userId,
    String portfolioId,
  ) {
    return TradeCalendar(
      userId: userId,
      portfolioId: portfolioId,
      events: dto.events.map((e) => fromEventDto(e)).toList(),
      totalEvents: dto.totalEvents ?? dto.events.length,
      startDate:
          dto.startDate != null ? DateTime.tryParse(dto.startDate!) : null,
      endDate: dto.endDate != null ? DateTime.tryParse(dto.endDate!) : null,
    );
  }

  /// Convert TradeCalendar domain entity to TradeCalendarDto
  static TradeCalendarDto toDto(TradeCalendar entity) {
    return TradeCalendarDto(
      events: entity.events
          .map(
            (e) => TradeCalendarEventDto(
              id: e.id,
              type: e.type,
              title: e.title,
              date: e.date.toIso8601String(),
              description: e.description,
              symbol: e.symbol,
              amount: e.amount,
              metadata: e.metadata,
            ),
          )
          .toList(),
      totalEvents: entity.totalEvents,
      startDate: entity.startDate?.toIso8601String(),
      endDate: entity.endDate?.toIso8601String(),
    );
  }
}
