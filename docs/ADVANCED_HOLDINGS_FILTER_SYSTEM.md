# Advanced Holdings Filter System - Implementation Guide

## Overview
Comprehensive filter system for the Trade Holdings Dashboard with support for all filter configuration fields. Provides both saved favorite filters and advanced custom filtering capabilities.

## Filter Architecture

### 1. **Filter Configuration Structure**

#### MetricsFilterConfig
Main configuration object containing all filter criteria:

```dart
MetricsFilterConfig(
  dateRange: DateRangeFilter?,
  instrumentFilters: InstrumentFilterCriteria?,
  tradeCharacteristics: TradeCharacteristicsFilter?,
  profitLossFilters: ProfitLossFilter?,
)
```

### 2. **Filter Categories**

#### A. Date Range Filter
- **Start Date**: Beginning of date range
- **End Date**: End of date range
- **UI**: Date picker dialogs
- **Application**: Filters holdings by entry/exit timestamps

#### B. Instrument Filters
- **Market Segments** (Multi-select dropdown):
  - Equity
  - Index
  - Equity Futures
  - Index Futures
  - Equity Options
  - Index Options
  - Unknown

- **Symbols** (Comma-separated text input):
  - Filter by base symbols (e.g., NIFTY, BANKNIFTY, RELIANCE)
  - Case-insensitive matching
  - Supports partial matching

- **Index Types** (Multi-select dropdown):
  - NIFTY
  - BANKNIFTY
  - FINNIFTY
  - MIDCPNIFTY

- **Derivative Types** (Multi-select dropdown):
  - Futures
  - Options

#### C. Trade Characteristics Filter
- **Direction** (Multi-select dropdown):
  - Buy
  - Sell

- **Status** (Multi-select dropdown):
  - Open
  - Win
  - Loss
  - Break Even

- **Strategies** (Comma-separated text input):
  - Filter by trading strategies
  - Examples: "Scalping", "Swing Trading", "Momentum Trading"

- **Tags** (Comma-separated text input):
  - Filter by custom tags
  - Examples: "earnings", "breakout", "reversal"

- **Holding Time Range**:
  - Min Holding Hours (numeric input)
  - Max Holding Hours (numeric input)
  - Application: Filters by duration between entry and exit

#### D. Profit/Loss Filters
- **P&L Range**:
  - Min P&L (₹) - Numeric input, supports negative values
  - Max P&L (₹) - Numeric input
  - Application: Filters by profit/loss amount

- **Position Size Range**:
  - Min Position Size (₹) - Numeric input
  - Max Position Size (₹) - Numeric input
  - Application: Filters by current value of holding

## UI Components

### 1. **AdvancedHoldingsFilterPanel**
Location: `lib/features/trade/presentation/widgets/advanced_holdings_filter_panel.dart`

#### Features:
- **Expandable/Collapsible**: Saves screen space
- **Active Filter Badge**: Shows count of active filters
- **Responsive Layout**:
  - Desktop: 2-column grid layout
  - Mobile: Single column vertical layout
- **Multi-Select Dropdowns**: For enum-based filters
- **Text Input Fields**: For symbols, strategies, tags
- **Date Pickers**: For date range selection
- **Numeric Input Fields**: For P&L and position size ranges

#### Actions:
- **Apply Filters**: Applies current configuration
- **Reset**: Clears all filters to default state

### 2. **FavoriteFilterPanel**
Location: `lib/features/trade/presentation/widgets/favorite_filter_panel.dart`

#### Features:
- Displays saved filters as chips
- Quick selection of predefined filters
- Star indicator for default filter
- Delete confirmation dialog
- Create new and manage filters actions

## Implementation Details

### Filter Application Logic

The filtering is applied client-side in `TradeHoldingsDashboardWebPage`:

```dart
List<TradeHoldingViewModel> _applyFilters(
  List<TradeHoldingViewModel> holdings,
  MetricsFilterConfig filter
)
```

#### Filter Execution Order:
1. Date Range Filter
2. Instrument Filters (Segments, Symbols, Index Types, Derivative Types)
3. Trade Characteristics (Direction, Status, Strategies, Tags, Holding Time)
4. Profit/Loss Filters (P&L Range, Position Size Range)

### Current Implementation Status

#### ✅ Fully Implemented:
- Symbol filtering (partial match, case-insensitive)
- Status filtering (exact match)
- P&L range filtering
- Position size range filtering
- Multi-select dropdowns with checkboxes
- Responsive layout (mobile/desktop)
- Active filter count badge
- Reset functionality

#### 🔄 Placeholder (TODO):
- Date range filtering (requires date field mapping)
- Market segment filtering (requires field mapping)
- Index type filtering (requires field mapping)
- Derivative type filtering (requires field mapping)
- Direction filtering (requires field mapping)
- Strategy filtering (requires field mapping)
- Tag filtering (requires field mapping)
- Holding time calculation and filtering

### Integration

The filter system is integrated into `TradeHoldingsDashboardWebPage`:

```dart
Column(
  children: [
    // Saved Filters (Favorite Filter Panel)
    FavoriteFilterPanel(...),
    
    // Advanced Custom Filters
    AdvancedHoldingsFilterPanel(
      initialConfig: _currentFilter,
      onApplyFilter: (config) { /* Apply */ },
      onReset: () { /* Reset */ },
    ),
    
    // Filtered Holdings List
    TradeHoldingsTemplate(
      holdings: _applyFilters(holdings, _currentFilter),
    ),
  ],
)
```

## Usage Flow

### 1. **Using Saved Filters**
   - User sees saved filters as chips in FavoriteFilterPanel
   - Clicks a filter chip
   - Filter configuration loads into AdvancedHoldingsFilterPanel
   - Holdings are automatically filtered
   - Success message shown

### 2. **Creating Custom Filters**
   - User expands AdvancedHoldingsFilterPanel
   - Selects/inputs desired filter criteria
   - Clicks "Apply Filters"
   - Holdings list updates with filtered results
   - Active filter count badge updates

### 3. **Resetting Filters**
   - User clicks "Reset" button
   - All filter fields clear
   - Holdings list shows all data
   - Success message shown

## Field Formatters

All enum values are formatted for display using helper methods:

- `_formatMarketSegment()`: MarketSegments → "Equity", "Index Futures", etc.
- `_formatIndexType()`: IndexTypes → "NIFTY", "BANKNIFTY", etc.
- `_formatDerivativeType()`: DerivativeTypes → "Futures", "Options"
- `_formatDirection()`: TradeDirections → "Buy", "Sell"
- `_formatStatus()`: TradeStatuses → "Open", "Win", "Loss", "Break Even"

## Performance Considerations

- **Client-Side Filtering**: All filtering happens in-memory
- **Optimized for < 1000 holdings**: For larger datasets, consider server-side filtering
- **Debouncing**: Text inputs could benefit from debouncing for large datasets
- **State Management**: Uses local state with MetricsFilterConfig

## Future Enhancements

### High Priority:
1. Complete field mapping for placeholder filters
2. Server-side filtering API integration
3. Save current advanced filter as favorite
4. Filter templates/presets

### Medium Priority:
1. Date range shortcuts (Last 7 days, This month, etc.)
2. Advanced symbol search with autocomplete
3. Filter combination logic (AND/OR operations)
4. Export filtered results

### Low Priority:
1. Filter usage analytics
2. Suggested filters based on portfolio
3. Filter validation and error messages
4. Keyboard shortcuts for filter operations

## Data Model Mapping

### TradeHoldingViewModel Fields Used:
- `symbol` → Symbol filtering
- `status` → Status filtering
- `profitLoss` → P&L filtering
- `currentValue` → Position size filtering
- `entryTimestamp` → Date filtering (TODO)
- `exitTimestamp` → Date filtering (TODO)
- `holdingDays` → Holding time filtering (TODO)
- `strategy` → Strategy filtering (TODO)
- `tags` → Tag filtering (TODO)
- `marketSegment` → Market segment filtering (TODO)
- `indexType` → Index type filtering (TODO)
- `derivativeType` → Derivative type filtering (TODO)
- `tradePositionType` → Direction filtering (TODO)

## Testing Checklist

- [ ] All multi-select dropdowns display correctly
- [ ] Date pickers work on mobile and desktop
- [ ] Numeric inputs validate properly
- [ ] Comma-separated inputs parse correctly
- [ ] Filter application updates holdings list
- [ ] Reset button clears all filters
- [ ] Active filter badge shows correct count
- [ ] Responsive layout works on all screen sizes
- [ ] Favorite filter integration works
- [ ] Empty state displays when no holdings match
- [ ] Performance with large datasets (>500 holdings)

## Code Organization

```
lib/features/trade/
├── internal/
│   └── domain/
│       ├── entities/
│       │   ├── favorite_filter.dart
│       │   ├── metrics_filter_config.dart
│       │   └── filter_criteria.dart
│       └── enums/
│           ├── market_segments.dart
│           ├── trade_statuses.dart
│           ├── trade_directions.dart
│           ├── index_types.dart
│           └── derivative_types.dart
├── presentation/
│   ├── widgets/
│   │   ├── advanced_holdings_filter_panel.dart  ← NEW
│   │   └── favorite_filter_panel.dart
│   └── web/pages/
│       └── trade_holdings_dashboard_web_page.dart  ← UPDATED
└── favorite_filter_providers.dart
```

## Summary

The advanced filter system provides comprehensive filtering capabilities covering:
- **5 Market Segments** via dropdown
- **4 Index Types** via dropdown
- **2 Derivative Types** via dropdown
- **2 Trade Directions** via dropdown
- **4 Trade Statuses** via dropdown
- **Unlimited Symbols** via text input
- **Unlimited Strategies** via text input
- **Unlimited Tags** via text input
- **Date Range** via date pickers
- **Holding Time Range** via numeric inputs
- **P&L Range** via numeric inputs
- **Position Size Range** via numeric inputs

All filters work together with AND logic - holdings must match ALL active filters to be displayed.
