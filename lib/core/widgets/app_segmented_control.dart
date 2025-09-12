import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

/// A platform-adaptive segmented control widget
class AppSegmentedControl<T extends Object> extends StatelessWidget {
  /// The currently selected value
  final T selectedValue;
  
  /// Map of values to display labels
  final Map<T, String> children;
  
  /// Callback when a segment is selected
  final ValueChanged<T> onValueChanged;
  
  /// Primary color for the control
  final Color? primaryColor;
  
  /// Constructor
  const AppSegmentedControl({
    Key? key,
    required this.selectedValue,
    required this.children,
    required this.onValueChanged,
    this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = primaryColor ?? theme.colorScheme.primary;
    
    // Use CupertinoSegmentedControl on iOS
    if (defaultTargetPlatform == TargetPlatform.iOS && !kIsWeb) {
      return CupertinoSegmentedControl<T>(
        children: Map.fromEntries(
          children.entries.map(
            (entry) => MapEntry(
              entry.key,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  entry.value,
                  style: TextStyle(
                    color: selectedValue == entry.key
                        ? CupertinoColors.white
                        : color,
                  ),
                ),
              ),
            ),
          ),
        ),
        onValueChanged: onValueChanged,
        selectedColor: color,
        unselectedColor: CupertinoColors.systemBackground,
        borderColor: color,
        groupValue: selectedValue,
      );
    }
    
    // Use SegmentedButton on Android/Web
    return SegmentedButton<T>(
      segments: children.entries.map((entry) {
        return ButtonSegment<T>(
          value: entry.key,
          label: Text(entry.value),
        );
      }).toList(),
      selected: {selectedValue},
      onSelectionChanged: (Set<T> selection) {
        if (selection.isNotEmpty) {
          onValueChanged(selection.first);
        }
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return color;
            }
            return Colors.transparent;
          },
        ),
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.white;
            }
            return color;
          },
        ),
      ),
    );
  }
}
