import 'package:flutter/material.dart';

import '../models/journal_mood_options.dart';

class MoodSelector extends StatelessWidget {
  const MoodSelector({required this.selectedMood, required this.onMoodSelected, super.key});

  final String? selectedMood;
  final ValueChanged<String> onMoodSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mood', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: JournalMoodOptions.moods.entries.map((entry) {
            final isSelected = selectedMood == entry.key;
            final moodData = entry.value;
            return InkWell(
              onTap: () => onMoodSelected(entry.key),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (moodData['color'] as Color).withOpacity(0.15)
                      : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  border: Border.all(color: isSelected ? moodData['color'] as Color : Colors.transparent, width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${moodData['emoji']} ${moodData['label']}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? moodData['color'] as Color : null,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
