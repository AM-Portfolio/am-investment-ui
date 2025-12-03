import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import '../../config/app_config.dart';
import '../../core/network/api_client.dart';
import 'internal/data/datasources/notebook_remote_datasource.dart';
import 'internal/data/repositories/notebook_repository_impl.dart';
import 'internal/domain/repositories/notebook_repository.dart';
import 'internal/domain/usecases/notebook_usecases.dart';
import 'presentation/notebook/cubit/notebook_cubit.dart';

final notebookCubitProvider = Provider<NotebookCubit>((ref) {
  final getIt = GetIt.instance;
  
  // Ensure dependencies are registered or create them here if not singleton
  // Assuming ApiClient and ApiConfig are available via GetIt or we can get them from other providers
  // For now, let's create the chain here to be safe and self-contained, or use GetIt if established.
  
  final apiClient = getIt<ApiClient>();
  final apiConfig = getIt<ApiConfig>();

  final remoteDataSource = NotebookRemoteDataSourceImpl(
    apiClient: apiClient,
    apiConfig: apiConfig,
  );

  final repository = NotebookRepositoryImpl(remoteDataSource);

  return NotebookCubit(
    getNotebookItemsUseCase: GetNotebookItemsUseCase(repository),
    createNotebookItemUseCase: CreateNotebookItemUseCase(repository),
    updateNotebookItemUseCase: UpdateNotebookItemUseCase(repository),
    deleteNotebookItemUseCase: DeleteNotebookItemUseCase(repository),
    getNotebookTagsUseCase: GetNotebookTagsUseCase(repository),
    createNotebookTagUseCase: CreateNotebookTagUseCase(repository),
    updateNotebookTagUseCase: UpdateNotebookTagUseCase(repository),
    deleteNotebookTagUseCase: DeleteNotebookTagUseCase(repository),
  );
});
