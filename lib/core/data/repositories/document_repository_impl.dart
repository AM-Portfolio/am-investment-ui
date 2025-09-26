import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../../domain/entities/document/document_upload.dart';
import '../../domain/repositories/document_repository.dart';
import '../api/models/api_document_upload.dart';
import '../mappers/document_mapper.dart';
import '../../../core/services/api/document_client.dart';
import '../../../core/services/api/api_exception.dart';

/// Concrete implementation of DocumentRepository
/// Handles API calls, caching, error handling, and data transformation
class DocumentRepositoryImpl implements DocumentRepository {
  /// API client for document operations
  final DocumentClient _apiClient;
  
  /// Cache for document uploads
  final Map<String, _CachedDocumentData<DocumentUpload>> _documentCache = {};
  
  /// Cache for document history
  final Map<String, _CachedDocumentData<DocumentUploadCollection>> _historyCache = {};
  
  /// Stream controllers for real-time updates
  final Map<String, StreamController<DocumentUpload>> _statusStreamControllers = {};
  final Map<String, StreamController<DocumentUploadCollection>> _historyStreamControllers = {};
  
  /// Cache duration (5 minutes for documents, 2 minutes for history)
  static const Duration _documentCacheExpiry = Duration(minutes: 5);
  static const Duration _historyCacheExpiry = Duration(minutes: 2);

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
        
        final mimeType = _getMimeType(fileName);
        final multipartFile = MultipartFile.fromBytes(
          file,
          filename: fileName,
          contentType: DioMediaType.parse(mimeType),
        );

        apiResponse = await _apiClient.uploadDocumentMultipart(
          multipartFile,
          _mapCategoryToApiString(category),
          portfolioId,
          userId,
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
      final domainModel = DocumentMapper.fromApiUploadResponse(apiResponse);
      final domainModelWithContext = domainModel.copyWith(
        metadata: domainModel.metadata.copyWith(
          portfolioId: portfolioId,
          userId: userId,
          description: description,
          customMetadata: metadata,
        ),
      );

      // Cache the result
      _documentCache[apiResponse.processId] = _CachedDocumentData(
        data: domainModelWithContext,
        timestamp: DateTime.now(),
      );

      // Notify status stream listeners
      _notifyStatusStreamListeners(apiResponse.processId, domainModelWithContext);

      // Clear history cache to ensure fresh data on next fetch
      _historyCache.remove(userId);

      return domainModelWithContext;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      debugPrint('Error uploading document: $e');
      throw ApiException('Failed to upload document: $e');
    }
  }

  @override
  Future<DocumentUpload> getDocumentStatus(String processId) async {
    try {
      // Check cache first
      if (isDocumentCachedDataFresh(processId)) {
        return _documentCache[processId]!.data;
      }

      // Fetch from API
      final apiResponse = await _apiClient.getProcessingStatus(processId);
      
      // Convert to domain model
      final domainModel = DocumentMapper.fromApiProcessStatus(apiResponse);
      
      // Cache the result
      _documentCache[processId] = _CachedDocumentData(
        data: domainModel,
        timestamp: DateTime.now(),
      );

      // Notify status stream listeners
      _notifyStatusStreamListeners(processId, domainModel);
      
      return domainModel;
    } on DioException catch (e) {
      // Return cached data if available, even if stale
      if (_documentCache.containsKey(processId)) {
        return _documentCache[processId]!.data;
      }
      throw _handleDioError(e);
    } catch (e) {
      debugPrint('Error fetching document status: $e');
      
      // Return cached data if available
      if (_documentCache.containsKey(processId)) {
        return _documentCache[processId]!.data;
      }
      
      throw ApiException('Failed to fetch document status: $e');
    }
  }

  @override
  Future<DocumentUploadCollection> getDocumentHistory({
    required String userId,
    DocumentCategory? category,
    DocumentProcessingStatus? status,
    int? limit,
    int? offset,
  }) async {
    try {
      // Check cache first (only if no filters applied)
      if (category == null && status == null && limit == null && offset == null) {
        if (isHistoryCachedDataFresh(userId)) {
          return _historyCache[userId]!.data;
        }
      }

      // Fetch from API
      final apiResponse = await _apiClient.getProcessingHistory(
        userId,
        documentType: category != null ? _mapCategoryToApiString(category) : null,
        status: status?.name,
        limit: limit,
        offset: offset,
      );
      
      // Convert to domain model
      final domainModel = DocumentMapper.fromApiStatusList(apiResponse, userId: userId);
      
      // Cache the result (only if no filters applied)
      if (category == null && status == null && limit == null && offset == null) {
        _historyCache[userId] = _CachedDocumentData(
          data: domainModel,
          timestamp: DateTime.now(),
        );
      }

      // Notify history stream listeners
      _notifyHistoryStreamListeners(userId, domainModel);
      
      return domainModel;
    } on DioException catch (e) {
      // Return cached data if available, even if stale
      if (_historyCache.containsKey(userId)) {
        return _historyCache[userId]!.data;
      }

      // Return mock data in development environment
      if (_isDevelopmentEnvironment()) {
        debugPrint('Using mock document history data in development');
        return DocumentMapper.createMockCollection(userId);
      }

      throw _handleDioError(e);
    } catch (e) {
      debugPrint('Error fetching document history: $e');
      
      // Return cached data if available
      if (_historyCache.containsKey(userId)) {
        return _historyCache[userId]!.data;
      }

      // Return mock data in development environment
      if (_isDevelopmentEnvironment()) {
        debugPrint('Using mock document history data in development');
        return DocumentMapper.createMockCollection(userId);
      }
      
      throw ApiException('Failed to fetch document history: $e');
    }
  }

  @override
  Future<void> cancelDocumentProcessing(String processId) async {
    try {
      await _apiClient.cancelProcessing(processId);
      
      // Update cached data if available
      if (_documentCache.containsKey(processId)) {
        final cachedDoc = _documentCache[processId]!.data;
        final updatedDoc = cachedDoc.copyWith(
          status: cachedDoc.status.copyWith(
            current: DocumentProcessingStatus.cancelled,
            completedAt: DateTime.now(),
            message: 'Processing cancelled by user',
          ),
        );
        
        _documentCache[processId] = _CachedDocumentData(
          data: updatedDoc,
          timestamp: DateTime.now(),
        );

        // Notify status stream listeners
        _notifyStatusStreamListeners(processId, updatedDoc);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      debugPrint('Error cancelling document processing: $e');
      throw ApiException('Failed to cancel document processing: $e');
    }
  }

  @override
  Future<List<int>> downloadProcessedDocument(String processId) async {
    try {
      final response = await _apiClient.downloadProcessedDocument(processId);
      return response.stream.toBytes();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      debugPrint('Error downloading processed document: $e');
      throw ApiException('Failed to download processed document: $e');
    }
  }

  @override
  Future<DocumentUploadCollection> getPortfolioDocuments({
    required String portfolioId,
    DocumentCategory? category,
    int? limit,
  }) async {
    // For now, this could be implemented by filtering the user's history
    // In a real API, there might be a dedicated endpoint for portfolio documents
    throw UnimplementedError('Portfolio documents endpoint not yet implemented');
  }

  @override
  Stream<DocumentUpload> documentStatusStream(String processId) {
    if (!_statusStreamControllers.containsKey(processId)) {
      _statusStreamControllers[processId] = StreamController<DocumentUpload>.broadcast();
    }
    return _statusStreamControllers[processId]!.stream;
  }

  @override
  Stream<DocumentUploadCollection> documentHistoryStream(String userId) {
    if (!_historyStreamControllers.containsKey(userId)) {
      _historyStreamControllers[userId] = StreamController<DocumentUploadCollection>.broadcast();
    }
    return _historyStreamControllers[userId]!.stream;
  }

  @override
  bool isDocumentCachedDataFresh(String processId) {
    if (!_documentCache.containsKey(processId)) return false;
    
    final cachedData = _documentCache[processId]!;
    final now = DateTime.now();
    return now.difference(cachedData.timestamp) < _documentCacheExpiry;
  }

  @override
  bool isHistoryCachedDataFresh(String userId) {
    if (!_historyCache.containsKey(userId)) return false;
    
    final cachedData = _historyCache[userId]!;
    final now = DateTime.now();
    return now.difference(cachedData.timestamp) < _historyCacheExpiry;
  }

  @override
  Future<void> clearDocumentCache(String processId) async {
    _documentCache.remove(processId);
  }

  @override
  Future<void> clearHistoryCache(String userId) async {
    _historyCache.remove(userId);
  }

  @override
  Future<void> clearAllCache(String userId) async {
    // Clear all document caches for documents belonging to this user
    _documentCache.removeWhere((key, value) => value.data.metadata.userId == userId);
    
    // Clear history cache
    _historyCache.remove(userId);
  }

  @override
  Future<DocumentUpload> refreshDocumentStatus(String processId) async {
    // Clear cache first, then fetch fresh data
    _documentCache.remove(processId);
    return getDocumentStatus(processId);
  }

  @override
  Future<DocumentUploadCollection> refreshDocumentHistory(String userId) async {
    // Clear cache first, then fetch fresh data
    _historyCache.remove(userId);
    return getDocumentHistory(userId: userId);
  }

  @override
  Future<Map<String, int>> getProcessingStatistics(String userId) async {
    try {
      final history = await getDocumentHistory(userId: userId);
      
      return {
        'total': history.totalUploads,
        'completed': history.completedUploads,
        'failed': history.failedUploads,
        'processing': history.processingUploads,
      };
    } catch (e) {
      debugPrint('Error fetching processing statistics: $e');
      return {
        'total': 0,
        'completed': 0,
        'failed': 0,
        'processing': 0,
      };
    }
  }

  @override
  Future<DocumentUpload> retryDocumentProcessing(String processId) async {
    // This would typically require a retry endpoint in the API
    throw UnimplementedError('Retry processing endpoint not yet implemented');
  }

  @override
  Future<List<DocumentUpload>> bulkUploadDocuments({
    required List<Map<String, dynamic>> uploadRequests,
    required String userId,
  }) async {
    // This would typically use a bulk upload endpoint
    throw UnimplementedError('Bulk upload endpoint not yet implemented');
  }

  @override
  List<DocumentCategory> getSupportedCategories() {
    return DocumentCategory.values;
  }

  @override
  Future<Map<String, dynamic>> validateDocument({
    required String fileName,
    required int fileSize,
    required DocumentCategory category,
  }) async {
    // Basic validation logic
    final errors = <String>[];
    final warnings = <String>[];

    // File size validation (50MB limit)
    const maxFileSize = 50 * 1024 * 1024; // 50MB
    if (fileSize > maxFileSize) {
      errors.add('File size exceeds 50MB limit');
    }

    // File extension validation
    final allowedExtensions = ['.pdf', '.jpg', '.jpeg', '.png', '.tiff'];
    final extension = fileName.toLowerCase().substring(fileName.lastIndexOf('.'));
    if (!allowedExtensions.contains(extension)) {
      errors.add('File type not supported. Allowed: ${allowedExtensions.join(', ')}');
    }

    // Category-specific validations
    if (category == DocumentCategory.companyFinancialReport && !fileName.toLowerCase().contains('financial')) {
      warnings.add('Filename doesn\'t seem to match document category');
    }

    return {
      'isValid': errors.isEmpty,
      'errors': errors,
      'warnings': warnings,
    };
  }

  /// Helper method to get MIME type from file name
  String _getMimeType(String fileName) {
    final extension = fileName.toLowerCase().substring(fileName.lastIndexOf('.'));
    switch (extension) {
      case '.pdf':
        return 'application/pdf';
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.tiff':
        return 'image/tiff';
      default:
        return 'application/octet-stream';
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

  /// Check if environment is development
  bool _isDevelopmentEnvironment() {
    return const String.fromEnvironment('ENVIRONMENT', defaultValue: 'prod') == 'dev';
  }

  /// Notify status stream listeners
  void _notifyStatusStreamListeners(String processId, DocumentUpload document) {
    final controller = _statusStreamControllers[processId];
    if (controller != null && !controller.isClosed) {
      controller.add(document);
    }
  }

  /// Notify history stream listeners
  void _notifyHistoryStreamListeners(String userId, DocumentUploadCollection collection) {
    final controller = _historyStreamControllers[userId];
    if (controller != null && !controller.isClosed) {
      controller.add(collection);
    }
  }

  /// Dispose stream controllers
  void dispose() {
    for (final controller in _statusStreamControllers.values) {
      controller.close();
    }
    for (final controller in _historyStreamControllers.values) {
      controller.close();
    }
    _statusStreamControllers.clear();
    _historyStreamControllers.clear();
  }
}

/// Helper class for caching data with timestamps
class _CachedDocumentData<T> {
  final T data;
  final DateTime timestamp;

  _CachedDocumentData({
    required this.data,
    required this.timestamp,
  });
}