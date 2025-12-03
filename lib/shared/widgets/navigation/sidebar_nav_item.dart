import 'package:flutter/material.dart';

class SidebarNavItem<T> extends StatelessWidget {
  const SidebarNavItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.isEnabled = true,
    this.isCompact = false,
    this.isCondensed = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final T value;
  final T groupValue;
  final ValueChanged<T> onChanged;
  final bool isEnabled;
  final bool isCompact;
  final bool isCondensed;

  @override
  Widget build(BuildContext context) {
    final isSelected = groupValue == value;
    final theme = Theme.of(context);

    // Compact mode: Icon only with enhanced styling
    if (isCompact) {
      return Tooltip(
        message: title,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: isEnabled ? () => onChanged(value) : null,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                  border: isSelected ? Border.all(color: theme.colorScheme.primary, width: 2) : null,
                  boxShadow: isSelected
                      ? [BoxShadow(color: theme.colorScheme.primary.withOpacity(0.4), blurRadius: 8, spreadRadius: 1)]
                      : null,
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: isEnabled
                      ? (isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.primary)
                      : theme.colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Condensed mode: Icon + abbreviated text
    if (isCondensed) {
      return Tooltip(
        message: subtitle,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: isEnabled ? () => onChanged(value) : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isSelected ? theme.colorScheme.primaryContainer : Colors.transparent,
                  border: isSelected ? Border.all(color: theme.colorScheme.primary.withOpacity(0.5)) : null,
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isEnabled
                            ? (isSelected ? theme.colorScheme.primary : theme.colorScheme.primary.withOpacity(0.1))
                            : theme.colorScheme.onSurface.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: isEnabled
                            ? (isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.primary)
                            : theme.colorScheme.onSurface.withOpacity(0.4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title.split(' ').first, // First word only
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isEnabled
                            ? (isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface)
                            : theme.colorScheme.onSurface.withOpacity(0.4),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Full mode: Original design
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: isEnabled ? () => onChanged(value) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isSelected ? theme.colorScheme.primaryContainer : Colors.transparent,
              border: isSelected ? Border.all(color: theme.colorScheme.primary.withOpacity(0.3)) : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isEnabled
                        ? (isSelected ? theme.colorScheme.primary : theme.colorScheme.primary.withOpacity(0.1))
                        : theme.colorScheme.onSurface.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: isEnabled
                        ? (isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.primary)
                        : theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isEnabled
                              ? (isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface)
                              : theme.colorScheme.onSurface.withOpacity(0.4),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isEnabled
                                ? theme.colorScheme.onSurface.withOpacity(0.6)
                                : theme.colorScheme.onSurface.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!isEnabled) Icon(Icons.lock_outline, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.3)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
