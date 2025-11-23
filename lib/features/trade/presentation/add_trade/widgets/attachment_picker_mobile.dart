import 'package:file_picker/file_picker.dart';

/// Stub for web drag and drop (not available on mobile)
void setupWebDragAndDrop({
  required Function(bool) onDragStateChanged,
  required Function(List<dynamic>) onFilesDropped,
}) {
  // No-op on mobile
}

/// Pick files using mobile file picker
Future<void> pickFilesMobile({required Function(List<dynamic>) onFilesSelected}) async {
  try {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx', 'xls', 'xlsx'],
    );

    if (result != null && result.files.isNotEmpty) {
      // Convert PlatformFile to file names/paths
      final fileNames = result.files.map((file) => file.name).toList();
      onFilesSelected(fileNames);
    }
  } catch (e) {
    // Handle error silently or log it
    print('Error picking files: $e');
  }
}

/// Stub for web file picker (not available on mobile)
void pickFilesWeb({required Function(List<dynamic>) onFilesSelected}) {
  // No-op on mobile - use pickFilesMobile instead
}
