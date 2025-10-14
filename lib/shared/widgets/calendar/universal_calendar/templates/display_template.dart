import 'package:flutter/material.dart';

import '../config.dart';
import '../types.dart';

/// Helper class to manage filter operations
class FilterOperations {
  static void selectQuickRange(
    QuickRangeType rangeType,
    Function(DateSelection) onSelectionChanged,
  ) {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: rangeType.days));

    final selection = DateSelection(
      startDate: startDate,
      endDate: endDate,
      description: rangeType.label,
      filterType: DateFilterMode.quick,
      metadata: {'rangeType': rangeType.name},
    );

    onSelectionChanged(selection);
  }

  static void selectTimePeriod(
    TimePeriodType periodType,
    Function(DateSelection) onSelectionChanged,
  ) {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    switch (periodType.code) {
      case 'current_week':
        final weekday = now.weekday;
        startDate = now.subtract(Duration(days: weekday - 1));
        endDate = startDate.add(const Duration(days: 6));
        break;
      case 'current_month':
        startDate = DateTime(now.year, now.month);
        endDate = DateTime(now.year, now.month + 1, 0);
        break;
      case 'current_quarter':
        final quarter = ((now.month - 1) ~/ 3) + 1;
        final quarterStart = (quarter - 1) * 3 + 1;
        startDate = DateTime(now.year, quarterStart);
        endDate = DateTime(now.year, quarterStart + 3, 0);
        break;
      case 'current_year':
        startDate = DateTime(now.year);
        endDate = DateTime(now.year, 12, 31);
        break;
      case 'previous_week':
        final weekday = now.weekday;
        final thisWeekStart = now.subtract(Duration(days: weekday - 1));
        startDate = thisWeekStart.subtract(const Duration(days: 7));
        endDate = thisWeekStart.subtract(const Duration(days: 1));
        break;
      case 'previous_month':
        if (now.month == 1) {
          startDate = DateTime(now.year - 1, 12);
          endDate = DateTime(now.year - 1, 12, 31);
        } else {
          startDate = DateTime(now.year, now.month - 1);
          endDate = DateTime(now.year, now.month, 0);
        }
        break;
      case 'previous_quarter':
        final currentQuarter = ((now.month - 1) ~/ 3) + 1;
        final prevQuarter = currentQuarter == 1 ? 4 : currentQuarter - 1;
        final year = currentQuarter == 1 ? now.year - 1 : now.year;
        final quarterStart = (prevQuarter - 1) * 3 + 1;
        startDate = DateTime(year, quarterStart);
        endDate = DateTime(year, quarterStart + 3, 0);
        break;
      case 'previous_year':
        startDate = DateTime(now.year - 1);
        endDate = DateTime(now.year - 1, 12, 31);
        break;
      default:
        return;
    }

    final selection = DateSelection(
      startDate: startDate,
      endDate: endDate,
      description: periodType.label,
      filterType: DateFilterMode.period,
      metadata: {'periodType': periodType.name},
    );

    onSelectionChanged(selection);
  }

  static Future<void> selectCustomRange(
    BuildContext context,
    FilterConfig config,
    DateSelection currentSelection,
    Function(DateSelection) onSelectionChanged,
  ) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: config.minDate ?? DateTime(2020),
      lastDate: config.maxDate ?? DateTime.now(),
      initialDateRange: currentSelection.hasDateRange
          ? DateTimeRange(
              start: currentSelection.startDate!,
              end: currentSelection.endDate!,
            )
          : null,
    );

    if (picked != null) {
      final selection = DateSelection(
        startDate: picked.start,
        endDate: picked.end,
        description: 'Custom Range',
        filterType: DateFilterMode.custom,
        metadata: {'pickedRange': true},
      );

      onSelectionChanged(selection);
    }
  }

  static void clearSelection(Function(DateSelection) onSelectionChanged) {
    const selection = DateSelection(
      startDate: null,
      endDate: null,
      description: 'All Time',
      filterType: DateFilterMode.quick,
    );

    onSelectionChanged(selection);
  }

  static bool isQuickRangeSelected(
    DateSelection selection,
    QuickRangeType rangeType,
  ) {
    if (!selection.hasDateRange) return false;

    final now = DateTime.now();
    final expectedEnd = DateTime(now.year, now.month, now.day);
    final expectedStart = expectedEnd.subtract(Duration(days: rangeType.days));

    return selection.startDate!.isAtSameMomentAs(
          DateTime(expectedStart.year, expectedStart.month, expectedStart.day),
        ) &&
        selection.endDate!.isAtSameMomentAs(expectedEnd);
  }

  static bool isTimePeriodSelected(
    DateSelection selection,
    TimePeriodType periodType,
  ) {
    if (!selection.hasDateRange) return false;
    return selection.metadata?['periodType'] == periodType.name;
  }
}

/// Display template handles the visual presentation of date filters
class CalendarDisplayTemplate extends StatelessWidget {
  const CalendarDisplayTemplate({
    required this.config,
    required this.filterConfig,
    required this.currentSelection,
    required this.onSelectionChanged,
    super.key,
    this.customContent,
  });

  final DisplayConfig config;
  final FilterConfig filterConfig;
  final DateSelection currentSelection;
  final Function(DateSelection) onSelectionChanged;
  final Widget? customContent;

  @override
  Widget build(BuildContext context) {
    if (customContent != null) return customContent!;

    // Build content based on enabled modes
    if (filterConfig.enabledModes.length == 1) {
      return _buildSingleModeContent(context);
    } else {
      return _buildTabContent(context);
    }
  }

  Widget _buildSingleModeContent(BuildContext context) {
    final mode = filterConfig.enabledModes.first;

    switch (mode) {
      case DateFilterMode.quick:
        return _buildQuickFilters(context);
      case DateFilterMode.period:
        return _buildPeriodFilters(context);
      case DateFilterMode.custom:
        return _buildCustomFilter(context);
      case DateFilterMode.advanced:
        return _buildAdvancedFilters(context);
    }
  }

  Widget _buildTabContent(BuildContext context) => DefaultTabController(
    length: filterConfig.enabledModes.length,
    child: Column(
      children: [
        TabBar(
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(
            context,
          ).colorScheme.onSurface.withOpacity(0.7),
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: filterConfig.enabledModes
              .map((mode) => Tab(text: _getModeLabel(mode), height: 36))
              .toList(),
        ),
        SizedBox(
          height: config.compactMode ? 100 : 140,
          child: TabBarView(
            children: filterConfig.enabledModes.map((mode) {
              switch (mode) {
                case DateFilterMode.quick:
                  return _buildQuickFilters(context);
                case DateFilterMode.period:
                  return _buildPeriodFilters(context);
                case DateFilterMode.custom:
                  return _buildCustomFilter(context);
                case DateFilterMode.advanced:
                  return _buildAdvancedFilters(context);
              }
            }).toList(),
          ),
        ),
      ],
    ),
  );

  Widget _buildQuickFilters(BuildContext context) => Padding(
    padding: config.padding,
    child: GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: config.gridColumns,
        childAspectRatio: 3.5,
        crossAxisSpacing: config.spacing,
        mainAxisSpacing: config.spacing,
      ),
      itemCount: filterConfig.enabledQuickRanges.length,
      itemBuilder: (context, index) {
        final rangeType = filterConfig.enabledQuickRanges[index];
        final isSelected = FilterOperations.isQuickRangeSelected(
          currentSelection,
          rangeType,
        );

        return _buildFilterButton(
          context: context,
          label: rangeType.label,
          isSelected: isSelected,
          onTap: () =>
              FilterOperations.selectQuickRange(rangeType, onSelectionChanged),
        );
      },
    ),
  );

  Widget _buildPeriodFilters(BuildContext context) => Padding(
    padding: config.padding,
    child: GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: config.gridColumns,
        childAspectRatio: 3.5,
        crossAxisSpacing: config.spacing,
        mainAxisSpacing: config.spacing,
      ),
      itemCount: filterConfig.enabledTimePeriods.length,
      itemBuilder: (context, index) {
        final periodType = filterConfig.enabledTimePeriods[index];
        final isSelected = FilterOperations.isTimePeriodSelected(
          currentSelection,
          periodType,
        );

        return _buildFilterButton(
          context: context,
          label: periodType.label,
          isSelected: isSelected,
          onTap: () =>
              FilterOperations.selectTimePeriod(periodType, onSelectionChanged),
        );
      },
    ),
  );

  Widget _buildCustomFilter(BuildContext context) => Padding(
    padding: config.padding,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.date_range, size: 20),
            label: const Text('Select Custom Range'),
            onPressed: () => FilterOperations.selectCustomRange(
              context,
              filterConfig,
              currentSelection,
              onSelectionChanged,
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(
                config.compactMode ? 140 : 180,
                config.itemHeight,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          if (!config.compactMode) ...[
            const SizedBox(height: 8),
            Text(
              'Pick specific start and end dates',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ],
      ),
    ),
  );

  Widget _buildAdvancedFilters(BuildContext context) => Padding(
    padding: config.padding,
    child: Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildQuickFilters(context)),
              const SizedBox(width: 8),
              Expanded(child: _buildPeriodFilters(context)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _buildCustomFilter(context),
      ],
    ),
  );

  Widget _buildFilterButton({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    switch (config.buttonStyle) {
      case CalendarButtonStyle.chip:
        return FilterChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (_) => onTap(),
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedColor: Theme.of(context).colorScheme.primaryContainer,
        );

      case CalendarButtonStyle.outlined:
        return OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            backgroundColor: isSelected
                ? Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withOpacity(0.3)
                : null,
            side: BorderSide(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline.withOpacity(0.5),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        );

      case CalendarButtonStyle.filled:
        return FilledButton(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            backgroundColor: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: Text(label),
        );

      case CalendarButtonStyle.text:
        return TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            backgroundColor: isSelected
                ? Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withOpacity(0.3)
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        );

      case CalendarButtonStyle.elevated:
      default:
        return ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
          ),
          child: Text(label),
        );
    }
  }

  String _getModeLabel(DateFilterMode mode) {
    switch (mode) {
      case DateFilterMode.quick:
        return 'Quick';
      case DateFilterMode.period:
        return 'Period';
      case DateFilterMode.custom:
        return 'Custom';
      case DateFilterMode.advanced:
        return 'Advanced';
    }
  }
}
