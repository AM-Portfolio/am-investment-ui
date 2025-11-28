import 'package:freezed_annotation/freezed_annotation.dart';

part 'journal_entry.freezed.dart';
part 'journal_entry.g.dart';

@freezed
class JournalEntry with _$JournalEntry {
  const factory JournalEntry({
    required String id,
    required String userId,
    String? tradeId,
    required String title,
    required String content,
    String? mood,
    int? marketSentiment,
    @Default([]) List<String> tags,
    @Default({}) Map<String, dynamic> customFields,
    required DateTime entryDate,
    @Default([]) List<String> imageUrls,
    @Default([]) List<String> relatedTradeIds,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _JournalEntry;

  factory JournalEntry.fromJson(Map<String, dynamic> json) => _$JournalEntryFromJson(json);
}
