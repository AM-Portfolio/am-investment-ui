# Hierarchical Calendar UI Implementation

## Overview
This document describes the implementation of a hierarchical drill-down calendar system for trade analytics with yearly → monthly → daily views.

## Architecture

### View Models (`lib/features/trade/presentation/models/calendar_view_models.dart`)

#### Enums
- **CalendarViewType**: `yearly`, `monthly`, `daily`

#### Data Models
1. **YearlyCalendarData**
   - Year-level aggregations
   - 12 month summaries
   - Best/worst month identification
   - Active months tracking
   - Profitable months count

2. **MonthlyCalendarData**
   - Month-level aggregations
   - Daily summaries for all days in month
   - Best/worst day identification
   - Trading days count
   - Average daily P&L

3. **DailyCalendarData**
   - Day-level details
   - Individual trade list
   - Symbol distribution
   - Average holding time
   - Volume calculations

4. **MonthSummary** (for yearly view)
   - Month number, year
   - Total trades, P&L
   - Win/loss counts
   - Trading days

5. **DaySummary** (for monthly view)
   - Day number, month, year
   - Total trades, P&L
   - Win/loss counts
   - Day of week helper

6. **TradeDetail** (for daily view)
   - Complete trade information
   - Entry/exit prices and times
   - Quantity, P&L
   - Holding duration
   - Status indicators

#### Navigation Models
1. **CalendarNavigationState**
   - Current view type
   - Year, month, day selection
   - Breadcrumb trail
   - Methods: `toMonthly()`, `toDaily()`, `toYearly()`, `changeYear()`

2. **CalendarBreadcrumb**
   - Label, year, month, day
   - Used for navigation trail

### Business Logic Services

#### CalendarAggregationService (`lib/features/trade/presentation/services/calendar_aggregation_service.dart`)
Responsible for data transformation and aggregation:

1. **aggregateYearlyData()**
   - Processes 12 months of data
   - Calculates yearly totals
   - Identifies best/worst months
   - Computes average monthly P&L

2. **aggregateMonthlyData()**
   - Processes all days in month
   - Calculates monthly totals
   - Identifies best/worst days
   - Computes average daily P&L

3. **aggregateDailyData()**
   - Processes all trades for day
   - Calculates symbol distribution
   - Computes average holding time
   - Aggregates volume and P&L

#### CalendarNavigationService (`lib/features/trade/presentation/services/calendar_navigation_service.dart`)
Manages view transitions and state:

1. **Navigation Methods**
   - `navigateToYearly()` - Go to year view
   - `navigateToMonthly()` - Drill down to month
   - `navigateToDaily()` - Drill down to day
   - `navigateBack()` - Go up one level
   - `navigateToBreadcrumb()` - Jump to breadcrumb level
   - `navigateToPreviousYear()` / `navigateToNextYear()` - Year navigation

2. **Helper Methods**
   - `getDateRangeForView()` - Get date range for current view
   - `getViewTitle()` - Get display title
   - `canNavigateBack()` - Check if back navigation possible
   - `isAtTopLevel()` - Check if at yearly view

3. **DateRange Model**
   - Start/end dates
   - Duration calculation
   - Date containment check

### UI Components

#### Calendar Cards (`lib/features/trade/presentation/widgets/calendar_cards.dart`)

1. **YearCard**
   - Displays year-level statistics
   - Shows P&L, trades, win rate, active months
   - Color-coded profitability indicator
   - Progress bar for active months
   - Click handler for drill-down

2. **MonthCard**
   - Displays month-level statistics
   - Shows P&L, trades, win rate, trading days
   - Highlights current month
   - Disabled state for months with no trades
   - Compact design for grid layout

3. **DayCard**
   - Displays day-level indicators
   - Day number
   - P&L indicator bar (green/red)
   - Trade count badge
   - Highlights today's date
   - Grayed out for non-current months
   - Click handler for drill-down

4. **TradeDetailCard**
   - Individual trade display
   - Symbol, type, quantity
   - P&L with percentage
   - Status icon (win/loss)
   - Click handler for details

#### Calendar Views (`lib/features/trade/presentation/widgets/calendar_views.dart`)

1. **YearlyCalendarView**
   - Year navigation header (previous/next buttons)
   - Year summary card (4 key metrics)
   - 12-month grid (4 columns)
   - Highlights current month
   - Month click → navigates to MonthlyCalendarView

2. **MonthlyCalendarView**
   - Month/year header with back button
   - Month summary card (4 key metrics)
   - Weekday headers (Mon-Sun)
   - Calendar grid (7 columns)
   - Highlights today
   - Day click → navigates to DailyCalendarView

3. **DailyCalendarView**
   - Date header with back button
   - Day summary card (4 key metrics)
   - Scrollable trade list
   - Empty state for no trades
   - Trade click → show details

### State Management

#### TradeCalendarCubit Updates (`lib/features/trade/presentation/cubit/trade_calendar_cubit.dart`)

**New Dependencies:**
- `GetTradeCalendarByMonth` use case
- `GetTradeCalendarByDay` use case
- `GetTradeCalendarByDateRange` use case
- `CalendarNavigationService`
- `CalendarAggregationService`

**New State:**
- `_navigationState: CalendarNavigationState` - Tracks current view

**New Methods:**

1. **Navigation Methods**
   ```dart
   navigateToYearly({userId, portfolioId, year?})
   navigateToMonthly({userId, portfolioId, month})
   navigateToDaily({userId, portfolioId, day})
   navigateBack({userId, portfolioId})
   navigateToBreadcrumb({userId, portfolioId, breadcrumb})
   changeYear({userId, portfolioId, year})
   navigateToPreviousYear({userId, portfolioId})
   navigateToNextYear({userId, portfolioId})
   ```

2. **Data Loading**
   ```dart
   _loadDataForCurrentView(userId, portfolioId)
   ```
   - Automatically determines which API to call based on current view
   - Yearly → uses `GetTradeCalendarByDateRange`
   - Monthly → uses `GetTradeCalendarByMonth`
   - Daily → uses `GetTradeCalendarByDay`

3. **Aggregation Methods**
   ```dart
   getYearlyCalendarData() -> YearlyCalendarData?
   getMonthlyCalendarData() -> MonthlyCalendarData?
   getDailyCalendarData() -> DailyCalendarData?
   ```

4. **Helper Methods**
   ```dart
   _emitHierarchicalCalendarState(calendarData, userId, portfolioId)
   _extractTradeDetailsFromCardData(cardDataList) -> List<TradeDetail>
   ```

**Getter:**
```dart
navigationState -> CalendarNavigationState
```

## User Experience Flow

### Yearly View (Default)
1. User lands on calendar page
2. Sees current year by default
3. Year summary shows: Total P&L, Total Trades, Win Rate, Active Months
4. Grid displays 12 month cards
5. Each month card shows: P&L, trades, win rate, trading days
6. Can navigate to previous/next year

### Monthly View (Drill-Down from Year)
1. User clicks on month card
2. Navigates to monthly view
3. Month summary shows: Total P&L, Total Trades, Win Rate, Trading Days
4. Calendar grid displays all days (Mon-Sun layout)
5. Each day card shows: day number, P&L indicator, trade count
6. Today's date highlighted
7. Back button returns to yearly view

### Daily View (Drill-Down from Month)
1. User clicks on day card
2. Navigates to daily view
3. Day summary shows: Total P&L, Total Trades, Win Rate, Symbols Traded
4. Scrollable list of all trades for that day
5. Each trade shows: symbol, type, quantity, P&L, status
6. Back button returns to monthly view

### Breadcrumb Navigation
1. Breadcrumbs display current path
2. Examples:
   - Yearly: "2024"
   - Monthly: "2024 > March"
   - Daily: "2024 > March > 15 March"
3. Click any breadcrumb to jump to that level

## Integration Requirements

The main calendar page (`trade_calendar_analytics_web_page.dart`) needs to:

1. **Import new components**
   ```dart
   import 'widgets/calendar_views.dart';
   import 'widgets/calendar_cards.dart';
   import 'models/calendar_view_models.dart' as view_models;
   ```

2. **Listen to navigation state**
   ```dart
   final navigationState = context.watch<TradeCalendarCubit>().navigationState;
   ```

3. **Render appropriate view**
   ```dart
   switch (navigationState.viewType) {
     case view_models.CalendarViewType.yearly:
       return YearlyCalendarView(...);
     case view_models.CalendarViewType.monthly:
       return MonthlyCalendarView(...);
     case view_models.CalendarViewType.daily:
       return DailyCalendarView(...);
   }
   ```

4. **Add breadcrumb navigation bar**
   ```dart
   Row(
     children: navigationState.breadcrumbs.map((crumb) => 
       TextButton(
         onPressed: () => cubit.navigateToBreadcrumb(...),
         child: Text(crumb.label),
       )
     ).toList(),
   )
   ```

5. **Wire up navigation callbacks**
   - Year card tap → `cubit.navigateToMonthly(month: month)`
   - Month card tap → `cubit.navigateToDaily(day: day)`
   - Back button → `cubit.navigateBack()`
   - Year change → `cubit.changeYear(year: year)`

## Benefits

1. **Modular Architecture**
   - Separate view models for each hierarchy level
   - Business logic isolated in services
   - Reusable card components

2. **Clean Separation of Concerns**
   - Views handle only UI
   - Services handle only logic
   - Cubit orchestrates everything

3. **Type Safety**
   - Freezed models with immutability
   - Compile-time validation checks
   - No optional drilling without required context

4. **Maintainability**
   - Each component in separate file
   - Clear naming conventions
   - Comprehensive documentation

5. **User Experience**
   - Intuitive drill-down navigation
   - Breadcrumb trail for context
   - Consistent visual design
   - Responsive to user actions

## Files Created/Modified

### New Files
1. `lib/features/trade/presentation/models/calendar_view_models.dart` (370 lines)
2. `lib/features/trade/presentation/services/calendar_aggregation_service.dart` (258 lines)
3. `lib/features/trade/presentation/services/calendar_navigation_service.dart` (186 lines)
4. `lib/features/trade/presentation/widgets/calendar_cards.dart` (403 lines)
5. `lib/features/trade/presentation/widgets/calendar_views.dart` (668 lines)

### Modified Files
1. `lib/features/trade/presentation/cubit/trade_calendar_cubit.dart`
   - Added 3 new use case dependencies
   - Added 2 new service instances
   - Added navigation state field
   - Added 9 navigation methods
   - Added 3 aggregation getters
   - Added helper methods

### Pending Integration
1. `lib/features/trade/presentation/pages/trade_calendar_analytics_web_page.dart`
   - Replace tabbed layout with hierarchical views
   - Add breadcrumb navigation
   - Wire up cubit navigation methods
   - Handle view switching

## Next Steps

1. Update `trade_calendar_analytics_web_page.dart` to use new hierarchical views
2. Test navigation flow (yearly → monthly → daily → back)
3. Test breadcrumb navigation
4. Test year navigation (previous/next)
5. Verify data loading for each view type
6. Test responsive behavior
7. Add error handling for navigation failures
8. Add loading states during view transitions
