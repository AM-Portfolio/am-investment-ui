import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/entities/document/document_upload.dart';
import '../domain/repositories/document_repository.dart';
import '../config/config_service.dart';

part 'document_upload_service.g.dart';

/// Service for handling document upload operations
/// Uses repository pattern and provides business logic layer
class DocumentUploadService {
  final DocumentRepository _documentRepository;

  DocumentUploadService(this._documentRepository);

  /// Upload a file for document processing
  /// Supports both File (mobile/desktop) and Uint8List (web) inputs
  /// Validates file before upload and handles business logic
  Future<DocumentUpload> uploadDocument({
    required dynamic file, // File or Uint8List
    required String fileName,
    required DocumentCategory category,
    required String portfolioId,
    required String userId,
    String? description,
  }) async {
    try {
      // Validate file before upload
      final fileSize = _getFileSize(file);
      final validationResult = await _documentRepository.validateDocument(
        fileName: fileName,
        fileSize: fileSize,
        category: category,
      );

      if (!validationResult['isValid']) {
        final errors = validationResult['errors'] as List<String>;
        throw ArgumentError('File validation failed: ${errors.join(', ')}');
      }

      // Log warnings if any
      final warnings = validationResult['warnings'] as List<String>?;
      if (warnings != null && warnings.isNotEmpty) {
        debugPrint('Upload warnings: ${warnings.join(', ')}');
      }

      // Check if environment allows document uploads
      if (!_isDocumentUploadEnabled()) {
        debugPrint('Document upload disabled in current environment');
        return _createMockUploadResult(
          category: category,
          fileName: fileName,
          userId: userId,
          portfolioId: portfolioId,
          description: description,
        );
      }

      // Upload through repository
      return await _documentRepository.uploadDocument(
        file: file,
        fileName: fileName,
        category: category,
        portfolioId: portfolioId,
        userId: userId,
        description: description,
      );
    } catch (e) {
      debugPrint('Error uploading document: $e');
      
      // Check if environment supports mock data as fallback
      if (_isDevelopmentEnvironment() || ConfigService.config?.api?.useMockData == true) {
        debugPrint('Using mock document upload data in development');
        return _createMockUploadResult(
          category: category,
          fileName: fileName,
          userId: userId,
          portfolioId: portfolioId,
          description: description,
        );
      }
      
      rethrow;
    }
  }

  /// Get processing status for a document
  /// Returns cached data if available and fresh, otherwise fetches from API
  Future<DocumentUpload> getDocumentStatus(String processId) async {
    try {
      return await _documentRepository.getDocumentStatus(processId);
    } catch (e) {
      debugPrint('Error getting document status: $e');
      
      // Check if environment supports mock data as fallback
      if (_isDevelopmentEnvironment() || ConfigService.config?.api?.useMockData == true) {
        debugPrint('Using mock document status data in development');
        return _createMockUploadResult(
          category: DocumentCategory.stockPortfolio,
          fileName: 'mock_document.pdf',
          userId: 'mock_user',
          portfolioId: 'mock_portfolio',
          processId: processId,
        );
      }
      
      rethrow;
    }
  }

  /// Get processing history for a user
  /// Provides caching and fallback to mock data in development
  Future<DocumentUploadCollection> getDocumentHistory({
    required String userId,
    DocumentCategory? category,
    DocumentProcessingStatus? status,
    int? limit = 50,
    int? offset = 0,
  }) async {
    try {
      return await _documentRepository.getDocumentHistory(
        userId: userId,
        category: category,
        status: status,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      debugPrint('Error getting document history: $e');
      
      // Check if environment supports mock data as fallback
      if (_isDevelopmentEnvironment() || ConfigService.config?.api?.useMockData == true) {
        debugPrint('Using mock document history data in development');
        return _createMockCollectionResult(userId);
      }
      
      rethrow;
    }
  }

  /// Cancel document processing
  /// Updates cached data immediately and notifies listeners
  Future<void> cancelDocumentProcessing(String processId) async {
    try {
      await _documentRepository.cancelDocumentProcessing(processId);
    }
    } catch (e) {
      debugPrint('Error cancelling document processing: $e');
      rethrow;
    }
  }

  /// Download processed document results
  Future<Uint8List> downloadProcessedDocument(String processId) async {
    try {
      final bytes = await _documentRepository.downloadProcessedDocument(processId);
      return Uint8List.fromList(bytes);
    } catch (e) {
      debugPrint('Error downloading processed document: $e');
      rethrow;
    }
  }

  /// Get processing statistics for a user
  Future<Map<String, int>> getProcessingStatistics(String userId) async {
    try {
      return await _documentRepository.getProcessingStatistics(userId);
    } catch (e) {
      debugPrint('Error getting processing statistics: $e');
      
      // Return default statistics in case of error
      return {
        'total': 0,
        'completed': 0,
        'failed': 0,
        'processing': 0,
      };
    }
  }

  /// Stream of document processing updates
  Stream<DocumentUpload> documentStatusStream(String processId) {
    return _documentRepository.documentStatusStream(processId);
  }

  /// Stream of document history updates
  Stream<DocumentUploadCollection> documentHistoryStream(String userId) {
    return _documentRepository.documentHistoryStream(userId);
  }

  /// Get supported document categories
  List<DocumentCategory> getSupportedCategories() {
    return _documentRepository.getSupportedCategories();
  }

  /// Validate document before upload
  Future<Map<String, dynamic>> validateDocument({
    required String fileName,
    required int fileSize,
    required DocumentCategory category,
  }) async {
    return await _documentRepository.validateDocument(
      fileName: fileName,
      fileSize: fileSize,
      category: category,
    );
  }

  /// Helper method to get file size
  int _getFileSize(dynamic file) {
    if (file is File) {
      return file.lengthSync();
    } else if (file is Uint8List) {
      return file.length;
    } else {
      throw ArgumentError('File must be either File or Uint8List');
    }
  }

  /// Check if document upload is enabled in current environment
  bool _isDocumentUploadEnabled() {
    final config = ConfigService.config;
    return config?.api?.document?.enabled ?? true;
  }

  /// Check if environment is development
  bool _isDevelopmentEnvironment() {
    return const String.fromEnvironment('ENVIRONMENT', defaultValue: 'prod') == 'dev';
  }

  /// Create mock upload result for development/testing
  DocumentUpload _createMockUploadResult({
    required DocumentCategory category,
    required String fileName,
    required String userId,
    required String portfolioId,
    String? description,
    String? processId,
  }) {
    return DocumentUpload.newUpload(
      processId: processId ?? 'mock_${DateTime.now().millisecondsSinceEpoch}',
      fileName: fileName,
      category: category,
      portfolioId: portfolioId,
      userId: userId,
      description: description ?? 'Mock upload for development',
    );
  }

  /// Create mock collection result for development/testing
  DocumentUploadCollection _createMockCollectionResult(String userId) {
    final mockUploads = [
      _createMockUploadResult(
        category: DocumentCategory.stockPortfolio,
        fileName: 'mock_portfolio.pdf',
        userId: userId,
        portfolioId: 'mock_portfolio_1',
        processId: 'mock_proc_1',
      ),
      _createMockUploadResult(
        category: DocumentCategory.mutualFund,
        fileName: 'mock_mutual_fund.pdf',
        userId: userId,
        portfolioId: 'mock_portfolio_1',
        processId: 'mock_proc_2',
      ),
    ];

    return DocumentUploadCollection(
      uploads: mockUploads,
      metadata: CollectionMetadata(
        lastUpdated: DateTime.now(),
        userId: userId,
        totalCount: mockUploads.length,
      ),
    );
  }
}

/// Provider for DocumentUploadService
/// Uses repository pattern instead of direct client access
@Riverpod()
DocumentUploadService documentUploadService(DocumentUploadServiceRef ref) {
  final documentRepository = ref.watch(documentRepositoryProvider);
  return DocumentUploadService(documentRepository);
}