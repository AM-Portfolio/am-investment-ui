import '../../domain/entities/document/document_upload.dart';

/// Repository interface for document upload operations
/// Defines the contract for document data access and processing
abstract class DocumentRepository {
  /// Upload a document for processing
  Future<DocumentUpload> uploadDocument({
    required dynamic file, // File or Uint8List
    required String fileName,
    required DocumentCategory category,
    required String portfolioId,
    required String userId,
    String? description,
    Map<String, String>? metadata,
  });

  /// Get document processing status by process ID
  Future<DocumentUpload> getDocumentStatus(String processId);

  /// Get document upload history for a user
  Future<DocumentUploadCollection> getDocumentHistory({
    required String userId,
    DocumentCategory? category,
    DocumentProcessingStatus? status,
    int? limit,
    int? offset,
  });

  /// Cancel document processing
  Future<void> cancelDocumentProcessing(String processId);

  /// Download processed document results
  Future<List<int>> downloadProcessedDocument(String processId);

  /// Get uploads by portfolio ID
  Future<DocumentUploadCollection> getPortfolioDocuments({
    required String portfolioId,
    DocumentCategory? category,
    int? limit,
  });

  /// Stream of document processing updates (for real-time status)
  Stream<DocumentUpload> documentStatusStream(String processId);

  /// Stream of document history updates
  Stream<DocumentUploadCollection> documentHistoryStream(String userId);

  /// Check if document data is cached and fresh
  bool isDocumentCachedDataFresh(String processId);

  /// Check if history data is cached and fresh
  bool isHistoryCachedDataFresh(String userId);

  /// Clear cached document data
  Future<void> clearDocumentCache(String processId);

  /// Clear cached history data
  Future<void> clearHistoryCache(String userId);

  /// Clear all cached data for user
  Future<void> clearAllCache(String userId);

  /// Refresh document status from API
  Future<DocumentUpload> refreshDocumentStatus(String processId);

  /// Refresh document history from API
  Future<DocumentUploadCollection> refreshDocumentHistory(String userId);

  /// Get processing statistics for user
  Future<Map<String, int>> getProcessingStatistics(String userId);

  /// Retry failed document processing
  Future<DocumentUpload> retryDocumentProcessing(String processId);

  /// Bulk upload multiple documents
  Future<List<DocumentUpload>> bulkUploadDocuments({
    required List<Map<String, dynamic>> uploadRequests,
    required String userId,
  });

  /// Get supported document categories
  List<DocumentCategory> getSupportedCategories();

  /// Validate document before upload
  Future<Map<String, dynamic>> validateDocument({
    required String fileName,
    required int fileSize,
    required DocumentCategory category,
  });
}