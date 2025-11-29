import 'package:flutter/material.dart';

import '../../../internal/domain/entities/journal_entry.dart';
import '../../widgets/journal/models/journal_mood_options.dart';
import '../../widgets/journal/utils/journal_helpers.dart';

class JournalCard extends StatelessWidget {
  const JournalCard({
    required this.entry,
    required this.onTap,
    required this.onDelete,
    required this.extractPlainText,
    required this.limitToWords,
    super.key,
  });

  final JournalEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final String Function(String) extractPlainText;
  final String Function(String, int) limitToWords;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [theme.colorScheme.surface, theme.colorScheme.surfaceContainerHighest.withOpacity(0.3)],
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 10),
              _buildTitle(theme),
              const SizedBox(height: 8),
              Flexible(child: _buildContent(theme)),
              if (entry.mood != null || entry.marketSentiment != null) ...[
                const SizedBox(height: 8),
                _buildMoodAndSentiment(),
              ],
              if (entry.relatedTradeIds.isNotEmpty) ...[const SizedBox(height: 6), _buildRelatedTrades(theme)],
              if (entry.tags.isNotEmpty) ...[const SizedBox(height: 6), _buildTags()],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          entry.entryDate.toString().split(' ')[0],
          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
        ),
      ),
      IconButton(
        icon: Icon(Icons.delete_outline, size: 18, color: theme.colorScheme.error.withOpacity(0.7)),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        onPressed: onDelete,
      ),
    ],
  );

  Widget _buildTitle(ThemeData theme) => Text(
    entry.title,
    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.2),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );

  Widget _buildContent(ThemeData theme) => Text(
    limitToWords(extractPlainText(entry.content), 25),
    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.65), height: 1.4),
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
  );

  Widget _buildMoodAndSentiment() => Row(
    children: [
      if (entry.mood != null) _buildMoodChip(entry.mood!),
      if (entry.mood != null && entry.marketSentiment != null) const SizedBox(width: 6),
      if (entry.marketSentiment != null)
        _buildSentimentChip(JournalHelpers.mapSentimentFromValue(entry.marketSentiment) ?? 'neutral'),
    ],
  );

  Widget _buildMoodChip(String mood) {
    var moodData = JournalMoodOptions.moods[mood];

    if (moodData == null) {
      final moodKey = JournalHelpers.mapMoodFromEntry(mood);
      if (moodKey != null) {
        moodData = JournalMoodOptions.moods[moodKey];
      }
    }

    if (moodData == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (moodData['color'] as Color).withOpacity(0.15),
        border: Border.all(color: moodData['color'] as Color, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${moodData['emoji']} ${moodData['label']}',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: moodData['color'] as Color),
      ),
    );
  }

  Widget _buildSentimentChip(String sentiment) {
    final sentimentData = JournalMoodOptions.sentiments[sentiment];
    if (sentimentData == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (sentimentData['color'] as Color).withOpacity(0.15),
        border: Border.all(color: sentimentData['color'] as Color, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(sentimentData['icon'] as IconData, size: 12, color: sentimentData['color'] as Color),
          const SizedBox(width: 4),
          Text(
            sentimentData['label'] as String,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: sentimentData['color'] as Color),
          ),
        ],
      ),
    );
  }

  Widget _buildTags() => Wrap(spacing: 4, runSpacing: 4, children: entry.tags.take(3).map(_buildTagChip).toList());

  Widget _buildTagChip(String tag) {
    final tagData = JournalMoodOptions.tags.firstWhere(
      (t) => t['label'] == tag,
      orElse: () => {'label': tag, 'color': const Color(0xFF6B7280)},
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (tagData['color'] as Color).withOpacity(0.15),
        border: Border.all(color: tagData['color'] as Color, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        tag,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: tagData['color'] as Color),
      ),
    );
  }

  Widget _buildRelatedTrades(ThemeData theme) {
    final tradeCount = entry.relatedTradeIds.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.analytics_outlined, size: 14, color: theme.colorScheme.secondary),
          const SizedBox(width: 6),
          Text(
            '$tradeCount Trade${tradeCount != 1 ? 's' : ''} Linked',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.secondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
