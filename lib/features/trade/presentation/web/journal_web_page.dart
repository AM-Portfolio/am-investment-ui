import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../internal/domain/entities/journal_entry.dart';
import '../../internal/presentation/cubits/journal/journal_cubit.dart';
import '../../internal/presentation/cubits/journal/journal_state.dart';
import '../../journal_providers.dart';
import '../widgets/journal/journal_entry_form.dart';

class JournalWebPage extends ConsumerStatefulWidget {
  const JournalWebPage({super.key, required this.userId});

  final String userId;

  @override
  ConsumerState<JournalWebPage> createState() => _JournalWebPageState();
}

class _JournalWebPageState extends ConsumerState<JournalWebPage> {
  late final JournalCubit _cubit;
  bool _showForm = false;
  JournalEntry? _editingEntry;

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

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
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
          body: _showForm
              ? _buildFormView()
              : _buildListView(),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Column(
      children: [
        // Back button header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              IconButton.outlined(
                onPressed: _hideForm,
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Back to list',
              ),
            ],
          ),
        ),
        // Form
        Expanded(
          child: JournalEntryForm(
            userId: widget.userId,
            cubit: _cubit,
            entry: _editingEntry,
          ),
        ),
      ],
    );
  }

  Widget _buildListView() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
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
                  const SizedBox(height: 8),
                  Text(
                    'Record your thoughts, emotions, and trade analysis',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showNewEntryForm,
                icon: const Icon(Icons.add),
                label: const Text('New Entry'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Content
          Expanded(
            child: BlocBuilder<JournalCubit, JournalState>(
              builder: (context, state) {
                return state.when(
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

                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 400,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.5,
                      ),
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Theme.of(context).dividerColor),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _showEditEntryForm(entry),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        entry.entryDate.toString().split(' ')[0],
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 20),
                                        onPressed: () {
                                          _cubit.removeJournalEntry(widget.userId, entry.id);
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    entry.title,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: Text(
                                      entry.content,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                      ),
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (entry.tags.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 4,
                                      children: entry.tags.take(3).map((tag) => Chip(
                                        label: Text(tag, style: const TextStyle(fontSize: 10)),
                                        padding: EdgeInsets.zero,
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: VisualDensity.compact,
                                      )).toList(),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
