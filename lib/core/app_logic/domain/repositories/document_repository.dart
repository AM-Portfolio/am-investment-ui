import '../entities/document/document_upload.dart';

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
}