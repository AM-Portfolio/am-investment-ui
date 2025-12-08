# Trade Calendar Migration to Shared Widgets

## Overview
This document outlines the migration of trade calendar logic from `features/trade/presentation/widgets` to the shared `lib/shared/widgets/calendar/universal_calendar` system.

## What Has Been Created

### 1. New Shared Calendar Types (`hierarchical_calendar_types.dart`)
- `CalendarViewLevel` - Enum for yearly/monthly/daily hierarchy
- `CalendarCellState` - Visual state indicators for calendar cells
- `DayCalendarData` - Data model for a single day
- `MonthCalendarData` - Data model for a month summary
- `YearCalendarData` - Data model for a year summary
- `HierarchicalCalendarNavigation` - Navigation state management
- `HierarchicalCalendarConfig` - Configuration for calendar behavior
- `CalendarEventDetail` - Trade/event details for a specific day

### 2. Hierarchical Calendar View Widget (`hierarchical_calendar_view.dart`)
A complete replacement for the old calendar views with:
- **Yearly View**: Grid of 12 months with mini calendars
- **Monthly View**: Full calendar grid of days (placeholder)
- **Daily View**: Event/trade list (placeholder)
- **Inline Day Selection**: Shows trade details below yearly view without navigation
- **No Summary Cards**: Monthly and daily summaries removed as per requirements
- **Hover Tooltips**: Day cells show trade info on hover
- **Responsive Design**: Adapts to mobile/tablet/desktop

### 3. Data Converter (`trade_calendar_converter.dart`)
Converts existing trade calendar data to shared format:
- `fromYearlyViewModel()` - YearlyCalendarData → YearCalendarData
- `fromMonthSummary()` - MonthSummary → MonthCalendarData
- `fromMonthlyViewModel()` - MonthlyCalendarData → MonthCalendarData
- `fromDaySummary()` - DaySummary → DayCalendarData
- `fromTradeDetail()` - TradeDetail → CalendarEventDetail
- `fromDailyViewModel()` - DailyCalendarData → List<CalendarEventDetail>

## Migration Steps

### Step 1: Update Imports
Replace old imports:
```dart
// OLD
import '../widgets/calendar_views.dart';
import '../widgets/calendar_cards.dart';

// NEW
import 'package:am_investment_ui/shared/widgets/calendar/universal_calendar/calendar_types.dart';
import 'package:am_investment_ui/shared/widgets/calendar/universal_calendar/hierarchical_calendar_view.dart';
import 'package:am_investment_ui/shared/widgets/calendar/universal_calendar/trade_calendar_converter.dart';
```

### Step 2: Convert Data Models
```dart
// In your cubit or view model converter:
import 'package:am_investment_ui/shared/widgets/calendar/universal_calendar/trade_calendar_converter.dart';

// Convert yearly data
final yearCalendarData = TradeCalendarDataConverter.fromYearlyViewModel(viewModel.yearlyData);

// Convert monthly data
final monthCalendarData = TradeCalendarDataConverter.fromMonthlyViewModel(viewModel.monthlyData);

// Convert daily events
final events = TradeCalendarDataConverter.fromDailyViewModel(viewModel.dailyData);
```

### Step 3: Replace Widget Usage
```dart
// OLD - YearlyCalendarView
YearlyCalendarView(
  yearData: yearData,
  onMonthTap: (month) => cubit.navigateToMonthly(...),
  onPreviousYear: () => cubit.navigateToPreviousYear(),
  onNextYear: () => cubit.navigateToNextYear(),
)

// NEW - HierarchicalCalendarView  
HierarchicalCalendarView(
  yearData: TradeCalendarDataConverter.fromYearlyViewModel(yearData),
  config: const HierarchicalCalendarConfig(
    showYearSummary: true,
    showMonthSummary: false,  // Removed as per requirement
    showDaySummary: false,    // Removed as per requirement
    showInlineTradeDetails: true,
    enableHoverTooltips: true,
  ),
  onMonthSelected: (month) {
    // Optional: Load month details
  },
  onDaySelected: (month, day) {
    // Load and display trades for selected day
  },
  eventBuilder: (events) {
    // Custom trade list UI (optional)
    return ListView.builder(...);
  },
)
```

### Step 4: Handle Day Selection for Inline Details
```dart
class _TradeCalendarPageState extends State<TradeCalendarPage> {
  List<CalendarEventDetail> _selectedDayEvents = [];

  @override
  Widget build(BuildContext context) {
    return HierarchicalCalendarView(
      yearData: yearCalendarData,
      onDaySelected: (month, day) async {
        // Fetch trades for the selected day
        final dailyData = await cubit.getDailyData(month, day);
        setState(() {
          _selectedDayEvents = TradeCalendarDataConverter.fromDailyViewModel(dailyData);
        });
      },
      eventBuilder: (events) {
        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return _buildTradeCard(event);
          },
        );
      },
    );
  }
}
```

## Configuration Options

### HierarchicalCalendarConfig
```dart
const HierarchicalCalendarConfig({
  bool enableMonthNavigation = true,      // Allow drilling into month view
  bool enableDayNavigation = true,        // Allow drilling into day view
  bool showYearSummary = true,           // Show year summary card
  bool showMonthSummary = false,         // Show month summary (disabled)
  bool showDaySummary = false,           // Show day summary (disabled)
  bool showInlineTradeDetails = true,    // Show trades below calendar
  bool showMiniCalendar = true,          // Show mini calendar in month cards
  bool enableHoverTooltips = true,       // Show hover tooltips on days
  int? yearGridColumns,                  // null = responsive
  int monthGridColumns = 7,              // Days of week
})
```

## Key Differences from Old Implementation

### ✅ Improvements
1. **No Summary Cards** - Monthly and daily summary cards removed for cleaner UI
2. **Inline Trade Details** - Trades show below calendar, no navigation needed
3. **Hover Information** - Day cells show trade info on hover
4. **Shared Codebase** - Reusable across portfolio, analytics, etc.
5. **Better Configuration** - Fine-grained control over features
6. **Type Safety** - Strongly typed data models
7. **Responsive** - Better mobile/tablet/desktop adaptation

### 🔄 Changes Required
1. **Data Conversion** - Must convert view models using `TradeCalendarDataConverter`
2. **Event Loading** - Must implement `onDaySelected` to load trades
3. **Custom Rendering** - Use `eventBuilder` for custom trade cards

## File Migration Checklist

- [x] Create `hierarchical_calendar_types.dart`
- [x] Create `hierarchical_calendar_view.dart`
- [x] Create `trade_calendar_converter.dart`
- [x] Update `calendar_types.dart` exports
- [ ] Update `TradeCalendarHierarchicalPage` to use new widgets
- [ ] Update `TradeCalendarCubit` to provide converted data
- [ ] Test yearly view with mini calendars
- [ ] Test inline day selection
- [ ] Test hover tooltips
- [ ] Deprecate old `calendar_views.dart`
- [ ] Deprecate old `calendar_cards.dart`
- [ ] Update documentation
- [ ] Update tests

## Example: Full Page Implementation

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:am_investment_ui/shared/widgets/calendar/universal_calendar/calendar_types.dart';

class TradeCalendarPage extends StatefulWidget {
  const TradeCalendarPage({
    required this.userId,
    required this.portfolioId,
    super.key,
  });

  final String userId;
  final String portfolioId;

  @override
  State<TradeCalendarPage> createState() => _TradeCalendarPageState();
}

class _TradeCalendarPageState extends State<TradeCalendarPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trade Calendar')),
      body: BlocBuilder<TradeCalendarCubit, TradeCalendarState>(
        builder: (context, state) {
          if (state is TradeCalendarLoaded) {
            final yearData = TradeCalendarDataConverter.fromYearlyViewModel(
              context.read<TradeCalendarCubit>().getYearlyCalendarData()!,
            );

            return HierarchicalCalendarView(
              yearData: yearData,
              config: const HierarchicalCalendarConfig(
                showYearSummary: true,
                showInlineTradeDetails: true,
                enableHoverTooltips: true,
              ),
              onDaySelected: (month, day) {
                // Will trigger inline trade details display
                context.read<TradeCalendarCubit>().loadDayTrades(
                  userId: widget.userId,
                  portfolioId: widget.portfolioId,
                  year: yearData.year,
                  month: month,
                  day: day,
                );
              },
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
```

## Next Steps

1. **Update TradeCalendarCubit**: Add method to provide data in new format
2. **Update Page**: Replace old widgets with `HierarchicalCalendarView`
3. **Test**: Verify all functionality works as expected
4. **Cleanup**: Remove old calendar_views.dart and calendar_cards.dart
5. **Document**: Update API documentation

## Benefits of Migration

1. **Maintainability**: Single source of truth for calendar logic
2. **Reusability**: Use same calendar for portfolio, analytics, etc.
3. **Consistency**: Same UX across all modules
4. **Flexibility**: Easy to configure and customize
5. **Performance**: Optimized rendering and state management
6. **Testing**: Easier to test shared components

## Support

For questions or issues with migration, refer to:
- `lib/shared/widgets/calendar/universal_calendar/README.md`
- `lib/shared/widgets/calendar/universal_calendar/integration_guide.dart`
- This migration guide
