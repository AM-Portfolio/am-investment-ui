import 'package:flutter/material.dart';

/// Reusable multi-select dropdown widget
class MultiSelectDropdown<T> extends StatelessWidget {
  const MultiSelectDropdown({
    required this.label,
    required this.selectedValues,
    required this.allValues,
    required this.formatter,
    required this.onChanged,
    super.key,
  });
  final String label;
  final List<T> selectedValues;
  final List<T> allValues;
  final String Function(T) formatter;
  final Function(List<T>) onChanged;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => _showMultiSelectDialog(context),
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: selectedValues.isNotEmpty
            ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () => onChanged([]))
            : const Icon(Icons.arrow_drop_down, size: 18),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        isDense: true,
      ),
      child: Text(
        selectedValues.isEmpty
            ? 'Select options'
            : selectedValues.length == 1
            ? formatter(selectedValues.first)
            : '${selectedValues.length} selected',
        style: TextStyle(color: selectedValues.isEmpty ? Colors.grey : null),
        overflow: TextOverflow.ellipsis,
      ),
    ),
  );

  Future<void> _showMultiSelectDialog(BuildContext context) async {
    final tempSelected = List<T>.from(selectedValues);

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(label),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: allValues.map((value) {
                final isSelected = tempSelected.contains(value);
                return CheckboxListTile(
                  title: Text(formatter(value)),
                  value: isSelected,
                  dense: true,
                  onChanged: (checked) {
                    setDialogState(() {
                      if (checked == true) {
                        tempSelected.add(value);
                      } else {
                        tempSelected.remove(value);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                setDialogState(tempSelected.clear);
              },
              child: const Text('Clear All'),
            ),
            ElevatedButton(
              onPressed: () {
                onChanged(tempSelected);
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
