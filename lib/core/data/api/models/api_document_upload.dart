import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_document_upload.freezed.dart';
part 'api_document_upload.g.dart';

/// Document types supported by the upload API
enum DocumentType {
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
  tradeEq,
}

/// Document processing status
enum DocumentStatus {
  @JsonValue('QUEUED')
  queued,
  @JsonValue('PROCESSING')
  processing,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('FAILED')
  failed,
}

/// Request model for document upload
@freezed
class DocumentUploadRequest with _$DocumentUploadRequest {
  const factory DocumentUploadRequest({
    required DocumentType documentType,
    required String portfolioId,
    required String userId,
    String? description,
    Map<String, String>? metadata,
  }) = _DocumentUploadRequest;

  factory DocumentUploadRequest.fromJson(Map<String, dynamic> json) =>
      _$DocumentUploadRequestFromJson(json);
}

/// Response model for document upload
@freezed
class DocumentUploadResponse with _$DocumentUploadResponse {
  const factory DocumentUploadResponse({
    required String processId,
    required DocumentType documentType,
    required String fileName,
    required DocumentStatus status,
    String? message,
    String? errorCode,
    Map<String, dynamic>? metadata,
  }) = _DocumentUploadResponse;

  factory DocumentUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$DocumentUploadResponseFromJson(json);
}

/// Document processing status response
@freezed
class DocumentProcessStatus with _$DocumentProcessStatus {
  const factory DocumentProcessStatus({
    required String processId,
    required DocumentStatus status,
    required String fileName,
    required DocumentType documentType,
    String? message,
    String? errorCode,
    DateTime? createdAt,
    DateTime? completedAt,
    Map<String, dynamic>? result,
  }) = _DocumentProcessStatus;

  factory DocumentProcessStatus.fromJson(Map<String, dynamic> json) =>
      _$DocumentProcessStatusFromJson(json);
}