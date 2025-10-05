import 'package:flutter/material.dart';

/// A customizable pill selector widget that displays options as selectable pills
/// Perfect for filters, tags, and multi-choice selections
class PillSelector<T> extends StatelessWidget {
  const PillSelector({
    required this.items,
    required this.selectedItem,
    required this.onSelectionChanged,
    required this.itemDisplayText,
    super.key,
    this.itemIcon,
    this.primaryColor,
    this.spacing = 6.0,
    this.runSpacing = 6.0,
    this.fontSize = 11.0,
    this.horizontalPadding = 10.0,
    this.verticalPadding = 4.0,
    this.borderRadius = 16.0,
    this.selectedTextColor = Colors.white,
    this.unselectedTextColor,
    this.selectedBackgroundColor,
    this.unselectedBackgroundColor = Colors.transparent,
    this.borderColor,
    this.enabled = true,
    this.scrollable = false,
    this.scrollDirection = Axis.horizontal,
  });

  /// List of items to display as pills
  final List<T> items;

  /// Currently selected item
  final T selectedItem;

  /// Callback when selection changes
  final ValueChanged<T> onSelectionChanged;

  /// Function to get display text for each item
  final String Function(T) itemDisplayText;

  /// Optional function to get icon for each item
  final IconData Function(T)? itemIcon;

  /// Primary color for styling
  final Color? primaryColor;

  /// Spacing between pills horizontally
  final double spacing;

  /// Spacing between pills vertically when wrapped
  final double runSpacing;

  /// Font size for pill text
  final double fontSize;

  /// Horizontal padding inside pills
  final double horizontalPadding;

  /// Vertical padding inside pills
  final double verticalPadding;

  /// Border radius for pills
  final double borderRadius;

  /// Text color when selected
  final Color selectedTextColor;

  /// Text color when not selected
  final Color? unselectedTextColor;

  /// Background color when selected
  final Color? selectedBackgroundColor;

  /// Background color when not selected
  final Color unselectedBackgroundColor;

  /// Border color (uses primaryColor by default)
  final Color? borderColor;

  /// Whether the selector is enabled
  final bool enabled;

  /// Whether to make pills scrollable
  final bool scrollable;

  /// Scroll direction when scrollable is true
  final Axis scrollDirection;

  @override
  Widget build(BuildContext context) {
    final effectivePrimaryColor =
        primaryColor ?? Theme.of(context).primaryColor;
    final effectiveUnselectedTextColor =
        unselectedTextColor ?? Colors.grey.shade700;
    final effectiveSelectedBackgroundColor =
        selectedBackgroundColor ?? effectivePrimaryColor;
    final effectiveBorderColor = borderColor ?? Colors.grey.shade400;

    final pillWidgets = items.map((item) {
      final isSelected = selectedItem == item;
      return InkWell(
        onTap: enabled ? () => onSelectionChanged(item) : null,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? effectiveSelectedBackgroundColor
                : unselectedBackgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: isSelected
                  ? effectiveSelectedBackgroundColor
                  : effectiveBorderColor,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (itemIcon != null) ...[
                Icon(
                  itemIcon!(item),
                  size: fontSize + 3,
                  color: isSelected
                      ? selectedTextColor
                      : effectiveUnselectedTextColor,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                itemDisplayText(item),
                style: TextStyle(
                  color: isSelected
                      ? selectedTextColor
                      : effectiveUnselectedTextColor,
                  fontSize: fontSize,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();

    if (scrollable && scrollDirection == Axis.horizontal) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: pillWidgets
              .map(
                (pill) => Container(
                  margin: EdgeInsets.only(right: spacing),
                  child: pill,
                ),
              )
              .toList(),
        ),
      );
    }

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: pillWidgets,
    );
  }
}

/// Predefined configurations for common pill selector use cases
class PillSelectorConfig {
  /// Configuration for compact pill selector (used in selector bars)
  static const compact = _PillSelectorConfig(
    fontSize: 11.0,
    horizontalPadding: 10.0,
    verticalPadding: 4.0,
    borderRadius: 16.0,
    spacing: 6.0,
    runSpacing: 6.0,
  );

  /// Configuration for normal pill selector
  static const normal = _PillSelectorConfig(
    fontSize: 12.0,
    horizontalPadding: 12.0,
    verticalPadding: 6.0,
    borderRadius: 20.0,
    spacing: 8.0,
    runSpacing: 8.0,
  );

  /// Configuration for large pill selector
  static const large = _PillSelectorConfig(
    fontSize: 14.0,
    horizontalPadding: 16.0,
    verticalPadding: 8.0,
    borderRadius: 24.0,
    spacing: 10.0,
    runSpacing: 10.0,
  );
}

class _PillSelectorConfig {
  const _PillSelectorConfig({
    required this.fontSize,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.borderRadius,
    required this.spacing,
    required this.runSpacing,
  });

  final double fontSize;
  final double horizontalPadding;
  final double verticalPadding;
  final double borderRadius;
  final double spacing;
  final double runSpacing;
}
