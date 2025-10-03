# Portfolio Heatmap Integration Guide

## Overview
This guide explains the updated integration flow for how the portfolio web heatmap is integrated with the shared investment heatmap library, following a clean layered architecture with consolidated duplicate removal.

## Updated Architecture Flow

```
Portfolio Feature → Shared Investment Heatmap → Core Heatmap Library
     ↓                        ↓                         ↓
Web Card Widget    →    Universal Widget        →    Template Card
Data Conversion    →    Filter Management      →    State Management
Portfolio Analytics → InvestmentInputData    →    HeatmapData
```

## Consolidated Architecture Components

### Layer 1: Core Heatmap Library (`lib/core/` & `lib/shared/models/heatmap/`)

**Core Domain Entities** (`lib/core/app_logic/domain/entities/heatmap/`):
- **HeatmapDataEntity** - Base domain entity with metadata
- **HeatmapTileEntity** - Individual tile entity 
- **HeatmapConfigurationEntity** - Layout and color scheme enums
- **HeatmapMetadata** - Metadata with dataSource, lastUpdated, additionalInfo

**UI Models with Entity-to-UI Mappers** (`lib/shared/models/heatmap/`):
- **HeatmapData** (UI Model) - Extends HeatmapDataEntity with UI-specific features
  ```dart
  // Mapper: Domain Entity → UI Model
  factory HeatmapData.fromEntity(
    HeatmapDataEntity entity, {
    required HeatmapConfiguration configuration,
    Widget? customHeader,
    Widget? customFooter,
    VoidCallback? onRefresh,
    Function(HeatmapTileData)? onTileInteraction,
  })
  ```
- **HeatmapTileData** (UI Model) - Extends HeatmapTileEntity with display properties
  ```dart
  // Mapper: Domain Entity → UI Model
  factory HeatmapTileData.fromEntity(
    HeatmapTileEntity entity, {
    Color? customColor,
    IconData? icon,
    String? imageUrl,
    VoidCallback? onTap,
    Map<String, Widget>? customWidgets,
  })
  ```
- **HeatmapConfiguration** (UI Model) - Extends HeatmapConfigurationEntity with UI configuration

### Layer 2: Shared Investment Heatmap (`lib/shared/widgets/investment/`)
- **InvestmentHeatmapWidget** - Universal investment data handler
- **ConfigurableHeatmapWidget** - Generic heatmap with selectors
- **UniversalHeatmapWidget** - Cubit-based state management widget

### Layer 3: Portfolio Feature Integration (`lib/features/portfolio/`)
- **PortfolioHeatmapWebCard** - Portfolio-specific web implementation
- **EnhancedPortfolioHeatmapCard** - Advanced portfolio heatmap with filters
- **ModernPortfolioHeatmapWebCard** - Modern UI variant

## Updated Integration Flow

### 1. Portfolio Data Layer
```dart
// Portfolio provider supplies domain entity
final heatmapAsync = ref.watch(portfolioHeatmapProvider(portfolioId));

// Domain entity (Heatmap) contains:
// - sectors: List<Sector> with performance data
// - metadata: Portfolio-specific context
```

### 2. Web Card Conversion Layer
```dart
// PortfolioHeatmapWebCard converts domain to UI models
HeatmapData _convertToHeatmapData(Heatmap heatmap, BuildContext context) {
  final tiles = heatmap.sectors.map((sector) => HeatmapTileData(
    id: sector.sectorName.toLowerCase().replaceAll(' ', '_'),
    name: sector.sectorName,
    displayName: sector.sectorName,
    weightage: sector.weightage,
    performance: sector.changePercent,
    value: sector.totalValue,
    customColor: _getSectorColor(sector.changePercent),
  )).toList();
  
  return HeatmapData(
    id: 'portfolio-heatmap-$portfolioId',
    title: title ?? 'Portfolio Heatmap',
    subtitle: 'Sector Performance Overview',
    tiles: tiles,
    metadata: HeatmapMetadata(
      dataSource: 'portfolio_heatmap_converter',
      lastUpdated: DateTime.now(),
      additionalInfo: {'portfolioId': portfolioId},
    ),
    configuration: HeatmapConfiguration.web(),
  );
}
```

### 3. Template Card Integration
```dart
// Uses consolidated HeatmapTemplateCard for consistent rendering
return HeatmapTemplateCard(
  data: heatmapData,
  icon: icon ?? Icons.grid_view,
  onTilePressed: onTilePressed,
);
```

### 4. Investment Widget Integration
```dart
// Alternative: Use InvestmentHeatmapWidget for advanced filtering
InvestmentHeatmapWidget(
  filterType: InvestmentFilterType.portfolio,
  inputData: convertToInvestmentInputData(portfolioData),
  onFiltersChanged: ({
    InvestmentFilterType? filterType,
    TimeFrame? timeFrame,
    MetricType? metric,
    SectorType? sector,
    MarketCapType? marketCap,
  }) => handleFilterChange(),
)
```

## Integration Patterns (After Consolidation)

### Pattern 1: Direct Portfolio Integration (Recommended)
```dart
// Simplified portfolio-specific widget
PortfolioHeatmapWebCard(
  portfolioId: "portfolio-123",
  title: "My Portfolio Performance",
  icon: Icons.pie_chart,
  onTilePressed: () => navigateToSectorDetails(),
)
```

**Features:**
- ✅ Automatic data fetching via portfolioHeatmapProvider
- ✅ Built-in loading, error, and empty states
- ✅ Domain-to-UI conversion handled internally
- ✅ Optimized for portfolio data structure

### Pattern 2: Investment Framework Integration (Flexible)
```dart
// Generic investment widget with portfolio data
InvestmentHeatmapWidget(
  filterType: InvestmentFilterType.portfolio,
  inputData: await convertPortfolioToInvestmentData(portfolioId),
  onFiltersChanged: ({
    InvestmentFilterType? filterType,
    TimeFrame? timeFrame,
    MetricType? metric,
    SectorType? sector,
    MarketCapType? marketCap,
  }) => refreshWithFilters(),
  onTilePressed: (investmentData) => showDetails(investmentData),
)
```

**Features:**
- ✅ Multi-investment type support (Portfolio, ETFs, Stocks, etc.)
- ✅ Advanced filtering capabilities
- ✅ Selector integration (TimeFrame, Metric, Sector, MarketCap)
- ✅ Generic data input via InvestmentInputData

### Pattern 3: Universal Widget Integration (Advanced)
```dart
// Cubit-based state management for complex scenarios
BlocProvider(
  create: (context) => HeatmapDisplayCubit(),
  child: UniversalHeatmapWidget(
    investmentType: InvestmentType.portfolio,
    rawData: portfolioAnalyticsJson,
    config: HeatmapDisplayConfig(
      showSelectors: true,
      layout: HeatmapLayoutType.treemap,
      colorScheme: HeatmapColorSchemeType.performance,
    ),
    onFiltersChanged: (filters) => updateCubitState(filters),
  ),
)
```

**Features:**
- ✅ Full state management with Cubit
- ✅ Raw data input with automatic conversion
- ✅ Configuration-driven behavior
- ✅ Complex filter state management

## Detailed Implementation Steps (Updated Flow)

### Step 1: Choose Integration Pattern
```dart
// Option A: Direct Portfolio Integration (Simplest)
// - Use PortfolioHeatmapWebCard directly
// - Built-in provider integration
// - Minimal setup required

// Option B: Investment Framework Integration (Most Flexible)  
// - Use InvestmentHeatmapWidget
// - Convert portfolio data to InvestmentInputData
// - Full filtering capabilities

// Option C: Universal Widget Integration (Most Advanced)
// - Use UniversalHeatmapWidget with Cubit
// - Complex state management
// - Maximum customization
```

### Step 2: Data Layer Setup
```dart
// For Pattern 1 (Direct Portfolio):
// Data handled automatically via portfolioHeatmapProvider

// For Pattern 2 (Investment Framework):
List<InvestmentInputData> convertPortfolioToInvestmentData(
  Heatmap portfolioHeatmap
) {
  return portfolioHeatmap.sectors.map((sector) => InvestmentInputData(
    id: sector.sectorName,
    name: sector.sectorName,
    symbol: sector.sectorCode,
    weightage: sector.weightage,
    performance: sector.changePercent,
    value: sector.totalValue,
    // Add sector/marketCap metadata for filtering
    metadata: {
      'sectorType': mapSectorToEnum(sector.sectorName),
      'marketCap': calculateMarketCap(sector),
    },
  )).toList();
}

// For Pattern 3 (Universal Widget):
// Raw JSON data passed directly to widget
```

### Step 3: Widget Implementation
```dart
// Pattern 1: Simple Implementation
class PortfolioOverviewPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: PortfolioHeatmapWebCard(
        portfolioId: widget.portfolioId,
        title: "Sector Performance",
        onTilePressed: () => _navigateToSectorDetails(),
      ),
    );
  }
}

// Pattern 2: Advanced Implementation
class AdvancedPortfolioPage extends ConsumerStatefulWidget {
  @override
  _AdvancedPortfolioPageState createState() => _AdvancedPortfolioPageState();
}

class _AdvancedPortfolioPageState extends ConsumerState<AdvancedPortfolioPage> {
  InvestmentFilterType _filterType = InvestmentFilterType.portfolio;
  TimeFrame _timeFrame = TimeFrame.oneDay;
  MetricType _metric = MetricType.performance;
  
  @override
  Widget build(BuildContext context) {
    return InvestmentHeatmapWidget(
      filterType: _filterType,
      inputData: _getFilteredData(),
      onFiltersChanged: ({
        InvestmentFilterType? filterType,
        TimeFrame? timeFrame,
        MetricType? metric,
        SectorType? sector,
        MarketCapType? marketCap,
      }) {
        setState(() {
          if (filterType != null) _filterType = filterType;
          if (timeFrame != null) _timeFrame = timeFrame;
          if (metric != null) _metric = metric;
        });
      },
    );
  }
}
```

### Step 4: Error and State Handling
```dart
// Pattern 1: Built-in state handling
// PortfolioHeatmapWebCard handles loading/error states automatically

// Pattern 2: Manual state handling
Widget build(BuildContext context, WidgetRef ref) {
  final portfolioAsync = ref.watch(portfolioHeatmapProvider(portfolioId));
  
  return portfolioAsync.when(
    data: (heatmap) => InvestmentHeatmapWidget(
      filterType: InvestmentFilterType.portfolio,
      inputData: convertPortfolioToInvestmentData(heatmap),
      isLoading: false,
    ),
    loading: () => InvestmentHeatmapWidget(
      filterType: InvestmentFilterType.portfolio,
      inputData: [],
      isLoading: true,
    ),
    error: (error, stack) => InvestmentHeatmapWidget(
      filterType: InvestmentFilterType.portfolio,
      inputData: [],
      error: error.toString(),
    ),
  );
}
```

## Usage Examples

## Consolidated Architecture Benefits

### ✅ Eliminated Duplicates
- **Before**: Multiple conflicting HeatmapData, HeatmapTileData, and HeatmapConfiguration classes
- **After**: Single source of truth with canonical classes in `heatmap_ui_data.dart` and `heatmap_tile_data.dart`

### ✅ Clear Dependency Flow
```
Core Entities → Shared Models → UI Widgets → Feature Implementations
     ↓               ↓             ↓              ↓
Domain Objects → UI Extensions → Reusable → Portfolio Specific
```

### ✅ Improved Maintainability
- **Centralized Enums**: HeatmapLayoutType, HeatmapColorSchemeType in core entities
- **Compatibility Layer**: `heatmap_data.dart` re-exports canonical classes for legacy imports
- **Type Safety**: Consistent metadata structure with HeatmapMetadata class

### ✅ Enhanced Reusability
- **Universal Widgets**: Work across portfolio, ETF, stock, and index heatmaps
- **Configurable Components**: Layout, color schemes, and filtering options
- **State Management**: Cubit-based architecture for complex scenarios

## Usage Examples

### Basic Portfolio Heatmap (Recommended)
```dart
class PortfolioPage extends ConsumerWidget {
  final String portfolioId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: PortfolioHeatmapWebCard(
        portfolioId: portfolioId,
        title: "Portfolio Performance",
        icon: Icons.pie_chart,
        onTilePressed: () => Navigator.pushNamed(
          context, 
          '/sector-details',
          arguments: portfolioId,
        ),
      ),
    );
  }
}
```

### Multi-Investment Type Dashboard
```dart
class InvestmentDashboard extends ConsumerStatefulWidget {
  @override
  _InvestmentDashboardState createState() => _InvestmentDashboardState();
}

class _InvestmentDashboardState extends ConsumerState<InvestmentDashboard> {
  InvestmentFilterType _currentFilter = InvestmentFilterType.portfolio;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Filter Tabs
          Row(
            children: InvestmentFilterType.values.map((type) => 
              FilterChip(
                selected: type == _currentFilter,
                label: Text(type.displayName),
                onSelected: (selected) {
                  if (selected) setState(() => _currentFilter = type);
                },
              ),
            ).toList(),
          ),
          
          // Dynamic Heatmap based on selected filter
          Expanded(
            child: InvestmentHeatmapWidget(
              filterType: _currentFilter,
              inputData: _getDataForFilter(_currentFilter),
              onFiltersChanged: ({
                InvestmentFilterType? filterType,
                TimeFrame? timeFrame,
                MetricType? metric,
                SectorType? sector,
                MarketCapType? marketCap,
              }) => _handleFilterChange(
                filterType: filterType,
                timeFrame: timeFrame,
                metric: metric,
                sector: sector,
                marketCap: marketCap,
              ),
              onTilePressed: (data) => _showDetailPage(data),
            ),
          ),
        ],
      ),
    );
  }
  
  List<InvestmentInputData> _getDataForFilter(InvestmentFilterType filter) {
    switch (filter) {
      case InvestmentFilterType.portfolio:
        return _convertPortfolioData();
      case InvestmentFilterType.etf:
        return _convertETFData();
      case InvestmentFilterType.stocks:
        return _convertStockData();
      // ... handle other types
      default:
        return [];
    }
  }
}
```

### Advanced Configuration Example
```dart
class CustomHeatmapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HeatmapDisplayCubit(),
      child: UniversalHeatmapWidget(
        investmentType: InvestmentType.portfolio,
        rawData: portfolioAnalyticsJson,
        config: HeatmapDisplayConfig(
          showSelectors: true,
          layout: HeatmapLayoutType.treemap,
          colorScheme: HeatmapColorSchemeType.performance,
          sortingType: HeatmapSortingType.performance,
          enabledFilters: [
            HeatmapFilterType.performance,
            HeatmapFilterType.weightage,
            HeatmapFilterType.value,
          ],
        ),
        initialFilters: HeatmapFilters(
          timeFrame: TimeFrame.oneMonth,
          metric: MetricType.performance,
          sector: SectorType.all,
          marketCap: MarketCapType.all,
        ),
        onTilePressed: (tileId, metadata) => _handleTileInteraction(tileId, metadata),
        onFiltersChanged: (filters) => _updateAnalytics(filters),
      ),
    );
  }
}
```

## Migration Guide

### From Old Architecture
If you're migrating from the old duplicate-heavy architecture:

1. **Update Imports**:
```dart
// OLD (may cause conflicts)
import '../models/heatmap/heatmap_data.dart';

// NEW (consolidated)
import '../models/heatmap.dart';  // Re-exports all canonical classes
```

2. **Update Constructor Calls**:
```dart
// OLD (missing required parameters)
HeatmapData(
  title: "Portfolio",
  tiles: tiles,
  configuration: config,
)

// NEW (with required metadata)
HeatmapData(
  id: 'unique-heatmap-id',
  title: "Portfolio",
  tiles: tiles,
  metadata: HeatmapMetadata(
    dataSource: 'portfolio_converter',
    lastUpdated: DateTime.now(),
  ),
  configuration: config,
)
```

3. **Update Enum References**:
```dart
// OLD (deprecated enums)
HeatmapColorScheme.performance
HeatmapLayout.treemap

// NEW (canonical enums)
HeatmapColorSchemeType.performance
HeatmapLayoutType.treemap
```

## Troubleshooting

### Common Issues After Consolidation

1. **Import Errors**: Use `import '../models/heatmap.dart'` for all heatmap classes
2. **Missing Parameters**: HeatmapData now requires `id` and `metadata` parameters
3. **Enum Conflicts**: Use canonical enum types (HeatmapColorSchemeType, HeatmapLayoutType)
4. **Provider Issues**: Ensure proper AsyncValue handling in Consumer widgets
```dart
class InvestmentDashboard extends StatefulWidget {
  @override
  State<InvestmentDashboard> createState() => _InvestmentDashboardState();
}

class _InvestmentDashboardState extends State<InvestmentDashboard> {
  InvestmentFilterType _currentType = InvestmentFilterType.portfolio;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter type selector
        SegmentedButton<InvestmentFilterType>(
          selected: {_currentType},
          onSelectionChanged: (Set<InvestmentFilterType> selection) {
            setState(() {
              _currentType = selection.first;
            });
          },
          segments: InvestmentFilterType.values.map((type) {
            return ButtonSegment(
              value: type,
              label: Text(type.displayName),
              icon: Icon(type.icon),
            );
          }).toList(),
        ),
        
        // Heatmap display
        Expanded(
          child: InvestmentHeatmapWidget(
            filterType: _currentType,
            inputData: _getDataForType(_currentType),
            onFiltersChanged: _handleFiltersChanged,
          ),
        ),
      ],
    );
  }
}
```

### Custom Integration with Additional Features
```dart
class CustomPortfolioHeatmap extends ConsumerStatefulWidget {
  @override
  ConsumerState<CustomPortfolioHeatmap> createState() => 
      _CustomPortfolioHeatmapState();
}

class _CustomPortfolioHeatmapState 
    extends ConsumerState<CustomPortfolioHeatmap> {
  
  @override
  Widget build(BuildContext context) {
    return ConfigurableHeatmapWidget(
      data: _buildHeatmapData(),
      showSelectors: true,
      compact: MediaQuery.of(context).size.width < 600,
      onSelectorsChanged: ({timeFrame, metric, sector, marketCap}) {
        // Update analytics based on filters
        ref.read(portfolioAnalyticsProvider.notifier).updateFilters(
          timeFrame: timeFrame,
          metric: metric,
          sector: sector,
          marketCap: marketCap,
        );
      },
      customTileBuilder: (tile) => CustomHeatmapTile(
        data: tile,
        onTap: () => _showTileAnalytics(tile),
      ),
    );
  }
}
```

## Best Practices

1. **Use Providers for State Management**: Leverage Riverpod providers for data fetching
2. **Separate Business Logic**: Keep data transformation separate from UI
3. **Error Handling**: Implement proper loading and error states
4. **Type Safety**: Use strong typing throughout the pipeline
5. **Reusability**: Design components to work with different investment types
6. **Performance**: Use const constructors and minimize rebuilds
7. **Accessibility**: Add semantic labels and screen reader support
8. **Testing**: Write unit tests for converters and integration tests for widgets

## File Structure
```
lib/
├── features/portfolio/
│   ├── providers/portfolio_providers.dart
│   └── presentation/web/widgets/
│       ├── portfolio_heatmap_web_card.dart
│       └── enhanced_portfolio_heatmap_card.dart
├── shared/
│   ├── models/investment/investment_types.dart
│   ├── widgets/investment/investment_heatmap_widget.dart
│   ├── converters/portfolio_analytics_converter.dart
│   └── widgets/heatmap/
│       ├── heatmap_template_card.dart
│       └── configurable_heatmap_widget.dart
├── examples/
│   └── portfolio_heatmap_integration_example.dart
└── docs/
    └── PORTFOLIO_HEATMAP_INTEGRATION.md
```

## Troubleshooting

### Common Issues
1. **Import Errors**: Ensure all required packages are imported
2. **Type Mismatches**: Verify data conversion between entity and UI models
3. **Provider Not Found**: Check provider registration in main.dart
4. **Layout Issues**: Verify responsive design breakpoints

### Performance Tips
1. Use `const` constructors where possible
2. Implement proper `shouldRebuild` logic in consumers
3. Cache converted data to avoid unnecessary transformations
4. Use `ListView.builder` for large datasets