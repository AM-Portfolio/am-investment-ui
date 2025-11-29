import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

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

/// Provider for base URL (should come from environment config)
final baseUrlProvider = Provider<String>((ref) {
  // TODO: Replace with actual backend URL from environment config
  return 'https://your-backend-api.com';
});

/// Provider for CloudinaryRemoteDataSource
final cloudinaryRemoteDataSourceProvider = Provider<CloudinaryRemoteDataSource>((ref) {
  final client = ref.watch(httpClientProvider);
  final baseUrl = ref.watch(baseUrlProvider);

  return CloudinaryRemoteDataSource(client: client, baseUrl: baseUrl);
});

/// Provider for CloudinaryRepository
final cloudinaryRepositoryProvider = Provider<CloudinaryRepository>((ref) {
  final remoteDataSource = ref.watch(cloudinaryRemoteDataSourceProvider);

  return CloudinaryRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Provider for CloudinaryUploadService (using repository)
final cloudinaryUploadServiceProvider = Provider<FileUploadService>((ref) {
  final repository = ref.watch(cloudinaryRepositoryProvider);

  return CloudinaryUploadService(repository: repository);
});

/// Main provider for file upload service
///
/// Uses Cloudinary via backend API
/// Backend handles cloud provider interactions, providing abstraction
final fileUploadServiceProvider = Provider<FileUploadService>((ref) {
  // Use Cloudinary via backend API
  return ref.watch(cloudinaryUploadServiceProvider);
});

// Use Case Providers
final uploadFileUseCaseProvider = Provider<UploadFileUseCase>((ref) {
  final repository = ref.watch(cloudinaryRepositoryProvider);
  return UploadFileUseCase(repository);
});

final uploadBatchFilesUseCaseProvider = Provider<UploadBatchFilesUseCase>((ref) {
  final repository = ref.watch(cloudinaryRepositoryProvider);
  return UploadBatchFilesUseCase(repository);
});

final deleteFileUseCaseProvider = Provider<DeleteFileUseCase>((ref) {
  final repository = ref.watch(cloudinaryRepositoryProvider);
  return DeleteFileUseCase(repository);
});

final getResourceUseCaseProvider = Provider<GetResourceUseCase>((ref) {
  final repository = ref.watch(cloudinaryRepositoryProvider);
  return GetResourceUseCase(repository);
});

final listResourcesUseCaseProvider = Provider<ListResourcesUseCase>((ref) {
  final repository = ref.watch(cloudinaryRepositoryProvider);
  return ListResourcesUseCase(repository);
});

// Attachment Cubit Provider
final attachmentCubitProvider = Provider.autoDispose<AttachmentCubit>(
  (ref) => AttachmentCubit(
    uploadFileUseCase: ref.read(uploadFileUseCaseProvider),
    uploadBatchFilesUseCase: ref.read(uploadBatchFilesUseCaseProvider),
    deleteFileUseCase: ref.read(deleteFileUseCaseProvider),
  ),
);
