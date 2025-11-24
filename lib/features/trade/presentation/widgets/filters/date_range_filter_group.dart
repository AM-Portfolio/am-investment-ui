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
  Widget buildContent(BuildContext context) => Column(
    children: [
      _buildDateField(context, 'Start Date', startDate, (date) {
        startDate = date;
        onChanged(startDate, endDate);
      }),
      const SizedBox(height: 12),
      _buildDateField(context, 'End Date', endDate, (date) {
        endDate = date;
        onChanged(startDate, endDate);
      }),
    ],
  );

  Widget _buildDateField(BuildContext context, String label, DateTime? value, Function(DateTime?) onChanged) => InkWell(
    onTap: () async {
      final picked = await showDatePicker(
        context: context,
        initialDate: value ?? DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );
      if (picked != null) {
        onChanged(picked);
      }
    },
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: value != null
            ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () => onChanged(null))
            : const Icon(Icons.calendar_today, size: 18),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        isDense: true,
      ),
      child: Text(
        value != null ? '${value.day}/${value.month}/${value.year}' : 'Select date',
        style: TextStyle(color: value != null ? null : Colors.grey),
      ),
    ),
  );

  DateRangeFilter? toFilterCriteria() {
    if (startDate != null && endDate != null) {
      return DateRangeFilter(startDate: startDate!, endDate: endDate!);
    }
    return null;
  }
}
