import 'package:flutter/material.dart';

/// A customizable dropdown widget that provides consistent styling and behavior
/// across the application. Supports icons, hints, and custom styling.
class CustomDropdown<T> extends StatelessWidget {
  const CustomDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    super.key,
    this.hint,
    this.label,
    this.icon,
    this.primaryColor,
    this.height = 40,
    this.isExpanded = true,
    this.fontSize = 13,
    this.iconSize = 18,
    this.borderRadius = 12,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 12),
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.enabled = true,
  });

  /// Current selected value
  final T? value;

  /// List of dropdown items
  final List<DropdownMenuItem<T>> items;

  /// Callback when value changes
  final ValueChanged<T?>? onChanged;

  /// Hint text when no value is selected
  final String? hint;

  /// Label for the dropdown
  final String? label;

  /// Icon to show at the end of dropdown
  final IconData? icon;

  /// Primary color for styling
  final Color? primaryColor;

  /// Height of the dropdown container
  final double height;

  /// Whether dropdown should expand to fill available width
  final bool isExpanded;

  /// Font size for text
  final double fontSize;

  /// Size of the dropdown icon
  final double iconSize;

  /// Border radius for the container
  final double borderRadius;

  /// Padding inside the container
  final EdgeInsets contentPadding;

  /// Background color override
  final Color? backgroundColor;

  /// Border color override
  final Color? borderColor;

  /// Text color override
  final Color? textColor;

  /// Whether the dropdown is enabled
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final effectivePrimaryColor =
        primaryColor ?? Theme.of(context).primaryColor;
    final effectiveBackgroundColor =
        backgroundColor ?? effectivePrimaryColor.withOpacity(0.05);
    final effectiveBorderColor =
        borderColor ?? effectivePrimaryColor.withOpacity(0.2);

    return Container(
      height: height,
      padding: contentPadding,
      decoration: BoxDecoration(
        color: enabled ? effectiveBackgroundColor : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: enabled ? effectiveBorderColor : Colors.grey.shade300,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: isExpanded,
          hint: hint != null
              ? Text(
                  hint!,
                  style: TextStyle(
                    color: effectivePrimaryColor.withOpacity(0.7),
                    fontSize: fontSize,
                  ),
                )
              : null,
          icon: Icon(
            icon ?? Icons.expand_more,
            color: enabled
                ? effectivePrimaryColor.withOpacity(0.7)
                : Colors.grey.shade400,
            size: iconSize,
          ),
          style: TextStyle(
            color: enabled ? effectivePrimaryColor : Colors.grey.shade500,
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
          ),
          items: enabled ? items : [],
          onChanged: enabled ? onChanged : null,
        ),
      ),
    );
  }
}

/// Extension to help create dropdown items with consistent styling
extension DropdownItemHelper<T> on T {
  /// Creates a dropdown item with icon and text
  DropdownMenuItem<T> toDropdownItem({
    required String text,
    IconData? icon,
    Color? iconColor,
    double iconSize = 14,
    double fontSize = 13,
    bool expandText = true,
  }) => DropdownMenuItem<T>(
    value: this,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: iconSize, color: iconColor),
          const SizedBox(width: 8),
        ],
        if (expandText)
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: fontSize),
              overflow: TextOverflow.ellipsis,
            ),
          )
        else
          Text(text, style: TextStyle(fontSize: fontSize)),
      ],
    ),
  );

  /// Creates a simple dropdown item with just text
  DropdownMenuItem<T> toSimpleDropdownItem({
    required String text,
    double fontSize = 13,
  }) => DropdownMenuItem<T>(
    value: this,
    child: Text(text, style: TextStyle(fontSize: fontSize)),
  );
}

/// Predefined dropdown configurations for common use cases
class DropdownConfig {
  /// Configuration for compact dropdown (used in selector bars)
  static const compact = _DropdownConfig(
    height: 40,
    fontSize: 13,
    iconSize: 18,
    borderRadius: 12,
    contentPadding: EdgeInsets.symmetric(horizontal: 12),
  );

  /// Configuration for form dropdown (used in forms)
  static const form = _DropdownConfig(
    height: 48,
    fontSize: 14,
    iconSize: 20,
    borderRadius: 8,
    contentPadding: EdgeInsets.symmetric(horizontal: 16),
  );

  /// Configuration for large dropdown (used in prominent areas)
  static const large = _DropdownConfig(
    height: 56,
    fontSize: 16,
    iconSize: 24,
    borderRadius: 12,
    contentPadding: EdgeInsets.symmetric(horizontal: 16),
  );
}

class _DropdownConfig {
  const _DropdownConfig({
    required this.height,
    required this.fontSize,
    required this.iconSize,
    required this.borderRadius,
    required this.contentPadding,
  });

  final double height;
  final double fontSize;
  final double iconSize;
  final double borderRadius;
  final EdgeInsets contentPadding;
}
