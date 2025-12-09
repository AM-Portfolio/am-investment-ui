# Attachment System - Quick Reference

## Import
```dart
import 'package:am_investment_ui/features/attachment/presentation/widgets/attachment_picker.dart';
```

## Basic Usage

### Auto Upload (Immediate)
```dart
AttachmentPicker(
  onAttachmentsChanged: (urls) => print('Uploaded: $urls'),
  featureName: 'journal',
)
```

### Manual Upload (Deferred)
```dart
final pickerKey = GlobalKey<AttachmentPickerMobileState>();

AttachmentPicker(
  key: pickerKey,
  autoUpload: false,
  onAttachmentsChanged: (urls) => print('Uploaded: $urls'),
  onPendingAttachmentsChanged: (pending) => print('Pending: ${pending.length}'),
  featureName: 'journal',
)

// Later: Upload when ready
await pickerKey.currentState?.uploadPendingFiles();
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `onAttachmentsChanged` | `Function(List<String>)` | ✅ | - | Callback with uploaded URLs |
| `featureName` | `String` | ✅ | - | Feature name for folders |
| `initialUrls` | `List<String>` | ❌ | `[]` | Existing URLs |
| `onPendingAttachmentsChanged` | `Function(List<PendingAttachment>)?` | ❌ | `null` | Callback for pending files |
| `userId` | `String?` | ❌ | `null` | User ID metadata |
| `maxAttachments` | `int` | ❌ | `5` | Max file count |
| `allowedType` | `AttachmentType` | ❌ | `image` | File type filter |
| `showPreview` | `bool` | ❌ | `true` | Show thumbnails |
| `label` | `String?` | ❌ | `null` | Custom label |
| `autoUpload` | `bool` | ❌ | `true` | Upload immediately |

## Attachment Types
```dart
AttachmentType.image    // JPG, PNG, GIF, WebP, BMP, SVG
AttachmentType.document // PDF, DOC, DOCX, XLS, XLSX
AttachmentType.video    // MP4, AVI, MOV, WebM
AttachmentType.any      // All types
```

## Platform Features

| Feature | Mobile | Web |
|---------|--------|-----|
| Gallery Picker | ✅ | ❌ |
| File Picker | ✅ | ✅ |
| Drag & Drop | ❌ | ✅ |
| Local Preview | ✅ (File path) | ✅ (Blob URL) |

## Common Patterns

### Form Integration
```dart
class MyForm extends StatefulWidget {
  @override
  State<MyForm> createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final _pickerKey = GlobalKey();
  List<String> _attachmentUrls = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AttachmentPicker(
          key: _pickerKey,
          autoUpload: false,
          onAttachmentsChanged: (urls) => _attachmentUrls = urls,
          featureName: 'journal',
        ),
        ElevatedButton(
          onPressed: _save,
          child: Text('Save'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    // Upload pending files first
    await _pickerKey.currentState?.uploadPendingFiles();
    // Then save form with _attachmentUrls
  }
}
```

### Multiple Pickers
```dart
Column(
  children: [
    AttachmentPicker(
      label: 'Screenshots',
      allowedType: AttachmentType.image,
      onAttachmentsChanged: (urls) => _screenshots = urls,
      featureName: 'trade',
    ),
    AttachmentPicker(
      label: 'Documents',
      allowedType: AttachmentType.document,
      onAttachmentsChanged: (urls) => _documents = urls,
      featureName: 'trade',
    ),
  ],
)
```

## Configuration

### Upload Folders
Edit `lib/config/upload_config.dart`:
```dart
static const Map<String, String> folders = {
  'journal': 'journal-attachments',
  'portfolio': 'portfolio-documents',
  'trade': 'trade-screenshots',
  'myfeature': 'my-custom-folder', // Add your feature
};
```

### File Size Limits
```dart
static const int maxImageSizeMB = 10;
static const int maxDocumentSizeMB = 50;
static const int maxVideoSizeMB = 100;
```

## API Endpoints Used
```
POST   /api/v1/resources/upload
DELETE /api/v1/resources/:publicId
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Files not uploading | Set `autoUpload: true` or call `uploadPendingFiles()` |
| Drag-drop not working | Only works on web platform |
| Preview broken | Check file paths (mobile) or blob URLs (web) |
| Backend errors | Verify API is running and CORS configured |

## Migration from Old Widget

```dart
// OLD
import 'package:am_investment_ui/core/widgets/attachments/attachment_picker_widget.dart';

AttachmentPickerWidget(
  attachmentUrls: _urls,
  onAttachmentsChanged: (urls) => setState(() => _urls = urls),
  featureName: 'journal',
)

// NEW
import 'package:am_investment_ui/features/attachment/presentation/widgets/attachment_picker.dart';

AttachmentPicker(
  initialUrls: _urls,
  onAttachmentsChanged: (urls) => setState(() => _urls = urls),
  featureName: 'journal',
  autoUpload: true, // Keep same behavior
)
```

## Architecture
```
features/attachment/
├── presentation/
│   ├── widgets/
│   │   ├── attachment_picker.dart         ← Use this
│   │   ├── mobile/attachment_picker_mobile.dart
│   │   └── web/attachment_picker_web.dart
│   └── models/pending_attachment.dart
├── internal/
│   ├── services/
│   │   ├── file_upload_service.dart       ← Service interface
│   │   └── cloudinary_upload_service.dart
│   └── data/... (DTOs, Mappers, DataSources)
└── attachment_providers.dart              ← Riverpod DI
```
