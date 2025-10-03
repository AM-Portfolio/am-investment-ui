# Investment Heatmap Pattern

This pattern provides a flexible, configurable heatmap widget system for displaying different types of investment data including portfolios, mutual funds, ETFs, indices, stocks, and sectors.

## Overview

The pattern consists of several key components:

1. **Investment Types & Configurations** - Defines different investment filter types and their specific configurations
2. **Investment Heatmap Widget** - Main widget that handles different filter types and maps them to displays
3. **Data Converters** - Utilities to convert various data formats to the standard input format
4. **Configurable Heatmap** - The underlying flexible heatmap display component

## Key Features

- **Multiple Investment Types**: Portfolio, Index, Mutual Funds, ETF, Stocks, Sectors
- **Automatic Configuration**: Each investment type has optimized default settings
- **Flexible Input Data**: Easy-to-use input data classes for different investment types
- **Real Data Integration**: Converters for portfolio analytics JSON data
- **Responsive Design**: Adapts to mobile and web layouts
- **Interactive Filtering**: Time frame, metric, sector, and market cap filters
- **Customizable Appearance**: Colors, icons, and layouts specific to investment types

## Usage Examples

### Basic Usage

```dart
import 'package:your_app/shared/investment_heatmap.dart';

// Using the main investment heatmap widget
InvestmentHeatmapWidget(
  filterType: InvestmentFilterType.portfolio,
  inputData: portfolioData,
  onTilePressed: (data) => print('Pressed: ${data.name}'),
  onFiltersChanged: (filters) => print('Filters changed'),
)
```

### Specific Investment Types

```dart
// Portfolio heatmap
InvestmentHeatmapWidget.portfolio(
  portfolioData: portfolioHoldings,
  compact: false,
  accentColor: Colors.blue,
)

// Mutual funds heatmap
InvestmentHeatmapWidget.mutualFunds(
  fundData: mutualFunds,
  compact: true,
  accentColor: Colors.orange,
)

// ETF heatmap
InvestmentHeatmapWidget.etf(
  etfData: etfList,
  compact: false,
  accentColor: Colors.purple,
)
```

### Data Conversion

```dart
// Convert portfolio analytics JSON to input data
final analyticsJson = PortfolioAnalyticsConverter.parsePortfolioAnalytics(jsonString);
final portfolioData = PortfolioAnalyticsConverter.convertPortfolioSectors(analyticsJson);
final stockData = PortfolioAnalyticsConverter.convertPortfolioStocks(analyticsJson);

// Get all available data types
final allData = PortfolioAnalyticsConverter.getAllDataTypes(analyticsJson);
```

## Investment Filter Types

### 1. Portfolio (`InvestmentFilterType.portfolio`)
- **Purpose**: Display portfolio holdings with weightage and performance
- **Features**: Sector filtering, market cap filtering, performance-based coloring
- **Layout**: Treemap (default) for proportional display
- **Data Source**: Portfolio holdings with weightage calculations

### 2. Index (`InvestmentFilterType.index`)
- **Purpose**: Display market indices performance
- **Features**: Market cap based weightage, constituent tracking
- **Layout**: Grid layout for equal comparison
- **Data Source**: Index data with constituents information

### 3. Mutual Funds (`InvestmentFilterType.mutualFunds`)
- **Purpose**: Display mutual fund performance and AUM
- **Features**: Category-based filtering, expense ratio tracking
- **Layout**: Grid layout for fund comparison
- **Data Source**: Fund NAV, AUM, and performance data

### 4. ETF (`InvestmentFilterType.etf`)
- **Purpose**: Display ETF performance and tracking
- **Features**: Tracking index information, volume-based sizing
- **Layout**: Treemap for volume-proportional display
- **Data Source**: ETF NAV, volume, and tracking data

### 5. Stocks (`InvestmentFilterType.stocks`)
- **Purpose**: Display individual stock performance
- **Features**: Sector and market cap filtering, volume tracking
- **Layout**: Grid layout for stock comparison
- **Data Source**: Stock price, volume, and market cap data

### 6. Sectors (`InvestmentFilterType.sectors`)
- **Purpose**: Display sector-wise performance
- **Features**: Sector allocation and weightage display
- **Layout**: Treemap for sector proportion visualization
- **Data Source**: Sector allocation and performance data

## Data Input Classes

### PortfolioInputData
```dart
PortfolioInputData(
  id: 'AAPL',
  name: 'Apple Inc.',
  currentValue: 150.25,
  changeAmount: 2.15,
  changePercent: 1.45,
  lastUpdated: DateTime.now(),
  weightage: 5.2,
  sector: 'Technology',
  marketCap: 'Large Cap',
)
```

### MutualFundInputData
```dart
MutualFundInputData(
  id: 'fund-1',
  name: 'Large Cap Growth Fund',
  currentValue: 45.67, // NAV
  changeAmount: 0.23,
  changePercent: 0.51,
  lastUpdated: DateTime.now(),
  aum: 2500000000, // Assets Under Management
  category: 'Large Cap',
  expenseRatio: 0.8,
)
```

### EtfInputData
```dart
EtfInputData(
  id: 'etf-1',
  name: 'Nifty 50 ETF',
  currentValue: 156.78,
  changeAmount: 1.23,
  changePercent: 0.79,
  lastUpdated: DateTime.now(),
  volume: 5000000,
  trackingIndex: 'Nifty 50',
  trackingError: 0.02,
)
```

## Configuration System

Each investment type has optimized configurations:

- **Time Frames**: Relevant time periods for each investment type
- **Metrics**: Appropriate metrics (change %, return, volume, etc.)
- **Layout**: Optimal layout (treemap vs grid) for data visualization
- **Colors**: Investment-type specific color schemes
- **Filters**: Relevant filter options (sector, market cap, etc.)

## Integration with Existing Data

The pattern includes converters for common data formats:

1. **Portfolio Analytics JSON**: Converts sector and stock data from analytics JSON
2. **Market Data APIs**: Easy integration with market data providers
3. **Custom Data Sources**: Extensible input data classes for any data source

## Responsive Design

- **Mobile**: Compact layout with essential information
- **Web**: Full layout with all features and filters
- **Adaptive**: Automatically adjusts based on screen size

## Example Integration

```dart
class PortfolioPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InvestmentHeatmapExample(), // Complete example with data loading
    );
  }
}
```

## Files Structure

```
lib/shared/
├── investment_heatmap.dart                     # Main export file
├── models/investment/
│   └── investment_types.dart                   # Investment types and configs
├── widgets/investment/
│   └── investment_heatmap_widget.dart          # Main heatmap widget
├── converters/
│   └── portfolio_analytics_converter.dart     # Data conversion utilities
└── examples/
    └── investment_heatmap_example.dart         # Usage examples
```

This pattern provides a complete, production-ready solution for displaying investment data in interactive heatmap formats with minimal integration effort.