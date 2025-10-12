import 'package:flutter/material.dart';
import '../../../data/models/calendar_data.dart';

class CalendarAnalyticsTemplate extends StatelessWidget {
  final CalendarData? calendar;
  final bool isLoading;
  final String? errorMessage;
  final Function(DateTime) onDateSelected;
  final bool isWebView;

  const CalendarAnalyticsTemplate({
    super.key,
    required this.calendar,
    required this.isLoading,
    this.errorMessage,
    required this.onDateSelected,
    this.isWebView = true,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(errorMessage!, style: const TextStyle(color: Colors.red)),
          ],
        ),
      );
    }

    if (calendar == null) {
      return const Center(child: Text('No calendar data available'));
    }

    return Column(
      children: [
        _buildHeader(),
        Expanded(child: _buildCalendarContent()),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Trade Calendar',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {},
              ),
              Text(
                DateTime.now().toString().substring(0, 7),
                style: const TextStyle(fontSize: 16),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarContent() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: 35,
      itemBuilder: (context, index) {
        final date = DateTime.now().subtract(Duration(days: 35 - index));
        return _buildCalendarDay(date);
      },
    );
  }

  Widget _buildCalendarDay(DateTime date) {
    return Card(
      child: InkWell(
        onTap: () => onDateSelected(date),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                date.day.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: date.day % 3 == 0 ? Colors.green : null,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
