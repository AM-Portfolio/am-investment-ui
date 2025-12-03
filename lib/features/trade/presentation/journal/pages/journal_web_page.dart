import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../journal_providers.dart';
import '../../cubit/journal/journal_cubit.dart';
import '../../cubit/journal/journal_state.dart';
import '../widgets/journal_three_column_layout.dart';

class JournalWebPage extends ConsumerStatefulWidget {
  const JournalWebPage({required this.userId, this.portfolioId, super.key});

  final String userId;
  final String? portfolioId;

  @override
  ConsumerState<JournalWebPage> createState() => _JournalWebPageState();
}

class _JournalWebPageState extends ConsumerState<JournalWebPage> {
  late final JournalCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = ref.read(journalCubitProvider);
    _cubit.loadJournalEntries(widget.userId);
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
        value: _cubit,
        child: BlocListener<JournalCubit, JournalState>(
          listener: (context, state) {
            // Handle success/error messages if needed
          },
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: BlocBuilder<JournalCubit, JournalState>(
              builder: (context, state) => state.when(
                initial: () => const SizedBox.shrink(),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (message) => Center(child: Text('Error: $message')),
                success: (message) => const Center(child: CircularProgressIndicator()),
                loaded: (entries) => JournalThreeColumnLayout(
                    entries: entries,
                    userId: widget.userId,
                    cubit: _cubit,
                  ),
              ),
            ),
          ),
        ),
      );
}

