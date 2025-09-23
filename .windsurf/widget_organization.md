# Widget Organization Guide

This document outlines the approach for organizing reusable widgets in the AM Investment UI application.

## Folder Structure

```
lib/
├── widgets/                        # Root widgets directory
│   ├── shared/                     # Shared widgets across features
│   │   ├── finance/                # Finance-specific widgets
│   │   │   ├── index.dart          # Export file for easier imports
│   │   │   ├── portfolio_summary_card.dart
│   │   │   ├── holdings_breakdown.dart
│   │   │   └── stock_details_item.dart
│   │   ├── tables/                 # Table and data display widgets
│   │   │   └── ...
│   │   └── cards/                  # Card and container widgets
│   │       └── ...
│   └── platform/                   # Platform-specific widget implementations
│       ├── responsive_layout.dart
│       └── platform_button.dart
└── features/                       # Feature modules
    ├── portfolio/                  # Portfolio feature
    │   ├── portfolio_screen.dart   # Main screen
    │   ├── web/                    # Web-specific implementations
    │   ├── ios/                    # iOS-specific implementations
    │   ├── android/                # Android-specific implementations
    │   └── widgets/                # Feature-specific widgets
    │       └── ...
    └── trade/                      # Trade management feature
        ├── trade_screen.dart
        ├── web/
        ├── ios/
        ├── android/
        └── widgets/
            └── ...
```

## Widget Organization Principles

1. **Shared vs. Feature-Specific**:
   - **Shared Widgets**: Components that can be reused across multiple features
   - **Feature-Specific Widgets**: Components that are tightly coupled to a specific feature

2. **Domain-Based Organization**:
   - Finance widgets: Components related to financial data display
   - Tables widgets: Components for tabular data presentation
   - Cards widgets: Reusable card layouts and containers

3. **Import Strategy**:
   - Use index.dart files for easier imports
   - Example: `import 'package:am_investment_ui/widgets/shared/finance/index.dart';`

## When to Place Widgets in Shared Folders

Place a widget in the shared folder when:

1. It can be used by multiple features (e.g., portfolio and trade management)
2. It represents a domain concept rather than a feature-specific implementation
3. It has clear, well-defined inputs and outputs
4. It doesn't depend on feature-specific state or logic

## Example Usage

```dart
// Import all finance widgets
import 'package:am_investment_ui/widgets/shared/finance/index.dart';

// Or import specific widgets
import 'package:am_investment_ui/widgets/shared/finance/portfolio_summary_card.dart';
```

## Shared Finance Widgets

1. **PortfolioSummaryCard**:
   - Displays portfolio summary information
   - Can be used in both portfolio and trade management features

2. **HoldingsBreakdown**:
   - Shows breakdown of holdings by market cap or sector
   - Reusable for any feature that needs to display asset allocation

3. **StockDetailsItem**:
   - Displays detailed information about a stock
   - Can be used in portfolio, trade, and watchlist features

## Benefits

1. **Reusability**: Widgets can be used across different features
2. **Consistency**: Common UI elements maintain consistent look and feel
3. **Maintainability**: Changes to shared widgets propagate to all uses
4. **Scalability**: Easy to add new features that use existing widgets
5. **Modularity**: Clear separation between shared and feature-specific components
