/// Stub implementation - should never be called directly
/// This file exists only to satisfy the conditional import system
void setupWebDragAndDrop({
  required Function(bool) onDragStateChanged,
  required Function(List<dynamic>) onFilesDropped,
}) {
  throw UnsupportedError('Platform-specific implementation not loaded');
}

void pickFilesMobile({required Function(List<dynamic>) onFilesSelected}) {
  throw UnsupportedError('Platform-specific implementation not loaded');
}

void pickFilesWeb({required Function(List<dynamic>) onFilesSelected}) {
  throw UnsupportedError('Platform-specific implementation not loaded');
}
