import 'package:freezed_annotation/freezed_annotation.dart';

part 'journal_entry.freezed.dart';
part 'journal_entry.g.dart';

@freezed
class JournalAttachment with _$JournalAttachment {
  const factory JournalAttachment({
    required String fileName,
    required String fileUrl,
    String? fileType,
    DateTime? uploadedAt,
    String? description,
  }) = _JournalAttachment;

  factory JournalAttachment.fromJson(Map<String, dynamic> json) => _$JournalAttachmentFromJson(json);
}

@freezed
class JournalEntry with _$JournalEntry {
  const factory JournalEntry({
    required String id,
    required String userId,
    required String title,
    required String content,
    required DateTime entryDate,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? tradeId,
    String? mood,
    int? marketSentiment,
    @Default([]) List<String> tags,
    @Default({}) Map<String, dynamic> customFields,
    @Deprecated('Use attachments instead') @Default([]) List<String> imageUrls,
    @Default([]) List<JournalAttachment> attachments,
    @Default([]) List<String> relatedTradeIds,
  }) = _JournalEntry;

  factory JournalEntry.fromJson(Map<String, dynamic> json) => _$JournalEntryFromJson(json);
}
