import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

/// File upload state management
class FileUploadState {
  const FileUploadState({
    this.selectedFiles,
    this.isDragOver = false,
    this.isUploading = false,
  });
  final List<PlatformFile>? selectedFiles;
  final bool isDragOver;
  final bool isUploading;

  FileUploadState copyWith({
    List<PlatformFile>? selectedFiles,
    bool? isDragOver,
    bool? isUploading,
  }) => FileUploadState(
    selectedFiles: selectedFiles ?? this.selectedFiles,
    isDragOver: isDragOver ?? this.isDragOver,
    isUploading: isUploading ?? this.isUploading,
  );

  bool get hasFiles => selectedFiles != null && selectedFiles!.isNotEmpty;
}

/// Callbacks for file upload operations
class FileUploadCallbacks {
  const FileUploadCallbacks({
    this.onPickFiles,
    this.onRemoveFile,
    this.onUploadFiles,
    this.onDropFiles,
    this.onShowError,
    this.onShowSuccess,
  });
  final VoidCallback? onPickFiles;
  final Function(PlatformFile)? onRemoveFile;
  final VoidCallback? onUploadFiles;
  final Function(List<String>)? onDropFiles;
  final Function(String)? onShowError;
  final Function(String)? onShowSuccess;
}
