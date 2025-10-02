```markdown
# Development Workflow & Build Rules

> **Related Documentation:** 
> - File organization and structure: [PROJECT_STRUCTURE.md](./PROJECT_STRUCTURE.md)
> - Code style and standards: [CODING_STANDARDS.md](./CODING_STANDARDS.md)
> - API implementation patterns: [API_GUIDELINES.md](./API_GUIDELINES.md)
> - Architecture patterns: [ARCHITECTURAL_PATTERNS.md](./ARCHITECTURAL_PATTERNS.md)

## Development Workflow

### Before Writing Any Code
1. **Read Documentation First**
   - Review [PROJECT_STRUCTURE.md](./PROJECT_STRUCTURE.md) for file organization
   - Check [CODING_STANDARDS.md](./CODING_STANDARDS.md) for style requirements
   - Study [API_GUIDELINES.md](./API_GUIDELINES.md) for API patterns
   - Reference [ARCHITECTURAL_PATTERNS.md](./ARCHITECTURAL_PATTERNS.md) for design patterns

2. **Examine Existing Implementations**
   - Find similar features in the codebase
   - Follow established patterns and naming conventions
   - Match existing code structure and organization
   - Reuse existing components and utilities

3. **Understand Dependencies**
   - Never manually initialize objects - use Riverpod providers
   - Follow the dependency injection hierarchy
   - Use existing repositories and services where possible

### Configuration Management Rules
```dart
// ✅ Always use ConfigService for configuration
final config = ConfigService.config;
final apiUrl = config?.api?.baseUrl ?? 'fallback-url';

// ❌ Never hardcode configuration values
final apiUrl = 'https://hardcoded-api.com'; // Bad!
```

**Configuration Files:**
- `assets/application.properties` - Main configuration
- `assets/application-dev.properties` - Development overrides
- `assets/application-prod.properties` - Production settings
- `assets/application-staging.properties` - Staging settings
- `assets/application-test.properties` - Test configuration

### Error Handling Standards
```dart
// Standard error handling pattern for all services
Future<T> performOperation<T>(Future<T> Function() operation) async {
  try {
    return await operation();
  } catch (e) {
    debugPrint('Error in ${T.toString().toLowerCase()}: $e');
    
    // Use mock data in development if available
    if (_isDevelopmentEnvironment() && _hasMockDataFor<T>()) {
      debugPrint('Falling back to mock data for ${T.toString()}');
      return _getMockData<T>();
    }
    
    rethrow; // Always rethrow unless handling gracefully
  }
}
```

## Build System Rules

### Code Generation Workflow
```bash
# Clean and regenerate all generated files
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs

# Watch mode for development
dart run build_runner watch --delete-conflicting-outputs
```

### Required Build Dependencies
Ensure these are in `pubspec.yaml` dev_dependencies:
```yaml
dev_dependencies:
  build_runner: ^2.4.9
  freezed: ^2.5.2
  json_serialization: ^6.8.0
  riverpod_generator: ^2.4.0
  retrofit_generator: ^8.1.0
```

### Pre-commit Checklist
1. **Code Generation**: Run `dart run build_runner build`
2. **Linting**: Run `dart analyze` and fix all issues
3. **Formatting**: Run `dart format lib/ test/`
4. **Tests**: Run `flutter test` and ensure all pass
5. **Documentation**: Update relevant documentation files

## Testing Rules

### Test File Organization
```
test/
├── features/                   # Feature-specific tests (mirror lib/features structure)
│   ├── portfolio/
│   │   ├── internal/
│   │   │   ├── data/
│   │   │   │   ├── repositories/  # Repository tests
│   │   │   │   └── mappers/       # Mapper tests
│   │   │   ├── domain/            # Domain logic tests
│   │   │   └── services/          # Service layer tests
│   │   └── presentation/
│   │       ├── cubit/             # State management tests
│   │       └── widgets/           # Widget tests
│   └── auth/
│       └── presentation/
│           └── widgets/           # Auth widget tests
├── core/                       # Core infrastructure tests
│   ├── utils/                  # Utility tests
│   ├── network/                # Network layer tests
│   └── providers/              # Provider tests
└── shared/                     # Shared component tests
    └── widgets/                # Shared widget tests
```

### Testing Standards
- **Services**: Mock API calls only, test real repository/mapper logic
- **Repositories**: Mock HTTP client, test real mapper and caching logic
- **Mappers**: Test all mapping scenarios with real data transformation
- **Widgets**: Test UI behavior and state management

### Mock Data Rules
```dart
// ✅ Good - Mock external dependencies only
class MockDocumentClient extends Mock implements DocumentClient {}

// ❌ Bad - Don't mock internal logic (repositories, mappers)
class MockDocumentRepository extends Mock implements DocumentRepository {}
```

## Environment Management

### Environment Detection
```dart
class EnvironmentHelper {
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'prod',
  );
  
  static bool get isDevelopment => environment == 'dev';
  static bool get isProduction => environment == 'prod';
  static bool get isStaging => environment == 'staging';
  static bool get isTesting => environment == 'test';
  
  static bool get mockDataEnabled => const bool.fromEnvironment(
    'MOCK_DATA_ENABLED',
    defaultValue: false,
  );
}
```

### Build Flavors
```bash
# Development build with mock data
flutter run --dart-define=ENVIRONMENT=dev --dart-define=MOCK_DATA_ENABLED=true

# Production build
flutter run --dart-define=ENVIRONMENT=prod --release

# Staging build
flutter run --dart-define=ENVIRONMENT=staging
```

## Performance Rules

### Code Size Constraints
- **Maximum method length**: 20 lines (extract smaller methods)
- **Maximum file length**: 500 lines (split into multiple files)
- **Maximum widget build method**: 15 lines (extract widget builders)

### Memory Management
```dart
// ✅ Good - Dispose resources properly
class SomeService {
  StreamController? _controller;
  
  void dispose() {
    _controller?.close();
    _controller = null;
  }
}

// ✅ Good - Use const constructors where possible
const LoadingIndicator(message: 'Loading...');
```

## Documentation Rules

### Code Documentation
```dart
/// Service for handling document upload operations.
/// 
/// This service provides business logic layer between UI and repository,
/// handles validation, error management, and environment-specific behavior.
/// 
/// Location: lib/features/document_processing/internal/services/document_upload_service.dart
/// 
/// Example usage:
/// ```dart
/// final service = ref.read(documentUploadServiceProvider);
/// final result = await service.uploadDocument(
///   file: selectedFile,
///   fileName: 'document.pdf',
///   category: DocumentCategory.taxDocument,
///   portfolioId: 'portfolio-123',
///   userId: 'user-456',
/// );
/// ```
@Injectable(as: DocumentUploadService)
class DocumentUploadServiceImpl implements DocumentUploadService {
  // Implementation...
}
```

### API Documentation
- Document all public methods with examples
- Include parameter validation rules
- Document error conditions and exceptions
- Provide usage examples for complex APIs
```