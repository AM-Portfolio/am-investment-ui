import 'package:flutter/material.dart';

import '../../../../../features/trade/internal/domain/enums/trade_directions.dart';
import '../../../../../features/trade/internal/domain/enums/trade_statuses.dart';
import '../../../../../features/trade/presentation/add_trade/widgets/status_selector.dart';

/// Compact inline Direction & Status selector for trade forms
class DirectionStatusSelector extends StatelessWidget {
  const DirectionStatusSelector({
    required this.selectedDirection,
    required this.selectedStatus,
    required this.onDirectionChanged,
    required this.onStatusChanged,
    super.key,
  });

  final TradeDirections selectedDirection;
  final TradeStatuses selectedStatus;
  final ValueChanged<TradeDirections> onDirectionChanged;
  final ValueChanged<TradeStatuses> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              children: [
                Text('Direction:', style: theme.textTheme.labelMedium),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _DirectionButton(
                          isSelected: selectedDirection == TradeDirections.long,
                          label: 'LONG',
                          icon: Icons.trending_up,
                          color: Colors.green,
                          onTap: () => onDirectionChanged(TradeDirections.long),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _DirectionButton(
                          isSelected: selectedDirection == TradeDirections.short,
                          label: 'SHORT',
                          icon: Icons.trending_down,
                          color: Colors.red,
                          onTap: () => onDirectionChanged(TradeDirections.short),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        StatusSelector(selectedStatus: selectedStatus, onStatusSelected: onStatusChanged),
      ],
    );
  }
}

class _DirectionButton extends StatelessWidget {
  const _DirectionButton({
    required this.isSelected,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final bool isSelected;
  final String label;
  final IconData icon;
  final MaterialColor color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.shade100 : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? color.shade700 : theme.colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? color.shade700 : theme.colorScheme.onSurface.withOpacity(0.5), size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color.shade700 : theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
