import 'package:flutter/material.dart';
import '../../../internal/domain/entities/journal_entry.dart';
import '../../cubit/journal/journal_cubit.dart';
import 'journal_entry_detail_view.dart';
import 'journal_entry_list_view.dart';
import 'journal_navigation_sidebar.dart';

class JournalThreeColumnLayout extends StatefulWidget {
  const JournalThreeColumnLayout({
    required this.entries,
    required this.userId,
    required this.cubit,
    super.key,
  });

  final List<JournalEntry> entries;
  final String userId;
  final JournalCubit cubit;

  @override
  State<JournalThreeColumnLayout> createState() => _JournalThreeColumnLayoutState();
}

class _JournalThreeColumnLayoutState extends State<JournalThreeColumnLayout> {
  String _selectedFolder = 'Daily Journal';
  String? _selectedEntryId;

  @override
  void initState() {
    super.initState();
    if (widget.entries.isNotEmpty) {
      _selectedEntryId = widget.entries.first.id;
    }
  }

  @override
  void didUpdateWidget(covariant JournalThreeColumnLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.entries.isNotEmpty && _selectedEntryId == null) {
      setState(() {
        _selectedEntryId = widget.entries.first.id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedEntry = widget.entries.where((e) => e.id == _selectedEntryId).firstOrNull;

    return Row(
      children: [
        // Left Column: Navigation
        JournalNavigationSidebar(
          selectedFolder: _selectedFolder,
          onFolderSelected: (folder) => setState(() => _selectedFolder = folder),
        ),
        
        VerticalDivider(width: 1, color: Theme.of(context).dividerColor),

        // Middle Column: Entry List
        JournalEntryListView(
          entries: widget.entries,
          selectedEntryId: _selectedEntryId,
          onEntrySelected: (entry) => setState(() => _selectedEntryId = entry.id),
        ),

        VerticalDivider(width: 1, color: Theme.of(context).dividerColor),

        // Right Column: Detail View
        Expanded(
          child: JournalEntryDetailView(
            entry: selectedEntry,
            userId: widget.userId,
            cubit: widget.cubit,
          ),
        ),
      ],
    );
  }
}
