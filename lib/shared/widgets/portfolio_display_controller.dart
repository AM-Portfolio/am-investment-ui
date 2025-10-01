import 'package:flutter/material.dart';

/// Enum for change type
enum ChangeType {
  daily,
  overall;

  String get displayName => switch (this) {
    ChangeType.daily => 'Today\'s Change',
    ChangeType.overall => 'Total P&L',
  };
}

/// Enum for display format
enum DisplayFormat {
  value,
  percentage;

  String get displayName => switch (this) {
    DisplayFormat.value => 'Value (\$)',
    DisplayFormat.percentage => 'Percentage (%)',
  };
}

/// Enum for sorting options
enum SortBy {
  name,
  profitLoss,
  profitLossPercentage,
  currentValue;

  String get displayName => switch (this) {
    SortBy.name => 'Name',
    SortBy.profitLoss => 'P&L Value',
    SortBy.profitLossPercentage => 'P&L %',
    SortBy.currentValue => 'Market Value',
  };
}

/// Comprehensive widget for controlling portfolio display options
class PortfolioDisplayController extends StatelessWidget {
  final ChangeType selectedChangeType;
  final DisplayFormat selectedDisplayFormat;
  final SortBy selectedSortBy;
  final bool sortAscending;
  final ValueChanged<ChangeType> onChangeTypeChanged;
  final ValueChanged<DisplayFormat> onDisplayFormatChanged;
  final ValueChanged<SortBy> onSortByChanged;
  final ValueChanged<bool> onSortOrderChanged;

  const PortfolioDisplayController({
    Key? key,
    required this.selectedChangeType,
    required this.selectedDisplayFormat,
    required this.selectedSortBy,
    required this.sortAscending,
    required this.onChangeTypeChanged,
    required this.onDisplayFormatChanged,
    required this.onSortByChanged,
    required this.onSortOrderChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Display Toggle (Today/Total)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: selectedChangeType == ChangeType.daily
                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: GestureDetector(
              onTap: () => onChangeTypeChanged(
                selectedChangeType == ChangeType.daily
                    ? ChangeType.overall
                    : ChangeType.daily,
              ),
              child: Text(
                selectedChangeType == ChangeType.daily ? 'Today' : 'Total',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: selectedChangeType == ChangeType.daily
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Format Toggle (\$ / %)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: selectedDisplayFormat == DisplayFormat.value
                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: GestureDetector(
              onTap: () => onDisplayFormatChanged(
                selectedDisplayFormat == DisplayFormat.value
                    ? DisplayFormat.percentage
                    : DisplayFormat.value,
              ),
              child: Text(
                selectedDisplayFormat == DisplayFormat.value ? '\$' : '%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: selectedDisplayFormat == DisplayFormat.value
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
          ),

          const Spacer(),

          // Sort Options - Tap to cycle through
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSortButton(context, 'Name', SortBy.name),
              const SizedBox(width: 12),
              _buildSortButton(context, 'P&L', SortBy.profitLoss),
              const SizedBox(width: 12),
              _buildSortButton(context, 'P&L%', SortBy.profitLossPercentage),
              const SizedBox(width: 12),
              _buildSortButton(context, 'Value', SortBy.currentValue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortButton(BuildContext context, String label, SortBy sortBy) {
    final isSelected = selectedSortBy == sortBy;
    final isAscending = sortAscending;

    return GestureDetector(
      onTap: () {
        if (isSelected) {
          // Toggle sort order if same sort type is selected
          onSortOrderChanged(!sortAscending);
        } else {
          // Change sort type and set to ascending by default
          onSortByChanged(sortBy);
          if (!sortAscending) {
            onSortOrderChanged(true);
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 2),
              Icon(
                isAscending
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                size: 16,
                color: Theme.of(context).primaryColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Legacy widget for backward compatibility
/// @deprecated Use PortfolioDisplayController instead
@Deprecated('Use PortfolioDisplayController instead')
class ChangeDisplaySelector extends StatelessWidget {
  final ChangeType selectedType;
  final DisplayFormat selectedFormat;
  final ValueChanged<ChangeType> onTypeChanged;
  final ValueChanged<DisplayFormat> onFormatChanged;

  const ChangeDisplaySelector({
    Key? key,
    required this.selectedType,
    required this.selectedFormat,
    required this.onTypeChanged,
    required this.onFormatChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PortfolioDisplayController(
      selectedChangeType: selectedType,
      selectedDisplayFormat: selectedFormat,
      selectedSortBy: SortBy.name,
      sortAscending: true,
      onChangeTypeChanged: onTypeChanged,
      onDisplayFormatChanged: onFormatChanged,
      onSortByChanged: (_) {},
      onSortOrderChanged: (_) {},
    );
  }
}

/// Legacy enum for backward compatibility
/// @deprecated Use DisplayFormat instead
@Deprecated('Use DisplayFormat instead')
typedef ChangeFormat = DisplayFormat;
