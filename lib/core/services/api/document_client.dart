import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/api/models/api_document_upload.dart';
import '../../config/config_service.dart';
import 'api_exception.dart';

part 'document_client.g.dart';

/// Retrofit client for document upload and processing API
/// Note: Retrofit requires static endpoints, so configuration is limited to baseUrl and timeouts
@RestApi()
abstract class DocumentClient {
  factory DocumentClient(Dio dio, {String baseUrl}) = _DocumentClient;

  /// Upload a document for processing
  /// POST /api/v1/documents/process
  @POST('/api/v1/documents/process')
  @MultiPart()
  Future<DocumentUploadResponse> uploadDocument(
    @Part(name: 'file') File file,
    @Part(name: 'documentType') String documentType,
    @Part(name: 'portfolioId') String portfolioId,
    @Part(name: 'userId') String userId, {
    @Part(name: 'description') String? description,
  });
}

/// Provider for DocumentClient
/// Configures Dio client with proper error handling, timeouts, and logging
/// Note: Only baseUrl and client configuration can be dynamic with Retrofit
@Riverpod()
DocumentClient documentClient(DocumentClientRef ref) {
  final dio = Dio();
  
  // Get configuration from ConfigService
  final config = ConfigService.config;
  final documentApiConfig = config?.api?.document;
  
  // Configure Dio with base options
  dio.options = BaseOptions(
    baseUrl: documentApiConfig?.baseUrl ?? 'http://localhost:8070',
    connectTimeout: Duration(seconds: documentApiConfig?.connectTimeout ?? 30),
    receiveTimeout: Duration(seconds: documentApiConfig?.receiveTimeout ?? 60),
    sendTimeout: Duration(seconds: documentApiConfig?.sendTimeout ?? 60),
    headers: {
      'Content-Type': 'multipart/form-data',
      'Accept': 'application/json',
    },
  );

  // Add interceptors
  _addInterceptors(dio);

  return DocumentClient(dio);
}

/// Add interceptors to Dio client
void _addInterceptors(Dio dio) {
  // Add authentication interceptor
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      // Add auth token if available
      final token = await _getAuthToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
    onError: (error, handler) {
      // Transform DioException to ApiException
      final apiException = _handleDioError(error);
      debugPrint('Document API Error: ${apiException.message}');
      handler.next(error);
    },
  ));

  // Add logging interceptor in debug mode
  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: false, // Don't log file bodies for uploads
      responseBody: true,
      error: true,
      logPrint: (obj) => debugPrint('[DocumentClient] $obj'),
    ));
  }

  // Add retry interceptor for network failures
  dio.interceptors.add(InterceptorsWrapper(
    onError: (error, handler) async {
      if (_shouldRetry(error) && error.requestOptions.extra['retryCount'] == null) {
        error.requestOptions.extra['retryCount'] = 1;
        
        // Wait before retry
        await Future.delayed(const Duration(seconds: 2));
        
        try {
          final response = await dio.fetch(error.requestOptions);
          handler.resolve(response);
          return;
        } catch (e) {
          // Retry failed, continue with original error
        }
      }
      handler.next(error);
    },
  ));
}

/// Get authentication token from storage
Future<String?> _getAuthToken() async {
  try {
    // This would integrate with your auth service
    // For now, return null - implement based on your auth pattern
    return null;
  } catch (e) {
    debugPrint('Error getting auth token: $e');
    return null;
  }
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

/// Check if request should be retried
bool _shouldRetry(DioException error) {
  return error.type == DioExceptionType.connectionError ||
         error.type == DioExceptionType.connectionTimeout ||
         (error.response?.statusCode != null && 
          error.response!.statusCode! >= 500);
}

