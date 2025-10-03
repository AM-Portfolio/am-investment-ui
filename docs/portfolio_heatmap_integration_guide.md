# Portfolio to Heatmap Template Integration Guide

## Overview

This guide explains the complete integration pattern from portfolio input to heatmap template display using the cubit-based approach. The system is designed to handle different investment types (Portfolio, Index, Mutual Funds, ETF) with proper configuration mapping and state management.

## Architecture Components

### 1. Core Components

```
Core Entities (lib/core/app_logic/domain/entities/heatmap/)
├── heatmap_tile_entity.dart       // Business logic for individual tiles
├── heatmap_data_entity.dart       // Business logic for complete heatmap
├── heatmap_configuration_entity.dart // Domain-level configuration
└── heatmap_entities.dart          // Export barrel

UI Models (lib/shared/models/heatmap/)
├── heatmap_tile_data.dart         // UI-specific tile with display properties
├── heatmap_ui_data.dart          // UI heatmap data with Flutter integration
└── heatmap_models.dart           // Export barrel

State Management (lib/shared/core/cubits/heatmap/)
├── heatmap_display_cubit.dart    // Main cubit for heatmap state
├── heatmap_state.dart           // Common heatmap states
└── base_heatmap_cubit.dart      // Abstract base cubit

Widgets (lib/shared/widgets/heatmap/)
├── heatmap_template_card.dart    // Core heatmap display template
├── configurable_heatmap_widget.dart // Configurable wrapper
├── universal_heatmap_widget.dart // Universal investment type handler
└── heatmap_selector_card.dart   // Selector controls
```

### 2. Integration Flow

```
Raw Data → HeatmapDisplayCubit → HeatmapData → Template Widget → Display
    ↓              ↓                ↓             ↓
Portfolio      Configuration    UI Models    Interactive
Analytics      Mapping         Conversion    Heatmap
```

## Step-by-Step Integration

### Step 1: Prepare Your Data

Your portfolio data should be structured like this:

```dart
Map<String, dynamic> portfolioData = {
  'analytics': {
    'heatmap': {
      'sectors': [
        {
          'sectorName': 'Technology',
          'weightage': 25.5,
          'changePercent': 2.3,
          'totalValue': 10000.0,
          'count': 5,
        },
        // ... more sectors
      ],
    },
  },
  'metadata': {
    'portfolioId': 'portfolio-123',
    'timestamp': '2025-10-04T10:00:00Z',
  },
};
```

### Step 2: Use the Universal Widget

The simplest integration uses the `PortfolioHeatmapWidget`:

```dart
class MyPortfolioPage extends StatelessWidget {
  final String portfolioId;
  final Map<String, dynamic> portfolioData;

  const MyPortfolioPage({
    required this.portfolioId,
    required this.portfolioData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PortfolioHeatmapWidget(
        portfolioData: portfolioData,
        title: 'My Portfolio Performance',
        onTilePressed: (tileId, metadata) {
          // Handle tile interaction
          Navigator.push(context, /* sector detail page */);
        },
        onFiltersChanged: (filters) {
          // Handle filter changes
          print('Filters: ${filters.toString()}');
        },
      ),
    );
  }
}
```

### Step 3: Provider-Based Integration

For reactive data loading with Riverpod:

```dart
class PortfolioHeatmapWebCard extends ConsumerWidget {
  final String portfolioId;

  const PortfolioHeatmapWebCard({required this.portfolioId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioAnalyticsAsync = ref.watch(portfolioAnalyticsProvider(portfolioId));

    return portfolioAnalyticsAsync.when(
      data: (analytics) {
        final rawData = _convertAnalyticsToRawData(analytics);
        
        return PortfolioHeatmapWidget(
          portfolioData: rawData,
          title: 'Portfolio Heatmap',
          onTilePressed: (tileId, metadata) {
            _navigateToSectorDetail(context, tileId, metadata);
          },
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, _) => Text('Error: $error'),
    );
  }

  Map<String, dynamic> _convertAnalyticsToRawData(dynamic analytics) {
    // Convert your analytics object to the expected format
    return {
      'analytics': {
        'heatmap': {
          'sectors': _extractSectors(analytics),
        },
      },
    };
  }
}
```

### Step 4: Advanced Configuration

For custom configurations:

```dart
class CustomPortfolioHeatmap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final customConfig = HeatmapDisplayConfig(
      type: InvestmentType.portfolio,
      showSelectors: true,
      compactMode: false,
      layout: HeatmapLayoutType.treemap,
      colorScheme: HeatmapColorSchemeType.performance,
      availableTimeFrames: [
        TimeFrame.oneMonth,
        TimeFrame.threeMonths,
        TimeFrame.oneYear,
      ],
      availableMetrics: [
        MetricType.changePercent,
        MetricType.changeValue,
      ],
    );

    return UniversalHeatmapWidget(
      investmentType: InvestmentType.portfolio,
      rawData: portfolioData,
      config: customConfig,
      initialFilters: const HeatmapFilters(
        timeFrame: TimeFrame.threeMonths,
        metric: MetricType.changePercent,
      ),
    );
  }
}
```

## Configuration Options

### Investment Type Configurations

Each investment type has pre-configured settings:

| Type | Layout | Time Frames | Metrics | Special Features |
|------|--------|-------------|---------|------------------|
| Portfolio | Treemap | 1M, 3M, 6M, 1Y, YTD, All | Change%, Value, Volume, MarketCap | Sector-focused |
| Index | Treemap | 1D, 1W, 1M, 3M, 1Y, All | Change%, Value, Volume, MarketCap | Component-focused |
| Mutual Funds | Grid | 1M, 3M, 6M, 1Y, 3Y, 5Y, All | Change%, Value, Volume | Fund-focused |
| ETF | Treemap | 1D, 1W, 1M, 3M, 6M, 1Y, All | Change%, Value, Volume, MarketCap | Holdings-focused |

### Display Modes

```dart
// Compact mode for dashboards
PortfolioHeatmapWidget(
  portfolioData: data,
  compactMode: true, // Smaller, less detailed
)

// Full mode for dedicated pages
PortfolioHeatmapWidget(
  portfolioData: data,
  compactMode: false, // Full-featured with all controls
)
```

## State Management Integration

### Using BlocProvider

```dart
class PortfolioHeatmapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HeatmapDisplayCubit(),
      child: BlocBuilder<HeatmapDisplayCubit, HeatmapDisplayState>(
        builder: (context, state) {
          if (state is HeatmapDisplayLoaded) {
            return HeatmapTemplateCard(
              data: state.data,
              // ... other properties
            );
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}
```

### Handling Filter Changes

```dart
void _handleFiltersChanged(HeatmapFilters filters) {
  // Save to preferences
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('heatmap_filters', jsonEncode(filters.toMap()));
  
  // Update URL (for web apps)
  context.go('/portfolio/heatmap?timeFrame=${filters.timeFrame.name}');
  
  // Analytics tracking
  analytics.track('heatmap_filter_changed', {
    'timeFrame': filters.timeFrame.name,
    'metric': filters.metric.name,
  });
}
```

## Data Conversion Patterns

### From Portfolio Analytics

```dart
Map<String, dynamic> convertPortfolioAnalytics(PortfolioAnalytics analytics) {
  return {
    'analytics': {
      'heatmap': {
        'sectors': analytics.sectors.map((sector) => {
          'sectorName': sector.name,
          'weightage': sector.allocation * 100,
          'changePercent': sector.performance.changePercent,
          'totalValue': sector.totalValue,
          'count': sector.holdingsCount,
        }).toList(),
      },
    },
    'metadata': {
      'portfolioId': analytics.portfolioId,
      'timestamp': analytics.lastUpdated.toIso8601String(),
    },
  };
}
```

### From Index Data

```dart
Map<String, dynamic> convertIndexData(IndexData indexData) {
  return {
    'components': indexData.components.map((component) => {
      'symbol': component.symbol,
      'name': component.companyName,
      'weight': component.weight * 100,
      'changePercent': component.performance.changePercent,
      'marketCap': component.marketCap,
      'sector': component.sector,
    }).toList(),
  };
}
```

## Error Handling

```dart
class RobustPortfolioHeatmap extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(portfolioAnalyticsProvider(portfolioId)).when(
      data: (analytics) {
        try {
          final rawData = convertAnalytics(analytics);
          return PortfolioHeatmapWidget(portfolioData: rawData);
        } catch (error) {
          return ErrorWidget('Failed to convert data: $error');
        }
      },
      loading: () => const HeatmapLoadingWidget(),
      error: (error, stack) => HeatmapErrorWidget(
        error: error,
        onRetry: () => ref.refresh(portfolioAnalyticsProvider(portfolioId)),
      ),
    );
  }
}
```

## Testing

```dart
void main() {
  group('Portfolio Heatmap Integration', () {
    testWidgets('displays portfolio heatmap correctly', (tester) async {
      final mockData = {
        'analytics': {
          'heatmap': {
            'sectors': [
              {
                'sectorName': 'Technology',
                'weightage': 30.0,
                'changePercent': 5.2,
                'totalValue': 15000.0,
                'count': 3,
              },
            ],
          },
        },
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PortfolioHeatmapWidget(
              portfolioData: mockData,
              title: 'Test Portfolio',
            ),
          ),
        ),
      );

      expect(find.text('Test Portfolio'), findsOneWidget);
      expect(find.text('Technology'), findsOneWidget);
    });
  });
}
```

## Best Practices

1. **Data Validation**: Always validate input data structure
2. **Error Boundaries**: Wrap widgets in error handling
3. **Performance**: Use compact mode for lists/dashboards
4. **Accessibility**: Ensure tiles are keyboard/screen reader accessible
5. **Responsive**: Test on different screen sizes
6. **State Persistence**: Save filter preferences
7. **Analytics**: Track user interactions for insights

## Migration from Existing Code

To migrate from the existing `PortfolioHeatmapWebCard`:

1. Replace `HeatmapData` imports with new UI models
2. Update constructor to include required `id` and `metadata`
3. Use `PortfolioHeatmapWidget` instead of direct template usage
4. Update color methods to use `.withValues(alpha: x)` instead of `.withOpacity(x)`

See `modern_portfolio_heatmap_web_card.dart` for a complete migration example.