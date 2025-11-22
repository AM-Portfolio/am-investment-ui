import 'package:flutter/material.dart';

import '../../../../../features/trade/internal/domain/enums/derivative_types.dart';
import '../../../../../features/trade/internal/domain/enums/option_types.dart';

/// Derivative details card for trade forms
class DerivativeCard extends StatelessWidget {
  const DerivativeCard({
    required this.selectedDerivativeType,
    required this.selectedOptionType,
    required this.strikePriceController,
    required this.expiryDate,
    required this.onDerivativeTypeChanged,
    required this.onOptionTypeChanged,
    required this.onExpiryDateTap,
    super.key,
  });

  final DerivativeTypes? selectedDerivativeType;
  final OptionTypes? selectedOptionType;
  final TextEditingController strikePriceController;
  final DateTime? expiryDate;
  final ValueChanged<DerivativeTypes?> onDerivativeTypeChanged;
  final ValueChanged<OptionTypes?> onOptionTypeChanged;
  final VoidCallback onExpiryDateTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(Icons.analytics, size: 16, color: Colors.purple.shade700),
                const SizedBox(width: 8),
                Text('Derivative (Optional)', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                DropdownButtonFormField<DerivativeTypes>(
                  value: selectedDerivativeType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    prefixIcon: Icon(Icons.analytics, size: 18),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: DerivativeTypes.values
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type.toString().split('.').last.toUpperCase())),
                      )
                      .toList(),
                  onChanged: onDerivativeTypeChanged,
                ),
                if (selectedDerivativeType != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: strikePriceController,
                          decoration: const InputDecoration(
                            labelText: 'Strike',
                            prefixIcon: Icon(Icons.gavel, size: 18),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<OptionTypes>(
                          value: selectedOptionType,
                          decoration: const InputDecoration(
                            labelText: 'Option',
                            prefixIcon: Icon(Icons.compare_arrows, size: 18),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: OptionTypes.values
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type.toString().split('.').last.toUpperCase()),
                                ),
                              )
                              .toList(),
                          onChanged: onOptionTypeChanged,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: onExpiryDateTap,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Expiry',
                        prefixIcon: Icon(Icons.calendar_today, size: 18),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: Text(
                        expiryDate?.toLocal().toString().split(' ')[0] ?? 'Not selected',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
