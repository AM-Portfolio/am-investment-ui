import 'package:flutter/material.dart';

import '../../../internal/domain/entities/filter_criteria.dart';
import 'filter_group.dart';

/// Date Range Filter Group
class DateRangeFilterGroup extends FilterGroup {
  DateRangeFilterGroup({required this.onChanged, this.startDate, this.endDate});
  DateTime? startDate;
  DateTime? endDate;
  final Function(DateTime?, DateTime?) onChanged;

  @override
  String get title => 'Date Range';

  @override
  IconData get icon => Icons.date_range;

  @override
  bool get hasActiveFilters => startDate != null || endDate != null;

  @override
  void reset() {
    startDate = null;
    endDate = null;
    onChanged(null, null);
  }

  @override
  Widget buildContent(BuildContext context) => Row(
    children: [
      Expanded(
        child: _buildModernDateSelector(
          context,
          label: 'Start Date',
          value: startDate,
          onChanged: (date) {
            startDate = date;
            onChanged(startDate, endDate);
          },
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _buildModernDateSelector(
          context,
          label: 'End Date',
          value: endDate,
          onChanged: (date) {
            endDate = date;
            onChanged(startDate, endDate);
          },
        ),
      ),
    ],
  );

  Widget _buildModernDateSelector(
    BuildContext context, {
    required String label,
    required DateTime? value,
    required Function(DateTime?) onChanged,
  }) {
    final theme = Theme.of(context);
    final hasValue = value != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 10,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (context, child) => Theme(
                data: theme.copyWith(
                  colorScheme: theme.colorScheme.copyWith(
                    primary: theme.colorScheme.primary,
                    onPrimary: theme.colorScheme.onPrimary,
                  ),
                ),
                child: child!,
              ),
            );
            if (picked != null) {
              onChanged(picked);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: hasValue
                  ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                  : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasValue
                    ? theme.colorScheme.primary.withOpacity(0.3)
                    : theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  size: 14,
                  color: hasValue ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    hasValue ? _formatDate(value) : 'Select date',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: hasValue ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withOpacity(0.5),
                      fontWeight: hasValue ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
                if (hasValue)
                  GestureDetector(
                    onTap: () => onChanged(null),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close_rounded, size: 12, color: theme.colorScheme.primary),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  DateRangeFilter? toFilterCriteria() {
    if (startDate != null && endDate != null) {
      return DateRangeFilter(startDate: startDate!, endDate: endDate!);
    }
    return null;
  }
}
