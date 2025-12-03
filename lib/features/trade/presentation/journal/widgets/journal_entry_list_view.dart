import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../internal/domain/entities/journal_entry.dart';
import '../../web/utils/journal_helpers.dart' as web_helpers;

class JournalEntryListView extends StatelessWidget {
  const JournalEntryListView({
    super.key,
    required this.entries,
    required this.selectedEntryId,
    required this.onEntrySelected,
  });

  final List<JournalEntry> entries;
  final String? selectedEntryId;
  final ValueChanged<JournalEntry> onEntrySelected;

  @override
  Widget build(BuildContext context) {
    final groupedEntries = _groupEntriesByDate(entries);

    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          right: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.5)),
          left: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.5)),
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.note_add_outlined, size: 20, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Log day',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                Icon(Icons.sort, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ],
            ),
          ),
          const Divider(height: 1),
          
          // Select All / Checkbox placeholder
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: false, 
                    onChanged: (v) {},
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Select All',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: ListView.builder(
              itemCount: groupedEntries.length,
              itemBuilder: (context, index) {
                final dateKey = groupedEntries.keys.elementAt(index);
                final dayEntries = groupedEntries[dateKey]!;
                
                // For this UI, we flatten the list or show headers?
                // The design shows a list of items, each item seems to be a day summary or an entry.
                // "Thu, Jul 20, 2023"
                // Let's assume one entry per day for the "Log day" view, or list all entries.
                // The design looks like a list of days.
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: dayEntries.map((entry) => _buildEntryItem(context, entry)).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<JournalEntry>> _groupEntriesByDate(List<JournalEntry> entries) {
    final grouped = <String, List<JournalEntry>>{};
    for (final entry in entries) {
      final dateKey = DateFormat('yyyy-MM-dd').format(entry.entryDate);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(entry);
    }
    // Sort keys desc
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    final sortedMap = <String, List<JournalEntry>>{};
    for (final key in sortedKeys) {
      sortedMap[key] = grouped[key]!;
    }
    return sortedMap;
  }

  Widget _buildEntryItem(BuildContext context, JournalEntry entry) {
    final isSelected = entry.id == selectedEntryId;
    final dateStr = DateFormat('EEE, MMM dd, yyyy').format(entry.entryDate);
    final subDateStr = DateFormat('MM/dd/yyyy').format(entry.entryDate); // Mocking the second date line

    return InkWell(
      onTap: () => onEntrySelected(entry),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3) : null,
          border: Border(
            bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.3)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selection indicator or checkbox
             SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: false, 
                    onChanged: (v) {},
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    side: BorderSide(color: Theme.of(context).disabledColor),
                  ),
                ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dateStr,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      // PNL Placeholder
                      Text(
                        '+\$1,330', // Placeholder
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        subDateStr,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      // Stats Placeholder
                      Row(
                        children: [
                          _buildMiniStat(context, '54% Win'),
                          const SizedBox(width: 8),
                          _buildMiniStat(context, '11 Trades'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildMiniStat(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: 10,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
