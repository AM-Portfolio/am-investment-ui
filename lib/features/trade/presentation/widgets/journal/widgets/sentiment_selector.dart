import 'package:flutter/material.dart';

import '../models/journal_mood_options.dart';

class SentimentSelector extends StatelessWidget {
  const SentimentSelector({required this.selectedSentiment, required this.onSentimentSelected, super.key});

  final String? selectedSentiment;
  final ValueChanged<String> onSentimentSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Market Sentiment',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: JournalMoodOptions.sentiments.entries.map((entry) {
            final isSelected = selectedSentiment == entry.key;
            final sentimentData = entry.value;
            return InkWell(
              onTap: () => onSentimentSelected(entry.key),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (sentimentData['color'] as Color).withOpacity(0.15)
                      : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  border: Border.all(
                    color: isSelected ? sentimentData['color'] as Color : Colors.transparent,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      sentimentData['icon'] as IconData,
                      size: 14,
                      color: isSelected
                          ? sentimentData['color'] as Color
                          : theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      sentimentData['label'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? sentimentData['color'] as Color : null,
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
