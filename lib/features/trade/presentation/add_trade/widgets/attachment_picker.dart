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
    // In a real app, you would upload these files and get URLs
    // For now, we'll just add placeholder names
    final newAttachments = List<String>.from(widget.attachments);
    for (final file in files) {
      newAttachments.add(file.toString());
    }
    widget.onAttachmentsChanged(newAttachments);
  }

  Future<void> _addAttachment(BuildContext context) async {
    if (kIsWeb) {
      pickFilesWeb(onFilesSelected: _handleFiles);
    } else {
      pickFilesMobile(onFilesSelected: _handleFiles);
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.attach_file, size: 18, color: theme.colorScheme.onPrimaryContainer),
            ),
            const SizedBox(width: 10),
            Text('Attachments', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const Spacer(),
            FilledButton.tonalIcon(
              onPressed: () => _addAttachment(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add File'),
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
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
              ? Column(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        _isDragging ? Icons.cloud_download : Icons.cloud_upload_outlined,
                        key: ValueKey(_isDragging),
                        size: 56,
                        color: _isDragging ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isDragging
                          ? 'Drop files here'
                          : kIsWeb
                          ? 'Drag & drop files here'
                          : 'Tap to add files',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: _isDragging ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      kIsWeb ? 'or click "Add File" button' : 'or use "Add File" button above',
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Supports: Images, PDFs, Word documents',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.4)),
                    ),
                  ],
                )
              : Wrap(
                  spacing: 12,
                  runSpacing: 12,
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

    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: fileColor.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
            child: Icon(_getFileIcon(), size: 18, color: fileColor),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              filename,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.close, size: 16, color: theme.colorScheme.onSecondaryContainer.withOpacity(0.7)),
            ),
          ),
        ],
      ),
    );
  }
}
