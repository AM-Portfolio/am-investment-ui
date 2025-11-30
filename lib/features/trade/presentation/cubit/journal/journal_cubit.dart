import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../internal/domain/entities/journal_entry.dart';
import '../../../internal/domain/usecases/create_journal_entry_usecase.dart';
import '../../../internal/domain/usecases/delete_journal_entry_usecase.dart';
import '../../../internal/domain/usecases/get_journal_entries_usecase.dart';
import '../../../internal/domain/usecases/update_journal_entry_usecase.dart';
import 'journal_state.dart';

class JournalCubit extends Cubit<JournalState> {
  JournalCubit({
    required this.getJournalEntries,
    required this.createJournalEntry,
    required this.updateJournalEntry,
    required this.deleteJournalEntry,
  }) : super(const JournalState.initial());

  final GetJournalEntriesUseCase getJournalEntries;
  final CreateJournalEntryUseCase createJournalEntry;
  final UpdateJournalEntryUseCase updateJournalEntry;
  final DeleteJournalEntryUseCase deleteJournalEntry;

  Future<void> loadJournalEntries(String userId) async {
    emit(const JournalState.loading());
    try {
      final entries = await getJournalEntries.getByUser(userId);
      emit(JournalState.loaded(entries));
    } catch (e) {
      emit(JournalState.error(e.toString()));
    }
  }

  Future<void> addJournalEntry({
    required String userId,
    required String title,
    required String content,
    required DateTime entryDate,
    String? tradeId,
    List<BehaviorPatternSummary>? behaviorPatternSummaries,
    Map<String, dynamic>? customFields,
    List<String>? imageUrls,
    List<JournalAttachment>? attachments,
    List<String>? relatedTradeIds,
  }) async {
    emit(const JournalState.loading());
    try {
      await createJournalEntry(
        userId: userId,
        title: title,
        content: content,
        entryDate: entryDate,
        tradeId: tradeId,
        behaviorPatternSummaries: behaviorPatternSummaries,
        customFields: customFields,
        imageUrls: imageUrls,
        attachments: attachments,
        relatedTradeIds: relatedTradeIds,
      );
      emit(const JournalState.success('Journal entry created successfully'));
      await loadJournalEntries(userId);
    } catch (e) {
      emit(JournalState.error(e.toString()));
    }
  }

  Future<void> editJournalEntry({
    required String entryId,
    required String userId,
    required String title,
    required String content,
    required DateTime entryDate,
    String? tradeId,
    List<BehaviorPatternSummary>? behaviorPatternSummaries,
    Map<String, dynamic>? customFields,
    List<String>? imageUrls,
    List<JournalAttachment>? attachments,
    List<String>? relatedTradeIds,
  }) async {
    emit(const JournalState.loading());
    try {
      await updateJournalEntry(
        entryId: entryId,
        userId: userId,
        title: title,
        content: content,
        entryDate: entryDate,
        tradeId: tradeId,
        behaviorPatternSummaries: behaviorPatternSummaries,
        customFields: customFields,
        imageUrls: imageUrls,
        attachments: attachments,
        relatedTradeIds: relatedTradeIds,
      );
      emit(const JournalState.success('Journal entry updated successfully'));
      await loadJournalEntries(userId);
    } catch (e) {
      emit(JournalState.error(e.toString()));
    }
  }

  Future<void> removeJournalEntry(String userId, String entryId) async {
    emit(const JournalState.loading());
    try {
      await deleteJournalEntry(entryId);
      emit(const JournalState.success('Journal entry deleted successfully'));
      await loadJournalEntries(userId);
    } catch (e) {
      emit(JournalState.error(e.toString()));
    }
  }
}
