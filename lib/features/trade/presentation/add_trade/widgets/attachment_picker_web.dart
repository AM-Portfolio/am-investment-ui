import 'dart:html' as html;

/// Setup drag and drop for web platform
void setupWebDragAndDrop({
  required Function(bool) onDragStateChanged,
  required Function(List<dynamic>) onFilesDropped,
}) {
  html.document.body?.onDragOver.listen((event) {
    event.preventDefault();
    onDragStateChanged(true);
  });

  html.document.body?.onDragLeave.listen((event) {
    // Check if we're leaving the window
    if (event.client.x == 0 && event.client.y == 0) {
      onDragStateChanged(false);
    }
  });

  html.document.body?.onDrop.listen((event) {
    event.preventDefault();
    event.stopPropagation();
    onDragStateChanged(false);

    final files = event.dataTransfer.files;
    if (files != null && files.isNotEmpty) {
      final validFiles = <html.File>[];
      for (final file in files) {
        if (_isValidFile(file.name)) {
          validFiles.add(file);
        }
      }
      if (validFiles.isNotEmpty) {
        onFilesDropped(validFiles.map((f) => f.name).toList());
      }
    }
  });
}

/// Pick files using web file input
void pickFilesWeb({required Function(List<dynamic>) onFilesSelected}) {
  final uploadInput = html.FileUploadInputElement();
  uploadInput.multiple = true;
  uploadInput.accept = 'image/*,.pdf,.doc,.docx';

  uploadInput.onChange.listen((event) {
    final files = uploadInput.files;
    if (files != null && files.isNotEmpty) {
      onFilesSelected(files.map((f) => f.name).toList());
    }
  });

  uploadInput.click();
}

/// Stub for mobile file picker (not available on web)
void pickFilesMobile({required Function(List<dynamic>) onFilesSelected}) {
  // No-op on web - use pickFilesWeb instead
}

bool _isValidFile(String filename) {
  final lower = filename.toLowerCase();
  return lower.endsWith('.png') ||
      lower.endsWith('.jpg') ||
      lower.endsWith('.jpeg') ||
      lower.endsWith('.gif') ||
      lower.endsWith('.webp') ||
      lower.endsWith('.pdf') ||
      lower.endsWith('.doc') ||
      lower.endsWith('.docx');
}
