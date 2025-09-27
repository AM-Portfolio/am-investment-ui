// import 'dart:io';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/mockito.dart';
// import 'package:mockito/annotations.dart';

// import '../../lib/core/services/document_upload_service.dart';
// import '../../lib/core/domain/entities/document/document_upload.dart';
// import '../../lib/core/domain/repositories/document_repository.dart';
// import '../../lib/core/data/repositories/document_repository_impl.dart';
// import '../../lib/core/services/api/document_client.dart';

// // Generate mocks for external dependencies only
// @GenerateMocks([DocumentClient])
// void main() {
//   group('DocumentUploadService', () {
//     late DocumentUploadService service;
//     late MockDocumentClient mockClient;
//     late DocumentRepository repository;

//     setUp(() {
//       mockClient = MockDocumentClient();
//       // Use real repository and mapper - don't mock internal logic
//       repository = DocumentRepositoryImpl(apiClient: mockClient);
//       service = DocumentUploadService(repository);
//     });

//     group('uploadDocument', () {
//       test('should successfully upload document with File input', () async {
//         // Arrange
//         final testFile = File('test/assets/test_document.pdf');
//         const fileName = 'test_document.pdf';
//         const category = DocumentCategory.stockPortfolio;
//         const portfolioId = 'portfolio_123';
//         const userId = 'user_456';
//         const description = 'Test document upload';

//         // Mock successful API response using the correct method signature
//         final mockApiResponse = DocumentUploadResponse(
//           processId: 'process_789',
//           status: 'QUEUED',
//           message: 'Document uploaded successfully',
//           uploadedAt: DateTime.now(),
//         );

//         when(mockClient.uploadDocument(
//           testFile,
//           'STOCK_PORTFOLIO',
//           portfolioId,
//           userId,
//           description: description,
//         )).thenAnswer((_) async => mockApiResponse);

//         // Act
//         final result = await service.uploadDocument(
//           file: testFile,
//           fileName: fileName,
//           category: category,
//           portfolioId: portfolioId,
//           userId: userId,
//           description: description,
//         );

//         // Assert - Validate complete flow including mapping
//         expect(result.identity.processId, 'process_789');
//         expect(result.identity.fileName, fileName);
//         expect(result.identity.category, category);
//         expect(result.metadata.portfolioId, portfolioId);
//         expect(result.metadata.userId, userId);
//         expect(result.metadata.description, description);

//         // Verify API calls
//         verify(mockClient.uploadDocument(
//           testFile,
//           'STOCK_PORTFOLIO',
//           portfolioId,
//           userId,
//           description: description,
//         )).called(1);
//       });

//       test('should handle file validation failure', () async {
//         // Arrange
//         final testFile = File('test/assets/invalid_file.exe');
//         const fileName = 'invalid_file.exe';
//         const category = DocumentCategory.stockPortfolio;

//         // Act & Assert
//         expect(
//           () async => await service.uploadDocument(
//             file: testFile,
//             fileName: fileName,
//             category: category,
//             portfolioId: 'portfolio_123',
//             userId: 'user_456',
//           ),
//           throwsA(isA<ArgumentError>()),
//         );

//         // Verify upload was not called due to validation failure
//         verifyNever(mockClient.uploadDocument(
//           any,
//           any,
//           any,
//           any,
//           description: anyNamed('description'),
//         ));
//       });

//       test('should handle API upload failure gracefully', () async {
//         // Arrange
//         final testFile = File('test/assets/test_document.pdf');
//         const fileName = 'test_document.pdf';
//         const category = DocumentCategory.stockPortfolio;

//         // Mock API failure
//         when(mockClient.uploadDocument(
//           testFile,
//           'STOCK_PORTFOLIO',
//           'portfolio_123',
//           'user_456',
//         )).thenThrow(Exception('Network error'));

//         // Act & Assert
//         expect(
//           () async => await service.uploadDocument(
//             file: testFile,
//             fileName: fileName,
//             category: category,
//             portfolioId: 'portfolio_123',
//             userId: 'user_456',
//           ),
//           throwsA(isA<Exception>()),
//         );

//         // Verify upload was attempted
//         verify(mockClient.uploadDocument(
//           testFile,
//           'STOCK_PORTFOLIO',
//           'portfolio_123',
//           'user_456',
//         )).called(1);
//       });
//     });
//   });
// }

// // Mock API response class for testing
// class DocumentUploadResponse {
//   final String processId;
//   final String status;
//   final String message;
//   final DateTime uploadedAt;

//   DocumentUploadResponse({
//     required this.processId,
//     required this.status,
//     required this.message,
//     required this.uploadedAt,
//   });
// }