import 'package:flutter/material.dart';

import '../models/journal_mood_options.dart';

class TagsSelector extends StatelessWidget {
  const TagsSelector({required this.selectedTags, required this.onTagToggled, super.key});

  final Set<String> selectedTags;
  final ValueChanged<String> onTagToggled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tags', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: JournalMoodOptions.tags.map((tagData) {
            final tag = tagData['label'] as String;
            final color = tagData['color'] as Color;
            final isSelected = selectedTags.contains(tag);
            return InkWell(
              onTap: () => onTagToggled(tag),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withOpacity(0.15)
                      : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  border: Border.all(color: isSelected ? color : Colors.transparent, width: 1.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(Icons.check, size: 12, color: color),
                      ),
                    Text(
                      tag,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? color : theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
