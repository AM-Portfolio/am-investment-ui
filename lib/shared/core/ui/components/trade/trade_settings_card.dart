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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.15)),
      ),
      padding: EdgeInsets.all(isMobile ? 8 : 10),
      child: Row(
        children: [
          if (!isMobile) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
              child: const Icon(Icons.tune, size: 16, color: Colors.purple),
            ),
            const SizedBox(width: 8),
            Text(
              'Trade Settings',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: DropdownButtonFormField<BrokerTypes>(
              value: selectedBroker,
              decoration: InputDecoration(
                labelText: isMobile ? null : 'Broker',
                hintText: isMobile && selectedBroker == null ? 'Broker' : null,
                prefixIcon: isMobile ? null : const Icon(Icons.business_center, size: 18),
                isDense: true,
                filled: true,
                fillColor: theme.colorScheme.surface.withOpacity(0.6),
                contentPadding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: isMobile ? 6 : 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.25)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                ),
              ),
              isExpanded: true,
              items: BrokerTypes.values
                  .map(
                    (broker) => DropdownMenuItem(
                      value: broker,
                      child: Text(broker.toString().split('.').last.toUpperCase(), overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: onBrokerChanged,
            ),
          ),
          SizedBox(width: isMobile ? 6 : 8),
          Expanded(
            child: DropdownButtonFormField<OrderTypes>(
              value: selectedOrderType,
              decoration: InputDecoration(
                labelText: isMobile ? null : 'Order Type',
                hintText: isMobile && selectedOrderType == null ? 'Order' : null,
                prefixIcon: isMobile ? null : const Icon(Icons.receipt_long, size: 18),
                isDense: true,
                filled: true,
                fillColor: theme.colorScheme.surface.withOpacity(0.6),
                contentPadding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: isMobile ? 6 : 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.25)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                ),
              ),
              isExpanded: true,
              items: OrderTypes.values
                  .map(
                    (type) => DropdownMenuItem(value: type, child: Text(type.toString().split('.').last.toUpperCase())),
                  )
                  .toList(),
              onChanged: onOrderTypeChanged,
            ),
          ),
        ],
      ),
    );
  }
}
