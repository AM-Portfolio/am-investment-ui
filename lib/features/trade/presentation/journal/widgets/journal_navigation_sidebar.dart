import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class JournalNavigationSidebar extends StatelessWidget {
  const JournalNavigationSidebar({
    required this.onFolderSelected,
    this.selectedFolder = 'Daily Journal',
    super.key,
  });

  final ValueChanged<String> onFolderSelected;
  final String selectedFolder;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Notebook',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search, size: 18),
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Add Folder Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.create_new_folder_outlined, size: 18),
              label: const Text('Add folder'),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                side: BorderSide(color: Theme.of(context).dividerColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Folders List
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(context, 'Folders'),
                  _buildFolderItem(context, 'All notes', Icons.notes),
                  _buildFolderItem(context, 'Trade Notes', Icons.candlestick_chart_outlined),
                  _buildFolderItem(context, 'Daily Journal', Icons.book_outlined),
                  _buildFolderItem(context, 'Sessions Recap', Icons.timelapse),
                  const Divider(height: 32),
                  _buildFolderItem(context, 'Quarterly Goals 📅', null),
                  _buildFolderItem(context, 'Trading Goals 🚀', null),
                  _buildFolderItem(context, 'Trading Plan 📝', null),
                  _buildFolderItem(context, '2023 Goals + Plan 🗺️', null),
                  _buildFolderItem(context, 'Notes 🍂', null),
                  _buildFolderItem(context, 'Plan of Action ✍️', null),
                  _buildFolderItem(context, 'Mistakes Reflection', null),
                  
                  const SizedBox(height: 24),
                  _buildSectionHeader(context, 'Tags'),
                  _buildTagItem(context, 'FOMC', 1),
                  _buildTagItem(context, 'Goals', 1),
                  _buildTagItem(context, 'Market News', 1),
                  _buildTagItem(context, 'Mistakes', 1),
                  _buildTagItem(context, 'Plan of Action', 1),
                  _buildTagItem(context, 'Trading Rules', 1),
                  
                  const SizedBox(height: 16),
                  _buildFolderItem(context, 'Recently Deleted', Icons.delete_outline),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
          ),
          Icon(Icons.keyboard_arrow_down, size: 16, color: Theme.of(context).colorScheme.secondary),
        ],
      ),
    );
  }

  Widget _buildFolderItem(BuildContext context, String title, IconData? icon) {
    final isSelected = title == selectedFolder;
    return InkWell(
      onTap: () => onFolderSelected(title),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
            ] else ...[
               // Indent for items without icon to align text if mixed, or just keep as is for "folder" look
               // The design shows colored tabs for some, let's keep it simple for now
               Container(
                 width: 4,
                 height: 18,
                 decoration: BoxDecoration(
                   color: _getColorForFolder(title),
                   borderRadius: BorderRadius.circular(2),
                 ),
               ),
               const SizedBox(width: 14), // 18 (icon) + 12 (gap) - 4 (bar) = 26. Let's do 14 + 12 = 26 approx
            ],
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected ? Theme.of(context).colorScheme.onPrimaryContainer : Theme.of(context).colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected)
               Icon(Icons.more_horiz, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    ).animate().fadeIn();
  }
  
  Color _getColorForFolder(String title) {
    // Mock colors based on title hash or predefined
    final colors = [
      Colors.orange,
      Colors.blue,
      Colors.purple,
      Colors.green,
      Colors.red,
      Colors.teal,
    ];
    return colors[title.hashCode % colors.length];
  }

  Widget _buildTagItem(BuildContext context, String tag, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              tag,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '($count)',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
