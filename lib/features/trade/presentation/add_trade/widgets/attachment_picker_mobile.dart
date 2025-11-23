/// Stub for web drag and drop (not available on mobile)
void setupWebDragAndDrop({
  required Function(bool) onDragStateChanged,
  required Function(List<dynamic>) onFilesDropped,
}) {
  // No-op on mobile
}

/// Pick files using mobile file picker
/// Note: In a real implementation, you would use file_picker package
/// For now, this is a stub that does nothing
void pickFilesMobile({required Function(List<dynamic>) onFilesSelected}) {
  // Stub - would use file_picker package in real implementation
  // Example: FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.custom, allowedExtensions: ['jpg', 'png', 'pdf', 'doc', 'docx']);
  // For now, do nothing (this prevents runtime errors on mobile)
}

/// Stub for web file picker (not available on mobile)
void pickFilesWeb({required Function(List<dynamic>) onFilesSelected}) {
  // No-op on mobile - use pickFilesMobile instead
}
