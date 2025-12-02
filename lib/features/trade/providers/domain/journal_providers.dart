/// Journal domain providers
/// 
/// This file contains use case providers for journal entry functionality.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../internal/domain/usecases/create_journal_entry_usecase.dart';
import '../../internal/domain/usecases/delete_journal_entry_usecase.dart';
import '../../internal/domain/usecases/get_journal_entries_usecase.dart';
import '../../internal/domain/usecases/update_journal_entry_usecase.dart';
import '../infrastructure/repository_providers.dart';

// ============================================================================
// Use Case Providers
// ============================================================================

/// Provider for GetJournalEntriesUseCase
final getJournalEntriesUseCaseProvider = Provider<GetJournalEntriesUseCase>((ref) {
  final repository = ref.watch(journalRepositoryProvider);
  return GetJournalEntriesUseCase(repository);
});

/// Provider for CreateJournalEntryUseCase
final createJournalEntryUseCaseProvider = Provider<CreateJournalEntryUseCase>((ref) {
  final repository = ref.watch(journalRepositoryProvider);
  return CreateJournalEntryUseCase(repository);
});

/// Provider for UpdateJournalEntryUseCase
final updateJournalEntryUseCaseProvider = Provider<UpdateJournalEntryUseCase>((ref) {
  final repository = ref.watch(journalRepositoryProvider);
  return UpdateJournalEntryUseCase(repository);
});

/// Provider for DeleteJournalEntryUseCase
final deleteJournalEntryUseCaseProvider = Provider<DeleteJournalEntryUseCase>((ref) {
  final repository = ref.watch(journalRepositoryProvider);
  return DeleteJournalEntryUseCase(repository);
});
