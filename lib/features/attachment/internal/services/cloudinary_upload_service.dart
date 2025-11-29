import 'dart:convert';
import 'dart:io';

import '../domain/repositories/cloudinary_repository.dart';
import 'file_upload_service.dart';

/// Cloudinary implementation of file upload service
///
/// Now uses repository pattern to communicate with backend API
/// Backend handles Cloudinary interactions, providing abstraction
class CloudinaryUploadService implements FileUploadService {
  CloudinaryUploadService({required CloudinaryRepository repository}) : _repository = repository;
  final CloudinaryRepository _repository;

  @override
  Future<String> uploadFile(String filePath, {String? folder, Map<String, dynamic>? metadata}) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw FileUploadException('File not found: $filePath');
      }

      // Read file and convert to base64
      final bytes = await file.readAsBytes();
      final base64Content = base64Encode(bytes);
      final filename = file.path.split('/').last;

      // Determine resource type from file extension
      final extension = filename.split('.').last.toLowerCase();
      final resourceType = _getResourceType(extension);

      // Upload via repository
      final result = await _repository.uploadFile(
        fileContent: base64Content,
        filename: filename,
        folder: folder,
        resourceType: resourceType,
      );

      return result.url;
    } catch (e) {
      if (e is FileUploadException) rethrow;
      throw FileUploadException('Failed to upload file', originalError: e);
    }
  }

  @override
  Future<List<String>> uploadMultipleFiles(
    List<String> filePaths, {
    String? folder,
    Map<String, dynamic>? metadata,
    void Function(int uploaded, int total)? onProgress,
  }) async {
    final urls = <String>[];

    for (var i = 0; i < filePaths.length; i++) {
      final url = await uploadFile(filePaths[i], folder: folder, metadata: metadata);
      urls.add(url);
      onProgress?.call(i + 1, filePaths.length);
    }

    return urls;
  }

  @override
  Future<bool> deleteFile(String fileUrl) async {
    try {
      final publicId = _extractPublicId(fileUrl);

      // Delete via repository
      final result = await _repository.deleteResource(publicId: publicId);

      return result;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteMultipleFiles(List<String> fileUrls) async {
    final results = await Future.wait(fileUrls.map(deleteFile));
    return results.every((success) => success);
  }

  @override
  String getOptimizedUrl(String originalUrl, {int? width, int? height, String? format, int? quality}) {
    // Extract Cloudinary URL parts
    final parts = originalUrl.split('/upload/');
    if (parts.length != 2) return originalUrl;

    final transformations = <String>[];
    if (width != null) transformations.add('w_$width');
    if (height != null) transformations.add('h_$height');
    if (format != null) transformations.add('f_$format');
    if (quality != null) transformations.add('q_$quality');

    if (transformations.isEmpty) return originalUrl;

    return '${parts[0]}/upload/${transformations.join(',')}/${parts[1]}';
  }

  String _extractPublicId(String url) {
    // Extract public_id from Cloudinary URL
    // Example: https://res.cloudinary.com/demo/image/upload/v1234/folder/image.jpg
    // Returns: folder/image

    final uri = Uri.parse(url);
    final segments = uri.pathSegments;

    // Find 'upload' segment
    final uploadIndex = segments.indexOf('upload');
    if (uploadIndex == -1 || uploadIndex >= segments.length - 1) {
      throw FileUploadException('Invalid Cloudinary URL: $url');
    }

    // Get everything after 'upload/v{version}/'
    final publicIdParts = segments.sublist(uploadIndex + 2);
    final publicId = publicIdParts.join('/');

    // Remove file extension
    final lastDotIndex = publicId.lastIndexOf('.');
    if (lastDotIndex == -1) return publicId;

    return publicId.substring(0, lastDotIndex);
  }

  /// Determine resource type from file extension
  String _getResourceType(String extension) {
    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'svg'];
    const videoExtensions = ['mp4', 'avi', 'mov', 'wmv', 'flv', 'webm'];
    const documentExtensions = ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx'];

    if (imageExtensions.contains(extension)) return 'image';
    if (videoExtensions.contains(extension)) return 'video';
    if (documentExtensions.contains(extension)) return 'raw';

    return 'auto';
  }
}
