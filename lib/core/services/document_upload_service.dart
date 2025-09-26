import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../api/document_client.dart';
import '../../data/api/models/api_document_upload.dart';

part 'document_upload_service.g.dart';

/// Service for handling document upload operations
class DocumentUploadService {
  final DocumentClient _documentClient;

  DocumentUploadService(this._documentClient);

  /// Upload a file for document processing
  /// Supports both File (mobile/desktop) and Uint8List (web) inputs
  Future<DocumentUploadResponse> uploadDocument({
    required dynamic file, // File or Uint8List
    required String fileName,
    required DocumentType documentType,
    required String portfolioId,
    required String userId,
    String? description,
  }) async {
    try {
      MultipartFile multipartFile;

      if (kIsWeb) {
        // Web platform - handle Uint8List
        if (file is Uint8List) {
          final mimeType = _getMimeType(fileName);
          multipartFile = MultipartFile.fromBytes(
            file,
            filename: fileName,
            contentType: DioMediaType.parse(mimeType),
          );
        } else {
          throw ArgumentError('On web platform, file must be Uint8List');
        }
      } else {
        // Mobile/Desktop platform - handle File
        if (file is File) {
          final mimeType = _getMimeType(fileName);
          multipartFile = await MultipartFile.fromFile(
            file.path,
            filename: fileName,
            contentType: DioMediaType.parse(mimeType),
          );
        } else if (file is Uint8List) {
          // Also support Uint8List on mobile/desktop
          final mimeType = _getMimeType(fileName);
          multipartFile = MultipartFile.fromBytes(
            file,
            filename: fileName,
            contentType: DioMediaType.parse(mimeType),
          );
        } else {
          throw ArgumentError('File must be either File or Uint8List');
        }
      }

      // Upload using the multipart method
      return await _documentClient.uploadDocumentMultipart(
        multipartFile,
        _documentTypeToString(documentType),
        portfolioId,
        userId,
        description: description,
      );
    } catch (e) {
      throw DocumentUploadException('Failed to upload document: $e');
    }
  }

  /// Upload a file directly using File object (mobile/desktop only)
  Future<DocumentUploadResponse> uploadFileDirectly({
    required File file,
    required DocumentType documentType,
    required String portfolioId,
    required String userId,
    String? description,
  }) async {
    if (kIsWeb) {
      throw UnsupportedError('File upload not supported on web. Use uploadDocument with Uint8List instead.');
    }

    try {
      return await _documentClient.uploadDocument(
        file,
        _documentTypeToString(documentType),
        portfolioId,
        userId,
        description: description,
      );
    } catch (e) {
      throw DocumentUploadException('Failed to upload file: $e');
    }
  }

  /// Get processing status for a document
  Future<DocumentProcessStatus> getProcessingStatus(String processId) async {
    try {
      return await _documentClient.getProcessingStatus(processId);
    } catch (e) {
      throw DocumentUploadException('Failed to get processing status: $e');
    }
  }

  /// Get processing history for a user
  Future<List<DocumentProcessStatus>> getProcessingHistory({
    required String userId,
    DocumentType? documentType,
    DocumentStatus? status,
    int? limit = 50,
    int? offset = 0,
  }) async {
    try {
      return await _documentClient.getProcessingHistory(
        userId,
        documentType: documentType != null ? _documentTypeToString(documentType) : null,
        status: status != null ? _documentStatusToString(status) : null,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      throw DocumentUploadException('Failed to get processing history: $e');
    }
  }

  /// Cancel document processing
  Future<void> cancelProcessing(String processId) async {
    try {
      await _documentClient.cancelProcessing(processId);
    } catch (e) {
      throw DocumentUploadException('Failed to cancel processing: $e');
    }
  }

  /// Download processed document results
  Future<Uint8List> downloadProcessedDocument(String processId) async {
    try {
      final responseBody = await _documentClient.downloadProcessedDocument(processId);
      return Uint8List.fromList(await responseBody.stream.toBytes());
    } catch (e) {
      throw DocumentUploadException('Failed to download processed document: $e');
    }
  }

  /// Helper method to determine MIME type from file extension
  String _getMimeType(String fileName) {
    final mimeType = lookupMimeType(fileName);
    return mimeType ?? 'application/octet-stream';
  }

  /// Convert DocumentType enum to string
  String _documentTypeToString(DocumentType type) {
    switch (type) {
      case DocumentType.brokerPortfolio:
        return 'BROKER_PORTFOLIO';
      case DocumentType.mutualFund:
        return 'MUTUAL_FUND';
      case DocumentType.npsStatement:
        return 'NPS_STATEMENT';
      case DocumentType.companyFinancialReport:
        return 'COMPANY_FINANCIAL_REPORT';
      case DocumentType.stockPortfolio:
        return 'STOCK_PORTFOLIO';
      case DocumentType.nseIndices:
        return 'NSE_INDICES';
      case DocumentType.tradeFno:
        return 'TRADE_FNO';
      case DocumentType.tradeEq:
        return 'TRADE_EQ';
    }
  }

  /// Convert DocumentStatus enum to string
  String _documentStatusToString(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.queued:
        return 'QUEUED';
      case DocumentStatus.processing:
        return 'PROCESSING';
      case DocumentStatus.completed:
        return 'COMPLETED';
      case DocumentStatus.failed:
        return 'FAILED';
    }
  }
}

/// Custom exception for document upload operations
class DocumentUploadException implements Exception {
  final String message;
  DocumentUploadException(this.message);

  @override
  String toString() => 'DocumentUploadException: $message';
}

/// Provider for DocumentUploadService
@Riverpod()
DocumentUploadService documentUploadService(DocumentUploadServiceRef ref) {
  final documentClient = ref.watch(documentClientProvider);
  return DocumentUploadService(documentClient);
}