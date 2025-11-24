import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../internal/domain/entities/favorite_filter.dart';
import '../cubits/favorite_filter/favorite_filter_cubit.dart';

/// Compact panel widget for displaying and managing favorite filters
class FavoriteFilterPanel extends StatelessWidget {
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
      return _buildEmptyState(context);
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Saved Filters',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    if (onCreateNew != null)
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: onCreateNew,
                        tooltip: 'Create New Filter',
                        iconSize: 20,
                      ),
                    if (onManageFilters != null)
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: onManageFilters,
                        tooltip: 'Manage Filters',
                        iconSize: 20,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
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
                    if (selected && onFilterSelected != null) {
                      onFilterSelected!(filter);
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
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) => Card(
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Icon(Icons.filter_list_off, size: 48, color: Colors.grey),
          const SizedBox(height: 8),
          Text('No saved filters', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Create a filter to save your preferences', style: Theme.of(context).textTheme.bodySmall),
          if (onCreateNew != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onCreateNew,
              icon: const Icon(Icons.add),
              label: const Text('Create Filter'),
            ),
          ],
        ],
      ),
    ),
  );

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
              context.read<FavoriteFilterCubit>().loadFilters(userId);
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
              context.read<FavoriteFilterCubit>().deleteFilter(userId, filter.id);
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
