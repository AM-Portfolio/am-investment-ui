# Attachment System - Complete Guide

## Overview
The attachment system provides a complete file upload solution with platform-specific implementations:
- **Mobile**: Gallery picker + File picker
- **Web**: Drag & drop + File picker
- **Both**: Deferred upload control (caller decides when to upload)

## Architecture

```
lib/features/attachment/
├── attachment_providers.dart                      # Riverpod providers
├── internal/
│   ├── data/
│   │   ├── datasources/
│   │   │   └── cloudinary_remote_data_source.dart # Backend API calls
│   │   ├── dtos/
│   │   │   └── cloudinary_dto.dart                # Data transfer objects
│   │   ├── mappers/
│   │   │   └── cloudinary_mapper.dart             # DTO ↔ Entity conversion
│   │   └── repositories/
│   │       └── cloudinary_repository_impl.dart    # Repository implementation
│   ├── domain/
│   │   ├── entities/
│   │   │   └── cloudinary_resource.dart           # Domain entities
│   │   └── repositories/
│   │       └── cloudinary_repository.dart         # Repository interface
│   └── services/
│       ├── file_upload_service.dart               # Service interface
│       └── cloudinary_upload_service.dart         # Service implementation
└── presentation/
    ├── models/
    │   └── pending_attachment.dart                # Pending file model
    └── widgets/
        ├── attachment_picker.dart                 # Platform-aware factory
        ├── mobile/
        │   └── attachment_picker_mobile.dart      # Mobile implementation
        ├── web/
        │   └── attachment_picker_web.dart         # Web with drag-drop
        └── shared/
            └── attachment_preview_grid.dart       # Shared preview UI
```

## Key Features

### 1. **Platform-Specific UI**
- **Mobile**: ImagePicker (gallery) + FilePicker (documents)
- **Web**: Drag-and-drop zone + FilePicker

### 2. **Deferred Upload Control**
- `autoUpload: true` - Upload immediately after file selection (default)
- `autoUpload: false` - Store files locally, caller controls upload timing

### 3. **Clean Architecture**
- Data layer: DTOs, Mappers, RemoteDataSource, Repository
- Domain layer: Entities, Repository interface
- Service layer: FileUploadService interface, Cloudinary implementation
- Presentation layer: Mobile/Web widgets with shared components

## Usage

### Basic Usage (Auto Upload)

```dart
import 'package:am_investment_ui/features/attachment/presentation/widgets/attachment_picker.dart';

AttachmentPicker(
  onAttachmentsChanged: (urls) {
    print('Uploaded URLs: $urls');
    // Save URLs to your model
  },
  featureName: 'journal',
  userId: currentUserId,
  allowedType: AttachmentType.image,
  maxAttachments: 5,
  autoUpload: true, // Default: upload immediately
)
```

### Deferred Upload (Manual Control)

```dart
final GlobalKey<AttachmentPickerState> pickerKey = GlobalKey();

AttachmentPicker(
  key: pickerKey,
  autoUpload: false, // Don't upload yet
  onAttachmentsChanged: (urls) {
    print('Uploaded URLs: $urls');
  },
  onPendingAttachmentsChanged: (pending) {
    print('Pending files: ${pending.length}');
    // Enable "Save" button when files are ready
  },
  featureName: 'journal',
)

// Later, when user confirms (e.g., clicks "Save")
ElevatedButton(
  onPressed: () async {
    // Upload all pending files
    await pickerKey.currentState?.uploadPendingFiles();
    // Then save your form
  },
  child: Text('Save'),
)
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `initialUrls` | `List<String>` | `[]` | Pre-existing uploaded URLs |
| `onAttachmentsChanged` | `Function(List<String>)` | Required | Called with uploaded URLs |
| `onPendingAttachmentsChanged` | `Function(List<PendingAttachment>)?` | `null` | Called when pending files change |
| `featureName` | `String` | Required | Feature name for folder organization |
| `userId` | `String?` | `null` | User ID for metadata |
| `maxAttachments` | `int` | `5` | Maximum number of attachments |
| `allowedType` | `AttachmentType` | `image` | File type restriction |
| `showPreview` | `bool` | `true` | Show preview thumbnails |
| `label` | `String?` | `null` | Custom label text |
| `autoUpload` | `bool` | `true` | Upload immediately or defer |

### Attachment Types

```dart
enum AttachmentType {
  image,    // JPG, PNG, GIF, WebP, BMP, SVG
  document, // PDF, DOC, DOCX, XLS, XLSX
  video,    // MP4, AVI, MOV, WebM
  any,      // All types
}
```

## Platform Behavior

### Mobile (iOS/Android)
- **Gallery Button**: Opens ImagePicker with camera roll
- **Browse Button**: Opens FilePicker based on `allowedType`
- **File Preview**: Uses local file paths
- **Pending Files**: Stored with file paths

### Web
- **Drag & Drop Zone**: Visual feedback on hover
- **Click to Browse**: Falls back to FilePicker
- **File Preview**: Uses Blob URLs for local files
- **Pending Files**: Stored with byte arrays

## Models

### PendingAttachment
```dart
class PendingAttachment {
  final String fileName;
  final String? filePath;      // Mobile: File path
  final Uint8List? fileBytes;  // Web: File bytes
  final String? previewUrl;    // Local preview URL
  
  String get extension;
  bool get isImage;
  bool get isVideo;
  bool get isDocument;
}
```

### AttachmentItem
```dart
class AttachmentItem {
  final PendingAttachment? pendingAttachment;
  final String? uploadedUrl;
  final bool isUploaded;
  
  String get displayName;
  String? get previewUrl;
  
  AttachmentItem.pending(PendingAttachment);
  AttachmentItem.uploaded(String url);
}
```

## Backend Integration

The system uses your backend API (not direct Cloudinary):

```
POST   /api/v1/resources/upload          - Upload file
GET    /api/v1/resources/:publicId       - Get resource
GET    /api/v1/resources                 - List resources
DELETE /api/v1/resources/:publicId       - Delete resource
POST   /api/v1/resources/signature       - Get upload signature
```

### API Flow
1. Widget picks file
2. If `autoUpload: true`, immediately calls `/api/v1/resources/upload`
3. If `autoUpload: false`, stores file locally
4. When `uploadPendingFiles()` called, uploads to backend
5. Backend handles Cloudinary upload and returns URL

## Configuration

### Upload Config (`lib/config/upload_config.dart`)

```dart
class UploadConfig {
  // File size limits
  static const int maxImageSizeMB = 10;
  static const int maxDocumentSizeMB = 50;
  static const int maxVideoSizeMB = 100;
  
  // Folder organization
  static const Map<String, String> folders = {
    'journal': 'journal-attachments',
    'portfolio': 'portfolio-documents',
    'trade': 'trade-screenshots',
  };
  
  static String getFolderForFeature(String feature);
}
```

## Advanced Examples

### Custom Validation Before Upload

```dart
AttachmentPicker(
  autoUpload: false,
  onPendingAttachmentsChanged: (pending) {
    // Validate files before upload
    final oversized = pending.where((p) {
      // Custom validation logic
      return false; // or true if oversized
    });
    
    if (oversized.isNotEmpty) {
      showError('Some files are too large');
    }
  },
  featureName: 'portfolio',
)
```

### Batch Upload with Progress

```dart
class MyFormWidget extends StatefulWidget {
  @override
  State<MyFormWidget> createState() => _MyFormWidgetState();
}

class _MyFormWidgetState extends State<MyFormWidget> {
  final _pickerKey = GlobalKey<AttachmentPickerMobileState>();
  bool _isUploading = false;

  Future<void> _saveForm() async {
    setState(() => _isUploading = true);
    
    try {
      // Upload all pending files
      await _pickerKey.currentState?.uploadPendingFiles();
      
      // Save form data
      await saveFormData();
      
      Navigator.pop(context);
    } catch (e) {
      showError('Failed: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AttachmentPicker(
          key: _pickerKey,
          autoUpload: false,
          featureName: 'journal',
        ),
        ElevatedButton(
          onPressed: _isUploading ? null : _saveForm,
          child: _isUploading 
            ? CircularProgressIndicator() 
            : Text('Save'),
        ),
      ],
    );
  }
}
```

## Dependency Injection

Providers are configured in `attachment_providers.dart`:

```dart
final fileUploadServiceProvider = Provider<FileUploadService>((ref) {
  final repository = ref.read(cloudinaryRepositoryProvider);
  return CloudinaryUploadService(repository);
});
```

To use in widgets:
```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadService = ref.read(fileUploadServiceProvider);
    // Use service
  }
}
```

## Migration from Old Widget

**Before:**
```dart
import 'package:am_investment_ui/core/widgets/attachments/attachment_picker_widget.dart';

AttachmentPickerWidget(
  attachmentUrls: _imageUrls,
  onAttachmentsChanged: (urls) => setState(() => _imageUrls = urls),
  featureName: 'journal',
)
```

**After:**
```dart
import 'package:am_investment_ui/features/attachment/presentation/widgets/attachment_picker.dart';

AttachmentPicker(
  initialUrls: _imageUrls,
  onAttachmentsChanged: (urls) => setState(() => _imageUrls = urls),
  featureName: 'journal',
  autoUpload: true, // Add this for same behavior
)
```

## Troubleshooting

### Issue: Files not uploading
**Solution**: Check `autoUpload` parameter. If `false`, call `uploadPendingFiles()` manually.

### Issue: Drag-drop not working on web
**Solution**: Ensure you're testing in a web browser. Drag-drop only works on web platform.

### Issue: Preview showing broken images
**Solution**: For pending files, ensure blob URLs are created on web or file paths exist on mobile.

### Issue: Backend API errors
**Solution**: Check backend API is running and CORS is configured for web uploads.

## Best Practices

1. **Use `autoUpload: false` for forms** - Let users review before uploading
2. **Show pending count** - Display how many files will be uploaded
3. **Validate early** - Check file types/sizes in `onPendingAttachmentsChanged`
4. **Handle errors gracefully** - Show user-friendly messages on upload failure
5. **Clean up URLs** - Revoke blob URLs on web when removing pending files
6. **Limit attachments** - Set reasonable `maxAttachments` based on context
7. **Use feature names** - Organize uploads by feature for better storage management

## Testing

### Test Auto Upload
```dart
testWidgets('uploads file immediately', (tester) async {
  final urls = <String>[];
  
  await tester.pumpWidget(
    AttachmentPicker(
      autoUpload: true,
      onAttachmentsChanged: (u) => urls.addAll(u),
      featureName: 'test',
    ),
  );
  
  // Simulate file pick
  // Verify upload happened
  expect(urls.length, 1);
});
```

### Test Deferred Upload
```dart
testWidgets('defers upload until called', (tester) async {
  final pending = <PendingAttachment>[];
  
  await tester.pumpWidget(
    AttachmentPicker(
      autoUpload: false,
      onPendingAttachmentsChanged: (p) => pending.addAll(p),
      featureName: 'test',
    ),
  );
  
  // Simulate file pick
  expect(pending.length, 1);
  
  // Call uploadPendingFiles()
  // Verify upload happened
});
```

## Related Files

- Feature providers: `lib/features/attachment/attachment_providers.dart`
- Upload config: `lib/config/upload_config.dart`
- Service interface: `lib/features/attachment/internal/services/file_upload_service.dart`
- Repository: `lib/features/attachment/internal/domain/repositories/cloudinary_repository.dart`
