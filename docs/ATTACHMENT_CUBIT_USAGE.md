# Attachment Cubit Usage Guide

## Overview
The attachment feature now includes a Cubit for state management, allowing you to extract business logic from widgets and follow clean architecture patterns.

## Architecture Layers

### 1. Domain Layer - Use Cases
Located in `lib/features/attachment/internal/domain/usecases/`

```dart
// Upload single file
UploadFileUseCase(repository).call(
  filePath: '/path/to/file',
  folder: 'journal-attachments/2024',
  metadata: {'feature': 'journal'},
);

// Upload batch files
UploadBatchFilesUseCase(repository).call(
  filePaths: ['/path/1', '/path/2'],
  folder: 'journal-attachments/2024',
  onProgress: (current, total) => print('$current/$total'),
);

// Delete file
DeleteFileUseCase(repository).call(publicId: 'folder/filename');

// Get resource info
GetResourceUseCase(repository).call(publicId: 'folder/filename');

// List resources
ListResourcesUseCase(repository).call(folder: 'journal-attachments');
```

### 2. Presentation Layer - Cubit
Located in `lib/features/attachment/internal/presentation/cubits/`

#### AttachmentState
```dart
@freezed
class AttachmentState with _$AttachmentState {
  const factory AttachmentState.initial() = _Initial;
  const factory AttachmentState.loading() = _Loading;
  const factory AttachmentState.uploading({
    required int currentFile,
    required int totalFiles,
    required double progress,
  }) = _Uploading;
  const factory AttachmentState.uploaded({
    required List<String> urls,
    required List<PendingAttachment> pending,
  }) = _Uploaded;
  const factory AttachmentState.error({
    required String message,
    List<String>? uploadedUrls,
    List<PendingAttachment>? pending,
  }) = _Error;
}
```

#### AttachmentCubit Methods
```dart
class AttachmentCubit extends Cubit<AttachmentState> {
  // Add pending attachment (not uploaded yet)
  void addPending(PendingAttachment attachment);
  
  // Add multiple pending attachments
  void addPendingBatch(List<PendingAttachment> attachments);
  
  // Remove pending attachment
  void removePending(PendingAttachment attachment);
  
  // Upload single file
  Future<void> uploadSingleFile({
    required PendingAttachment attachment,
    required String featureName,
    String? userId,
  });
  
  // Upload all pending files
  Future<void> uploadPendingFiles({
    required String featureName,
    String? userId,
  });
  
  // Delete uploaded file
  Future<void> deleteFile(String url);
  
  // Initialize with existing URLs
  void initializeWithUrls(List<String> urls);
  
  // Reset state
  void reset();
}
```

## Usage Examples

### Example 1: Widget with Cubit (Recommended)

```dart
class JournalFormWithCubit extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attachmentCubit = ref.watch(attachmentCubitProvider);
    final attachmentState = ref.watch(attachmentCubitProvider);

    return Column(
      children: [
        // Listen to state changes
        ref.listen<AttachmentState>(
          attachmentCubitProvider.select((cubit) => cubit.state),
          (previous, next) {
            next.maybeWhen(
              uploaded: (urls, pending) {
                print('Uploaded: $urls');
                print('Pending: ${pending.length}');
              },
              error: (message, _, __) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message)),
                );
              },
              orElse: () {},
            );
          },
        ),
        
        // Pick file button
        ElevatedButton(
          onPressed: () async {
            final file = await pickFile();
            if (file != null) {
              final pending = PendingAttachment(
                fileName: file.name,
                filePath: file.path,
              );
              
              // Add to pending list
              attachmentCubit.addPending(pending);
            }
          },
          child: Text('Pick File'),
        ),
        
        // Upload all pending files
        ElevatedButton(
          onPressed: () {
            attachmentCubit.uploadPendingFiles(
              featureName: 'journal',
              userId: currentUserId,
            );
          },
          child: Text('Upload All'),
        ),
        
        // Show state
        attachmentState.when(
          initial: () => Text('No files'),
          loading: () => CircularProgressIndicator(),
          uploading: (current, total, progress) => Column(
            children: [
              LinearProgressIndicator(value: progress),
              Text('Uploading $current/$total'),
            ],
          ),
          uploaded: (urls, pending) => Column(
            children: [
              Text('Uploaded: ${urls.length}'),
              Text('Pending: ${pending.length}'),
            ],
          ),
          error: (message, urls, pending) => Text('Error: $message'),
        ),
      ],
    );
  }
}
```

### Example 2: Using Cubit with Existing Widget

```dart
class JournalFormWithAttachmentPicker extends ConsumerStatefulWidget {
  @override
  ConsumerState createState() => _JournalFormState();
}

class _JournalFormState extends ConsumerState {
  @override
  void initState() {
    super.initState();
    
    // Initialize cubit with existing URLs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = ref.read(attachmentCubitProvider);
      cubit.initializeWithUrls(widget.initialUrls);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cubit = ref.read(attachmentCubitProvider);
    final state = ref.watch(attachmentCubitProvider);
    
    return Column(
      children: [
        // Use existing AttachmentPicker widget
        AttachmentPicker(
          autoUpload: false,
          onPendingAttachmentsChanged: (pending) {
            // Sync pending with cubit
            cubit.addPendingBatch(pending);
          },
          onAttachmentsChanged: (urls) {
            // Update cubit with uploaded URLs
            cubit.initializeWithUrls(urls);
          },
          featureName: 'journal',
        ),
        
        // Save button
        ElevatedButton(
          onPressed: () async {
            // Upload all pending files before saving
            await cubit.uploadPendingFiles(
              featureName: 'journal',
              userId: currentUserId,
            );
            
            // Get uploaded URLs from cubit
            final urls = cubit.uploadedUrls;
            
            // Save journal entry with URLs
            await saveJournalEntry(urls: urls);
          },
          child: Text('Save'),
        ),
        
        // Show upload progress
        state.maybeWhen(
          uploading: (current, total, progress) => Column(
            children: [
              LinearProgressIndicator(value: progress),
              Text('Uploading file $current of $total'),
            ],
          ),
          orElse: () => SizedBox.shrink(),
        ),
      ],
    );
  }
}
```

### Example 3: Direct Use Case Usage (Without Cubit)

```dart
class SimpleUploadService {
  final UploadFileUseCase uploadFileUseCase;
  final DeleteFileUseCase deleteFileUseCase;
  
  SimpleUploadService({
    required this.uploadFileUseCase,
    required this.deleteFileUseCase,
  });
  
  Future<String> uploadJournalImage(String filePath) async {
    final result = await uploadFileUseCase.call(
      filePath: filePath,
      folder: 'journal-attachments/${DateTime.now().year}',
      metadata: {
        'feature': 'journal',
        'uploadedAt': DateTime.now().toIso8601String(),
      },
    );
    
    return result.secureUrl;
  }
  
  Future<void> deleteImage(String url) async {
    final publicId = _extractPublicId(url);
    await deleteFileUseCase.call(publicId: publicId);
  }
}

// Provider
final simpleUploadServiceProvider = Provider((ref) {
  return SimpleUploadService(
    uploadFileUseCase: ref.read(uploadFileUseCaseProvider),
    deleteFileUseCase: ref.read(deleteFileUseCaseProvider),
  );
});
```

## When to Use Cubit vs Direct Widget

### Use Cubit When:
- ✅ You need centralized state management across multiple widgets
- ✅ Complex upload logic with batch operations
- ✅ Need to track upload progress globally
- ✅ Want separation of business logic from UI
- ✅ Building features like file managers or galleries
- ✅ Need to persist attachment state across navigation

### Use Direct Widget When:
- ✅ Simple file upload in a form
- ✅ Single file upload scenarios
- ✅ Self-contained components
- ✅ Quick prototypes
- ✅ No need for state sharing

## Providers Available

```dart
// Use Case Providers
uploadFileUseCaseProvider          // Single file upload
uploadBatchFilesUseCaseProvider    // Batch file upload
deleteFileUseCaseProvider          // Delete file
getResourceUseCaseProvider         // Get resource info
listResourcesUseCaseProvider       // List resources

// Cubit Provider
attachmentCubitProvider            // Main cubit (auto-dispose)

// Service Provider (backward compatibility)
fileUploadServiceProvider          // FileUploadService interface
```

## State Management Pattern

### 1. Add Pending Files
```dart
final cubit = ref.read(attachmentCubitProvider);
cubit.addPending(PendingAttachment(...));
```

### 2. Upload When Ready
```dart
await cubit.uploadPendingFiles(
  featureName: 'journal',
  userId: userId,
);
```

### 3. Access Uploaded URLs
```dart
final urls = cubit.uploadedUrls;
```

### 4. Handle States
```dart
state.when(
  initial: () => ...,
  loading: () => ...,
  uploading: (current, total, progress) => ...,
  uploaded: (urls, pending) => ...,
  error: (message, urls, pending) => ...,
);
```

## Migration Path

### Step 1: Keep existing widget-based code
Your current `AttachmentPicker` widget still works as before.

### Step 2: Gradually introduce cubit
Add cubit to new features or complex scenarios.

### Step 3: Sync widget with cubit
Use callbacks to keep cubit updated with widget state.

### Step 4: Full cubit adoption (optional)
Replace direct widget usage with cubit-managed state.

## Best Practices

1. **Auto-dispose Cubit**: Use `Provider.autoDispose` to prevent memory leaks
2. **Single Responsibility**: One cubit per feature (journal, portfolio, etc.)
3. **Error Handling**: Always handle error state in UI
4. **Progress Feedback**: Show upload progress for better UX
5. **Validation**: Validate files before adding to pending list
6. **Clean URLs**: Extract public IDs correctly for deletion

## Testing

```dart
test('cubit uploads pending files', () async {
  final mockRepository = MockCloudinaryRepository();
  final uploadUseCase = UploadFileUseCase(mockRepository);
  final batchUseCase = UploadBatchFilesUseCase(mockRepository);
  final deleteUseCase = DeleteFileUseCase(mockRepository);
  
  final cubit = AttachmentCubit(
    uploadFileUseCase: uploadUseCase,
    uploadBatchFilesUseCase: batchUseCase,
    deleteFileUseCase: deleteUseCase,
  );
  
  cubit.addPending(PendingAttachment(
    fileName: 'test.jpg',
    filePath: '/path/to/test.jpg',
  ));
  
  await cubit.uploadPendingFiles(featureName: 'journal');
  
  expect(cubit.uploadedUrls.length, 1);
  expect(cubit.pendingAttachments.length, 0);
});
```

## Summary

The attachment system now supports both approaches:
1. **Simple Widget-Based**: Use `AttachmentPicker` for straightforward scenarios
2. **Cubit-Based**: Use `AttachmentCubit` for complex state management

Choose the approach that best fits your needs!
