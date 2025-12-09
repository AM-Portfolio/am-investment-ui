# Cloudinary File Upload Integration

## Overview
Complete implementation of Cloudinary-based file upload system with a clean, swappable architecture. All file uploads (images, documents, videos) across all features use this shared infrastructure.

## Architecture

### Layer Structure
```
lib/
├── core/
│   ├── services/
│   │   └── file_upload/
│   │       ├── file_upload_service.dart           # Abstract interface
│   │       ├── cloudinary_upload_service.dart     # Cloudinary implementation
│   │       ├── local_upload_service.dart          # Mock for testing
│   │       └── file_upload_provider.dart          # Riverpod provider
│   │
│   └── widgets/
│       └── attachments/
│           └── attachment_picker_widget.dart      # Shared upload UI
│
├── config/
│   ├── cloudinary_config.dart                     # Cloudinary credentials
│   └── upload_config.dart                         # Upload limits & rules
│
└── features/
    └── trade/
        └── presentation/
            └── widgets/
                └── journal/
                    └── journal_entry_form.dart    # Uses AttachmentPickerWidget
```

## Components

### 1. Abstract Service Interface
`lib/core/services/file_upload/file_upload_service.dart`

Defines the contract that all upload providers must implement:
- `uploadFile()` - Upload single file
- `uploadMultipleFiles()` - Upload multiple files with progress
- `deleteFile()` - Delete file by URL
- `deleteMultipleFiles()` - Batch delete
- `getOptimizedUrl()` - Get transformed URLs (resize, format, quality)

### 2. Cloudinary Implementation
`lib/core/services/file_upload/cloudinary_upload_service.dart`

Production-ready Cloudinary integration:
- ✅ Signed uploads with SHA1 signature
- ✅ Automatic folder organization by feature/year
- ✅ Metadata tagging (userId, feature, type)
- ✅ Public ID extraction for deletion
- ✅ URL transformation for optimization
- ✅ Error handling with custom exceptions

**Key Methods:**
```dart
// Upload
final url = await uploadService.uploadFile(
  'path/to/file.jpg',
  folder: 'journal-attachments/2025',
  metadata: {'userId': '123', 'feature': 'journal'},
);

// Delete
await uploadService.deleteFile(url);

// Optimize
final thumbnail = uploadService.getOptimizedUrl(
  url,
  width: 200,
  height: 200,
  quality: 80,
);
```

### 3. Local Mock Service
`lib/core/services/file_upload/local_upload_service.dart`

For development/testing without Cloudinary account:
- Returns mock URLs
- Simulates upload delays
- No actual network calls

### 4. Provider Configuration
`lib/core/services/file_upload/file_upload_provider.dart`

Riverpod provider for dependency injection:
```dart
final fileUploadServiceProvider = Provider<FileUploadService>((ref) {
  const useMock = false; // Toggle between Cloudinary and Mock
  
  if (useMock) {
    return LocalUploadService();
  }
  
  final config = CloudinaryConfig.fromEnv();
  return CloudinaryUploadService(config);
});
```

**To swap providers:** Just change the return statement!

### 5. Cloudinary Configuration
`lib/config/cloudinary_config.dart`

Manages Cloudinary credentials:
```dart
// From environment variables
final config = CloudinaryConfig.fromEnv();

// For development
final config = CloudinaryConfig.development();

// Manual
final config = CloudinaryConfig(
  cloudName: 'your-cloud',
  apiKey: 'your-key',
  apiSecret: 'your-secret',
);
```

### 6. Upload Configuration
`lib/config/upload_config.dart`

Global upload rules:
- **File size limits**: 10MB (images), 50MB (documents), 100MB (videos)
- **Allowed types**: jpg, png, pdf, doc, mp4, etc.
- **Compression**: 1920x1920 max, 85% quality
- **Folder structure**: Auto-organized by feature/year

### 7. Shared Attachment Widget
`lib/core/widgets/attachments/attachment_picker_widget.dart`

Reusable upload UI component:

**Features:**
- ✅ Image/document/video/any file picker
- ✅ Thumbnail previews with delete
- ✅ Upload progress indicator
- ✅ Max attachment limits
- ✅ File type validation
- ✅ Error handling with user feedback

**Usage:**
```dart
AttachmentPickerWidget(
  attachmentUrls: _imageUrls,
  onAttachmentsChanged: (urls) => setState(() => _imageUrls = urls),
  featureName: 'journal',          // For folder organization
  maxAttachments: 5,
  allowedType: AttachmentType.image,
  showPreview: true,
  userId: widget.userId,           // For metadata
)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `attachmentUrls` | `List<String>` | Current attachment URLs |
| `onAttachmentsChanged` | `Function(List<String>)` | Callback when URLs change |
| `featureName` | `String` | Feature name for folder (journal, portfolio, etc.) |
| `maxAttachments` | `int` | Maximum files allowed (default: 5) |
| `allowedType` | `AttachmentType` | File type: image, document, video, any |
| `showPreview` | `bool` | Show thumbnail grid (default: true) |
| `userId` | `String?` | Optional user ID for metadata |

## Setup Instructions

### 1. Create Cloudinary Account
1. Go to https://cloudinary.com/users/register_free
2. Sign up for free account
3. Note your **Cloud Name**, **API Key**, and **API Secret** from dashboard

### 2. Configure Environment
Create `.env` file (or use build configuration):
```env
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
```

### 3. Build with Environment Variables
```bash
# Web
flutter build web --dart-define=CLOUDINARY_CLOUD_NAME=your_cloud_name \
                  --dart-define=CLOUDINARY_API_KEY=your_key \
                  --dart-define=CLOUDINARY_API_SECRET=your_secret

# Mobile
flutter run --dart-define=CLOUDINARY_CLOUD_NAME=your_cloud_name \
            --dart-define=CLOUDINARY_API_KEY=your_key \
            --dart-define=CLOUDINARY_API_SECRET=your_secret
```

### 4. Alternative: Use Mock Service
For development without Cloudinary:
```dart
// lib/core/services/file_upload/file_upload_provider.dart
final fileUploadServiceProvider = Provider<FileUploadService>((ref) {
  const useMock = true;  // ✅ Enable mock
  
  if (useMock) {
    return LocalUploadService();
  }
  // ...
});
```

## Usage Examples

### Journal Entry (Images)
```dart
AttachmentPickerWidget(
  attachmentUrls: _imageUrls,
  onAttachmentsChanged: (urls) => setState(() => _imageUrls = urls),
  featureName: 'journal',
  maxAttachments: 5,
  allowedType: AttachmentType.image,
  userId: widget.userId,
)
```

### Portfolio Documents
```dart
AttachmentPickerWidget(
  attachmentUrls: _documentUrls,
  onAttachmentsChanged: (urls) => setState(() => _documentUrls = urls),
  featureName: 'portfolio',
  maxAttachments: 10,
  allowedType: AttachmentType.document,
  label: 'Supporting Documents',
)
```

### Any File Type
```dart
AttachmentPickerWidget(
  attachmentUrls: _fileUrls,
  onAttachmentsChanged: (urls) => setState(() => _fileUrls = urls),
  featureName: 'documents',
  maxAttachments: 20,
  allowedType: AttachmentType.any,
)
```

## Cloudinary Folder Structure

Files are auto-organized:
```
cloudinary-root/
├── journal-attachments/
│   ├── 2025/
│   │   ├── image1.jpg
│   │   └── image2.png
│   └── 2024/
├── portfolio-documents/
│   └── 2025/
├── trade-screenshots/
│   └── 2025/
└── user-documents/
    └── 2025/
```

## Swapping to Different Provider

### AWS S3 Example
```dart
// 1. Create lib/core/services/file_upload/aws_s3_upload_service.dart
class AWSS3UploadService implements FileUploadService {
  @override
  Future<String> uploadFile(...) async {
    // AWS S3 upload logic
  }
  // ... implement all methods
}

// 2. Update provider
final fileUploadServiceProvider = Provider<FileUploadService>((ref) {
  return AWSS3UploadService(/* config */);  // ✅ One line change!
});
```

### Firebase Storage Example
```dart
class FirebaseUploadService implements FileUploadService {
  final FirebaseStorage _storage;
  
  @override
  Future<String> uploadFile(...) async {
    final ref = _storage.ref().child('uploads/$fileName');
    await ref.putFile(File(filePath));
    return await ref.getDownloadURL();
  }
  // ... implement all methods
}
```

## Error Handling

All upload errors throw `FileUploadException`:
```dart
try {
  final url = await uploadService.uploadFile(path);
} on FileUploadException catch (e) {
  print('Upload failed: ${e.message}');
  print('Error code: ${e.code}');
  print('Original error: ${e.originalError}');
}
```

## Security Notes

### API Credentials
- ✅ **Never commit** API secrets to git
- ✅ Use environment variables or secure vaults
- ✅ Different credentials per environment (dev/staging/prod)

### Upload Preset (Optional)
For unsigned uploads (client-side only):
1. Create upload preset in Cloudinary dashboard
2. Set folder restrictions
3. Use preset instead of API secret

### Backend Validation
Cloudinary uploads are signed, but always:
- Validate file URLs on backend before saving
- Check file ownership
- Implement delete permissions

## Performance Optimization

### Image Compression
```dart
final XFile? image = await picker.pickImage(
  source: ImageSource.gallery,
  maxWidth: 1920,
  maxHeight: 1920,
  imageQuality: 85,  // 0-100
);
```

### Lazy Loading Thumbnails
```dart
final thumbnail = uploadService.getOptimizedUrl(
  originalUrl,
  width: 200,
  height: 200,
  quality: 60,
  format: 'webp',
);
```

### CDN Caching
Cloudinary automatically provides global CDN caching for all uploaded files.

## Testing

### Unit Tests
```dart
test('should upload file successfully', () async {
  final mockService = LocalUploadService();
  
  final url = await mockService.uploadFile('test.jpg');
  
  expect(url, contains('mock-cdn.example.com'));
  expect(mockService.uploadedFiles, hasLength(1));
});
```

### Integration Tests
Use `LocalUploadService` for tests:
```dart
ProviderScope(
  overrides: [
    fileUploadServiceProvider.overrideWithValue(LocalUploadService()),
  ],
  child: MyApp(),
);
```

## Troubleshooting

### "Upload failed with status 401"
- Check API credentials are correct
- Verify signature generation

### "File not found"
- Check file path is valid
- Ensure file picker returned a path

### "Target of URI doesn't exist"
- Run `flutter pub get`
- Check import paths are correct

### Images not showing
- Verify URLs are public
- Check CORS settings in Cloudinary
- Enable `Resource list` in Cloudinary settings

## Dependencies

```yaml
dependencies:
  http: ^1.2.0              # HTTP requests
  crypto: ^3.0.3            # SHA1 signature
  path: ^1.9.0              # Path manipulation
  image_picker: ^1.1.2      # Image selection
  file_picker: ^8.1.2       # File selection
  flutter_riverpod: ^2.5.1  # State management
```

## Future Enhancements

- [ ] Multiple cloud provider support (AWS + Cloudinary)
- [ ] Client-side image cropping
- [ ] Video thumbnail generation
- [ ] Batch upload with retry logic
- [ ] Upload queue management
- [ ] Offline upload queue
- [ ] Image filters/transformations

## Summary

✅ **Complete**: Full upload/delete/optimize flow  
✅ **Shared**: One widget for all features  
✅ **Swappable**: Easy to change providers  
✅ **Tested**: Mock service for development  
✅ **Secure**: Signed uploads, env variables  
✅ **Scalable**: Supports images, docs, videos  
✅ **Organized**: Auto folder structure by feature/year  

This architecture provides a production-ready, maintainable file upload system! 🚀
