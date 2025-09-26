# Service Testing Guidelines

> **Related Documentation:** For complete testing workflow, see [DEVELOPMENT_RULES.md](../docs/DEVELOPMENT_RULES.md)

## Testing Philosophy

This project follows a **"Mock External, Test Internal"** philosophy for service layer testing:

### ✅ What to Mock
- **HTTP Clients** (Dio, http.Client)
- **API Clients** (Retrofit-generated clients) 
- **External Services** (Firebase, Analytics, Payment processors)
- **Platform APIs** (Device storage, camera, location)
- **Third-party SDKs** (Social login, crash reporting)

### ❌ What NOT to Mock
- **Repositories** (Test real repository implementations)
- **Mappers** (Test real data transformation logic)
- **Business Logic** (Test real service methods)
- **Domain Entities** (Test real domain objects)
- **Utility Functions** (Test real utility methods)

## Test Structure

### Service Test Pattern
```dart
@GenerateMocks([ExternalClient]) // Mock external dependencies only
void main() {
  group('ServiceName', () {
    late ServiceClass service;
    late MockExternalClient mockClient;
    late RealRepository repository; // Use real repository
    
    setUp(() {
      mockClient = MockExternalClient();
      repository = RealRepositoryImpl(mockClient); // Real implementation
      service = ServiceClass(repository); // Real service with real repository
    });
    
    test('should handle success scenario with real data transformation', () async {
      // Arrange - Mock external API response
      when(mockClient.apiCall()).thenAnswer((_) async => mockApiResponse);
      
      // Act - Test real business logic flow
      final result = await service.businessMethod();
      
      // Assert - Validate complete transformation including mapping
      expect(result.domainProperty, expectedValue);
      verify(mockClient.apiCall()).called(1);
    });
  });
}
```

### Complete Flow Testing
```dart
test('should transform API response through complete domain flow', () async {
  // Arrange - Realistic API response
  final apiResponse = ApiDocumentResponse(
    id: 'doc_123',
    status: 'completed',
    uploadedAt: '2023-01-01T12:00:00Z',
    metadata: {'category': 'stockPortfolio'},
  );
  
  when(mockClient.getDocument(any)).thenAnswer((_) async => apiResponse);
  
  // Act - Execute complete flow: API → Repository → Mapper → Service → Domain
  final result = await service.getDocument('doc_123');
  
  // Assert - Validate domain object properties after transformation
  expect(result.documentId, 'doc_123');
  expect(result.status, DocumentStatus.completed);
  expect(result.uploadedAt, DateTime(2023, 1, 1, 12, 0, 0));
  expect(result.category, DocumentCategory.stockPortfolio);
  
  // Verify the complete call chain
  verify(mockClient.getDocument('doc_123')).called(1);
});
```

### Error Scenario Testing
```dart
test('should handle API errors and fallback to mock data in development', () async {
  // Arrange - Simulate network failure
  when(mockClient.apiCall()).thenThrow(DioException(/* network error */));
  
  // Act - Service should handle error gracefully
  final result = await service.getData();
  
  // Assert - Should return mock data in development
  expect(result, isNotNull);
  expect(result.source, DataSource.mock); // Indicate mock data was used
  
  verify(mockClient.apiCall()).called(1);
});
```

## Test Data Strategy

### Realistic Test Data
```dart
class TestDataFactory {
  static ApiPortfolioResponse createValidPortfolioResponse() {
    return ApiPortfolioResponse(
      userId: 'test_user_123',
      totalValue: 50000.00,
      holdings: [
        ApiHolding(
          symbol: 'AAPL',
          quantity: 10,
          currentPrice: 150.00,
          dailyChange: 2.50,
        ),
        ApiHolding(
          symbol: 'GOOGL', 
          quantity: 5,
          currentPrice: 2800.00,
          dailyChange: -15.75,
        ),
      ],
      lastUpdated: '2023-01-01T12:00:00Z',
    );
  }
  
  static ApiPortfolioResponse createEmptyPortfolioResponse() {
    return ApiPortfolioResponse(
      userId: 'empty_user',
      totalValue: 0.0,
      holdings: [],
      lastUpdated: DateTime.now().toIso8601String(),
    );
  }
}
```

### Edge Case Testing
```dart
group('edge cases', () {
  test('should handle empty API response', () async {
    // Test with empty data
    when(mockClient.getData()).thenAnswer(
      (_) async => TestDataFactory.createEmptyResponse()
    );
    
    final result = await service.processData();
    
    expect(result.items, isEmpty);
    expect(result.totalCount, 0);
  });
  
  test('should handle malformed API response', () async {
    // Test with invalid/partial data
    when(mockClient.getData()).thenAnswer(
      (_) async => TestDataFactory.createMalformedResponse()
    );
    
    expect(
      () async => await service.processData(),
      throwsA(isA<ValidationException>()),
    );
  });
});
```

## Validation Testing

### Input Validation
```dart
group('input validation', () {
  test('should reject invalid file types', () async {
    expect(
      () async => await service.uploadDocument(
        fileName: 'virus.exe',
        category: DocumentCategory.stockPortfolio,
      ),
      throwsA(isA<ValidationException>()),
    );
  });
  
  test('should validate required fields', () async {
    expect(
      () async => await service.createUser(
        email: '', // Invalid
        password: 'validpassword',
      ),
      throwsA(isA<ValidationException>()),
    );
  });
});
```

## State Management Testing

### Authentication State
```dart
test('should maintain consistent auth state through operations', () async {
  // Arrange
  await authService.signIn('user@test.com', 'password');
  expect(authService.isAuthenticated, true);
  
  // Act - Perform operation that might affect auth state
  await authService.refreshToken();
  
  // Assert - Auth state should remain consistent
  expect(authService.isAuthenticated, true);
  expect(authService.getCurrentUser(), isNotNull);
});
```

### Stream Testing
```dart
test('should emit correct state changes', () async {
  // Arrange
  final stateChanges = <AuthState>[];
  final subscription = authService.authStateChanges.listen(stateChanges.add);
  
  // Act
  await authService.signIn('user@test.com', 'password');
  await Future.delayed(Duration(milliseconds: 10)); // Allow emissions
  
  // Assert
  expect(stateChanges, hasLength(2));
  expect(stateChanges.first.status, AuthStatus.loading);
  expect(stateChanges.last.status, AuthStatus.authenticated);
  
  await subscription.cancel();
});
```

## Configuration Testing

### Environment-Specific Behavior
```dart
test('should use correct configuration for environment', () async {
  // Arrange
  await ConfigService.initialize(environment: 'test');
  
  // Act
  final shouldUseMockData = service.shouldUseMockData();
  
  // Assert
  expect(shouldUseMockData, true); // Test environment enables mock data
  expect(ConfigService.isTest, true);
});
```

## Performance Testing

### Response Time Validation
```dart
test('should complete operation within reasonable time', () async {
  // Arrange
  final stopwatch = Stopwatch()..start();
  
  // Act
  await service.performOperation();
  
  // Assert
  stopwatch.stop();
  expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // Max 5 seconds
});
```

## Integration Testing Hints

While these are unit tests, they prepare for integration testing:

```dart
// This unit test structure makes integration testing easier
test('should integrate with real API client', () async {
  // When ready for integration tests, replace MockClient with real client
  // final realClient = DocumentClient(Dio());
  // final repository = DocumentRepositoryImpl(realClient);
  // final service = DocumentUploadService(repository);
  
  // For now, test with mocked client but real repository/mapper
  final result = await service.uploadDocument(/* params */);
  
  // Assert domain-level expectations that should work with real API
  expect(result.processId, isNotEmpty);
  expect(result.status, isA<DocumentProcessingStatus>());
});
```

## Test Coverage Goals

- **Service Methods**: 100% coverage of all public methods
- **Error Paths**: All error handling branches tested
- **Edge Cases**: Empty data, malformed data, network failures
- **State Transitions**: All state changes validated
- **Configuration**: All environment-specific behaviors tested
- **Data Transformation**: All mapping scenarios covered

## Running Tests

```bash
# Run all service tests
flutter test test/services/

# Run specific service tests
flutter test test/services/auth_service_test.dart

# Run with coverage
flutter test --coverage test/services/

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
```

## Mock Data Guidelines

Mock data should be:
- **Realistic**: Use real-world-like data structures and values
- **Comprehensive**: Cover success, error, and edge cases
- **Maintainable**: Centralized in factory classes
- **Environment-Aware**: Different data for different test scenarios

Example mock data organization:
```dart
class MockDataProvider {
  static const String testUserId = 'test_user_123';
  static const String testPortfolioId = 'test_portfolio_456';
  
  static ApiResponse successResponse() => /* realistic success data */;
  static ApiResponse errorResponse() => /* realistic error data */;
  static ApiResponse emptyResponse() => /* valid but empty data */;
}