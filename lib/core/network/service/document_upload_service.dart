import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/document/document_upload.dart';
import '../../domain/repositories/document_repository.dart';
import '../../../config/config_service.dart';
import '../../../di/app_providers.dart';

part '../../services/document_upload_service.g.dart';

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
      _validateFile(fileName, fileSize);

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

  /// Get file size from different file types
  int _getFileSize(dynamic file) {
    if (file is File) {
      return file.lengthSync();
    } else if (file is Uint8List) {
      return file.length;
    } else {
      throw ArgumentError('Unsupported file type: ${file.runtimeType}');
    }
  }

  /// Basic file validation
  void _validateFile(String fileName, int fileSize) {
    // File size validation (50MB limit)
    const maxFileSize = 50 * 1024 * 1024; // 50MB
    if (fileSize > maxFileSize) {
      throw ArgumentError('File size exceeds 50MB limit');
    }

    // File extension validation
    final allowedExtensions = ['.pdf', '.jpg', '.jpeg', '.png', '.tiff','.xls', '.xlsx', '.csv'];
    final extension = fileName.toLowerCase().substring(fileName.lastIndexOf('.'));
    if (!allowedExtensions.contains(extension)) {
      throw ArgumentError('File type not supported. Allowed: ${allowedExtensions.join(', ')}');
    }
  }

  /// Check if document upload is enabled in current environment
  bool _isDocumentUploadEnabled() {
    return ConfigService.config?.api?.document?.enabled ?? true;
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
  }) {
    final mockProcessId = 'mock_${DateTime.now().millisecondsSinceEpoch}';
    
    return DocumentUpload.newUpload(
      processId: mockProcessId,
      fileName: fileName,
      category: category,
      portfolioId: portfolioId,
      userId: userId,
      description: description,
    );
  }


}

/// Provider for DocumentUploadService
/// Provides configured service instance with repository dependency
@Riverpod()
DocumentUploadService documentUploadService(DocumentUploadServiceRef ref) {
  final repository = ref.watch(documentRepositoryProvider);
  return DocumentUploadService(repository);
}