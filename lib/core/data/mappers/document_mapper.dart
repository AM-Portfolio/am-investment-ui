import '../../network/dtos/document/document_dtos.dart';
import '../../domain/entities/document/document_upload.dart';

/// Mapper to convert between API models and domain entities for documents
/// This provides isolation between external API structure and internal business logic
class DocumentMapper {
  /// Convert API DocumentUploadResponse to domain DocumentUpload entity
  static DocumentUpload fromApiUploadResponse(DocumentUploadResponse apiResponse) {
    return DocumentUpload(
      identity: DocumentIdentity(
        processId: apiResponse.processId,
        fileName: apiResponse.fileName,
        category: _mapApiDocumentTypeToCategory(apiResponse.documentType),
      ),
      metadata: DocumentMetadata(
        portfolioId: '', // This might need to come from the request context
        userId: '', // This might need to come from the request context
        uploadedAt: DateTime.now(),
        description: apiResponse.message,
        customMetadata: apiResponse.metadata?.cast<String, String>(),
      ),
      status: ProcessingStatus(
        current: _mapApiStatusToDomainStatus(apiResponse.status),
        createdAt: DateTime.now(),
        message: apiResponse.message,
        errorCode: apiResponse.errorCode,
      ),
    );
  }

  /// Convert API DocumentUploadResponse to domain DocumentUpload entity with context
  static DocumentUpload fromApiUploadResponseWithContext(
    DocumentUploadResponse apiResponse, {
    required String portfolioId,
    required String userId,
    String? description,
  }) {
    return DocumentUpload(
      identity: DocumentIdentity(
        processId: apiResponse.processId,
        fileName: apiResponse.fileName,
        category: _mapApiDocumentTypeToCategory(apiResponse.documentType),
      ),
      metadata: DocumentMetadata(
        portfolioId: portfolioId,
        userId: userId,
        uploadedAt: DateTime.now(),
        description: description ?? apiResponse.message,
        customMetadata: apiResponse.metadata?.cast<String, String>(),
      ),
      status: ProcessingStatus(
        current: _mapApiStatusToDomainStatus(apiResponse.status),
        createdAt: DateTime.now(),
        message: apiResponse.message,
        errorCode: apiResponse.errorCode,
      ),
    );
  }



  /// Convert list of API DocumentUploadResponse to domain DocumentUploadCollection
  static DocumentUploadCollection fromApiUploadResponseList(
    List<DocumentUploadResponse> apiResponseList, {
    required String userId,
  }) {
    final uploads = apiResponseList
        .map((apiResponse) => fromApiUploadResponse(apiResponse))
        .toList();

    return DocumentUploadCollection(
      uploads: uploads,
      metadata: CollectionMetadata(
        lastUpdated: DateTime.now(),
        userId: userId,
        totalCount: uploads.length,
      ),
    );
  }

  /// Convert domain DocumentUpload to API DocumentUploadRequest
  static DocumentUploadRequest toApiUploadRequest({
    required DocumentCategory category,
    required String portfolioId,
    required String userId,
    String? description,
    Map<String, String>? metadata,
  }) {
    return DocumentUploadRequest(
      documentType: _mapCategoryToApiDocumentType(category),
      portfolioId: portfolioId,
      userId: userId,
      description: description,
      metadata: metadata,
    );
  }

  /// Map API DocumentType to domain DocumentCategory
  static DocumentCategory _mapApiDocumentTypeToCategory(DocumentType apiType) {
    switch (apiType) {
      case DocumentType.brokerPortfolio:
        return DocumentCategory.brokerPortfolio;
      case DocumentType.mutualFund:
        return DocumentCategory.mutualFund;
      case DocumentType.npsStatement:
        return DocumentCategory.npsStatement;
      case DocumentType.companyFinancialReport:
        return DocumentCategory.companyFinancialReport;
      case DocumentType.stockPortfolio:
        return DocumentCategory.stockPortfolio;
      case DocumentType.nseIndices:
        return DocumentCategory.nseIndices;
      case DocumentType.tradeFno:
        return DocumentCategory.tradeFno;
      case DocumentType.tradeEq:
        return DocumentCategory.tradeEq;
    }
  }

  /// Map domain DocumentCategory to API DocumentType
  static DocumentType _mapCategoryToApiDocumentType(DocumentCategory category) {
    switch (category) {
      case DocumentCategory.brokerPortfolio:
        return DocumentType.brokerPortfolio;
      case DocumentCategory.mutualFund:
        return DocumentType.mutualFund;
      case DocumentCategory.npsStatement:
        return DocumentType.npsStatement;
      case DocumentCategory.companyFinancialReport:
        return DocumentType.companyFinancialReport;
      case DocumentCategory.stockPortfolio:
        return DocumentType.stockPortfolio;
      case DocumentCategory.nseIndices:
        return DocumentType.nseIndices;
      case DocumentCategory.tradeFno:
        return DocumentType.tradeFno;
      case DocumentCategory.tradeEq:
        return DocumentType.tradeEq;
    }
  }

  /// Map API DocumentStatus to domain DocumentProcessingStatus
  static DocumentProcessingStatus _mapApiStatusToDomainStatus(DocumentStatus apiStatus) {
    switch (apiStatus) {
      case DocumentStatus.queued:
        return DocumentProcessingStatus.queued;
      case DocumentStatus.processing:
        return DocumentProcessingStatus.processing;
      case DocumentStatus.completed:
        return DocumentProcessingStatus.completed;
      case DocumentStatus.failed:
        return DocumentProcessingStatus.failed;
    }
  }

  /// Map API result to domain DocumentResult
  static DocumentResult _mapApiResultToDomainResult(Map<String, dynamic> apiResult) {
    return DocumentResult(
      extractedData: apiResult,
      warnings: apiResult['warnings']?.cast<String>(),
      metrics: _extractProcessingMetrics(apiResult),
    );
  }

  /// Extract processing metrics from API result
  static ProcessingMetrics? _extractProcessingMetrics(Map<String, dynamic> apiResult) {
    final metricsData = apiResult['metrics'] as Map<String, dynamic>?;
    if (metricsData == null) return null;

    return ProcessingMetrics(
      pagesProcessed: metricsData['pagesProcessed'] as int? ?? 0,
      fieldsExtracted: metricsData['fieldsExtracted'] as int? ?? 0,
      confidenceScore: (metricsData['confidenceScore'] as num?)?.toDouble() ?? 0.0,
      processingTime: metricsData['processingTimeMs'] != null 
          ? Duration(milliseconds: metricsData['processingTimeMs'] as int)
          : null,
    );
  }

  /// Create mock DocumentUpload for development/testing
  static DocumentUpload createMockDocument({
    required String processId,
    required DocumentCategory category,
    required String fileName,
    required String userId,
    required String portfolioId,
    DocumentProcessingStatus status = DocumentProcessingStatus.completed,
  }) {
    final now = DateTime.now();
    
    return DocumentUpload(
      identity: DocumentIdentity(
        processId: processId,
        fileName: fileName,
        category: category,
      ),
      metadata: DocumentMetadata(
        portfolioId: portfolioId,
        userId: userId,
        uploadedAt: now.subtract(const Duration(minutes: 5)),
        description: 'Mock document for testing',
      ),
      status: ProcessingStatus(
        current: status,
        createdAt: now.subtract(const Duration(minutes: 5)),
        completedAt: status == DocumentProcessingStatus.completed 
            ? now.subtract(const Duration(minutes: 1))
            : null,
        message: status == DocumentProcessingStatus.completed 
            ? 'Document processed successfully'
            : 'Processing in progress',
      ),
      result: status == DocumentProcessingStatus.completed
          ? DocumentResult(
              extractedData: {
                'totalValue': 150000.0,
                'holdings': 15,
                'extractedFields': 25,
              },
              metrics: ProcessingMetrics(
                pagesProcessed: 3,
                fieldsExtracted: 25,
                confidenceScore: 0.95,
                processingTime: const Duration(seconds: 30),
              ),
            )
          : null,
    );
  }

  /// Create mock DocumentUploadCollection
  static DocumentUploadCollection createMockCollection(String userId) {
    final mockUploads = [
      createMockDocument(
        processId: 'proc_001',
        category: DocumentCategory.stockPortfolio,
        fileName: 'portfolio_statement.pdf',
        userId: userId,
        portfolioId: 'port_001',
        status: DocumentProcessingStatus.completed,
      ),
      createMockDocument(
        processId: 'proc_002',
        category: DocumentCategory.mutualFund,
        fileName: 'mutual_fund_statement.pdf',
        userId: userId,
        portfolioId: 'port_001',
        status: DocumentProcessingStatus.processing,
      ),
      createMockDocument(
        processId: 'proc_003',
        category: DocumentCategory.brokerPortfolio,
        fileName: 'broker_holdings.pdf',
        userId: userId,
        portfolioId: 'port_001',
        status: DocumentProcessingStatus.failed,
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