import 'package:flutter/material.dart';

/// Attachment picker for trade screenshots, documents, etc.
class AttachmentPicker extends StatelessWidget {
  const AttachmentPicker({required this.attachments, required this.onAttachmentsChanged, super.key});
  final List<String> attachments;
  final ValueChanged<List<String>> onAttachmentsChanged;

  void _addAttachment(BuildContext context) {
    // TODO: Implement file picker integration
    // For now, show a placeholder
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File picker will be integrated here')));
  }

  void _removeAttachment(int index) {
    final newList = List<String>.from(attachments);
    newList.removeAt(index);
    onAttachmentsChanged(newList);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.attach_file, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text('Attachments', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _addAttachment(context),
              icon: const Icon(Icons.add),
              label: const Text('Add File'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
          ),
          child: attachments.isEmpty
              ? Column(
                  children: [
                    Icon(Icons.cloud_upload_outlined, size: 48, color: theme.colorScheme.onSurface.withOpacity(0.3)),
                    const SizedBox(height: 8),
                    Text(
                      'No attachments added',
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add screenshots, PDFs, or other documents',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.4)),
                    ),
                  ],
                )
              : Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: attachments
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
    if (filename.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (filename.endsWith('.png') || filename.endsWith('.jpg') || filename.endsWith('.jpeg')) {
      return Icons.image;
    }
    return Icons.insert_drive_file;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: theme.colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getFileIcon(), size: 20, color: theme.colorScheme.onSecondaryContainer),
          const SizedBox(width: 8),
          Text(filename, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSecondaryContainer)),
          const SizedBox(width: 8),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(12),
            child: Icon(Icons.close, size: 16, color: theme.colorScheme.onSecondaryContainer),
          ),
        ],
      ),
    );
  }
}
