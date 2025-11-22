import 'package:flutter/material.dart';

import '../../../internal/domain/enums/trade_directions.dart';

/// Visual selector for trade direction (Long/Short)
class DirectionSelector extends StatelessWidget {
  const DirectionSelector({required this.selectedDirection, required this.onDirectionSelected, super.key});
  final TradeDirections? selectedDirection;
  final ValueChanged<TradeDirections> onDirectionSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Trade Direction', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _DirectionCard(
                direction: TradeDirections.long,
                label: 'LONG',
                icon: Icons.trending_up,
                color: Colors.green,
                isSelected: selectedDirection == TradeDirections.long,
                onTap: () => onDirectionSelected(TradeDirections.long),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _DirectionCard(
                direction: TradeDirections.short,
                label: 'SHORT',
                icon: Icons.trending_down,
                color: Colors.red,
                isSelected: selectedDirection == TradeDirections.short,
                onTap: () => onDirectionSelected(TradeDirections.short),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DirectionCard extends StatelessWidget {
  const _DirectionCard({
    required this.direction,
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });
  final TradeDirections direction;
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : theme.colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))]
              : null,
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: isSelected ? color : theme.colorScheme.onSurface.withOpacity(0.6)),
            const SizedBox(height: 12),
            Text(
              label,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? color : theme.colorScheme.onSurface,
              ),
            ),
            if (isSelected) ...[const SizedBox(height: 8), Icon(Icons.check_circle, color: color, size: 24)],
          ],
        ),
      ),
    );
  }
}
