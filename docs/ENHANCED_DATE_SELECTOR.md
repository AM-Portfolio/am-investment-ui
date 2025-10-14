# Enhanced Trade Calendar Date Selector

## Overview
The enhanced `TradeCalendarDateSelector` provides multiple flexible ways for users to filter their trade data by different time periods, making it easy to analyze trading performance across various timeframes.

## Selection Modes

### 1. 📅 Date Range
- **Custom Range Picker**: Select any start and end date using Flutter's native date range picker
- **Use Case**: Analyze specific periods, custom timeframes, or irregular date ranges
- **API Impact**: Passes exact start and end dates for precise filtering

### 2. 📆 Month Selection
- **Year Dropdown**: Choose from the last 5 years
- **Month Grid**: Interactive 3x4 grid with abbreviated month names (Jan, Feb, etc.)
- **Visual Feedback**: Selected month highlighted with primary color
- **Use Case**: Monthly performance analysis, month-over-month comparisons
- **API Impact**: Converts to first and last day of selected month

### 3. 📊 Quarter Selection  
- **Year Dropdown**: Choose from the last 5 years
- **Quarter Grid**: 2x2 grid showing Q1-Q4 with month ranges
- **Descriptions**: Shows "Jan-Mar", "Apr-Jun", etc. for clarity
- **Use Case**: Quarterly performance reviews, seasonal analysis
- **API Impact**: Converts to quarter start (1st day) and end (last day)

### 4. 📈 Year Selection
- **Year Grid**: 3x3 grid showing last 10 years
- **Single Tap**: Quick year selection with visual feedback
- **Use Case**: Annual performance analysis, year-over-year comparisons
- **API Impact**: Converts to January 1st - December 31st of selected year

### 5. ⚡ Quick Select
Two categories of quick filters:

#### **Current Periods** (Real-time)
- **This Week**: Monday to Sunday of current week
- **This Month**: 1st to last day of current month  
- **This Quarter**: Current quarter based on today's date
- **This Year**: January 1st to December 31st of current year

#### **Historical Periods** (Lookback)
- **Last 7 Days**: Rolling 7-day window from today
- **Last 30 Days**: Rolling 30-day window
- **Last 90 Days**: Rolling 90-day window (Quarter)
- **Last 6 Months**: Rolling 180-day window
- **Last Year**: Rolling 365-day window

## User Experience Features

### 🎯 Smart Selection Display
- **Current Selection**: Shows selected period in readable format
- **Clear Button**: Easily reset to "All Time" view
- **Visual Feedback**: Highlighted tabs and selected periods

### 📱 Responsive Design
- **Scrollable Content**: Tab content adapts to different screen sizes
- **Touch-Friendly**: Large buttons and proper spacing
- **Tablet Optimized**: Grid layouts work well on larger screens

### 🔄 API Integration
- **Automatic Refresh**: Triggers data reload when selection changes
- **Feedback Notifications**: Shows selected period in snackbar
- **Description Context**: Provides human-readable selection description

## Technical Implementation

### Callback Signature
```dart
typedef DateRangeCallback = void Function(
  DateTime? startDate, 
  DateTime? endDate,
  String selectionDescription,
);
```

### Date Range Conversion
All selection modes convert to standardized DateTime ranges:
- **Month**: `DateTime(year, month, 1)` to `DateTime(year, month+1, 0)`
- **Quarter**: `DateTime(year, quarterStart, 1)` to `DateTime(year, quarterEnd+1, 0)`
- **Year**: `DateTime(year, 1, 1)` to `DateTime(year, 12, 31)`

### State Management
- Maintains selection state across tab switches
- Preserves visual selection indicators
- Handles year dependencies for month/quarter selection

## Usage Example

```dart
TradeCalendarDateSelector(
  onDateRangeChanged: (startDate, endDate, description) {
    // Handle date range selection
    // startDate & endDate: null for "All Time", DateTime objects for specific ranges
    // description: Human-readable selection like "Q2 2024 (Apr - Jun)"
    
    // Trigger API call with new date range
    ref.invalidate(tradeCalendarStreamProvider);
    
    // Show user feedback
    showSnackBar(SnackBar(content: Text('Filter: $description')));
  },
  initialStartDate: DateTime.now().subtract(Duration(days: 30)),
  initialEndDate: DateTime.now(),
  initialMode: DateSelectionMode.quick,
  minDate: DateTime(2020),
  maxDate: DateTime.now(),
)
```

This enhanced date selector provides traders with intuitive, flexible options to analyze their trading performance across any timeframe, from daily analysis to multi-year trends.