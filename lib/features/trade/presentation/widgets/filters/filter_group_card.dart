import 'package:flutter/material.dart';

import 'filter_group.dart';

/// Collapsible filter group card widget
class FilterGroupCard extends StatefulWidget {
  const FilterGroupCard({required this.filterGroup, super.key, this.onRemove, this.canRemove = true});
  final FilterGroup filterGroup;
  final VoidCallback? onRemove;
  final bool canRemove;

  @override
  State<FilterGroupCard> createState() => _FilterGroupCardState();
}

class _FilterGroupCardState extends State<FilterGroupCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(widget.filterGroup.icon, size: 20, color: theme.primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.filterGroup.title,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (widget.filterGroup.hasActiveFilters)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Active',
                        style: TextStyle(fontSize: 10, color: theme.primaryColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  const SizedBox(width: 8),
                  if (widget.canRemove && widget.onRemove != null)
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: widget.onRemove,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Remove filter group',
                    ),
                  const SizedBox(width: 8),
                  Icon(_isExpanded ? Icons.expand_less : Icons.expand_more, size: 20),
                ],
              ),
            ),
          ),
          // Content
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(padding: const EdgeInsets.all(12), child: widget.filterGroup.buildContent(context)),
          ],
        ],
      ),
    );
  }
}
