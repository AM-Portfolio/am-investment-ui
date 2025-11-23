import 'package:flutter/material.dart';

import '../../../../../features/trade/internal/domain/enums/broker_types.dart';
import '../../../../../features/trade/internal/domain/enums/order_types.dart';

/// Trade settings card (Broker & Order Type)
class TradeSettingsCard extends StatelessWidget {
  const TradeSettingsCard({
    required this.selectedBroker,
    required this.selectedOrderType,
    required this.onBrokerChanged,
    required this.onOrderTypeChanged,
    super.key,
  });

  final BrokerTypes? selectedBroker;
  final OrderTypes? selectedOrderType;
  final ValueChanged<BrokerTypes?> onBrokerChanged;
  final ValueChanged<OrderTypes?> onOrderTypeChanged;

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
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.tune, size: 16, color: Colors.purple),
              ),
              const SizedBox(width: 10),
              Text(
                'Trade Settings',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<BrokerTypes>(
                  value: selectedBroker,
                  decoration: InputDecoration(
                    labelText: 'Broker',
                    prefixIcon: const Icon(Icons.business_center, size: 18),
                    isDense: true,
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                  items: BrokerTypes.values
                      .map(
                        (broker) => DropdownMenuItem(
                          value: broker,
                          child: Text(broker.toString().split('.').last.toUpperCase()),
                        ),
                      )
                      .toList(),
                  onChanged: onBrokerChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<OrderTypes>(
                  value: selectedOrderType,
                  decoration: InputDecoration(
                    labelText: 'Order Type',
                    prefixIcon: const Icon(Icons.receipt_long, size: 18),
                    isDense: true,
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                  items: OrderTypes.values
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type.toString().split('.').last.toUpperCase())),
                      )
                      .toList(),
                  onChanged: onOrderTypeChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
