import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Widget for uploading and managing image attachments in journal entries
class ImageAttachmentWidget extends StatefulWidget {
  final List<String> imageUrls;
  final Function(List<String>) onImagesChanged;
  final int maxImages;

  const ImageAttachmentWidget({
    super.key,
    required this.imageUrls,
    required this.onImagesChanged,
    this.maxImages = 5,
  });

  @override
  State<ImageAttachmentWidget> createState() => _ImageAttachmentWidgetState();
}

class _ImageAttachmentWidgetState extends State<ImageAttachmentWidget> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickImage() async {
    if (widget.imageUrls.length >= widget.maxImages) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Maximum ${widget.maxImages} images allowed'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _isUploading = true;
        });

        // Upload image to server
        final imageUrl = await _uploadImage(image);

        if (imageUrl != null && mounted) {
          final updatedUrls = [...widget.imageUrls, imageUrl];
          widget.onImagesChanged(updatedUrls);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<String?> _uploadImage(XFile image) async {
    try {
      // TODO: Implement actual upload to your backend
      // For now, using local file path or base64
      
      // Example implementation:
      // final bytes = await image.readAsBytes();
      // final response = await http.post(
      //   Uri.parse('https://your-api.com/upload'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({'image': base64Encode(bytes)}),
      // );
      // if (response.statusCode == 200) {
      //   final data = jsonDecode(response.body);
      //   return data['url'];
      // }
      
      // Temporary: return the local path
      return image.path;
    } catch (e) {
      debugPrint('Upload failed: $e');
      return null;
    }
  }

  void _removeImage(int index) {
    final updatedUrls = [...widget.imageUrls];
    updatedUrls.removeAt(index);
    widget.onImagesChanged(updatedUrls);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Attachments',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(width: 8),
            Text(
              '(${widget.imageUrls.length}/${widget.maxImages})',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            // Display existing images
            ...widget.imageUrls.asMap().entries.map((entry) {
              final index = entry.key;
              final url = entry.value;
              return _ImageThumbnail(
                imageUrl: url,
                onRemove: () => _removeImage(index),
              );
            }),
            // Add image button
            if (widget.imageUrls.length < widget.maxImages)
              _AddImageButton(
                onPressed: _isUploading ? null : _pickImage,
                isUploading: _isUploading,
              ),
          ],
        ),
      ],
    );
  }
}

class _ImageThumbnail extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onRemove;

  const _ImageThumbnail({
    required this.imageUrl,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildImage(),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.close, size: 16, color: Colors.white),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
                onPressed: onRemove,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    // Check if it's a network URL
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.broken_image, color: Colors.grey),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        },
      );
    }
    
    // For local files (not supported on web)
    if (!kIsWeb) {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.broken_image, color: Colors.grey),
          );
        },
      );
    }
    
    // Fallback
    return const Center(
      child: Icon(Icons.image, color: Colors.grey),
    );
  }
}

class _AddImageButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isUploading;

  const _AddImageButton({
    required this.onPressed,
    required this.isUploading,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 1,
            style: BorderStyle.solid,
          ),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: isUploading
            ? const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add Image',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
