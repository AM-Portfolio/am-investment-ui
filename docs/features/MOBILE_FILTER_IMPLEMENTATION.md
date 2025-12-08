# Mobile Filter Implementation

## Overview
Mobile-optimized filter panel for trade holdings with bottom sheet design and tab-based organization. Provides the same filtering capabilities as the web version but optimized for touch interaction and limited screen space.

## Architecture

### Files Created
1. **mobile_filter_panel.dart** (609 lines)
   - Mobile-optimized filter panel component
   - Bottom sheet presentation at 85% screen height
   - Tab-based organization (4 tabs)
   - Favorite filters integration
   - Mobile-friendly action bar

2. **trade_holdings_dashboard_mobile_page.dart** (Updated - 177 lines)
   - Integrated MobileFilterPanel
   - Filter state management
   - Filter application logic
   - SnackBar confirmations

## Design Pattern

### Bottom Sheet with Tabs
The mobile filter uses a modal bottom sheet with tab-based organization to handle the complexity of multiple filter groups while maintaining usability on small screens.

**Benefits:**
- **Maximizes Screen Real Estate**: 85% height allows filters without covering entire screen
- **Organized Content**: 4 tabs group related filters logically
- **Touch-Optimized**: Large tap targets, appropriate spacing
- **Keyboard-Aware**: Responsive to keyboard with `viewInsets.bottom` padding
- **Quick Access**: Favorite filters dropdown for saved configurations

### Tab Organization

#### 1. Date Range Tab
- Start date picker
- End date picker
- Preset quick selections (Last 7 days, Last 30 days, etc.)

#### 2. Instrument Tab
- Market segments selector
- Symbol search/filter
- Index types filter
- Derivative types filter

#### 3. Trade Characteristics Tab
- Strategy selector
- Tags multi-select
- Direction filter (Long/Short)
- Status filter (Open/Closed)
- Holding time range

#### 4. P&L Tab
- Min profit/loss amount
- Max profit/loss amount
- Min position size
- Max position size

## Components

### MobileFilterPanel
```dart
class MobileFilterPanel extends ConsumerStatefulWidget {
  const MobileFilterPanel({
    required this.userId,
    required this.initialConfig,
    required this.onApplyFilter,
    super.key,
    this.onReset,
  });

  final String userId;
  final MetricsFilterConfig initialConfig;
  final Function(MetricsFilterConfig) onApplyFilter;
  final VoidCallback? onReset;
}
```

### Key Features

#### 1. Compact Header
```dart
Container(
  height: 48,
  padding: const EdgeInsets.symmetric(horizontal: 16),
  decoration: BoxDecoration(...),
  child: Row(
    children: [
      // Filter icon + count badge
      // Title
      // Favorite filters dropdown
      // Filter button
    ],
  ),
)
```

#### 2. Filter Count Badge
Shows number of active filters in a circular badge on the filter icon:
```dart
Badge(
  label: Text('3'), // Active filter count
  child: Icon(Icons.filter_list),
)
```

#### 3. Favorite Filters Integration
- Dropdown button in header
- Load saved filter configurations
- Apply favorite with one tap
- Manage favorites (rename, delete)
- Save current filters as new favorite

#### 4. Bottom Action Bar
```dart
Row(
  children: [
    TextButton(
      onPressed: _handleReset,
      child: Text('Reset'),
    ),
    Spacer(),
    FilledButton(
      onPressed: _handleApply,
      child: Text('Apply Filters'),
    ),
  ],
)
```

#### 5. Empty States
Each tab shows helpful empty state when no filters are active:
```dart
Center(
  child: Column(
    children: [
      Icon(Icons.filter_list_off),
      Text('No date range selected'),
      TextButton(
        onPressed: () => _tabController.index = 0,
        child: Text('Add Filter'),
      ),
    ],
  ),
)
```

## Filter Application Logic

### Dashboard Integration
The mobile dashboard applies filters before displaying holdings:

```dart
Widget _buildHoldingsTab() {
  return holdingsAsync.when(
    data: (holdingsViewModel) {
      final filteredHoldings = _applyFilters(
        holdingsViewModel.holdings,
        _currentFilter
      );
      
      return Column(
        children: [
          // MobileFilterPanel with BlocProvider
          BlocProvider(
            create: (context) => ref.read(favoriteFilterCubitProvider),
            child: MobileFilterPanel(
              userId: widget.userId,
              initialConfig: _currentFilter,
              onApplyFilter: (filter) {
                setState(() => _currentFilter = filter);
                ScaffoldMessenger.of(context).showSnackBar(...);
              },
              onReset: () {
                setState(() => _currentFilter = MetricsFilterConfig.empty());
                ScaffoldMessenger.of(context).showSnackBar(...);
              },
            ),
          ),
          // Holdings list with filtered data
          Expanded(
            child: TradeHoldingsTemplate(
              holdings: filteredHoldings,
              ...
            ),
          ),
        ],
      );
    },
  );
}
```

### Filter Implementation
```dart
List<TradeHoldingViewModel> _applyFilters(
  List<TradeHoldingViewModel> holdings,
  MetricsFilterConfig filter,
) {
  var result = holdings;

  // Date range
  if (filter.dateRange != null) {
    result = result.where((h) {
      final tradeDate = h.entryTimestamp;
      if (tradeDate == null) return true;
      return tradeDate.isAfter(filter.dateRange!.startDate) &&
             tradeDate.isBefore(filter.dateRange!.endDate);
    }).toList();
  }

  // Instrument filters
  if (filter.instrumentFilters != null) {
    if (filter.instrumentFilters!.baseSymbols.isNotEmpty) {
      result = result.where((h) =>
        filter.instrumentFilters!.baseSymbols.any((symbol) => 
          h.symbol.toUpperCase().contains(symbol.toUpperCase())
        )
      ).toList();
    }
  }

  // Trade characteristics
  if (filter.tradeCharacteristics != null) {
    if (filter.tradeCharacteristics!.statuses.isNotEmpty) {
      result = result.where((h) {
        if (h.status == null) return false;
        return filter.tradeCharacteristics!.statuses.any((status) => 
          h.status!.toLowerCase() == status.name.toLowerCase()
        );
      }).toList();
    }
    
    if (filter.tradeCharacteristics!.strategies.isNotEmpty) {
      result = result.where((h) {
        if (h.strategy == null) return false;
        return filter.tradeCharacteristics!.strategies.contains(h.strategy);
      }).toList();
    }
    
    if (filter.tradeCharacteristics!.tags.isNotEmpty) {
      result = result.where((h) {
        if (h.tags == null || h.tags!.isEmpty) return false;
        return filter.tradeCharacteristics!.tags.any((tag) => h.tags!.contains(tag));
      }).toList();
    }
  }

  // Profit/Loss
  if (filter.profitLossFilters != null) {
    result = result.where((h) {
      final pnl = h.profitLoss;
      if (pnl == null) return true;
      
      final min = filter.profitLossFilters!.minProfitLoss;
      final max = filter.profitLossFilters!.maxProfitLoss;
      
      if (min != null && pnl < min) return false;
      if (max != null && pnl > max) return false;
      
      return true;
    }).toList();
  }

  return result;
}
```

## State Management

### Filter State
- `_currentFilter`: MetricsFilterConfig - Current active filter configuration
- Initialized with `MetricsFilterConfig.empty()`
- Updated when filters are applied
- Reset to empty when "Reset" is pressed

### Favorite Filter State
- Managed by `FavoriteFilterCubit` (Bloc pattern)
- Loaded on page init via `initState`
- Shared between mobile and web implementations
- Persisted to backend/local storage

### Tab State
- `TabController` with 4 tabs
- Synchronized with filter group visibility
- Persists during bottom sheet session
- Reset when bottom sheet is dismissed

## User Flow

### Applying Filters
1. User taps filter button in header
2. Bottom sheet slides up with tab view
3. User navigates tabs and configures filters
4. User taps "Apply Filters"
5. Bottom sheet dismisses
6. Holdings list refreshes with filtered data
7. SnackBar confirms "Filters applied"
8. Filter count badge updates

### Using Favorite Filters
1. User taps favorite dropdown in header
2. Dropdown shows saved filters
3. User selects a favorite
4. All filter groups load favorite configuration
5. Bottom sheet scrolls to first active filter
6. User can review and modify if needed
7. User applies filters

### Saving Favorite
1. User configures desired filters
2. User opens favorite dropdown
3. User taps "Manage Favorites"
4. User taps "Save Current as Favorite"
5. Dialog prompts for name
6. User enters name and confirms
7. New favorite appears in dropdown

### Resetting Filters
1. User taps "Reset" in action bar
2. All filter groups clear
3. Empty states show in all tabs
4. Filter count badge shows "0"
5. User can start fresh or dismiss

## Mobile UX Optimizations

### Touch-Friendly
- **Minimum Tap Target**: 48px height for all interactive elements
- **Spacing**: 16px padding around filter groups
- **Buttons**: Full-width FilledButton for primary action
- **Inputs**: Large text fields with clear labels

### Responsive
- **Keyboard Handling**: Bottom padding adjusts when keyboard appears
- **Orientation**: Works in portrait and landscape
- **Tablet**: Wider bottom sheet on tablets (max 600px)
- **Safe Areas**: Respects notches and system UI

### Performance
- **Lazy Tabs**: Tab content only built when selected
- **Debounced Search**: Symbol search debounced to reduce rebuilds
- **Efficient Filters**: Filter logic optimized with early returns
- **Memoization**: Filter groups memoize expensive computations

### Accessibility
- **Semantic Labels**: All interactive elements have labels
- **Screen Reader**: Announcements for filter changes
- **Contrast**: WCAG AA compliant color contrast
- **Focus**: Logical tab order within bottom sheet

## Comparison: Mobile vs Web

| Feature | Mobile | Web |
|---------|--------|-----|
| **Layout** | Bottom sheet with tabs | Side panel with expandable groups |
| **Height** | 85% screen height | Full viewport height |
| **Navigation** | Horizontal tabs | Vertical scrolling |
| **Filter Count** | Badge on icon | Text label |
| **Favorites** | Dropdown button | Dropdown in header |
| **Actions** | Bottom action bar | Top header bar |
| **Empty State** | Per tab | Per group |
| **Keyboard** | Auto-adjusting padding | Fixed layout |
| **Screen Size** | Optimized for small | Optimized for large |

## Testing Checklist

### Functional Tests
- [ ] Filter button opens bottom sheet
- [ ] All 4 tabs are accessible
- [ ] Each filter group loads correctly
- [ ] Applying filters updates holdings list
- [ ] Reset clears all filters
- [ ] Filter count badge shows correct number
- [ ] Favorite filters dropdown works
- [ ] Saving favorite persists data
- [ ] Loading favorite applies filters
- [ ] Deleting favorite removes from list
- [ ] Renaming favorite updates name

### UI/UX Tests
- [ ] Bottom sheet animates smoothly
- [ ] Tabs swipe horizontally
- [ ] Keyboard pushes content up
- [ ] Empty states show when appropriate
- [ ] Loading states show during async operations
- [ ] Error states show for failures
- [ ] SnackBars confirm actions
- [ ] Badges update in real-time

### Responsive Tests
- [ ] Works on small phones (320px width)
- [ ] Works on large phones (428px width)
- [ ] Works on tablets (768px width)
- [ ] Portrait orientation
- [ ] Landscape orientation
- [ ] Safe area insets respected
- [ ] Notch/Dynamic Island handling

### Performance Tests
- [ ] Bottom sheet opens in < 200ms
- [ ] Filter application in < 100ms
- [ ] No jank during tab switching
- [ ] Smooth scrolling in bottom sheet
- [ ] No memory leaks on repeated open/close
- [ ] Efficient rebuild on filter changes

## Future Enhancements

### Planned Features
1. **Filter Presets**: Quick filters like "Profitable Trades", "Last Month", "Tech Stocks"
2. **Advanced Search**: Full-text search across multiple fields
3. **Filter History**: Recently used filter configurations
4. **Filter Chips**: Show active filters as dismissible chips
5. **Smart Suggestions**: AI-suggested filters based on data patterns

### Performance Improvements
1. **Virtual Scrolling**: For large filter option lists
2. **Incremental Filtering**: Apply filters as user types
3. **Filter Caching**: Cache filter results for faster switching
4. **Background Processing**: Filter in isolate for large datasets

### Accessibility
1. **Voice Control**: Voice commands for common filters
2. **High Contrast**: Additional high contrast theme
3. **Font Scaling**: Better support for large text sizes
4. **Haptic Feedback**: Tactile confirmation of actions

## Troubleshooting

### Bottom Sheet Not Opening
- **Check**: `showModalBottomSheet` is being called
- **Check**: No context errors preventing modal display
- **Check**: Scaffold is present in widget tree

### Filters Not Applying
- **Check**: `onApplyFilter` callback is wired correctly
- **Check**: `setState` is called to rebuild widget
- **Check**: Filter logic matches data structure
- **Check**: Filter groups return correct configs

### Favorite Filters Not Loading
- **Check**: `BlocProvider` wraps MobileFilterPanel
- **Check**: `favoriteFilterCubitProvider` is accessible
- **Check**: `loadFilters` is called in `initState`
- **Check**: User ID is passed correctly

### Performance Issues
- **Check**: Filter groups dispose properly
- **Check**: No unnecessary rebuilds
- **Check**: Large lists use ListView.builder
- **Check**: Filter logic is optimized

## Related Documentation
- [Filter Panel Implementation](./FILTER_PANEL_IMPLEMENTATION.md) - Web filter panel details
- [Favorite Filters](./FAVORITE_FILTERS.md) - Favorite filter system
- [Trade Holdings Dashboard](./TRADE_HOLDINGS_DASHBOARD.md) - Dashboard overview
- [Mobile UI Guidelines](./MOBILE_UI_IMPROVEMENTS.md) - General mobile design patterns

## Migration Notes
If migrating from web filter panel to mobile:
1. Replace `FilterPanel` with `MobileFilterPanel`
2. Update `initialConfig` parameter (was `currentFilter`)
3. Wrap with `BlocProvider` for favorites
4. Add filter application logic to page
5. Update filter logic to match domain entities
6. Test on multiple screen sizes
