import 'package:freezed_annotation/freezed_annotation.dart';

part 'document_upload.freezed.dart';
part 'document_upload.g.dart';

/// Document processing states
enum DocumentProcessingStatus {
  @JsonValue('QUEUED')
  queued,
  @JsonValue('PROCESSING')
  processing,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('FAILED')
  failed,
  @JsonValue('CANCELLED')
  cancelled;

  /// Get the JSON value for this enum
  String get value {
    switch (this) {
      case DocumentProcessingStatus.queued:
        return 'QUEUED';
      case DocumentProcessingStatus.processing:
        return 'PROCESSING';
      case DocumentProcessingStatus.completed:
        return 'COMPLETED';
      case DocumentProcessingStatus.failed:
        return 'FAILED';
      case DocumentProcessingStatus.cancelled:
        return 'CANCELLED';
    }
  }
}

/// Supported document categories
enum DocumentCategory {
  @JsonValue('BROKER_PORTFOLIO')
  brokerPortfolio,
  @JsonValue('MUTUAL_FUND')
  mutualFund,
  @JsonValue('NPS_STATEMENT')
  npsStatement,
  @JsonValue('COMPANY_FINANCIAL_REPORT')
  companyFinancialReport,
  @JsonValue('STOCK_PORTFOLIO')
  stockPortfolio,
  @JsonValue('NSE_INDICES')
  nseIndices,
  @JsonValue('TRADE_FNO')
  tradeFno,
  @JsonValue('TRADE_EQ')
  tradeEq;

  /// Get the JSON value for this enum
  String get value {
    switch (this) {
      case DocumentCategory.brokerPortfolio:
        return 'BROKER_PORTFOLIO';
      case DocumentCategory.mutualFund:
        return 'MUTUAL_FUND';
      case DocumentCategory.npsStatement:
        return 'NPS_STATEMENT';
      case DocumentCategory.companyFinancialReport:
        return 'COMPANY_FINANCIAL_REPORT';
      case DocumentCategory.stockPortfolio:
        return 'STOCK_PORTFOLIO';
      case DocumentCategory.nseIndices:
        return 'NSE_INDICES';
      case DocumentCategory.tradeFno:
        return 'TRADE_FNO';
      case DocumentCategory.tradeEq:
        return 'TRADE_EQ';
    }
  }
}

/// Main document upload entity
@freezed
class DocumentUpload with _$DocumentUpload {
  const DocumentUpload._();
  
  const factory DocumentUpload({
    required DocumentIdentity identity,
    required DocumentMetadata metadata,
    required ProcessingStatus status,
    DocumentResult? result,
  }) = _DocumentUpload;

  factory DocumentUpload.fromJson(Map<String, dynamic> json) =>
      _$DocumentUploadFromJson(json);

  /// Factory for creating a new upload
  factory DocumentUpload.newUpload({
    required String processId,
    required String fileName,
    required DocumentCategory category,
    required String portfolioId,
    required String userId,
    String? description,
  }) {
    return DocumentUpload(
      identity: DocumentIdentity(
        processId: processId,
        fileName: fileName,
        category: category,
      ),
      metadata: DocumentMetadata(
        portfolioId: portfolioId,
        userId: userId,
        description: description,
        uploadedAt: DateTime.now(),
      ),
      status: ProcessingStatus(
        current: DocumentProcessingStatus.queued,
        createdAt: DateTime.now(),
      ),
    );
  }

  /// Check if document processing is complete
  bool get isCompleted => status.current == DocumentProcessingStatus.completed;
  
  /// Check if document processing has failed
  bool get hasFailed => status.current == DocumentProcessingStatus.failed;
  
  /// Check if document is currently being processed
  bool get isProcessing => status.current == DocumentProcessingStatus.processing;
  
  /// Check if document can be cancelled
  bool get canBeCancelled => 
      status.current == DocumentProcessingStatus.queued || 
      status.current == DocumentProcessingStatus.processing;

  /// Get processing duration
  Duration? get processingDuration {
    if (status.completedAt == null) return null;
    return status.completedAt!.difference(status.createdAt);
  }
}

/// Document identity value object
@freezed
class DocumentIdentity with _$DocumentIdentity {
  const factory DocumentIdentity({
    required String processId,
    required String fileName,
    required DocumentCategory category,
  }) = _DocumentIdentity;

  factory DocumentIdentity.fromJson(Map<String, dynamic> json) =>
      _$DocumentIdentityFromJson(json);
}

/// Document metadata value object
@freezed
class DocumentMetadata with _$DocumentMetadata {
  const factory DocumentMetadata({
    required String portfolioId,
    required String userId,
    required DateTime uploadedAt,
    String? description,
    Map<String, String>? customMetadata,
  }) = _DocumentMetadata;

  factory DocumentMetadata.fromJson(Map<String, dynamic> json) =>
      _$DocumentMetadataFromJson(json);
}

/// Processing status value object
@freezed
class ProcessingStatus with _$ProcessingStatus {
  const factory ProcessingStatus({
    required DocumentProcessingStatus current,
    required DateTime createdAt,
    DateTime? completedAt,
    String? message,
    String? errorCode,
  }) = _ProcessingStatus;

  factory ProcessingStatus.fromJson(Map<String, dynamic> json) =>
      _$ProcessingStatusFromJson(json);
}

/// Document processing result value object
@freezed
class DocumentResult with _$DocumentResult {
  const factory DocumentResult({
    required Map<String, dynamic> extractedData,
    List<String>? warnings,
    ProcessingMetrics? metrics,
  }) = _DocumentResult;

  factory DocumentResult.fromJson(Map<String, dynamic> json) =>
      _$DocumentResultFromJson(json);
}

/// Processing metrics value object
@freezed
class ProcessingMetrics with _$ProcessingMetrics {
  const factory ProcessingMetrics({
    required int pagesProcessed,
    required int fieldsExtracted,
    required double confidenceScore,
    Duration? processingTime,
  }) = _ProcessingMetrics;

  factory ProcessingMetrics.fromJson(Map<String, dynamic> json) =>
      _$ProcessingMetricsFromJson(json);
}

/// Document upload collection entity
@freezed
class DocumentUploadCollection with _$DocumentUploadCollection {
  const DocumentUploadCollection._();
  
  const factory DocumentUploadCollection({
    required List<DocumentUpload> uploads,
    required CollectionMetadata metadata,
  }) = _DocumentUploadCollection;

  factory DocumentUploadCollection.fromJson(Map<String, dynamic> json) =>
      _$DocumentUploadCollectionFromJson(json);

  /// Create empty collection
  factory DocumentUploadCollection.empty() {
    return DocumentUploadCollection(
      uploads: const [],
      metadata: CollectionMetadata.empty(),
    );
  }

  /// Collection statistics
  bool get isEmpty => uploads.isEmpty;
  int get totalUploads => uploads.length;
  
  int get completedUploads => uploads
      .where((upload) => upload.isCompleted)
      .length;
      
  int get failedUploads => uploads
      .where((upload) => upload.hasFailed)
      .length;
      
  int get processingUploads => uploads
      .where((upload) => upload.isProcessing)
      .length;

  /// Get uploads by status
  List<DocumentUpload> getUploadsByStatus(DocumentProcessingStatus status) {
    return uploads.where((upload) => upload.status.current == status).toList();
  }

  /// Get uploads by category
  List<DocumentUpload> getUploadsByCategory(DocumentCategory category) {
    return uploads.where((upload) => upload.identity.category == category).toList();
  }

  /// Get recent uploads
  List<DocumentUpload> getRecentUploads(int count) {
    final sorted = List<DocumentUpload>.from(uploads);
    sorted.sort((a, b) => b.metadata.uploadedAt.compareTo(a.metadata.uploadedAt));
    return sorted.take(count).toList();
  }
}

/// Collection metadata value object
@freezed
class CollectionMetadata with _$CollectionMetadata {
  const factory CollectionMetadata({
    required DateTime lastUpdated,
    required String userId,
    int? totalCount,
  }) = _CollectionMetadata;

  factory CollectionMetadata.fromJson(Map<String, dynamic> json) =>
      _$CollectionMetadataFromJson(json);

  factory CollectionMetadata.empty() {
    return CollectionMetadata(
      lastUpdated: DateTime.now(),
      userId: '',
      totalCount: 0,
    );
  }
}