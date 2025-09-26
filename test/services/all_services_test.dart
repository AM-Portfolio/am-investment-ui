import 'package:flutter_test/flutter_test.dart';

import '../services/document_upload_service_test.dart' as document_upload_service_test;

/// Comprehensive test suite for all service layer components
/// 
/// This test suite follows the established testing principles:
/// - Mock external dependencies only (API clients, HTTP clients)
/// - Test real internal logic (repositories, mappers, business logic)
/// - Validate complete data flows and transformations
/// - Test all error scenarios and edge cases
/// 
/// Each service test validates:
/// 1. Successful operations with real data transformation
/// 2. Error handling and graceful degradation
/// 3. Mock data fallback in development environment
/// 4. Input validation and edge cases
/// 5. State management and persistence
/// 6. Configuration-driven behavior
void main() {
  group('Service Layer Tests', () {
    group('DocumentUploadService Tests', document_upload_service_test.main);
  });
}