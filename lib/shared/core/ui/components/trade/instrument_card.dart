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
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.candlestick_chart, size: 16, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 10),
              Text(
                'Instrument',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: symbolController,
            decoration: InputDecoration(
              labelText: 'Symbol *',
              hintText: 'e.g., RELIANCE',
              prefixIcon: const Icon(Icons.search, size: 18),
              isDense: true,
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
              ),
            ),
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<ExchangeTypes>(
            value: selectedExchange,
            decoration: InputDecoration(
              labelText: 'Exchange *',
              prefixIcon: const Icon(Icons.account_balance, size: 18),
              isDense: true,
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
              ),
            ),
            items: ExchangeTypes.values
                .map(
                  (exchange) =>
                      DropdownMenuItem(value: exchange, child: Text(exchange.toString().split('.').last.toUpperCase())),
                )
                .toList(),
            onChanged: onExchangeChanged,
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<MarketSegments>(
            value: selectedSegment,
            decoration: InputDecoration(
              labelText: 'Segment *',
              prefixIcon: const Icon(Icons.pie_chart, size: 18),
              isDense: true,
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
              ),
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
