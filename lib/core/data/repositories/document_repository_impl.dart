import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../../domain/entities/document/document_upload.dart';
import '../../domain/repositories/document_repository.dart';
import '../api/models/api_document_upload.dart';
import '../mappers/document_mapper.dart';
import '../../../core/services/api/document_client.dart';
import '../../../core/services/api/api_exception.dart';

/// Concrete implementation of DocumentRepository
/// Handles API calls and data transformation for document uploads
class DocumentRepositoryImpl implements DocumentRepository {
  /// API client for document operations
  final DocumentClient _apiClient;

  /// Constructor
  DocumentRepositoryImpl({required DocumentClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<DocumentUpload> uploadDocument({
    required dynamic file,
    required String fileName,
    required DocumentCategory category,
    required String portfolioId,
    required String userId,
    String? description,
    Map<String, String>? metadata,
  }) async {
    try {
      DocumentUploadResponse apiResponse;

      if (kIsWeb) {
        // Web platform - handle Uint8List
        if (file is! Uint8List) {
          throw ArgumentError('On web platform, file must be Uint8List');
        }
        
        throw UnsupportedError('MultipartFile upload temporarily disabled due to Retrofit issue');
      } else {
        // Mobile/Desktop platform - handle File
        if (file is! File) {
          throw ArgumentError('On mobile/desktop platforms, file must be File');
        }

        apiResponse = await _apiClient.uploadDocument(
          file,
          _mapCategoryToApiString(category),
          portfolioId,
          userId,
          description: description,
        );
      }

      // Convert to domain model with context
      return DocumentMapper.fromApiUploadResponseWithContext(
        apiResponse,
        portfolioId: portfolioId,
        userId: userId,
        description: description,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      debugPrint('Error uploading document: $e');
      throw ApiException('Failed to upload document: $e');
    }
  }



  /// Map DocumentCategory to API string
  String _mapCategoryToApiString(DocumentCategory category) {
    return category.name.toUpperCase();
  }

  /// Handle Dio errors and convert to ApiException
  ApiException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('Request timeout. Please check your connection.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? 'Unknown error occurred';
        return ApiException('Server error ($statusCode): $message');
      case DioExceptionType.connectionError:
        return ApiException('Connection error. Please check your internet connection.');
      case DioExceptionType.cancel:
        return ApiException('Request was cancelled');
      default:
        return ApiException('Network error: ${e.message}');
    }
  }
}