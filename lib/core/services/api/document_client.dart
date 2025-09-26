import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/api/models/api_document_upload.dart';

part 'document_client.g.dart';

/// Retrofit client for document upload and processing API
@RestApi()
abstract class DocumentClient {
  factory DocumentClient(Dio dio, {String baseUrl}) = _DocumentClient;

  /// Upload a document for processing
  /// POST /api/v1/documents/process
  @POST('/api/v1/documents/process')
  @MultiPart()
  Future<DocumentUploadResponse> uploadDocument(
    @Part('file') File file,
    @Part('documentType') String documentType,
    @Part('portfolioId') String portfolioId,
    @Part('userId') String userId, {
    @Part('description') String? description,
  });

  /// Upload document with MultipartFile (for web support)
  /// POST /api/v1/documents/process
  @POST('/api/v1/documents/process')
  @MultiPart()
  Future<DocumentUploadResponse> uploadDocumentMultipart(
    @Part() MultipartFile file,
    @Part('documentType') String documentType,
    @Part('portfolioId') String portfolioId,
    @Part('userId') String userId, {
    @Part('description') String? description,
  });

  /// Get document processing status
  /// GET /api/v1/documents/process/{processId}/status
  @GET('/api/v1/documents/process/{processId}/status')
  Future<DocumentProcessStatus> getProcessingStatus(
    @Path('processId') String processId,
  );

  /// Get all document processing history for a user
  /// GET /api/v1/documents/process/history
  @GET('/api/v1/documents/process/history')
  Future<List<DocumentProcessStatus>> getProcessingHistory(
    @Query('userId') String userId, {
    @Query('documentType') String? documentType,
    @Query('status') String? status,
    @Query('limit') int? limit,
    @Query('offset') int? offset,
  });

  /// Cancel document processing
  /// DELETE /api/v1/documents/process/{processId}
  @DELETE('/api/v1/documents/process/{processId}')
  Future<void> cancelProcessing(
    @Path('processId') String processId,
  );

  /// Download processed document results
  /// GET /api/v1/documents/process/{processId}/download
  @GET('/api/v1/documents/process/{processId}/download')
  Future<ResponseBody> downloadProcessedDocument(
    @Path('processId') String processId,
  );
}

/// Provider for DocumentClient
@Riverpod()
DocumentClient documentClient(DocumentClientRef ref) {
  final dio = Dio();
  
  // Configure Dio with base options
  dio.options = BaseOptions(
    baseUrl: 'http://localhost:8070', // Document service base URL
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60), // Longer timeout for file uploads
    sendTimeout: const Duration(seconds: 60),
    headers: {
      'Content-Type': 'multipart/form-data',
      'Accept': 'application/json',
    },
  );

  // Add logging interceptor in debug mode
  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      response: true,
      responseBody: true,
      error: true,
    ));
  }

  return DocumentClient(dio);
}