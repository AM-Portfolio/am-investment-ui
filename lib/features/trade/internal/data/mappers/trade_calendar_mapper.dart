import '../../domain/entities/trade_calendar.dart';
import '../dtos/trade_calendar_dto.dart';

/// Mapper for trade calendar between DTO and domain entity
class TradeCalendarMapper {
  /// Convert TradeCalendarEventDto to TradeCalendarEvent domain entity
  static TradeCalendarEvent fromEventDto(TradeCalendarEventDto dto, String portfolioId) {
    return TradeCalendarEvent(
      tradeId: dto.id,
      portfolioId: portfolioId,
      tradeDate: DateTime.parse(dto.date),
      symbol: dto.symbol,
      status: dto.type,
      profitLoss: dto.amount,
      metadata: dto.metadata ?? {},
    );
  }

  /// Convert TradeCalendar Dto to TradeCalendar domain entity
  static TradeCalendar fromDto(
    TradeCalendarDto dto,
    String userId,
    String portfolioId,
  ) {
    return TradeCalendar(
      userId: userId,
      portfolioId: portfolioId,
      events: dto.events.map((e) => fromEventDto(e, portfolioId)).toList(),
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
              id: e.tradeId,
              type: e.status ?? 'UNKNOWN',
              title: e.symbol ?? 'Trade Event',
              date: e.tradeDate.toIso8601String(),
              description: null,
              symbol: e.symbol,
              amount: e.profitLoss,
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
