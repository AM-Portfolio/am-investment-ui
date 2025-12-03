import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../internal/domain/entities/journal_entry.dart';
import '../../cubit/journal/journal_cubit.dart';
import '../../web/widgets/journal/journal_entry_form.dart';

class JournalEntryDetailView extends StatelessWidget {
  const JournalEntryDetailView({
    required this.entry,
    required this.userId,
    required this.cubit,
    super.key,
  });

  final JournalEntry? entry;
  final String userId;
  final JournalCubit cubit;

  @override
  Widget build(BuildContext context) {
    if (entry == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.touch_app_outlined, size: 64, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text(
              'Select an entry to view details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                  ),
            ),
          ],
        ),
      );
    }

    final dateStr = DateFormat('EEE MMM dd, yyyy').format(entry!.entryDate);
    final createdStr = DateFormat('MMM dd, yyyy h:mm a').format(entry!.createdAt);
    final updatedStr = DateFormat('MMM dd, yyyy h:mm a').format(entry!.updatedAt);

    return Container(
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 12),
                    Text(
                      dateStr,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 16),
                

                
                // Action Buttons
                Row(
                  children: [
                    Text('Recently used:', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    const SizedBox(width: 12),
                    OutlinedButton(onPressed: () {}, child: const Text('Existing template 1')),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.add, size: 16), label: const Text('Add template')),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
              ],
            ),
          ),

          // Content Editor (Reusing JournalEntryForm or similar, but simplified for viewing/editing)
          // For now, we'll wrap the JournalEntryForm to allow editing the content.
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: JournalEntryForm(
                userId: userId,
                cubit: cubit,
                portfolioId: '8a57024c-05c2-475b-a2c4-0545865efa4a', // TODO: Pass from parent
                entry: entry,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }


}
