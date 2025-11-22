import 'package:flutter/material.dart';

import '../../../../../features/trade/internal/domain/enums/exchange_types.dart';
import '../../../../../features/trade/internal/domain/enums/market_segments.dart';

/// Instrument details card for trade forms
class InstrumentCard extends StatelessWidget {
  const InstrumentCard({
    required this.symbolController,
    required this.selectedExchange,
    required this.selectedSegment,
    required this.onExchangeChanged,
    required this.onSegmentChanged,
    super.key,
  });

  final TextEditingController symbolController;
  final ExchangeTypes? selectedExchange;
  final MarketSegments? selectedSegment;
  final ValueChanged<ExchangeTypes?> onExchangeChanged;
  final ValueChanged<MarketSegments?> onSegmentChanged;

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
              Icon(Icons.abc, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text('Instrument', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: symbolController,
            decoration: const InputDecoration(
              labelText: 'Symbol *',
              hintText: 'e.g., RELIANCE',
              prefixIcon: Icon(Icons.abc, size: 18),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<ExchangeTypes>(
            value: selectedExchange,
            decoration: const InputDecoration(
              labelText: 'Exchange *',
              prefixIcon: Icon(Icons.business, size: 18),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: ExchangeTypes.values
                .map(
                  (exchange) =>
                      DropdownMenuItem(value: exchange, child: Text(exchange.toString().split('.').last.toUpperCase())),
                )
                .toList(),
            onChanged: onExchangeChanged,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<MarketSegments>(
            value: selectedSegment,
            decoration: const InputDecoration(
              labelText: 'Segment *',
              prefixIcon: Icon(Icons.category, size: 18),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: MarketSegments.values
                .map(
                  (segment) =>
                      DropdownMenuItem(value: segment, child: Text(segment.toString().split('.').last.toUpperCase())),
                )
                .toList(),
            onChanged: onSegmentChanged,
          ),
        ],
      ),
    );
  }
}
