import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';


import '../../../journal_providers.dart';
import '../../../notebook_providers.dart';
import '../../../internal/domain/enums/notebook_item_type.dart';
import '../../../internal/domain/entities/notebook_item.dart';
import '../../../internal/domain/entities/journal_entry.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../../config/environment.dart';
import '../../cubit/journal/journal_cubit.dart';
import '../../cubit/journal/journal_state.dart';
import '../../notebook/cubit/notebook_cubit.dart';
import '../../notebook/cubit/notebook_state.dart';
import '../widgets/journal_three_column_layout.dart';
import '../widgets/add_folder_dialog.dart';

class JournalWebPage extends ConsumerStatefulWidget {
  const JournalWebPage({required this.userId, this.portfolioId, super.key});

  final String userId;
  final String? portfolioId;

  @override
  ConsumerState<JournalWebPage> createState() => _JournalWebPageState();
}

class _JournalWebPageState extends ConsumerState<JournalWebPage> {
  late final JournalCubit _journalCubit;
  late final NotebookCubit _notebookCubit;

  @override
  void initState() {
    super.initState();
    _journalCubit = ref.read(journalCubitProvider);
    _notebookCubit = ref.read(notebookCubitProvider);
    
    // Mode Logger
    AppLogger.info(
      'Initializing Journal Web Page', 
      tag: 'JournalWebPage'
    );
    AppLogger.info(
      'Current Mode: ${EnvironmentConfig.environment.name}', 
      tag: 'JournalWebPage'
    );
    AppLogger.info(
      'Mock Data Enabled: ${EnvironmentConfig.settings['useMockData']}', 
      tag: 'JournalWebPage'
    );
    
    _journalCubit.loadJournalEntries(widget.userId);
    _notebookCubit.loadNotebook(widget.userId);
  }

  Future<void> _handleAddFolder() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddFolderDialog(userId: widget.userId),
    );

    if (result != null && mounted) {
      final folderName = result['name'] as String;
      final color = result['color'] as Color;
      final icon = result['icon'] as IconData;

      // Create metadata to store color and icon
      final metadata = {
        'color': color.value.toRadixString(16),
        'icon': icon.codePoint,
      };

      // Create NotebookItem for the folder
      final folder = NotebookItem(
        userId: widget.userId,
        type: NotebookItemType.FOLDER,
        title: folderName,
        metadata: metadata,
      );

      // Call cubit to create folder
      await _notebookCubit.createItem(folder);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Folder "$folderName" created successfully'),
            backgroundColor: color,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _handleEntryDropped(JournalEntry entry, String folderId) async {
    // Create a NOTE item in the folder that references the journal entry
    final note = NotebookItem(
      userId: widget.userId,
      type: NotebookItemType.NOTE,
      title: 'Journal Entry - ${DateFormat('MMM dd, yyyy').format(entry.entryDate)}',
      parentId: folderId,
      content: entry.content ?? '',
      metadata: {
        'journalEntryId': entry.id,
        'linkedAt': DateTime.now().toIso8601String(),
        'entryDate': entry.entryDate.toIso8601String(),
      },
      tagIds: entry.tagIds,
    );

    // Call cubit to create note
    await _notebookCubit.createItem(note);
    
    // Refresh notebook to show updated folder structure
    await _notebookCubit.loadNotebook(widget.userId);

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Journal entry added to folder'),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'Undo',
            textColor: Colors.white,
            onPressed: () {
              // TODO: Implement undo
            },
          ),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _journalCubit),
          BlocProvider.value(value: _notebookCubit),
        ],
        child: MultiBlocListener(
          listeners: [
            BlocListener<JournalCubit, JournalState>(
              listener: (context, state) {
                // Handle journal success/error messages if needed
              },
            ),
            BlocListener<NotebookCubit, NotebookState>(
              listener: (context, state) {
                // Handle notebook success/error messages if needed
              },
            ),
          ],
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: BlocBuilder<JournalCubit, JournalState>(
              builder: (context, journalState) {
                return BlocBuilder<NotebookCubit, NotebookState>(
                  builder: (context, notebookState) {
                    // Combine states or handle loading separately?
                    // For now, let's show layout if journal is loaded, notebook can load in background or show loading in sidebar
                    
                    return journalState.when(
                      initial: () => const SizedBox.shrink(),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (message) => Center(child: Text('Error: $message')),
                      success: (message) => const Center(child: CircularProgressIndicator()),
                      loaded: (entries) => JournalThreeColumnLayout(
                          entries: entries,
                          userId: widget.userId,
                          journalCubit: _journalCubit,
                          notebookCubit: _notebookCubit,
                          onAddFolder: _handleAddFolder,
                          onEntryDropped: _handleEntryDropped,
                        ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      );
}

