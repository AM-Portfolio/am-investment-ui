// Export all heatmap integration components
// This file provides a single import point for all heatmap-related functionality

// Core cubit and state management
export 'core/cubits/heatmap/heatmap_display_cubit.dart';

// Universal widgets for all investment types
export 'widgets/heatmap/universal_heatmap_widget.dart';
export 'widgets/heatmap/configurable_heatmap_widget.dart';
export 'widgets/heatmap/heatmap_template_card.dart';

// UI models and data structures
export 'models/heatmap/heatmap_ui_data.dart';
export 'models/heatmap/heatmap_tile_data.dart';

// Core domain entities
export '../core/app_logic/domain/entities/heatmap/heatmap_entities.dart';

// Selector widgets and types
export 'widgets/selectors/selectors.dart';

// Extensions for investment-specific configurations
export 'extensions/investment_extensions.dart';

// Convenience widgets for specific use cases
// These provide pre-configured widgets for common scenarios

/// Quick-start widgets for different investment types
/// 
/// Usage:
/// ```dart
/// // Portfolio heatmap
/// PortfolioHeatmapWidget(
///   portfolioData: portfolioAnalytics,
///   title: 'My Portfolio',
///   onTilePressed: (tileId, metadata) => navigateToDetail(tileId),
/// )
/// 
/// // Index heatmap
/// IndexHeatmapWidget(
///   indexData: indexComponents,
///   title: 'S&P 500',
/// )
/// 
/// // Mutual funds heatmap
/// MutualFundsHeatmapWidget(
///   fundsData: fundsData,
///   compactMode: true,
/// )
/// ```

/// Universal heatmap widget that handles all investment types
/// 
/// Usage:
/// ```dart
/// UniversalHeatmapWidget(
///   investmentType: InvestmentType.portfolio,
///   rawData: portfolioData,
///   title: 'Custom Title',
///   onTilePressed: handleTilePress,
///   onFiltersChanged: handleFiltersChanged,
/// )
/// ```

/// For advanced use cases with custom configurations
/// 
/// Usage:
/// ```dart
/// final customConfig = HeatmapDisplayConfig.portfolio(
///   title: 'Advanced Portfolio View',
///   compactMode: false,
/// );
/// 
/// UniversalHeatmapWidget(
///   investmentType: InvestmentType.portfolio,
///   rawData: data,
///   config: customConfig,
///   initialFilters: HeatmapFilters(
///     timeFrame: TimeFrame.threeMonths,
///     metric: MetricType.changePercent,
///   ),
/// )
/// ```

/// Integration with state management (Riverpod example)
/// 
/// ```dart
/// class PortfolioHeatmapPage extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final portfolioAsync = ref.watch(portfolioProvider(portfolioId));
///     
///     return portfolioAsync.when(
///       data: (portfolio) => PortfolioHeatmapWidget(
///         portfolioData: portfolio.toRawData(),
///         title: portfolio.name,
///       ),
///       loading: () => CircularProgressIndicator(),
///       error: (error, _) => Text('Error: $error'),
///     );
///   }
/// }
/// ```

/// Data conversion helpers
/// 
/// For converting from your existing data structures:
/// ```dart
/// Map<String, dynamic> convertPortfolioAnalytics(PortfolioAnalytics analytics) {
///   return {
///     'analytics': {
///       'heatmap': {
///         'sectors': analytics.sectors.map((sector) => {
///           'sectorName': sector.name,
///           'weightage': sector.allocation * 100,
///           'changePercent': sector.performance.changePercent,
///           'totalValue': sector.totalValue,
///           'count': sector.holdingsCount,
///         }).toList(),
///       },
///     },
///   };
/// }
/// ```