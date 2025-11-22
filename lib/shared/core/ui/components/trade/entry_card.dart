import 'package:flutter/material.dart';

/// Entry details card for trade forms
class EntryCard extends StatelessWidget {
  const EntryCard({
    required this.entryDate,
    required this.entryPriceController,
    required this.entryQuantityController,
    required this.onDateTap,
    super.key,
  });

  final DateTime? entryDate;
  final TextEditingController entryPriceController;
  final TextEditingController entryQuantityController;
  final VoidCallback onDateTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.login, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text('Entry', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: onDateTap,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date *',
                prefixIcon: Icon(Icons.event, size: 18),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Text(
                entryDate?.toLocal().toString().split(' ')[0] ?? 'Not selected',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: entryPriceController,
                  decoration: const InputDecoration(
                    labelText: 'Price *',
                    prefixIcon: Icon(Icons.currency_rupee, size: 18),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: entryQuantityController,
                  decoration: const InputDecoration(
                    labelText: 'Qty *',
                    prefixIcon: Icon(Icons.tag, size: 18),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
