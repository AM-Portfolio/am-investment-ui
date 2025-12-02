/// Journal cubit provider
/// 
/// This file contains the presentation layer provider for JournalCubit.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../presentation/cubit/journal/journal_cubit.dart';
import '../domain/journal_providers.dart';

// ============================================================================
// Cubit Provider
// ============================================================================

/// Provider for JournalCubit
/// 
/// Manages journal entry state and operations in the UI.
final journalCubitProvider = Provider<JournalCubit>(
  (ref) => JournalCubit(
    getJournalEntries: ref.watch(getJournalEntriesUseCaseProvider),
    createJournalEntry: ref.watch(createJournalEntryUseCaseProvider),
    updateJournalEntry: ref.watch(updateJournalEntryUseCaseProvider),
    deleteJournalEntry: ref.watch(deleteJournalEntryUseCaseProvider),
  ),
);
