import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../internal/domain/entities/favorite_filter.dart';
import '../cubits/favorite_filter/favorite_filter_cubit.dart';

/// Compact panel widget for displaying and managing favorite filters
class FavoriteFilterPanel extends StatefulWidget {
  const FavoriteFilterPanel({
    required this.userId,
    super.key,
    this.onFilterSelected,
    this.onCreateNew,
    this.onManageFilters,
  });

  final String userId;
  final void Function(FavoriteFilter filter)? onFilterSelected;
  final VoidCallback? onCreateNew;
  final VoidCallback? onManageFilters;

  @override
  State<FavoriteFilterPanel> createState() => _FavoriteFilterPanelState();
}

class _FavoriteFilterPanelState extends State<FavoriteFilterPanel> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) => BlocBuilder<FavoriteFilterCubit, FavoriteFilterState>(
    builder: (context, state) => state.when(
      initial: () => const SizedBox.shrink(),
      loading: () => const Center(
        child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()),
      ),
      loaded: (filterList, selectedFilter) => _buildFilterList(context, filterList, selectedFilter),
      error: (message) => _buildError(context, message),
    ),
  );

  Widget _buildFilterList(BuildContext context, FavoriteFilterList filterList, FavoriteFilter? selectedFilter) {
    if (filterList.filters.isEmpty) {
      return const SizedBox.shrink(); // Don't show anything if no filters
    }

    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compact Header - Icon Only
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.bookmark_rounded, size: 18, color: theme.primaryColor),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${filterList.filters.length}',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.primaryColor),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(_isExpanded ? Icons.expand_less : Icons.expand_more, size: 18, color: theme.hintColor),
                  if (_isExpanded) ...[
                    const SizedBox(width: 12),
                    if (widget.onCreateNew != null)
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        onPressed: widget.onCreateNew,
                        tooltip: 'Create New Filter',
                        iconSize: 18,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                    if (widget.onManageFilters != null)
                      IconButton(
                        icon: const Icon(Icons.settings_outlined),
                        onPressed: widget.onManageFilters,
                        tooltip: 'Manage Filters',
                        iconSize: 18,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                  ],
                ],
              ),
            ),
          ),
          // Expandable content
          if (_isExpanded) ...[
            Divider(height: 1, color: theme.dividerColor.withOpacity(0.3)),
            // Filter chips
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: filterList.filters.map((filter) {
                  final isSelected = selectedFilter?.id == filter.id;
                  final isDefault = filter.isDefault;

                  return FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isDefault)
                          const Padding(padding: EdgeInsets.only(right: 4.0), child: Icon(Icons.star, size: 14)),
                        Text(filter.name),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected && widget.onFilterSelected != null) {
                        widget.onFilterSelected!(filter);
                        context.read<FavoriteFilterCubit>().selectFilter(filter);
                      }
                    },
                    avatar: isDefault ? const Icon(Icons.star, size: 16) : null,
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => _confirmDelete(context, filter),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) => Card(
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 8),
          Text('Error loading filters', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(message, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<FavoriteFilterCubit>().loadFilters(widget.userId);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    ),
  );

  void _confirmDelete(BuildContext context, FavoriteFilter filter) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Filter'),
        content: Text('Are you sure you want to delete "${filter.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<FavoriteFilterCubit>().deleteFilter(widget.userId, filter.id);
              Navigator.of(dialogContext).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
