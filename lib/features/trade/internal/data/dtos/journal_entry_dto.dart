import 'package:json_annotation/json_annotation.dart';

part 'journal_entry_dto.g.dart';

/// DTO for creating/updating a journal entry
@JsonSerializable()
class TradeJournalEntryRequestDto {
  const TradeJournalEntryRequestDto({
    required this.userId,
    required this.title,
    required this.content,
    required this.entryDate,
    this.tradeId,
    this.mood,
    this.marketSentiment,
    this.tags,
    this.customFields,
    this.imageUrls,
    this.relatedTradeIds,
  });

  factory TradeJournalEntryRequestDto.fromJson(Map<String, dynamic> json) =>
      _$TradeJournalEntryRequestDtoFromJson(json);

  final String userId;
  final String? tradeId;
  final String title;
  final String content;
  final String? mood;
  final int? marketSentiment;
  final List<String>? tags;
  final Map<String, dynamic>? customFields;
  final String entryDate;
  final List<String>? imageUrls;
  final List<String>? relatedTradeIds;

  Map<String, dynamic> toJson() => _$TradeJournalEntryRequestDtoToJson(this);
}

/// DTO for journal entry response
@JsonSerializable()
class TradeJournalEntryResponseDto {
  const TradeJournalEntryResponseDto({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.entryDate,
    required this.createdAt,
    required this.updatedAt,
    this.tradeId,
    this.mood,
    this.marketSentiment,
    this.tags,
    this.customFields,
    this.imageUrls,
    this.relatedTradeIds,
  });

  factory TradeJournalEntryResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TradeJournalEntryResponseDtoFromJson(json);

  final String id;
  final String userId;
  final String? tradeId;
  final String title;
  final String content;
  final String? mood;
  final int? marketSentiment;
  final List<String>? tags;
  final Map<String, dynamic>? customFields;
  final String entryDate;
  final List<String>? imageUrls;
  final List<String>? relatedTradeIds;
  final String createdAt;
  final String updatedAt;

  Map<String, dynamic> toJson() => _$TradeJournalEntryResponseDtoToJson(this);
}

/// DTO for journal entry list response
@JsonSerializable()
class JournalEntryListResponseDto {
  const JournalEntryListResponseDto({required this.content});

  factory JournalEntryListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$JournalEntryListResponseDtoFromJson(json);

  final List<TradeJournalEntryResponseDto> content;

  Map<String, dynamic> toJson() => _$JournalEntryListResponseDtoToJson(this);
}
