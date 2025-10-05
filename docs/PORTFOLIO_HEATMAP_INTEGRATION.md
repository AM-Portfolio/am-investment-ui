## Portfolio Heatmap Integration Guide

### Overview
This guide explains how to integrate the unified portfolio heatmap system in your Flutter app, including migration from legacy cubits, usage patterns, and feature highlights.

---

### 1. Integration Example

**Basic Usage:**
```dart
BlocProvider<UnifiedPortfolioHeatmapCubit>(
	create: (context) => UnifiedPortfolioHeatmapCubit(
		context.read<PortfolioAnalyticsService>(),
	),
	child: SimplifiedPortfolioHeatmapWebPage(
		portfolioId: portfolioId,
		portfolioName: portfolioName,
	),
)
```

**Direct Usage (for testing):**
```dart
UnifiedPortfolioHeatmapCubit cubit = UnifiedPortfolioHeatmapCubit(service);
cubit.loadHeatmapData(portfolioId: '123');
```

---

### 2. Migration Steps

**From legacy dual-cubit setup:**
```dart
// OLD
MultiBlocProvider(
	providers: [
		BlocProvider<PortfolioAnalyticsCubit>(...),
		BlocProvider<PortfolioHeatmapCubit>(...),
	],
	child: PortfolioHeatmapWebPage(...),
)

// NEW
BlocProvider<UnifiedPortfolioHeatmapCubit>(
	create: (context) => UnifiedPortfolioHeatmapCubit(
		context.read<PortfolioAnalyticsService>(),
	),
	child: SimplifiedPortfolioHeatmapWebPage(...),
)
```

---

### 3. Features & Controls

- **Unified State Management:** Single cubit for all heatmap logic
- **Sector Filtering:** Use `updateSectorFilter` for dynamic filtering
- **Performance Sorting:** Tiles sorted by weightage and performance
- **Multiple Layouts:** Treemap, grid, and list views
- **Investment Cards:** All layouts support investment-style cards
- **Responsive UI:** Mobile and desktop optimized
- **Error & Loading States:** Built-in error and loading widgets

---

### 4. API Reference

**UnifiedPortfolioHeatmapCubit Methods:**
- `loadHeatmapData(...)` – Loads and transforms portfolio analytics
- `refresh(portfolioId)` – Refreshes data for the portfolio
- `updateSectorFilter(portfolioId, sector)` – Changes sector filter

**State Classes:**
- `UnifiedPortfolioHeatmapInitial`
- `UnifiedPortfolioHeatmapLoading`
- `UnifiedPortfolioHeatmapLoaded`
- `UnifiedPortfolioHeatmapEmpty`
- `UnifiedPortfolioHeatmapError`

---

### 5. Testing Utilities

See `UnifiedPortfolioHeatmapTestUtils` for:
- Mock cubit creation
- State transition tests
- Sector filtering tests

---

### 6. Feature Preservation

All legacy features are preserved and improved:
- Sector filtering
- Performance sorting
- Investment cards
- Total value display
- Mobile optimization
- Grid/treemap/list layouts

---

### 7. Performance & Maintainability

- **Codebase reduced by 60%**
- **Single source of truth**
- **Direct data flow, no intermediate layers**
- **Self-documenting, easy to test and debug**

---

### 8. Advanced Usage

You can extend the cubit for custom filtering, sorting, or layout logic as needed. All controls are exposed via the cubit and web page widgets.

---

### 9. Support & Migration Help

For migration assistance, see `PortfolioHeatmapMigrationHelper` in the examples folder.

---

**For further details, see the code in:**
- `lib/examples/portfolio_heatmap_integration_example.dart`
- `lib/features/portfolio/presentation/cubit/unified_portfolio_heatmap_cubit.dart`
- `lib/features/portfolio/presentation/web/pages/simplified_portfolio_heatmap_web_page.dart`
