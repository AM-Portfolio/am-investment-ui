import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../../domain/entities/document/document_upload.dart';
import '../../domain/repositories/document_repository.dart';
import '../mappers/document_mapper.dart';
import '../../../../config/config_service.dart';
import '../../../network/document_client.dart';
import '../../../network/dtos/document/document_dtos.dart';
import '../../../errors/exception.dart';

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
        
        // Create a temporary file for web uploads using MultipartFile.fromBytes
        final multipartFile = MultipartFile.fromBytes(
          file,
          filename: fileName,
        );
        
        // Use direct Dio call for web uploads since Retrofit doesn't handle Uint8List well
        apiResponse = await _uploadDocumentWeb(
          multipartFile,
          _mapCategoryToApiString(category),
          portfolioId,
          userId,
          fileName,
          description: description,
        );
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

  /// Upload document for web platform using direct Dio call
  /// This method bypasses Retrofit limitations with Uint8List handling
  Future<DocumentUploadResponse> _uploadDocumentWeb(
    MultipartFile multipartFile,
    String documentType,
    String portfolioId,
    String userId,
    String fileName, {
    String? description,
  }) async {
    try {
      // Get the base Dio instance from the client to maintain configuration
      final dio = Dio();
      
      // Copy configuration from the document client
      final config = ConfigService.config;
      final documentApiConfig = config.api.document;
      
      dio.options = BaseOptions(
        baseUrl: documentApiConfig?.baseUrl ?? 'http://localhost:8070',
        connectTimeout: Duration(seconds: documentApiConfig?.connectTimeout ?? 30),
        receiveTimeout: Duration(seconds: documentApiConfig?.receiveTimeout ?? 60),
        sendTimeout: Duration(seconds: documentApiConfig?.sendTimeout ?? 60),
        headers: {
          'Accept': 'application/json',
        },
      );

      // Create form data
      final formData = FormData.fromMap({
        'file': multipartFile,
        'documentType': documentType,
        'portfolioId': portfolioId,
        'userId': userId,
        if (description != null) 'description': description,
      });

      // Make the API call
      final response = await dio.post(
        '/api/v1/documents/process',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      // Parse response to DocumentUploadResponse
      return DocumentUploadResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      debugPrint('Error in web document upload: $e');
      throw ApiException('Failed to upload document via web: $e');
    }
  }

  /// Map DocumentCategory to API string
  String _mapCategoryToApiString(DocumentCategory category) {
    return category.value.toUpperCase();
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