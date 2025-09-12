import 'package:flutter/material.dart';

/// Widget to display financial values with color-coded indicators
class ValueIndicator extends StatelessWidget {
  /// The value to display
  final double value;
  
  /// The label to display above the value
  final String label;
  
  /// Whether to show the value as a percentage
  final bool isPercentage;
  
  /// Whether to show positive/negative indicators
  final bool showIndicator;
  
  /// Whether to use compact formatting for large numbers
  final bool useCompactFormat;
  
  /// Custom text style for the value
  final TextStyle? valueStyle;
  
  /// Custom text style for the label
  final TextStyle? labelStyle;
  
  /// Constructor
  const ValueIndicator({
    Key? key,
    required this.value,
    required this.label,
    this.isPercentage = false,
    this.showIndicator = true,
    this.useCompactFormat = false,
    this.valueStyle,
    this.labelStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Determine color based on value
    Color valueColor;
    IconData? indicatorIcon;
    
    if (value > 0) {
      valueColor = Colors.green;
      indicatorIcon = Icons.arrow_upward;
    } else if (value < 0) {
      valueColor = Colors.red;
      indicatorIcon = Icons.arrow_downward;
    } else {
      valueColor = theme.colorScheme.onSurface;
      indicatorIcon = null;
    }
    
    // Format the value
    String formattedValue;
    if (isPercentage) {
      formattedValue = '${value.abs().toStringAsFixed(2)}%';
    } else if (useCompactFormat) {
      if (value.abs() >= 1000000) {
        formattedValue = '${(value.abs() / 1000000).toStringAsFixed(2)}M';
      } else if (value.abs() >= 1000) {
        formattedValue = '${(value.abs() / 1000).toStringAsFixed(2)}K';
      } else {
        formattedValue = value.abs().toStringAsFixed(2);
      }
    } else {
      formattedValue = value.abs().toStringAsFixed(2);
    }
    
    // Add prefix if needed
    if (!isPercentage) {
      formattedValue = '₹$formattedValue';
    }
    
    // Add sign if needed
    if (value > 0 && !isPercentage) {
      formattedValue = '+$formattedValue';
    } else if (value < 0 && !isPercentage) {
      formattedValue = '-$formattedValue';
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: labelStyle ?? theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIndicator && indicatorIcon != null)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  indicatorIcon,
                  color: valueColor,
                  size: 16,
                ),
              ),
            Text(
              formattedValue,
              style: valueStyle?.copyWith(color: valueColor) ?? 
                theme.textTheme.titleMedium?.copyWith(color: valueColor),
            ),
          ],
        ),
      ],
    );
  }
}
