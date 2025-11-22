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
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text('Trade Settings', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<BrokerTypes>(
                  value: selectedBroker,
                  decoration: const InputDecoration(
                    labelText: 'Broker',
                    prefixIcon: Icon(Icons.account_balance, size: 18),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  decoration: const InputDecoration(
                    labelText: 'Order Type',
                    prefixIcon: Icon(Icons.receipt, size: 18),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
