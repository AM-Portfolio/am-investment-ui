import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/config_service.dart';
import '../../core/network/api_client.dart';
import 'internal/data/datasources/notebook_remote_datasource.dart';
import 'internal/data/repositories/notebook_repository_impl.dart';
import 'internal/domain/repositories/notebook_repository.dart';
import 'internal/domain/usecases/notebook_usecases.dart';
import 'presentation/notebook/cubit/notebook_cubit.dart';

// Infrastructure Providers

/// Provider for ApiClient
final _apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

/// Provider for NotebookRemoteDataSource
final _notebookRemoteDataSourceProvider = Provider<NotebookRemoteDataSource>((ref) {
  final apiClient = ref.watch(_apiClientProvider);
  final apiConfig = ConfigService.config.api;
  return NotebookRemoteDataSourceImpl(apiClient: apiClient, apiConfig: apiConfig);
});

/// Provider for NotebookRepository
final _notebookRepositoryProvider = Provider<NotebookRepository>((ref) {
  final remoteDataSource = ref.watch(_notebookRemoteDataSourceProvider);
  return NotebookRepositoryImpl(remoteDataSource);
});

// Use Case Providers

/// Provider for GetNotebookItemsUseCase
final _getNotebookItemsUseCaseProvider = Provider<GetNotebookItemsUseCase>((ref) {
  final repository = ref.watch(_notebookRepositoryProvider);
  return GetNotebookItemsUseCase(repository);
});

/// Provider for CreateNotebookItemUseCase
final _createNotebookItemUseCaseProvider = Provider<CreateNotebookItemUseCase>((ref) {
  final repository = ref.watch(_notebookRepositoryProvider);
  return CreateNotebookItemUseCase(repository);
});

/// Provider for UpdateNotebookItemUseCase
final _updateNotebookItemUseCaseProvider = Provider<UpdateNotebookItemUseCase>((ref) {
  final repository = ref.watch(_notebookRepositoryProvider);
  return UpdateNotebookItemUseCase(repository);
});

/// Provider for DeleteNotebookItemUseCase
final _deleteNotebookItemUseCaseProvider = Provider<DeleteNotebookItemUseCase>((ref) {
  final repository = ref.watch(_notebookRepositoryProvider);
  return DeleteNotebookItemUseCase(repository);
});

/// Provider for GetNotebookTagsUseCase
final _getNotebookTagsUseCaseProvider = Provider<GetNotebookTagsUseCase>((ref) {
  final repository = ref.watch(_notebookRepositoryProvider);
  return GetNotebookTagsUseCase(repository);
});

/// Provider for CreateNotebookTagUseCase
final _createNotebookTagUseCaseProvider = Provider<CreateNotebookTagUseCase>((ref) {
  final repository = ref.watch(_notebookRepositoryProvider);
  return CreateNotebookTagUseCase(repository);
});

/// Provider for UpdateNotebookTagUseCase
final _updateNotebookTagUseCaseProvider = Provider<UpdateNotebookTagUseCase>((ref) {
  final repository = ref.watch(_notebookRepositoryProvider);
  return UpdateNotebookTagUseCase(repository);
});

/// Provider for DeleteNotebookTagUseCase
final _deleteNotebookTagUseCaseProvider = Provider<DeleteNotebookTagUseCase>((ref) {
  final repository = ref.watch(_notebookRepositoryProvider);
  return DeleteNotebookTagUseCase(repository);
});

// Cubit Provider

/// Provider for NotebookCubit
final notebookCubitProvider = Provider<NotebookCubit>(
  (ref) => NotebookCubit(
    getNotebookItemsUseCase: ref.watch(_getNotebookItemsUseCaseProvider),
    createNotebookItemUseCase: ref.watch(_createNotebookItemUseCaseProvider),
    updateNotebookItemUseCase: ref.watch(_updateNotebookItemUseCaseProvider),
    deleteNotebookItemUseCase: ref.watch(_deleteNotebookItemUseCaseProvider),
    getNotebookTagsUseCase: ref.watch(_getNotebookTagsUseCaseProvider),
    createNotebookTagUseCase: ref.watch(_createNotebookTagUseCaseProvider),
    updateNotebookTagUseCase: ref.watch(_updateNotebookTagUseCaseProvider),
    deleteNotebookTagUseCase: ref.watch(_deleteNotebookTagUseCaseProvider),
  ),
);
