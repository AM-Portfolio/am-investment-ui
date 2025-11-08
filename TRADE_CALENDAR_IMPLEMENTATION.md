# Trade Calendar API Integration - Implementation Summary

## Overview
Successfully extracted and expanded trade calendar functionality into separate, modular files with support for multiple calendar query types.

## Architecture Changes

### 1. Data Transfer Objects (DTOs)
**File**: `lib/features/trade/internal/data/dtos/trade_calendar_dto.dart`

Added type aliases for calendar variants (all use the same base structure):
- `TradeCalendarMonthDto` - Calendar by month
- `TradeCalendarDayDto` - Calendar by specific day
- `TradeCalendarDateRangeDto` - Calendar by date range  
- `TradeCalendarQuarterDto` - Calendar by quarter
- `TradeCalendarFinancialYearDto` - Calendar by financial year

All variants return the same structure: `{ "portfolioId": [TradeDetailDto, ...] }`

### 2. Remote Data Source
**File**: `lib/features/trade/internal/data/datasources/trade_remote_data_source.dart`

Added 5 new methods with API integration:

#### getTradeCalendarByMonth
```dart
Future<TradeCalendarDto> getTradeCalendarByMonth(
  String userId,
  String portfolioId, {
  required int year,
  required int month,
})
```
**API**: `GET /api/v1/trades/calendar/month?portfolioId={id}&year={year}&month={month}`

#### getTradeCalendarByDay
```dart
Future<TradeCalendarDto> getTradeCalendarByDay(
  String userId,
  String portfolioId, {
  required DateTime date,
})
```
**API**: `GET /api/v1/trades/calendar/day?date={YYYY-MM-DD}&portfolioId={id}`

#### getTradeCalendarByDateRange
```dart
Future<TradeCalendarDto> getTradeCalendarByDateRange(
  String userId,
  String portfolioId, {
  required DateTime startDate,
  required DateTime endDate,
})
```
**API**: `GET /api/v1/trades/calendar/date-range?startDate={start}&endDate={end}&portfolioId={id}`

#### getTradeCalendarByQuarter
```dart
Future<TradeCalendarDto> getTradeCalendarByQuarter(
  String userId,
  String portfolioId, {
  required int year,
  required int quarter,
})
```
**API**: `GET /api/v1/trades/calendar/quarter?portfolioId={id}&year={year}&quarter={quarter}`

#### getTradeCalendarByFinancialYear
```dart
Future<TradeCalendarDto> getTradeCalendarByFinancialYear(
  String userId,
  String portfolioId, {
  required int financialYear,
})
```
**API**: `GET /api/v1/trades/calendar/financial-year?portfolioId={id}&financialYear={year}`

**Legacy Method**: `getTradeCalendar()` now delegates to `getTradeCalendarByMonth()`

### 3. Mock Data Helper
**File**: `lib/features/trade/internal/data/datasources/trade_mock_data_helper.dart`

Added mock data methods:
- `getMockTradeCalendarByDay()` - Loads from `calender-by-day-response.json`
- `getMockTradeCalendarByDateRange()` - Loads from `calender-by-date-range-response.json`

### 4. Repository Layer
**File**: `lib/features/trade/internal/domain/repositories/trade_repository.dart`

Added abstract methods:
```dart
Future<TradeCalendar> getTradeCalendarByMonth(String userId, String portfolioId, {required int year, required int month});
Future<TradeCalendar> getTradeCalendarByDay(String userId, String portfolioId, {required DateTime date});
Future<TradeCalendar> getTradeCalendarByDateRange(String userId, String portfolioId, {required DateTime startDate, required DateTime endDate});
Future<TradeCalendar> getTradeCalendarByQuarter(String userId, String portfolioId, {required int year, required int quarter});
Future<TradeCalendar> getTradeCalendarByFinancialYear(String userId, String portfolioId, {required int financialYear});
```

**File**: `lib/features/trade/internal/data/repositories/trade_repository_impl.dart`

Implemented all methods with:
- Logging and error handling
- DTO to entity mapping via `TradeCalendarMapper`
- Cache management for month/quarter/financial year queries
- No caching for day and date range queries (more dynamic)

### 5. Use Cases
Created separate use case files for each calendar variant:

1. **get_trade_calendar_by_month.dart** - Monthly calendar with month validation (1-12)
2. **get_trade_calendar_by_day.dart** - Daily calendar 
3. **get_trade_calendar_by_date_range.dart** - Date range calendar with validation (startDate <= endDate)
4. **get_trade_calendar_by_quarter.dart** - Quarterly calendar with quarter validation (1-4)
5. **get_trade_calendar_by_financial_year.dart** - Financial year calendar

All use cases include:
- Parameter validation
- Comprehensive logging
- Error handling

### 6. Asset Configuration
**File**: `pubspec.yaml`

Added calendar mock data directory:
```yaml
- lib/assets/mock_data/trade/calander/
```

## API Endpoints Summary

| Type | Endpoint | Parameters |
|------|----------|------------|
| Month | `/api/v1/trades/calendar/month` | portfolioId, year, month |
| Day | `/api/v1/trades/calendar/day` | portfolioId, date (YYYY-MM-DD) |
| Date Range | `/api/v1/trades/calendar/date-range` | portfolioId, startDate, endDate |
| Quarter | `/api/v1/trades/calendar/quarter` | portfolioId, year, quarter (1-4) |
| Financial Year | `/api/v1/trades/calendar/financial-year` | portfolioId, financialYear |

## Response Format
All endpoints return the same structure:
```json
{
  "portfolioId": [
    {
      "tradeId": "...",
      "portfolioId": "...",
      "instrumentInfo": {...},
      "status": "...",
      "tradePositionType": "...",
      "entryInfo": {...},
      "exitInfo": {...},
      "metrics": {...},
      "tradeExecutions": [...],
      "tradeDate": "...",
      "tradeEndDate": "...",
      "psychologyData": {},
      "entryReasoning": {},
      "exitReasoning": {}
    }
  ]
}
```

## Mock Data Files
Located in `lib/assets/mock_data/trade/calander/`:
- `trade_calendar.json` - General calendar data
- `calender-by-day-response.json` - Day-specific trades (3 trades on 2020-09-23)
- `calender-by-date-range-response.json` - Date range trades (15 trades from Jul-Sep 2020)
- `calender-api.txt` - API endpoint documentation

## Usage Examples

### Getting Monthly Calendar
```dart
final calendar = await getTradeCalendarByMonth(
  userId,
  portfolioId,
  year: 2020,
  month: 9,
);
```

### Getting Daily Calendar
```dart
final calendar = await getTradeCalendarByDay(
  userId,
  portfolioId,
  date: DateTime(2020, 9, 23),
);
```

### Getting Date Range Calendar
```dart
final calendar = await getTradeCalendarByDateRange(
  userId,
  portfolioId,
  startDate: DateTime(2020, 7, 1),
  endDate: DateTime(2020, 9, 30),
);
```

## Benefits
1. ✅ **Modular Design** - Each calendar type has dedicated files
2. ✅ **Type Safety** - Separate methods with specific parameters
3. ✅ **Validation** - Input validation in use cases
4. ✅ **Logging** - Comprehensive logging at every layer
5. ✅ **Error Handling** - Fallback to mock data on API failures
6. ✅ **Clean Architecture** - Follows repository pattern with clear separation
7. ✅ **Backward Compatible** - Legacy `getTradeCalendar()` still works

## Next Steps
To fully integrate, you may want to:
1. Update the cubit to expose methods for each calendar type
2. Add providers/dependency injection for new use cases
3. Create UI components for different calendar views (day, range, quarter, etc.)
4. Add tests for new methods
5. Update documentation for calendar API usage patterns

## Files Created/Modified

### Created:
- `lib/features/trade/internal/domain/usecases/get_trade_calendar_by_month.dart`
- `lib/features/trade/internal/domain/usecases/get_trade_calendar_by_day.dart`
- `lib/features/trade/internal/domain/usecases/get_trade_calendar_by_date_range.dart`
- `lib/features/trade/internal/domain/usecases/get_trade_calendar_by_quarter.dart`
- `lib/features/trade/internal/domain/usecases/get_trade_calendar_by_financial_year.dart`

### Modified:
- `lib/features/trade/internal/data/dtos/trade_calendar_dto.dart`
- `lib/features/trade/internal/data/datasources/trade_remote_data_source.dart`
- `lib/features/trade/internal/data/datasources/trade_mock_data_helper.dart`
- `lib/features/trade/internal/domain/repositories/trade_repository.dart`
- `lib/features/trade/internal/data/repositories/trade_repository_impl.dart`
- `pubspec.yaml`
