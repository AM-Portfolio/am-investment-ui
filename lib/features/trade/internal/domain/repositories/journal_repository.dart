import '../entities/journal_entry.dart';

/// Repository interface for journal operations
abstract class JournalRepository {
  /// Create a new journal entry
  Future<JournalEntry> createJournalEntry({
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
    List<String>? relatedTradeIds,
  });

  /// Get a journal entry by ID
  Future<JournalEntry> getJournalEntry(String entryId);

  /// Update a journal entry
  Future<JournalEntry> updateJournalEntry({
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
    List<String>? relatedTradeIds,
  });

  /// Delete a journal entry
  Future<void> deleteJournalEntry(String entryId);

  /// Get journal entries for a user
  Future<List<JournalEntry>> getJournalEntriesByUser(String userId);

  /// Get journal entries for a specific trade
  Future<List<JournalEntry>> getJournalEntriesByTrade(String tradeId);

  /// Get journal entries by date range
  Future<List<JournalEntry>> getJournalEntriesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );
}
