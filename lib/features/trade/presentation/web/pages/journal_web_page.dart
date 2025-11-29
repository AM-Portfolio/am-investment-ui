import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../internal/domain/entities/journal_entry.dart';
import '../../../internal/presentation/cubits/journal/journal_cubit.dart';
import '../../../internal/presentation/cubits/journal/journal_state.dart';
import '../../../journal_providers.dart';
import '../../widgets/journal/journal_entry_form.dart';
import '../../widgets/journal/models/journal_mood_options.dart';
import '../../widgets/journal/utils/journal_helpers.dart';

class JournalWebPage extends ConsumerStatefulWidget {
  const JournalWebPage({required this.userId, super.key});

  final String userId;

  @override
  ConsumerState<JournalWebPage> createState() => _JournalWebPageState();
}

class _JournalWebPageState extends ConsumerState<JournalWebPage> {
  late final JournalCubit _cubit;
  bool _showForm = false;
  JournalEntry? _editingEntry;
  int _currentPage = 0;
  static const int _itemsPerPage = 12;

  @override
  void initState() {
    super.initState();
    _cubit = ref.read(journalCubitProvider);
    _cubit.loadJournalEntries(widget.userId);
  }

  void _showNewEntryForm() {
    setState(() {
      _showForm = true;
      _editingEntry = null;
    });
  }

  void _showEditEntryForm(JournalEntry entry) {
    setState(() {
      _showForm = true;
      _editingEntry = entry;
    });
  }

  void _hideForm() {
    setState(() {
      _showForm = false;
      _editingEntry = null;
    });
  }

  String _extractPlainText(String content) {
    try {
      final delta = quill.Document.fromJson(jsonDecode(content));
      return delta.toPlainText().trim();
    } catch (e) {
      return content;
    }
  }

  String _limitToWords(String text, int maxWords) {
    final words = text.split(RegExp(r'\s+'));
    if (words.length <= maxWords) return text;
    return '${words.take(maxWords).join(' ')}...';
  }

  Widget _buildMoodChip(String mood) {
    // First try to find by key
    var moodData = JournalMoodOptions.moods[mood];

    // If not found, try to extract key from formatted string (e.g., "😊 Confident" -> "confident")
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

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: _cubit,
    child: BlocListener<JournalCubit, JournalState>(
      listener: (context, state) {
        state.whenOrNull(
          success: (message) {
            _hideForm();
          },
        );
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: _showForm ? _buildFormView() : _buildListView(),
      ),
    ),
  );

  Widget _buildFormView() => Column(
    children: [
      // Back button header
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
        child: Row(
          children: [
            IconButton.outlined(onPressed: _hideForm, icon: const Icon(Icons.arrow_back), tooltip: 'Back to list'),
          ],
        ),
      ),
      // Form
      Expanded(
        child: JournalEntryForm(userId: widget.userId, cubit: _cubit, entry: _editingEntry),
      ),
    ],
  );

  Widget _buildListView() => Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trade Journal',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Record your thoughts, emotions, and trade analysis',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _showNewEntryForm,
              icon: const Icon(Icons.add),
              label: const Text('New Entry'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Content
        Expanded(
          child: BlocBuilder<JournalCubit, JournalState>(
            builder: (context, state) => state.when(
              initial: () => const SizedBox.shrink(),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (message) => Center(child: Text('Error: $message')),
              success: (message) => const Center(child: CircularProgressIndicator()),
              loaded: (entries) {
                if (entries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.book_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No journal entries yet',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start by creating your first entry',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Pagination calculations
                final totalPages = (entries.length / _itemsPerPage).ceil();
                final startIndex = _currentPage * _itemsPerPage;
                final endIndex = (startIndex + _itemsPerPage).clamp(0, entries.length);
                final paginatedEntries = entries.sublist(startIndex, endIndex);

                return Column(
                  children: [
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 380,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.6,
                        ),
                        itemCount: paginatedEntries.length,
                        itemBuilder: (context, index) {
                          final entry = paginatedEntries[index];
                          return Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.5)),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => _showEditEntryForm(entry),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Theme.of(context).colorScheme.surface,
                                      Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                                    ],
                                  ),
                                ),
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            entry.entryDate.toString().split(' ')[0],
                                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                              color: Theme.of(context).colorScheme.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete_outline,
                                            size: 18,
                                            color: Theme.of(context).colorScheme.error.withOpacity(0.7),
                                          ),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          onPressed: () {
                                            _cubit.removeJournalEntry(widget.userId, entry.id);
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      entry.title,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _limitToWords(_extractPlainText(entry.content), 25),
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.65),
                                        height: 1.4,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const Spacer(),
                                    // Mood and Sentiment Row
                                    if (entry.mood != null || entry.marketSentiment != null) ...[
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          if (entry.mood != null) _buildMoodChip(entry.mood!),
                                          if (entry.mood != null && entry.marketSentiment != null)
                                            const SizedBox(width: 6),
                                          if (entry.marketSentiment != null)
                                            _buildSentimentChip(
                                              JournalHelpers.mapSentimentFromValue(entry.marketSentiment) ?? 'neutral',
                                            ),
                                        ],
                                      ),
                                    ],
                                    // Tags Row (separate from mood/sentiment)
                                    if (entry.tags.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 4,
                                        runSpacing: 4,
                                        children: entry.tags.take(3).map(_buildTagChip).toList(),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Pagination controls
                    if (totalPages > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
                              icon: const Icon(Icons.chevron_left),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Page ${_currentPage + 1} of $totalPages',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              onPressed: _currentPage < totalPages - 1 ? () => setState(() => _currentPage++) : null,
                              icon: const Icon(Icons.chevron_right),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    ),
  );
}
