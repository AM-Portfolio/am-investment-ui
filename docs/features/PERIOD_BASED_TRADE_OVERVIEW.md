# Period-Based Trade Overview for Journal

## Overview
Enhanced the trade overview feature to support multiple time periods: Daily, Weekly, Monthly, and Yearly. Users can now link trades from different time periods to their journal entries, making it easier to create weekly reviews, monthly recaps, or yearly summaries.

## New Features

### 1. **Period Selector** 
Added a segmented button control with 4 period options:
- **Day** 📅 - View trades for a specific date
- **Week** 📊 - View all trades from Monday to Sunday of the selected week
- **Month** 📆 - View all trades for the entire month
- **Year** 🗓️ - View all trades for the entire year

### 2. **Smart Date Range Display**
The date selector now shows contextual information based on the selected period:
- **Daily**: "Nov 30, 2025"
- **Weekly**: "Nov 24 - Nov 30, 2025" (Monday to Sunday)
- **Monthly**: "November 2025"
- **Yearly**: "2025"

### 3. **Period-Aware Trade Loading**
The system automatically uses the appropriate API endpoint based on the selected period:
- **Daily**: Uses `getTradeCalendarByDay` for precise single-day queries
- **Weekly**: Uses `getTradeCalendarByDateRange` with Monday-Sunday range
- **Monthly**: Uses `getTradeCalendarByMonth` for optimized monthly queries
- **Yearly**: Uses `getTradeCalendarByDateRange` with Jan 1 - Dec 31 range

## Technical Implementation

### Updated Components

#### `TradePeriodType` Enum
```dart
enum TradePeriodType { daily, weekly, monthly, yearly }
```

#### `TradeOverviewSelector` Widget
**New Properties:**
- `selectedPeriod`: Current period type selection
- `onPeriodChanged`: Callback when period type changes

**New UI Elements:**
- Compact segmented button with icons for each period type
- Dynamic date range display based on selected period
- Responsive button sizing with compact density

#### `JournalEntryForm` State Management
**New State Variables:**
- `_tradePeriod`: Tracks currently selected period type (default: daily)

**Updated Methods:**
- `_loadTradesForPeriod()`: Replaces `_loadTradesForDate()`, handles all period types
  - Switches between different API calls based on period
  - Calculates appropriate date ranges for weekly/yearly periods
  - Converts trade entities to view models

**Period-Specific Logic:**
```dart
switch (period) {
  case TradePeriodType.daily:
    // Direct day query
    
  case TradePeriodType.weekly:
    // Calculate Mon-Sun range
    startDate = date.subtract(Duration(days: date.weekday - 1));
    endDate = startDate.add(Duration(days: 6));
    
  case TradePeriodType.monthly:
    // Month-optimized query
    
  case TradePeriodType.yearly:
    // Full year range
    startDate = DateTime(date.year, 1, 1);
    endDate = DateTime(date.year, 12, 31);
}
```

#### `TradePreviewDialog` Updates
**New Properties:**
- `periodType`: Displays appropriate header text based on period

**Updated Header Display:**
- "Trades for Nov 30, 2025" (daily)
- "Trades for Week of Nov 24 - Nov 30, 2025" (weekly)
- "Trades for November 2025" (monthly)
- "Trades for Year 2025" (yearly)

**Updated Empty State:**
- Changed message from "Try selecting a different date" to "Try selecting a different date or period"

## User Experience

### Use Cases

#### 1. **Daily Journal Entry** (Default)
- Quick reflection on a single day's trades
- Link specific trades from that day
- Perfect for day traders

#### 2. **Weekly Review**
- Select "Week" period
- View all trades from Monday to Sunday
- Great for swing traders reviewing weekly performance
- Link all relevant trades to a weekly summary

#### 3. **Monthly Recap**
- Select "Month" period
- See entire month's trading activity
- Ideal for monthly performance reviews
- Link significant trades to monthly analysis

#### 4. **Yearly Summary**
- Select "Year" period
- View full year's trades
- Perfect for annual reviews
- Link best/worst trades to yearly reflections

### Workflow Example

**Creating a Weekly Review:**
1. Click "New Entry" in journal
2. Set entry date to any day in the target week
3. Click period selector, choose "Week"
4. Date display updates to show "Nov 24 - Nov 30, 2025"
5. System automatically loads all trades from that week
6. Preview shows count: "47 Trades Available"
7. Click to open detailed trade selector
8. Select trades to link (e.g., biggest winners/losers)
9. Write weekly analysis in journal
10. Save entry with linked trades

## Benefits

### For Traders
- **Flexible Analysis**: Review trades at different time scales
- **Pattern Recognition**: Identify weekly/monthly patterns
- **Performance Tracking**: Easy to create regular review cadence
- **Context Preservation**: Link relevant trades to reflections

### For Learning
- **Weekly Reviews**: Consistent habit formation
- **Monthly Recaps**: Bigger picture analysis
- **Yearly Summaries**: Long-term progress tracking
- **Multi-Timeframe Insights**: Different perspectives on same data

### For Journaling
- **Versatile Entries**: Daily logs, weekly reviews, monthly recaps
- **Rich Context**: Link multiple trades across time periods
- **Better Organization**: Period-based categorization
- **Comprehensive Records**: Complete trading history association

## API Integration

### Endpoints Used

1. **Daily**: `GET /api/v1/trades/calendar/day`
   - Parameters: `portfolioId`, `date`
   - Returns: Trades for specific date

2. **Monthly**: `GET /api/v1/trades/calendar/month`
   - Parameters: `portfolioId`, `year`, `month`
   - Returns: All trades in month (optimized query)

3. **Weekly/Yearly**: `GET /api/v1/trades/calendar/date-range`
   - Parameters: `portfolioId`, `startDate`, `endDate`
   - Returns: All trades in date range

### Performance Optimization

- **Monthly queries**: Use dedicated endpoint for better performance
- **Daily queries**: Precise, fast single-day lookups
- **Range queries**: Efficient for weekly and yearly periods
- **Caching potential**: Period-based queries are cache-friendly

## UI Design

### Compact Segmented Button
- Small icons for each period type
- Minimal padding for space efficiency
- Clear visual selection state
- Responsive to theme changes

### Date Range Display
- Contextual formatting based on period
- Clear, readable date ranges
- Consistent with Material Design 3

### Trade Count Badge
- Updates based on period
- Shows total available and selected
- Visual feedback for selection state

## Future Enhancements

### Potential Additions
1. **Custom Date Ranges**: User-defined start/end dates
2. **Quarter View**: Q1, Q2, Q3, Q4 period option
3. **Multi-Period Comparison**: Compare weeks/months side-by-side
4. **Preset Ranges**: "Last 7 days", "Last 30 days", "YTD"
5. **Period Stats**: Show aggregate P&L for period
6. **Trade Filtering**: Filter period trades by status/symbol
7. **Calendar View**: Visual calendar with trade density
8. **Export Period**: Export all trades from selected period

### Advanced Features
- **Recurring Entries**: Auto-create weekly/monthly journals
- **Period Templates**: Pre-populated prompts for reviews
- **Comparison Mode**: Compare current period to previous
- **Goal Tracking**: Set and track period-based goals
- **Pattern Alerts**: Notify when similar patterns emerge

## Testing Considerations

### Test Cases
- ✅ Period selector switches correctly
- ✅ Date range calculates properly for each period
- ✅ Weekly range starts on Monday, ends on Sunday
- ✅ Monthly query uses correct year/month
- ✅ Yearly range covers Jan 1 - Dec 31
- ✅ Trade count updates when period changes
- ✅ Dialog header shows correct period text
- ✅ API calls use appropriate endpoints
- ✅ Empty state shows for periods with no trades
- ✅ Selection persists across period changes

### Edge Cases
- Week spanning two months/years
- Leap years in yearly view
- Current incomplete period (current week/month)
- Very large periods (100+ trades)
- Rapid period switching
- Network errors during load

## Conclusion

The period-based trade overview significantly enhances the journal feature by providing flexible time-scale analysis. Users can now create comprehensive reviews at daily, weekly, monthly, or yearly intervals, linking relevant trades to their reflections. This makes the journal more versatile and valuable for traders at all experience levels and trading styles.

The implementation leverages existing API infrastructure efficiently, using optimized endpoints for each period type. The UI is clean, compact, and intuitive, fitting naturally into the existing journal form design.
