import 'package:flutter/material.dart';

/// A reusable row widget for displaying label-value pairs.
///
/// This widget provides a consistent layout for displaying information
/// in a two-column format (label on left, value on right).
class InfoRow extends StatelessWidget {
  const InfoRow({required this.label, required this.value, this.valueColor, this.isBold = false, super.key});

  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[600]),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: valueColor ?? Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    ),
  );
}
