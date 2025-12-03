import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../journal_providers.dart';
import '../../../notebook_providers.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../../config/environment.dart';
import '../../cubit/journal/journal_cubit.dart';
import '../../cubit/journal/journal_state.dart';
import '../../notebook/cubit/notebook_cubit.dart';
import '../../notebook/cubit/notebook_state.dart';
import '../widgets/journal_three_column_layout.dart';

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

