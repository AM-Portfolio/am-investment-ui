# Portfolio to Heatmap Integration Guide

## Overview
This guide explains the best way to integrate portfolio data to display a heatmap template, following a clean separation of concerns and reusable patterns.

## Architecture Flow

```
Portfolio Data → Investment Input → Configuration → UI Display
     ↓               ↓                ↓             ↓
Portfolio Analytics  InvestmentInputData  HeatmapData  HeatmapTemplateCard
```

## Step-by-Step Integration

### 1. Data Input Layer
- **Source**: Portfolio Analytics JSON or Provider data
- **Converter**: Transform raw data to `InvestmentInputData`
- **Purpose**: Normalize different data sources into a common format

### 2. Configuration Layer
- **Source**: `InvestmentTypeConfig` based on filter type
- **Purpose**: Map investment types to appropriate display configurations
- **Output**: UI-specific settings (colors, layouts, available filters)

### 3. Data Transformation Layer
- **Source**: `InvestmentInputData` + Configuration
- **Purpose**: Convert business data to UI-ready format
- **Output**: `HeatmapData` with `HeatmapTileData` tiles

### 4. Display Layer
- **Widget**: `InvestmentHeatmapWidget` or `ConfigurableHeatmapWidget`
- **Template**: `HeatmapTemplateCard`
- **Purpose**: Render the final heatmap with interactions

## Implementation Options

### Option 1: Direct Integration (Simple)
```dart
PortfolioHeatmapWebCard(
  portfolioId: "portfolio-id",
  title: "Portfolio Heatmap",
  onTilePressed: () => {},
)
```

### Option 2: Investment Pattern (Flexible)
```dart
InvestmentHeatmapWidget(
  filterType: InvestmentFilterType.portfolio,
  inputData: portfolioInputData,
  onFiltersChanged: (filters) => {},
)
```

### Option 3: Configurable Pattern (Advanced)
```dart
ConfigurableHeatmapWidget(
  data: heatmapData,
  showSelectors: true,
  onSelectorsChanged: (selectors) => {},
)
```

## Detailed Implementation Steps

### Step 1: Data Input Preparation
```dart
// 1.1 Get portfolio analytics from provider
final analyticsAsync = ref.watch(portfolioAnalyticsProvider(portfolioId));

// 1.2 Convert raw analytics to investment input data
final inputData = PortfolioAnalyticsConverter.convertToInvestmentData(
  analytics,
  portfolioId: portfolioId,
);
```

### Step 2: Configuration Selection
```dart
// 2.1 Choose appropriate filter type
final filterType = InvestmentFilterType.portfolio;

// 2.2 Get configuration for the filter type
final config = InvestmentTypeConfig.getConfig(filterType);

// 2.3 Apply platform-specific settings
final config = InvestmentTypeConfig.getConfig(
  filterType,
  compactView: isMobile,
  accentColor: Colors.blue,
);
```

### Step 3: Widget Integration
```dart
// 3.1 Simple integration (recommended for most cases)
EnhancedPortfolioHeatmapCard.web(
  portfolioId: "portfolio-123",
  title: "My Portfolio",
  onTilePressed: (data) => showTileDetails(data),
  onFiltersChanged: (filters) => handleFilterChange(filters),
)

// 3.2 Advanced integration with full control
InvestmentHeatmapWidget(
  filterType: InvestmentFilterType.portfolio,
  inputData: portfolioInputData,
  compact: false,
  onTilePressed: (data) => navigateToAsset(data),
  onFiltersChanged: (filters) => updateAnalytics(filters),
)
```

### Step 4: Error Handling
```dart
return analyticsAsync.when(
  data: (analytics) => _buildHeatmap(analytics),
  loading: () => _buildLoadingState(),
  error: (error, stack) => _buildErrorState(error),
);
```

## Usage Examples

### Basic Portfolio Heatmap
```dart
class PortfolioPage extends ConsumerWidget {
  final String portfolioId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: EnhancedPortfolioHeatmapCard.web(
        portfolioId: portfolioId,
        title: "Portfolio Performance",
        onTilePressed: (data) {
          Navigator.pushNamed(
            context, 
            '/sector-details',
            arguments: data.id,
          );
        },
      ),
    );
  }
}
```

### Multi-Investment Type Dashboard
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