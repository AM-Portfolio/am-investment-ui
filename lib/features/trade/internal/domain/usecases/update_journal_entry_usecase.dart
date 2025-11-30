import '../entities/journal_entry.dart';
import '../repositories/journal_repository.dart';

class UpdateJournalEntryUseCase {
  UpdateJournalEntryUseCase(this._repository);

  final JournalRepository _repository;

  Future<JournalEntry> call({
    required String entryId,
    required String userId,
    required String title,
    required String content,
    required DateTime entryDate,
    String? tradeId,
    String? mood,
    int? marketSentiment,
    List<String>? tags,
    Map<String, dynamic>? customFields,
    List<String>? imageUrls,
    List<JournalAttachment>? attachments,
    List<String>? relatedTradeIds,
  }) => _repository.updateJournalEntry(
    entryId: entryId,
    userId: userId,
    title: title,
    content: content,
    entryDate: entryDate,
    tradeId: tradeId,
    mood: mood,
    marketSentiment: marketSentiment,
    tags: tags,
    customFields: customFields,
    imageUrls: imageUrls,
    attachments: attachments,
    relatedTradeIds: relatedTradeIds,
  );
}
