import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../di/app_providers.dart';
import 'internal/data/datasources/cloudinary_remote_data_source.dart';
import 'internal/data/repositories/cloudinary_repository_impl.dart';
import 'internal/domain/repositories/cloudinary_repository.dart';
import 'internal/domain/usecases/delete_file_usecase.dart';
import 'internal/domain/usecases/get_resource_usecase.dart';
import 'internal/domain/usecases/list_resources_usecase.dart';
import 'internal/domain/usecases/upload_batch_files_usecase.dart';
import 'internal/domain/usecases/upload_file_usecase.dart';
import 'internal/presentation/cubits/attachment_cubit.dart';
import 'internal/services/cloudinary_upload_service.dart';
import 'internal/services/file_upload_service.dart';

/// Provider for HTTP client
final httpClientProvider = Provider<http.Client>((ref) => http.Client());

/// Provider for CloudinaryRemoteDataSource
final cloudinaryRemoteDataSourceProvider = FutureProvider<CloudinaryRemoteDataSource>((ref) async {
  final client = ref.watch(httpClientProvider);
  final appConfig = await ref.watch(appConfigProvider.future);

  return CloudinaryRemoteDataSource(client: client, apiConfig: appConfig.api);
});

/// Provider for CloudinaryRepository
final cloudinaryRepositoryProvider = FutureProvider<CloudinaryRepository>((ref) async {
  final remoteDataSource = await ref.watch(cloudinaryRemoteDataSourceProvider.future);

  return CloudinaryRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Provider for CloudinaryUploadService (using repository)
final cloudinaryUploadServiceProvider = FutureProvider<FileUploadService>((ref) async {
  final repository = await ref.watch(cloudinaryRepositoryProvider.future);

  return CloudinaryUploadService(repository: repository);
});

/// Main provider for file upload service
///
/// Uses Cloudinary via backend API
/// Backend handles cloud provider interactions, providing abstraction
final fileUploadServiceProvider = FutureProvider<FileUploadService>((ref) async {
  // Use Cloudinary via backend API
  return await ref.watch(cloudinaryUploadServiceProvider.future);
});

// Use Case Providers
final uploadFileUseCaseProvider = FutureProvider<UploadFileUseCase>((ref) async {
  final repository = await ref.watch(cloudinaryRepositoryProvider.future);
  return UploadFileUseCase(repository);
});

final uploadBatchFilesUseCaseProvider = FutureProvider<UploadBatchFilesUseCase>((ref) async {
  final repository = await ref.watch(cloudinaryRepositoryProvider.future);
  return UploadBatchFilesUseCase(repository);
});

final deleteFileUseCaseProvider = FutureProvider<DeleteFileUseCase>((ref) async {
  final repository = await ref.watch(cloudinaryRepositoryProvider.future);
  return DeleteFileUseCase(repository);
});

final getResourceUseCaseProvider = FutureProvider<GetResourceUseCase>((ref) async {
  final repository = await ref.watch(cloudinaryRepositoryProvider.future);
  return GetResourceUseCase(repository);
});

final listResourcesUseCaseProvider = FutureProvider<ListResourcesUseCase>((ref) async {
  final repository = await ref.watch(cloudinaryRepositoryProvider.future);
  return ListResourcesUseCase(repository);
});

// Attachment Cubit Provider
final attachmentCubitProvider = Provider.autoDispose<AttachmentCubit>(
  (ref) => AttachmentCubit(
    uploadFileUseCase: ref.read(uploadFileUseCaseProvider).value!,
    uploadBatchFilesUseCase: ref.read(uploadBatchFilesUseCaseProvider).value!,
    deleteFileUseCase: ref.read(deleteFileUseCaseProvider).value!,
  ),
);
