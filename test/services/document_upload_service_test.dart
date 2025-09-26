import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../../lib/core/services/document_upload_service.dart';
import '../../lib/core/domain/entities/document/document_upload.dart';
import '../../lib/core/domain/repositories/document_repository.dart';
import '../../lib/core/clients/document_client.dart';

// Generate mocks for external dependencies only
@GenerateMocks([DocumentClient])
void main() {
  group('DocumentUploadService', () {
    late DocumentUploadService service;
    late MockDocumentClient mockClient;
    late DocumentRepository repository;

    setUp(() {
      mockClient = MockDocumentClient();
      // Use real repository and mapper - don't mock internal logic
      repository = DocumentRepositoryImpl(mockClient);
      service = DocumentUploadService(repository);
    });

    group('uploadDocument', () {
      test('should successfully upload document with File input', () async {
        // Arrange
        final testFile = File('test/assets/test_document.pdf');
        const fileName = 'test_document.pdf';
        const category = DocumentCategory.stockPortfolio;
        const portfolioId = 'portfolio_123';
        const userId = 'user_456';
        const description = 'Test document upload';

        // Mock successful validation response
        final validationResponse = {
          'isValid': true,
          'errors': <String>[],
          'warnings': <String>['File size is large'],
        };

        // Mock successful API response
        final mockApiResponse = ApiDocumentUploadResponse(
          processId: 'process_789',
          status: 'uploaded',
          message: 'Document uploaded successfully',
          uploadedAt: DateTime.now().toIso8601String(),
        );

        when(mockClient.validateDocument(
          fileName: fileName,
          fileSize: anyNamed('fileSize'),
          category: category.toString().split('.').last,
        )).thenAnswer((_) async => validationResponse);

        when(mockClient.uploadDocument(
          userId: userId,
          file: any,
          metadata: anyNamed('metadata'),
        )).thenAnswer((_) async => mockApiResponse);

        // Act
        final result = await service.uploadDocument(
          file: testFile,
          fileName: fileName,
          category: category,
          portfolioId: portfolioId,
          userId: userId,
          description: description,
        );

        // Assert - Validate complete flow including mapping
        expect(result.processId, 'process_789');
        expect(result.fileName, fileName);
        expect(result.category, category);
        expect(result.portfolioId, portfolioId);
        expect(result.userId, userId);
        expect(result.description, description);
        expect(result.status, DocumentProcessingStatus.uploaded);

        // Verify API calls
        verify(mockClient.validateDocument(
          fileName: fileName,
          fileSize: any,
          category: category.toString().split('.').last,
        )).called(1);

        verify(mockClient.uploadDocument(
          userId: userId,
          file: any,
          metadata: any,
        )).called(1);
      });

      test('should successfully upload document with Uint8List input', () async {
        // Arrange
        final testData = Uint8List.fromList([1, 2, 3, 4, 5]);
        const fileName = 'web_document.pdf';
        const category = DocumentCategory.mutualFund;
        const portfolioId = 'portfolio_web';
        const userId = 'user_web';

        // Mock successful validation
        final validationResponse = {
          'isValid': true,
          'errors': <String>[],
          'warnings': <String>[],
        };

        // Mock successful API response
        final mockApiResponse = ApiDocumentUploadResponse(
          processId: 'web_process_123',
          status: 'uploaded',
          message: 'Document uploaded successfully',
          uploadedAt: DateTime.now().toIso8601String(),
        );

        when(mockClient.validateDocument(
          fileName: fileName,
          fileSize: testData.length,
          category: category.toString().split('.').last,
        )).thenAnswer((_) async => validationResponse);

        when(mockClient.uploadDocument(
          userId: userId,
          file: any,
          metadata: any,
        )).thenAnswer((_) async => mockApiResponse);

        // Act
        final result = await service.uploadDocument(
          file: testData,
          fileName: fileName,
          category: category,
          portfolioId: portfolioId,
          userId: userId,
        );

        // Assert
        expect(result.processId, 'web_process_123');
        expect(result.fileName, fileName);
        expect(result.category, category);
        expect(result.status, DocumentProcessingStatus.uploaded);

        // Verify correct file size was passed
        verify(mockClient.validateDocument(
          fileName: fileName,
          fileSize: testData.length,
          category: category.toString().split('.').last,
        )).called(1);
      });

      test('should throw ArgumentError when file validation fails', () async {
        // Arrange
        final testFile = File('test/assets/invalid_file.txt');
        const fileName = 'invalid_file.txt';
        const category = DocumentCategory.stockPortfolio;

        // Mock validation failure
        final validationResponse = {
          'isValid': false,
          'errors': ['File type not supported', 'File size too large'],
          'warnings': <String>[],
        };

        when(mockClient.validateDocument(
          fileName: fileName,
          fileSize: any,
          category: category.toString().split('.').last,
        )).thenAnswer((_) async => validationResponse);

        // Act & Assert
        expect(
          () async => await service.uploadDocument(
            file: testFile,
            fileName: fileName,
            category: category,
            portfolioId: 'portfolio_123',
            userId: 'user_456',
          ),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('File validation failed'),
          )),
        );

        // Verify validation was called but upload was not
        verify(mockClient.validateDocument(
          fileName: fileName,
          fileSize: any,
          category: category.toString().split('.').last,
        )).called(1);

        verifyNever(mockClient.uploadDocument(
          userId: any,
          file: any,
          metadata: any,
        ));
      });

      test('should throw ArgumentError for unsupported file type', () async {
        // Arrange
        const unsupportedFile = 'not a file or Uint8List';

        // Act & Assert
        expect(
          () async => await service.uploadDocument(
            file: unsupportedFile,
            fileName: 'test.pdf',
            category: DocumentCategory.stockPortfolio,
            portfolioId: 'portfolio_123',
            userId: 'user_456',
          ),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('File must be either File or Uint8List'),
          )),
        );
      });

      test('should handle API upload failure gracefully', () async {
        // Arrange
        final testFile = File('test/assets/test_document.pdf');
        const fileName = 'test_document.pdf';
        const category = DocumentCategory.stockPortfolio;

        // Mock successful validation
        final validationResponse = {
          'isValid': true,
          'errors': <String>[],
          'warnings': <String>[],
        };

        when(mockClient.validateDocument(
          fileName: fileName,
          fileSize: any,
          category: category.toString().split('.').last,
        )).thenAnswer((_) async => validationResponse);

        // Mock API failure
        when(mockClient.uploadDocument(
          userId: any,
          file: any,
          metadata: any,
        )).thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () async => await service.uploadDocument(
            file: testFile,
            fileName: fileName,
            category: category,
            portfolioId: 'portfolio_123',
            userId: 'user_456',
          ),
          throwsA(isA<Exception>()),
        );

        // Verify both validation and upload were attempted
        verify(mockClient.validateDocument(
          fileName: fileName,
          fileSize: any,
          category: category.toString().split('.').last,
        )).called(1);

        verify(mockClient.uploadDocument(
          userId: any,
          file: any,
          metadata: any,
        )).called(1);
      });
    });

    group('getDocumentStatus', () {
      test('should return document status for valid process ID', () async {
        // Arrange
        const processId = 'process_123';
        final mockApiResponse = ApiDocumentStatusResponse(
          processId: processId,
          status: 'processing',
          progress: 75,
          message: 'Document is being processed',
          lastUpdated: DateTime.now().toIso8601String(),
        );

        when(mockClient.getDocumentStatus(processId))
            .thenAnswer((_) async => mockApiResponse);

        // Act
        final result = await service.getDocumentStatus(processId);

        // Assert - Test real mapper logic
        expect(result.processId, processId);
        expect(result.status, DocumentProcessingStatus.processing);
        expect(result.progress, 75);
        expect(result.message, 'Document is being processed');

        verify(mockClient.getDocumentStatus(processId)).called(1);
      });

      test('should handle status check failure', () async {
        // Arrange
        const processId = 'nonexistent_process';

        when(mockClient.getDocumentStatus(processId))
            .thenThrow(Exception('Process not found'));

        // Act & Assert
        expect(
          () async => await service.getDocumentStatus(processId),
          throwsA(isA<Exception>()),
        );

        verify(mockClient.getDocumentStatus(processId)).called(1);
      });
    });

    group('getUserDocuments', () {
      test('should return user documents collection', () async {
        // Arrange
        const userId = 'user_123';
        final mockApiResponse = ApiDocumentCollectionResponse(
          uploads: [
            ApiDocumentUpload(
              processId: 'proc_1',
              fileName: 'doc1.pdf',
              category: 'stockPortfolio',
              portfolioId: 'portfolio_1',
              userId: userId,
              status: 'completed',
              uploadedAt: DateTime.now().toIso8601String(),
            ),
            ApiDocumentUpload(
              processId: 'proc_2',
              fileName: 'doc2.pdf',
              category: 'mutualFund',
              portfolioId: 'portfolio_1',
              userId: userId,
              status: 'processing',
              uploadedAt: DateTime.now().toIso8601String(),
            ),
          ],
          metadata: ApiCollectionMetadata(
            lastUpdated: DateTime.now().toIso8601String(),
            userId: userId,
            totalCount: 2,
          ),
        );

        when(mockClient.getUserDocuments(userId))
            .thenAnswer((_) async => mockApiResponse);

        // Act
        final result = await service.getUserDocuments(userId);

        // Assert - Test complete mapping logic
        expect(result.uploads, hasLength(2));
        expect(result.uploads.first.processId, 'proc_1');
        expect(result.uploads.first.category, DocumentCategory.stockPortfolio);
        expect(result.uploads.first.status, DocumentProcessingStatus.completed);
        expect(result.uploads.last.processId, 'proc_2');
        expect(result.uploads.last.category, DocumentCategory.mutualFund);
        expect(result.uploads.last.status, DocumentProcessingStatus.processing);

        expect(result.metadata.userId, userId);
        expect(result.metadata.totalCount, 2);

        verify(mockClient.getUserDocuments(userId)).called(1);
      });

      test('should return empty collection for user with no documents', () async {
        // Arrange
        const userId = 'user_no_docs';
        final mockApiResponse = ApiDocumentCollectionResponse(
          uploads: [],
          metadata: ApiCollectionMetadata(
            lastUpdated: DateTime.now().toIso8601String(),
            userId: userId,
            totalCount: 0,
          ),
        );

        when(mockClient.getUserDocuments(userId))
            .thenAnswer((_) async => mockApiResponse);

        // Act
        final result = await service.getUserDocuments(userId);

        // Assert
        expect(result.uploads, isEmpty);
        expect(result.metadata.totalCount, 0);
        expect(result.metadata.userId, userId);

        verify(mockClient.getUserDocuments(userId)).called(1);
      });
    });

    group('validateDocument', () {
      test('should validate document and return validation result', () async {
        // Arrange
        const fileName = 'test.pdf';
        const fileSize = 1024000; // 1MB
        const category = DocumentCategory.stockPortfolio;

        final expectedValidation = {
          'isValid': true,
          'errors': <String>[],
          'warnings': ['File is large'],
        };

        when(mockClient.validateDocument(
          fileName: fileName,
          fileSize: fileSize,
          category: category.toString().split('.').last,
        )).thenAnswer((_) async => expectedValidation);

        // Act
        final result = await service.validateDocument(
          fileName: fileName,
          fileSize: fileSize,
          category: category,
        );

        // Assert
        expect(result['isValid'], true);
        expect(result['errors'], isEmpty);
        expect(result['warnings'], contains('File is large'));

        verify(mockClient.validateDocument(
          fileName: fileName,
          fileSize: fileSize,
          category: category.toString().split('.').last,
        )).called(1);
      });

      test('should return validation errors for invalid file', () async {
        // Arrange
        const fileName = 'invalid.exe';
        const fileSize = 50000000; // 50MB
        const category = DocumentCategory.stockPortfolio;

        final expectedValidation = {
          'isValid': false,
          'errors': ['Invalid file type', 'File too large'],
          'warnings': <String>[],
        };

        when(mockClient.validateDocument(
          fileName: fileName,
          fileSize: fileSize,
          category: category.toString().split('.').last,
        )).thenAnswer((_) async => expectedValidation);

        // Act
        final result = await service.validateDocument(
          fileName: fileName,
          fileSize: fileSize,
          category: category,
        );

        // Assert
        expect(result['isValid'], false);
        expect(result['errors'], hasLength(2));
        expect(result['errors'], contains('Invalid file type'));
        expect(result['errors'], contains('File too large'));

        verify(mockClient.validateDocument(
          fileName: fileName,
          fileSize: fileSize,
          category: category.toString().split('.').last,
        )).called(1);
      });
    });
  });
}

// Mock API response classes that would normally be generated
class ApiDocumentUploadResponse {
  final String processId;
  final String status;
  final String message;
  final String uploadedAt;

  ApiDocumentUploadResponse({
    required this.processId,
    required this.status,
    required this.message,
    required this.uploadedAt,
  });
}

class ApiDocumentStatusResponse {
  final String processId;
  final String status;
  final int progress;
  final String message;
  final String lastUpdated;

  ApiDocumentStatusResponse({
    required this.processId,
    required this.status,
    required this.progress,
    required this.message,
    required this.lastUpdated,
  });
}

class ApiDocumentCollectionResponse {
  final List<ApiDocumentUpload> uploads;
  final ApiCollectionMetadata metadata;

  ApiDocumentCollectionResponse({
    required this.uploads,
    required this.metadata,
  });
}

class ApiDocumentUpload {
  final String processId;
  final String fileName;
  final String category;
  final String portfolioId;
  final String userId;
  final String status;
  final String uploadedAt;
  final String? description;

  ApiDocumentUpload({
    required this.processId,
    required this.fileName,
    required this.category,
    required this.portfolioId,
    required this.userId,
    required this.status,
    required this.uploadedAt,
    this.description,
  });
}

class ApiCollectionMetadata {
  final String lastUpdated;
  final String userId;
  final int totalCount;

  ApiCollectionMetadata({
    required this.lastUpdated,
    required this.userId,
    required this.totalCount,
  });
}