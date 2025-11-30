# Cloudinary Backend API Integration Architecture

## Overview

This document describes the clean architecture implementation for Cloudinary file upload integration using a backend API. The architecture follows the same pattern as the trade feature, providing clear separation of concerns and protecting the frontend from backend changes.

## Architecture Layers

```
Presentation Layer (UI)
    ↓
Service Layer (CloudinaryUploadService)
    ↓
Domain Layer (Repositories, Entities)
    ↓
Data Layer (DTOs, Mappers, Remote Data Source)
    ↓
Backend API
    ↓
Cloudinary API
```

## Key Benefits

1. **Backend Abstraction**: Frontend doesn't know about Cloudinary - backend could switch to AWS S3 without frontend changes
2. **Type Safety**: Freezed DTOs ensure immutability and type safety
3. **Clean Separation**: DTOs isolate API changes from domain logic
4. **Testability**: Each layer can be tested independently
5. **Maintainability**: Clear responsibilities for each component

## File Structure

```
lib/core/services/file_upload/
├── domain/
│   ├── entities/
│   │   └── cloudinary_resource.dart          # Domain entities (freezed)
│   └── repositories/
│       └── cloudinary_repository.dart         # Repository interface
├── data/
│   ├── dtos/
│   │   └── cloudinary_dto.dart                # Data Transfer Objects (freezed)
│   ├── mappers/
│   │   └── cloudinary_mapper.dart             # DTO ↔ Entity conversion
│   ├── remote/
│   │   └── cloudinary_remote_data_source.dart # Backend API calls
│   └── repositories/
│       └── cloudinary_repository_impl.dart    # Repository implementation
├── providers/
│   └── cloudinary_providers.dart              # Riverpod providers
├── file_upload_service.dart                   # Service interface
├── cloudinary_upload_service.dart             # Service implementation
└── file_upload_provider.dart                  # Main service provider
```

## Layer Responsibilities

### 1. Domain Layer

**Entities** (`cloudinary_resource.dart`)
- Pure business objects
- No dependencies on external libraries (except freezed)
- Immutable using `@freezed`

```dart
@freezed
class CloudinaryResource with _$CloudinaryResource {
  const factory CloudinaryResource({
    required String publicId,
    required String url,
    required String secureUrl,
    // ... other fields
  }) = _CloudinaryResource;
}
```

**Repository Interface** (`cloudinary_repository.dart`)
- Defines contract for data access
- Implementation-agnostic
- Returns domain entities

### 2. Data Layer

**DTOs** (`cloudinary_dto.dart`)
- Match backend API exactly
- Freezed for immutability
- JSON serialization with `fromJson`/`toJson`

```dart
@freezed
class UploadResponseDto with _$UploadResponseDto {
  const factory UploadResponseDto({
    required String publicId,
    required String url,
    required String secureUrl,
    // ... matches API response
  }) = _UploadResponseDto;

  factory UploadResponseDto.fromJson(Map<String, dynamic> json) =>
      _$UploadResponseDtoFromJson(json);
}
```

**Mappers** (`cloudinary_mapper.dart`)
- Convert DTOs → Entities
- Convert parameters → DTOs
- Isolate domain from API changes

```dart
class CloudinaryMapper {
  static UploadResult fromUploadResponseDto(UploadResponseDto dto) {
    return UploadResult(
      url: dto.secureUrl ?? dto.url,
      publicId: dto.publicId,
      // ...
    );
  }
}
```

**Remote Data Source** (`cloudinary_remote_data_source.dart`)
- HTTP calls to backend API
- Returns DTOs (not entities)
- Handles network errors

```dart
class CloudinaryRemoteDataSource {
  Future<UploadResponseDto> uploadFile({
    required String fileContent,
    required String filename,
    // ...
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/cloudinary/upload'),
      // ...
    );
    return UploadResponseDto.fromJson(json.decode(response.body));
  }
}
```

**Repository Implementation** (`cloudinary_repository_impl.dart`)
- Coordinates data source and mappers
- Returns domain entities
- Handles business logic errors

```dart
class CloudinaryRepositoryImpl implements CloudinaryRepository {
  @override
  Future<UploadResult> uploadFile(...) async {
    final responseDto = await _remoteDataSource.uploadFile(...);
    return CloudinaryMapper.fromUploadResponseDto(responseDto);
  }
}
```

### 3. Service Layer

**Service Implementation** (`cloudinary_upload_service.dart`)
- Implements `FileUploadService` interface
- Uses repository
- Handles file I/O and conversions

```dart
class CloudinaryUploadService implements FileUploadService {
  final CloudinaryRepository _repository;

  @override
  Future<String> uploadFile(String filePath, ...) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final base64Content = base64Encode(bytes);
    
    final result = await _repository.uploadFile(
      fileContent: base64Content,
      filename: filename,
      // ...
    );
    
    return result.url;
  }
}
```

### 4. Providers

**Dependency Injection** (`cloudinary_providers.dart`)
```dart
// HTTP Client
final httpClientProvider = Provider<http.Client>((ref) => http.Client());

// Base URL (from environment)
final baseUrlProvider = Provider<String>((ref) => 'https://your-backend-api.com');

// Remote Data Source
final cloudinaryRemoteDataSourceProvider = Provider<CloudinaryRemoteDataSource>((ref) {
  return CloudinaryRemoteDataSource(
    client: ref.watch(httpClientProvider),
    baseUrl: ref.watch(baseUrlProvider),
  );
});

// Repository
final cloudinaryRepositoryProvider = Provider<CloudinaryRepository>((ref) {
  return CloudinaryRepositoryImpl(
    remoteDataSource: ref.watch(cloudinaryRemoteDataSourceProvider),
  );
});

// Service
final cloudinaryUploadServiceProvider = Provider<FileUploadService>((ref) {
  return CloudinaryUploadService(
    repository: ref.watch(cloudinaryRepositoryProvider),
  );
});
```

## Backend API Endpoints

Based on the Postman collection:

### 1. Upload File
```
POST /api/cloudinary/upload
Content-Type: application/json

Request:
{
  "fileContent": "base64EncodedString",
  "filename": "image.jpg",
  "folder": "journal_entries",
  "overwrite": false,
  "resourceType": "image"
}

Response:
{
  "publicId": "journal_entries/abc123",
  "url": "http://res.cloudinary.com/...",
  "secureUrl": "https://res.cloudinary.com/...",
  "format": "jpg",
  "bytes": 123456,
  "resourceType": "image",
  "createdAt": "2024-01-15T10:30:00Z",
  "metadata": {}
}
```

### 2. Get Resource
```
GET /api/cloudinary/resources/:publicId?resourceType=image

Response:
{
  "publicId": "journal_entries/abc123",
  "url": "http://res.cloudinary.com/...",
  "secureUrl": "https://res.cloudinary.com/...",
  "format": "jpg",
  "bytes": 123456,
  "width": 1920,
  "height": 1080,
  "resourceType": "image",
  "createdAt": "2024-01-15T10:30:00Z",
  "folder": "journal_entries",
  "metadata": {}
}
```

### 3. List Resources
```
GET /api/cloudinary/resources?folder=journal_entries&resourceType=image&maxResults=100

Response:
{
  "resources": [
    {
      "publicId": "...",
      "url": "...",
      // ... same as Get Resource response
    }
  ]
}
```

### 4. Delete Resource
```
DELETE /api/cloudinary/resources/:publicId?resourceType=image

Response:
{
  "result": "ok",
  "publicId": "journal_entries/abc123"
}
```

### 5. Generate Signature
```
POST /api/cloudinary/signature
Content-Type: application/json

Request:
{
  "publicId": "journal_entries/abc123",
  "folder": "journal_entries",
  "resourceType": "image",
  "params": {}
}

Response:
{
  "apiKey": "your_api_key",
  "publicId": "journal_entries/abc123",
  "timestamp": 1642248600,
  "signature": "sha1_hash",
  "cloudName": "your_cloud_name",
  "folder": "journal_entries",
  "resourceType": "image",
  "uploadUrl": "https://api.cloudinary.com/v1_1/your_cloud_name/image/upload",
  "params": {}
}
```

## Configuration

### Backend URL Configuration

Update `baseUrlProvider` in `cloudinary_providers.dart`:

```dart
final baseUrlProvider = Provider<String>((ref) {
  // Production
  return const String.fromEnvironment(
    'BACKEND_API_URL',
    defaultValue: 'https://api.your-domain.com',
  );
  
  // Or from config file
  // return ref.watch(appConfigProvider).backendUrl;
});
```

### Environment Variables

Add to your `.env` file or build configuration:
```
BACKEND_API_URL=https://api.your-domain.com
```

## Usage in Features

### Upload Files

```dart
class JournalEntryForm extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AttachmentPickerWidget(
      maxImages: 5,
      maxDocuments: 3,
      maxVideos: 2,
      onAttachmentsChanged: (attachments) {
        // Attachments contain URLs returned from backend
      },
    );
  }
}
```

The `AttachmentPickerWidget` automatically:
1. Picks files using file_picker/image_picker
2. Calls `fileUploadServiceProvider.uploadFile()`
3. Service reads file, converts to base64
4. Calls repository
5. Repository calls remote data source
6. Remote data source calls backend API
7. Backend uploads to Cloudinary
8. Response flows back through mappers
9. Widget receives URL

## Testing Strategy

### Unit Tests

**1. Mapper Tests**
```dart
test('fromUploadResponseDto converts correctly', () {
  final dto = UploadResponseDto(
    publicId: 'test/image',
    url: 'http://test.com/image.jpg',
    secureUrl: 'https://test.com/image.jpg',
  );
  
  final result = CloudinaryMapper.fromUploadResponseDto(dto);
  
  expect(result.url, 'https://test.com/image.jpg');
  expect(result.publicId, 'test/image');
});
```

**2. Repository Tests** (with mock data source)
```dart
test('uploadFile returns UploadResult', () async {
  final mockDataSource = MockCloudinaryRemoteDataSource();
  final repository = CloudinaryRepositoryImpl(remoteDataSource: mockDataSource);
  
  when(mockDataSource.uploadFile(...)).thenAnswer((_) async => mockDto);
  
  final result = await repository.uploadFile(...);
  
  expect(result, isA<UploadResult>());
});
```

**3. Service Tests** (with mock repository)
```dart
test('uploadFile reads file and calls repository', () async {
  final mockRepository = MockCloudinaryRepository();
  final service = CloudinaryUploadService(repository: mockRepository);
  
  when(mockRepository.uploadFile(...)).thenAnswer((_) async => mockResult);
  
  final url = await service.uploadFile('/path/to/file.jpg');
  
  expect(url, isNotEmpty);
  verify(mockRepository.uploadFile(...)).called(1);
});
```

### Integration Tests

Mock HTTP client in `CloudinaryRemoteDataSource` tests:

```dart
test('uploadFile calls correct endpoint', () async {
  final mockClient = MockClient((request) async {
    expect(request.url.path, '/api/cloudinary/upload');
    expect(request.method, 'POST');
    
    return http.Response(jsonEncode({
      'publicId': 'test/image',
      'url': 'http://test.com/image.jpg',
      'secureUrl': 'https://test.com/image.jpg',
    }), 200);
  });
  
  final dataSource = CloudinaryRemoteDataSource(
    client: mockClient,
    baseUrl: 'https://test.com',
  );
  
  final result = await dataSource.uploadFile(...);
  
  expect(result.publicId, 'test/image');
});
```

## Code Generation

### Running Freezed

After modifying DTOs or entities:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This generates:
- `*.freezed.dart` - Freezed code (copyWith, ==, hashCode, toString)
- `*.g.dart` - JSON serialization code

### Watch Mode (Development)

```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

Automatically regenerates on file changes.

## Migration from Direct API

### Before (Direct Cloudinary)
```dart
class CloudinaryUploadService {
  final CloudinaryConfig _config;
  
  Future<String> uploadFile() async {
    // Direct API call to Cloudinary
    final response = await http.post(
      Uri.parse('https://api.cloudinary.com/v1_1/${_config.cloudName}/upload'),
      // ...
    );
  }
}
```

### After (Backend API)
```dart
class CloudinaryUploadService {
  final CloudinaryRepository _repository;
  
  Future<String> uploadFile() async {
    // Call backend API via repository
    final result = await _repository.uploadFile(...);
    return result.url;
  }
}
```

## Error Handling

### Remote Data Source
- HTTP errors → Exception with status code
- JSON parsing errors → Exception
- Network errors → Exception

### Repository
- Catches data source exceptions
- Wraps in domain exceptions
- Logs errors

### Service
- Catches repository exceptions
- Converts to `FileUploadException`
- User-friendly error messages

## Performance Considerations

1. **Base64 Encoding**: For large files, consider chunking or streaming
2. **Multiple Uploads**: Uses `Future.wait()` for parallel uploads
3. **Caching**: Repository can cache resource details
4. **Retry Logic**: Add exponential backoff in remote data source

## Security

1. **API Keys**: Never exposed to frontend (handled by backend)
2. **Signatures**: Generated by backend
3. **HTTPS**: All API calls use secure connections
4. **File Validation**: Backend validates file types and sizes

## Future Enhancements

1. **Progress Tracking**: Stream upload progress
2. **Caching**: Cache uploaded resources locally
3. **Offline Support**: Queue uploads for retry
4. **Compression**: Compress images before upload
5. **CDN Optimization**: Smart transformations

## Troubleshooting

### DTOs Not Found
```
Error: The getter 'publicId' isn't defined for UploadResponseDto
```
**Solution**: Run `flutter pub run build_runner build --delete-conflicting-outputs`

### Import Errors
```
Error: Target of URI doesn't exist
```
**Solution**: Check file paths in imports, ensure all files are created

### Backend Connection
```
Error: Upload failed: 500 - Internal Server Error
```
**Solution**: 
1. Check `baseUrlProvider` has correct URL
2. Verify backend is running
3. Check backend logs for errors
4. Validate request DTO matches backend expectations

## Best Practices

1. **Always use DTOs** for API communication
2. **Never expose backend details** to domain layer
3. **Use mappers** for all conversions
4. **Keep entities pure** (no JSON, no HTTP)
5. **Test each layer** independently
6. **Document API contracts** when they change
7. **Version APIs** to prevent breaking changes

## Related Documentation

- [Cloudinary File Upload Integration](./CLOUDINARY_FILE_UPLOAD_INTEGRATION.md) - Original implementation
- [API Guidelines](../docs/API_GUIDELINES.md) - API best practices
- [Coding Standards](../docs/CODING_STANDARDS.md) - Code style guide
- [Trade Feature](../features/trade/README.md) - Reference architecture

## Summary

This architecture provides:
- ✅ Clear separation of concerns
- ✅ Protection from backend changes
- ✅ Type-safe API communication
- ✅ Testable components
- ✅ Maintainable codebase
- ✅ Scalable pattern for new features

The frontend no longer knows about Cloudinary - it just uploads files to a backend API. The backend can change cloud providers without any frontend changes required.
