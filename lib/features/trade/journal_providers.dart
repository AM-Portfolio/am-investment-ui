import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/config_service.dart';
import '../../core/network/api_client.dart';
import 'internal/data/datasources/journal_remote_data_source.dart';
import 'internal/data/repositories/journal_repository_impl.dart';
import 'internal/domain/repositories/journal_repository.dart';
import 'internal/domain/usecases/create_journal_entry_usecase.dart';
import 'internal/domain/usecases/delete_journal_entry_usecase.dart';
import 'internal/domain/usecases/get_journal_entries_usecase.dart';
import 'internal/domain/usecases/update_journal_entry_usecase.dart';
import 'presentation/cubit/journal/journal_cubit.dart';

// Infrastructure Providers

/// Provider for ApiClient
final _apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

/// Provider for JournalRemoteDataSource
final _journalRemoteDataSourceProvider = Provider<JournalRemoteDataSource>((ref) {
  final apiClient = ref.watch(_apiClientProvider);
  final apiConfig = ConfigService.config.api;
  return JournalRemoteDataSourceImpl(apiClient: apiClient, tradeConfig: apiConfig.trade);
});

/// Provider for JournalRepository
final _journalRepositoryProvider = Provider<JournalRepository>((ref) {
  final remoteDataSource = ref.watch(_journalRemoteDataSourceProvider);
  return JournalRepositoryImpl(remoteDataSource: remoteDataSource);
});

// Use Case Providers

/// Provider for GetJournalEntriesUseCase
final _getJournalEntriesUseCaseProvider = Provider<GetJournalEntriesUseCase>((ref) {
  final repository = ref.watch(_journalRepositoryProvider);
  return GetJournalEntriesUseCase(repository);
});

/// Provider for CreateJournalEntryUseCase
final _createJournalEntryUseCaseProvider = Provider<CreateJournalEntryUseCase>((ref) {
  final repository = ref.watch(_journalRepositoryProvider);
  return CreateJournalEntryUseCase(repository);
});

/// Provider for UpdateJournalEntryUseCase
final _updateJournalEntryUseCaseProvider = Provider<UpdateJournalEntryUseCase>((ref) {
  final repository = ref.watch(_journalRepositoryProvider);
  return UpdateJournalEntryUseCase(repository);
});

/// Provider for DeleteJournalEntryUseCase
final _deleteJournalEntryUseCaseProvider = Provider<DeleteJournalEntryUseCase>((ref) {
  final repository = ref.watch(_journalRepositoryProvider);
  return DeleteJournalEntryUseCase(repository);
});

// Cubit Provider

/// Provider for JournalCubit
final journalCubitProvider = Provider<JournalCubit>(
  (ref) => JournalCubit(
    getJournalEntries: ref.watch(_getJournalEntriesUseCaseProvider),
    createJournalEntry: ref.watch(_createJournalEntryUseCaseProvider),
    updateJournalEntry: ref.watch(_updateJournalEntryUseCaseProvider),
    deleteJournalEntry: ref.watch(_deleteJournalEntryUseCaseProvider),
  ),
);
