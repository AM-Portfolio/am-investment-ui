import 'package:json_annotation/json_annotation.dart';

part 'trade_calendar_dto.g.dart';

/// DTO for trade calendar event from API
@JsonSerializable()
class TradeCalendarEventDto {
  const TradeCalendarEventDto({
    required this.id,
    required this.type,
    required this.title,
    required this.date,
    this.description,
    this.symbol,
    this.amount,
    this.metadata,
  });

  factory TradeCalendarEventDto.fromJson(Map<String, dynamic> json) =>
      _$TradeCalendarEventDtoFromJson(json);

  final String id;
  final String type;
  final String title;
  final String date;
  final String? description;
  final String? symbol;
  final double? amount;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() => _$TradeCalendarEventDtoToJson(this);
}

/// DTO for trade calendar from API
@JsonSerializable()
class TradeCalendarDto {
  const TradeCalendarDto({
    required this.events,
    this.totalEvents,
    this.startDate,
    this.endDate,
  });

  factory TradeCalendarDto.fromJson(Map<String, dynamic> json) =>
      _$TradeCalendarDtoFromJson(json);

  final List<TradeCalendarEventDto> events;
  final int? totalEvents;
  final String? startDate;
  final String? endDate;

  Map<String, dynamic> toJson() => _$TradeCalendarDtoToJson(this);
}
