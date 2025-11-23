import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

// Conditional import for platform-specific file picking
import 'attachment_picker_stub.dart'
    if (dart.library.html) 'attachment_picker_web.dart'
    if (dart.library.io) 'attachment_picker_mobile.dart';

/// Attachment picker with drag-and-drop support (web) and file picker (mobile)
class AttachmentPicker extends StatefulWidget {
  const AttachmentPicker({required this.attachments, required this.onAttachmentsChanged, super.key});
  final List<String> attachments;
  final ValueChanged<List<String>> onAttachmentsChanged;

  @override
  State<AttachmentPicker> createState() => _AttachmentPickerState();
}

class _AttachmentPickerState extends State<AttachmentPicker> {
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setupWebDragAndDrop(
          onDragStateChanged: (isDragging) {
            if (mounted) {
              setState(() => _isDragging = isDragging);
            }
          },
          onFilesDropped: _handleFiles,
        );
      });
    }
  }

  void _handleFiles(List<dynamic> files) {
    if (files.isEmpty) return;

    // In a real app, you would upload these files and get URLs
    // For now, we'll just add placeholder names
    final newAttachments = List<String>.from(widget.attachments);
    for (final file in files) {
      newAttachments.add(file.toString());
    }
    widget.onAttachmentsChanged(newAttachments);

    // Show success feedback on mobile
    if (!kIsWeb && mounted) {
      // Use a delayed callback to ensure the widget is still mounted after picker closes
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text('${files.length} file(s) attached'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
      });
    }
  }

  Future<void> _addAttachment(BuildContext context) async {
    try {
      if (kIsWeb) {
        pickFilesWeb(onFilesSelected: _handleFiles);
      } else {
        // Call the mobile picker (it handles the callback internally)
        pickFilesMobile(onFilesSelected: _handleFiles);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting files: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _removeAttachment(int index) {
    final newList = List<String>.from(widget.attachments);
    newList.removeAt(index);
    widget.onAttachmentsChanged(newList);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.attach_file_rounded, size: 18, color: theme.colorScheme.onSecondaryContainer),
            ),
            const SizedBox(width: 10),
            Text('Attachments', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const Spacer(),
            FilledButton.icon(
              onPressed: () => _addAttachment(context),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(isMobile ? 'Add' : 'Add File'),
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: 8),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: BoxDecoration(
            color: _isDragging
                ? theme.colorScheme.primaryContainer.withOpacity(0.2)
                : theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isDragging ? theme.colorScheme.primary : theme.colorScheme.outline.withOpacity(0.2),
              width: _isDragging ? 2 : 1,
            ),
          ),
          child: widget.attachments.isEmpty
              ? InkWell(
                  onTap: isMobile ? () => _addAttachment(context) : null,
                  borderRadius: BorderRadius.circular(8),
                  child: Column(
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          _isDragging
                              ? Icons.cloud_download_rounded
                              : isMobile
                              ? Icons.add_photo_alternate_outlined
                              : Icons.cloud_upload_outlined,
                          key: ValueKey(_isDragging),
                          size: isMobile ? 48 : 56,
                          color: _isDragging ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.3),
                        ),
                      ),
                      SizedBox(height: isMobile ? 8 : 12),
                      Text(
                        _isDragging
                            ? 'Drop files here'
                            : isMobile
                            ? 'Tap to add files'
                            : 'Drag & drop files here',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: _isDragging ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                          fontSize: isMobile ? 14 : 16,
                        ),
                      ),
                      SizedBox(height: isMobile ? 4 : 6),
                      if (!isMobile)
                        Text(
                          'or click "Add File" button',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      SizedBox(height: isMobile ? 2 : 4),
                      Text(
                        isMobile ? 'Images, PDFs, Documents' : 'Supports: Images, PDFs, Word documents',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                          fontSize: isMobile ? 11 : 12,
                        ),
                      ),
                    ],
                  ),
                )
              : Wrap(
                  spacing: isMobile ? 8 : 12,
                  runSpacing: isMobile ? 8 : 12,
                  children: widget.attachments
                      .asMap()
                      .entries
                      .map(
                        (entry) => _AttachmentTile(filename: entry.value, onRemove: () => _removeAttachment(entry.key)),
                      )
                      .toList(),
                ),
        ),
      ],
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  const _AttachmentTile({required this.filename, required this.onRemove});
  final String filename;
  final VoidCallback onRemove;

  IconData _getFileIcon() {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (lower.endsWith('.png') || lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return Icons.image;
    }
    if (lower.endsWith('.doc') || lower.endsWith('.docx')) {
      return Icons.description;
    }
    return Icons.insert_drive_file;
  }

  Color _getFileColor(BuildContext context) {
    final theme = Theme.of(context);
    final lower = filename.toLowerCase();
    if (lower.endsWith('.pdf')) return Colors.red.shade400;
    if (lower.endsWith('.png') || lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return Colors.blue.shade400;
    }
    if (lower.endsWith('.doc') || lower.endsWith('.docx')) {
      return Colors.indigo.shade400;
    }
    return theme.colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fileColor = _getFileColor(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 280),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 12, vertical: isMobile ? 8 : 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: fileColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: Icon(_getFileIcon(), size: 20, color: fileColor),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              filename,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
                fontSize: isMobile ? 13 : 14,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close_rounded, size: 16, color: theme.colorScheme.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
