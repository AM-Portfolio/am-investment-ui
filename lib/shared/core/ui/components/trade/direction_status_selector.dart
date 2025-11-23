import 'package:flutter/material.dart';

import '../../../../../features/trade/internal/domain/enums/trade_directions.dart';
import '../../../../../features/trade/internal/domain/enums/trade_statuses.dart';

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

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Direction Section
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Icon(Icons.swap_horiz, size: 18, color: theme.colorScheme.primary.withOpacity(0.7)),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _CompactButton(
                          isSelected: selectedDirection == TradeDirections.long,
                          label: 'Long',
                          icon: Icons.arrow_upward,
                          color: Colors.green,
                          onTap: () => onDirectionChanged(TradeDirections.long),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _CompactButton(
                          isSelected: selectedDirection == TradeDirections.short,
                          label: 'Short',
                          icon: Icons.arrow_downward,
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

          // Divider
          Container(
            height: 32,
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),

          // Status Section
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Icon(Icons.radio_button_checked, size: 18, color: theme.colorScheme.primary.withOpacity(0.7)),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _CompactButton(
                          isSelected: selectedStatus == TradeStatuses.open,
                          label: 'Open',
                          icon: Icons.lock_open,
                          color: Colors.blue,
                          onTap: () => onStatusChanged(TradeStatuses.open),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _CompactButton(
                          isSelected: selectedStatus == TradeStatuses.closed,
                          label: 'Closed',
                          icon: Icons.lock,
                          color: Colors.grey,
                          onTap: () => onStatusChanged(TradeStatuses.closed),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactButton extends StatelessWidget {
  const _CompactButton({
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
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : theme.colorScheme.outline.withOpacity(0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? color : theme.colorScheme.onSurface.withOpacity(0.4), size: 14),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? color : theme.colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
