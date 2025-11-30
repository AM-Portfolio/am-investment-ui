import 'package:flutter/material.dart';

import '../components/journal_form_header.dart';
import '../widgets/url_preview_widget.dart';

/// Section containing optional fields like date, trade ID, and URL
class OptionalFieldsSection extends StatelessWidget {
  const OptionalFieldsSection({
    required this.entryDate,
    required this.tradeIdController,
    required this.urlController,
    required this.isEditMode,
    required this.isUrlExpanded,
    required this.urlPreview,
    required this.onDateSelect,
    required this.onToggleUrlExpansion,
    required this.onClearUrl,
    super.key,
  });

  final DateTime entryDate;
  final TextEditingController tradeIdController;
  final TextEditingController urlController;
  final bool isEditMode;
  final bool isUrlExpanded;
  final String? urlPreview;
  final VoidCallback onDateSelect;
  final VoidCallback onToggleUrlExpansion;
  final VoidCallback onClearUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasTradeId = tradeIdController.text.trim().isNotEmpty;
    final hasUrl = urlController.text.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.2),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Entry Date
          JournalFormHeader(entryDate: entryDate, isEditMode: isEditMode, onDateSelect: onDateSelect),

          // Trade ID field - only show in edit mode or if it has a value
          if (isEditMode || hasTradeId) ...[const SizedBox(height: 12), _buildTradeIdField(theme)],

          // URL section - only show in edit mode or if URL exists
          if (isEditMode || hasUrl) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: onToggleUrlExpansion,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isUrlExpanded
                        ? theme.colorScheme.primary.withOpacity(0.5)
                        : theme.dividerColor.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: isUrlExpanded ? theme.colorScheme.primaryContainer.withOpacity(0.2) : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.link,
                      size: 18,
                      color: isUrlExpanded ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isUrlExpanded ? 'Add URL' : 'Add URL (optional)',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isUrlExpanded ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                        fontWeight: isUrlExpanded ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      isUrlExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 20,
                      color: isUrlExpanded ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),

            // Expandable URL field
            if (isUrlExpanded) ...[
              const SizedBox(height: 8),
              _buildUrlField(theme),
              if (urlPreview != null) ...[
                const SizedBox(height: 8),
                UrlPreviewWidget(url: urlPreview!, onClose: onClearUrl),
              ],
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildTradeIdField(ThemeData theme) => Container(
    decoration: BoxDecoration(
      border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: TextFormField(
      controller: tradeIdController,
      decoration: InputDecoration(
        label: Container(padding: const EdgeInsets.symmetric(horizontal: 4), child: const Text('Trade ID (optional)')),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        floatingLabelAlignment: FloatingLabelAlignment.start,
        hintText: 'Optional',
        prefixIcon: const Icon(Icons.tag, size: 18),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    ),
  );

  Widget _buildUrlField(ThemeData theme) {
    final hasUrl = urlController.text.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: hasUrl ? theme.colorScheme.primary.withOpacity(0.5) : theme.dividerColor.withOpacity(0.5),
          width: hasUrl ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: hasUrl ? theme.colorScheme.primaryContainer.withOpacity(0.1) : null,
      ),
      child: TextFormField(
        controller: urlController,
        decoration: InputDecoration(
          label: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Add URL (optional)'),
                if (hasUrl) ...[
                  const SizedBox(width: 6),
                  Icon(Icons.check_circle, size: 14, color: theme.colorScheme.primary),
                ],
              ],
            ),
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          floatingLabelAlignment: FloatingLabelAlignment.start,
          hintText: 'https://tradingview.com/chart/...',
          prefixIcon: Icon(Icons.link, size: 20, color: hasUrl ? theme.colorScheme.primary : null),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
