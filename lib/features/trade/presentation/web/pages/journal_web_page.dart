import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../internal/domain/entities/journal_entry.dart';
import '../../../internal/presentation/cubits/journal/journal_cubit.dart';
import '../../../internal/presentation/cubits/journal/journal_state.dart';
import '../../../journal_providers.dart';
import '../../widgets/journal/journal_entry_form.dart';
import '../../widgets/journal/utils/journal_helpers.dart';
import '../utils/journal_helpers.dart' as web_helpers;
import '../widgets/journal_card.dart';
import '../widgets/journal_filters_bar.dart';

class JournalWebPage extends ConsumerStatefulWidget {
  const JournalWebPage({required this.userId, this.portfolioId, super.key});

  final String userId;
  final String? portfolioId;

  @override
  ConsumerState<JournalWebPage> createState() => _JournalWebPageState();
}

class _JournalWebPageState extends ConsumerState<JournalWebPage> {
  late final JournalCubit _cubit;
  bool _showForm = false;
  JournalEntry? _editingEntry;
  int _currentPage = 0;
  static const int _itemsPerPage = 12;

  // Filter states
  final TextEditingController _searchController = TextEditingController();
  String? _selectedMoodFilter;
  String? _selectedSentimentFilter;
  final Set<String> _selectedTagFilters = {};
  int? _selectedYear = 2025;
  int? _selectedMonth = DateTime.now().month;
  bool _showLast20 = false;
  String _filterLogic = 'AND'; // 'AND' or 'OR'
  bool _showFilters = false;
  bool _showAdvancedFilters = false;

  @override
  void initState() {
    super.initState();
    _cubit = ref.read(journalCubitProvider);
    _cubit.loadJournalEntries(widget.userId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  List<JournalEntry> _filterEntries(List<JournalEntry> entries) {
    var filtered = entries;

    // Show last 20 entries (takes priority)
    if (_showLast20) {
      final sortedList = List<JournalEntry>.from(filtered);
      sortedList.sort((a, b) => b.entryDate.compareTo(a.entryDate));
      return sortedList.take(20).toList();
    }

    // Search filter (always applied with AND logic)
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      filtered = filtered
          .where(
            (entry) =>
                entry.title.toLowerCase().contains(searchTerm) ||
                web_helpers.JournalHelpers.extractPlainText(entry.content).toLowerCase().contains(searchTerm),
          )
          .toList();
    }

    // Apply filters based on AND/OR logic
    if (_filterLogic == 'OR') {
      // OR logic: entry passes if it matches ANY filter
      filtered = filtered.where((entry) {
        // If no filters are active (except search), include all
        if (_selectedMoodFilter == null &&
            _selectedSentimentFilter == null &&
            _selectedTagFilters.isEmpty &&
            _selectedYear == null &&
            _selectedMonth == null) {
          return true;
        }

        // Check each filter - return true if any matches
        if (_selectedMoodFilter != null) {
          final moodKey = JournalHelpers.mapMoodFromEntry(entry.mood);
          if (moodKey == _selectedMoodFilter) return true;
        }

        if (_selectedSentimentFilter != null) {
          final sentimentKey = JournalHelpers.mapSentimentFromValue(entry.marketSentiment);
          if (sentimentKey == _selectedSentimentFilter) return true;
        }

        if (_selectedTagFilters.isNotEmpty) {
          if (_selectedTagFilters.any((tag) => entry.tags.contains(tag))) return true;
        }

        if (_selectedYear != null && entry.entryDate.year == _selectedYear) return true;
        if (_selectedMonth != null && entry.entryDate.month == _selectedMonth) return true;

        return false;
      }).toList();
    } else {
      // AND logic: entry must match ALL active filters
      // Mood filter
      if (_selectedMoodFilter != null) {
        filtered = filtered.where((entry) {
          final moodKey = JournalHelpers.mapMoodFromEntry(entry.mood);
          return moodKey == _selectedMoodFilter;
        }).toList();
      }

      // Sentiment filter
      if (_selectedSentimentFilter != null) {
        filtered = filtered.where((entry) {
          final sentimentKey = JournalHelpers.mapSentimentFromValue(entry.marketSentiment);
          return sentimentKey == _selectedSentimentFilter;
        }).toList();
      }

      // Tags filter
      if (_selectedTagFilters.isNotEmpty) {
        filtered = filtered.where((entry) => _selectedTagFilters.any((tag) => entry.tags.contains(tag))).toList();
      }

      // Year filter
      if (_selectedYear != null) {
        filtered = filtered.where((entry) => entry.entryDate.year == _selectedYear).toList();
      }

      // Month filter
      if (_selectedMonth != null) {
        filtered = filtered.where((entry) => entry.entryDate.month == _selectedMonth).toList();
      }
    }

    return filtered;
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedMoodFilter = null;
      _selectedSentimentFilter = null;
      _selectedTagFilters.clear();
      _selectedYear = 2025;
      _selectedMonth = DateTime.now().month;
      _showLast20 = false;
      _currentPage = 0;
    });
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
        child: JournalEntryForm(
          userId: widget.userId,
          cubit: _cubit,
          portfolioId: widget.portfolioId ?? '8a57024c-05c2-475b-a2c4-0545865efa4a',
          entry: _editingEntry,
        ),
      ),
    ],
  );

  Widget _buildListView() => Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with Search
        Row(
          children: [
            Expanded(
              child: Column(
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
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 300,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search entries...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () => setState(() {
                            _searchController.clear();
                            _currentPage = 0;
                          }),
                        )
                      : null,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  isDense: true,
                ),
                onChanged: (value) => setState(() => _currentPage = 0),
              ),
            ),
            const SizedBox(width: 12),
            IconButton.outlined(
              onPressed: () => setState(() => _showFilters = !_showFilters),
              icon: Icon(
                _showFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
                color:
                    (_selectedMoodFilter != null ||
                        _selectedSentimentFilter != null ||
                        _selectedTagFilters.isNotEmpty ||
                        _showLast20)
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              tooltip: 'Filters',
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _showNewEntryForm,
              icon: const Icon(Icons.add),
              label: const Text('New Entry'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
            ),
          ],
        ),

        // Filter chips bar
        if (_showFilters) ...[
          const SizedBox(height: 16),
          JournalFiltersBar(
            selectedMoodFilter: _selectedMoodFilter,
            selectedSentimentFilter: _selectedSentimentFilter,
            selectedTagFilters: _selectedTagFilters,
            selectedYear: _selectedYear,
            selectedMonth: _selectedMonth,
            showLast20: _showLast20,
            filterLogic: _filterLogic,
            showAdvancedFilters: _showAdvancedFilters,
            onMoodChanged: (mood) => setState(() {
              _selectedMoodFilter = mood;
              _currentPage = 0;
            }),
            onSentimentChanged: (sentiment) => setState(() {
              _selectedSentimentFilter = sentiment;
              _currentPage = 0;
            }),
            onTagChanged: (tag, selected) => setState(() {
              if (selected) {
                _selectedTagFilters.add(tag);
              } else {
                _selectedTagFilters.remove(tag);
              }
              _currentPage = 0;
            }),
            onYearChanged: (year) => setState(() {
              _selectedYear = year;
              _currentPage = 0;
            }),
            onMonthChanged: (month) => setState(() {
              _selectedMonth = month;
              _currentPage = 0;
            }),
            onShowLast20Changed: (show) => setState(() {
              _showLast20 = show;
              _currentPage = 0;
            }),
            onFilterLogicChanged: (logic) => setState(() {
              _filterLogic = logic;
              _currentPage = 0;
            }),
            onToggleAdvancedFilters: () => setState(() => _showAdvancedFilters = !_showAdvancedFilters),
            onClearFilters: _clearFilters,
          ),
        ],

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
                // Apply filters
                final filteredEntries = _filterEntries(entries);

                if (filteredEntries.isEmpty) {
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
                final totalPages = (filteredEntries.length / _itemsPerPage).ceil();
                final startIndex = _currentPage * _itemsPerPage;
                final endIndex = (startIndex + _itemsPerPage).clamp(0, filteredEntries.length);
                final paginatedEntries = filteredEntries.sublist(startIndex, endIndex);

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
                          return JournalCard(
                            entry: entry,
                            onTap: () => _showEditEntryForm(entry),
                            onDelete: () => _cubit.removeJournalEntry(widget.userId, entry.id),
                            extractPlainText: web_helpers.JournalHelpers.extractPlainText,
                            limitToWords: web_helpers.JournalHelpers.limitToWords,
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
