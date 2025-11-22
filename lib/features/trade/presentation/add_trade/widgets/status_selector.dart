import 'package:flutter/material.dart';

import '../../../internal/domain/enums/trade_statuses.dart';

/// Visual selector for trade status
class StatusSelector extends StatelessWidget {
  const StatusSelector({required this.selectedStatus, required this.onStatusSelected, super.key});
  final TradeStatuses? selectedStatus;
  final ValueChanged<TradeStatuses> onStatusSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Trade Status', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _StatusChip(
              status: TradeStatuses.open,
              label: 'Open',
              icon: Icons.lock_open,
              color: Colors.blue,
              isSelected: selectedStatus == TradeStatuses.open,
              onTap: () => onStatusSelected(TradeStatuses.open),
            ),
            _StatusChip(
              status: TradeStatuses.closed,
              label: 'Closed',
              icon: Icons.lock,
              color: Colors.green,
              isSelected: selectedStatus == TradeStatuses.closed,
              onTap: () => onStatusSelected(TradeStatuses.closed),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.status,
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });
  final TradeStatuses status;
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : theme.colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: isSelected ? color : theme.colorScheme.onSurface.withOpacity(0.6)),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : theme.colorScheme.onSurface,
              ),
            ),
            if (isSelected) ...[const SizedBox(width: 8), Icon(Icons.check_circle, color: color, size: 18)],
          ],
        ),
      ),
    );
  }
}
