import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../shared/widgets/heatmap/universal_heatmap_widget.dart';
import '../../../../../shared/core/cubits/heatmap/heatmap_display_cubit.dart';
import '../../../providers/portfolio_providers.dart';
import '../../../../../core/utils/logger.dart';

/// Modern portfolio heatmap card using the cubit-based universal heatmap widget
/// This demonstrates the best practice integration pattern
class ModernPortfolioHeatmapWebCard extends ConsumerWidget {
  final String portfolioId;
  final String? title;
  final IconData? icon;
  final bool compactMode;
  final VoidCallback? onTilePressed;
  final Function(HeatmapFilters filters)? onFiltersChanged;

  const ModernPortfolioHeatmapWebCard({
    super.key,
    required this.portfolioId,
    this.title,
    this.icon,
    this.compactMode = false,
    this.onTilePressed,
    this.onFiltersChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppLogger.debug(
      'Building ModernPortfolioHeatmapWebCard for portfolioId: $portfolioId',
      tag: 'ModernPortfolioHeatmapWebCard',
    );

    // Watch the portfolio analytics provider
    final portfolioAnalyticsAsync = ref.watch(
      portfolioAnalyticsProvider(portfolioId),
    );

    return portfolioAnalyticsAsync.when(
      data: (analytics) {
        if (analytics == null) {
          return _buildEmptyCard();
        }

        // Convert analytics to raw data format expected by the universal widget
        final rawData = _convertAnalyticsToRawData(analytics);

        return Card(
          elevation: 2,
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                if (!compactMode) ...[
                  _buildHeader(context),
                  const SizedBox(height: 16),
                ],

                // Heatmap widget
                SizedBox(
                  height: compactMode ? 200 : 350,
                  child: PortfolioHeatmapWidget(
                    portfolioData: rawData,
                    title: title ?? 'Portfolio Sector Performance',
                    compactMode: compactMode,
                    onTilePressed: (tileId, metadata) {
                      AppLogger.debug(
                        'Tile pressed: $tileId with metadata: $metadata',
                        tag: 'ModernPortfolioHeatmapWebCard',
                      );
                      onTilePressed?.call();
                    },
                    onFiltersChanged: (filters) {
                      AppLogger.debug(
                        'Filters changed: ${filters.toString()}',
                        tag: 'ModernPortfolioHeatmapWebCard',
                      );
                      onFiltersChanged?.call(filters);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => _buildLoadingCard(),
      error: (error, stackTrace) {
        AppLogger.error(
          'Failed to load portfolio analytics: $portfolioId',
          tag: 'ModernPortfolioHeatmapWebCard',
          error: error,
          stackTrace: stackTrace,
        );
        return _buildErrorCard(error.toString());
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: Theme.of(context).primaryColor, size: 24),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title ?? 'Portfolio Heatmap',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'Sector allocation and performance overview',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: compactMode ? 200 : 350,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading portfolio heatmap...'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: compactMode ? 200 : 350,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load heatmap',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCard() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: compactMode ? 200 : 350,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.data_usage_outlined, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No portfolio data available',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Convert portfolio analytics to the raw data format expected by universal widget
  Map<String, dynamic> _convertAnalyticsToRawData(dynamic analytics) {
    // This assumes your analytics object has a heatmap property with sectors
    // Adjust the structure based on your actual portfolio analytics data model

    if (analytics is Map<String, dynamic>) {
      return analytics;
    }

    // If analytics is a custom object, convert it to map
    // This is a generic example - replace with your actual analytics structure
    return {
      'analytics': {
        'heatmap': {'sectors': _extractSectorsFromAnalytics(analytics)},
      },
      'metadata': {
        'portfolioId': portfolioId,
        'timestamp': DateTime.now().toIso8601String(),
      },
    };
  }

  /// Extract sectors data from analytics object
  List<Map<String, dynamic>> _extractSectorsFromAnalytics(dynamic analytics) {
    // This is a placeholder - implement based on your actual analytics structure
    // The universal widget expects this structure for portfolio type:
    // [
    //   {
    //     'sectorName': 'Technology',
    //     'weightage': 25.5,
    //     'changePercent': 2.3,
    //     'totalValue': 10000.0,
    //     'count': 5,
    //   },
    //   ...
    // ]

    return [
      {
        'sectorName': 'Technology',
        'weightage': 25.5,
        'changePercent': 2.3,
        'totalValue': 10000.0,
        'count': 5,
      },
      {
        'sectorName': 'Healthcare',
        'weightage': 18.2,
        'changePercent': -1.2,
        'totalValue': 7500.0,
        'count': 3,
      },
      {
        'sectorName': 'Finance',
        'weightage': 22.1,
        'changePercent': 1.8,
        'totalValue': 9200.0,
        'count': 4,
      },
      // Add more sectors based on your actual data
    ];
  }
}

/// Usage example for different contexts
class PortfolioHeatmapUsageExamples extends StatelessWidget {
  final String portfolioId;

  const PortfolioHeatmapUsageExamples({super.key, required this.portfolioId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Portfolio Heatmap Examples')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full-featured web card
            Text(
              'Full Web Card',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            ModernPortfolioHeatmapWebCard(
              portfolioId: portfolioId,
              title: 'Portfolio Performance',
              icon: Icons.pie_chart,
              onTilePressed: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Tile pressed!')));
              },
              onFiltersChanged: (filters) {
                print('Filters changed: $filters');
              },
            ),

            const SizedBox(height: 24),

            // Compact card for dashboards
            Text(
              'Compact Dashboard Card',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            ModernPortfolioHeatmapWebCard(
              portfolioId: portfolioId,
              title: 'Quick Overview',
              compactMode: true,
            ),

            const SizedBox(height: 24),

            // Side-by-side comparison
            Text(
              'Side-by-Side Comparison',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ModernPortfolioHeatmapWebCard(
                    portfolioId: '$portfolioId-1',
                    title: 'Portfolio A',
                    compactMode: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ModernPortfolioHeatmapWebCard(
                    portfolioId: '$portfolioId-2',
                    title: 'Portfolio B',
                    compactMode: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Provider-based integration example using the cubit
class PortfolioHeatmapProvider extends ConsumerWidget {
  final String portfolioId;

  const PortfolioHeatmapProvider({super.key, required this.portfolioId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch multiple related providers
    final portfolioAsync = ref.watch(portfolioProvider(portfolioId));
    final analyticsAsync = ref.watch(portfolioAnalyticsProvider(portfolioId));
    final performanceAsync = ref.watch(
      portfolioPerformanceProvider(portfolioId),
    );

    return portfolioAsync.when(
      data: (portfolio) {
        return analyticsAsync.when(
          data: (analytics) {
            return performanceAsync.when(
              data: (performance) {
                // Combine all data sources
                final combinedData = {
                  'portfolio': portfolio?.toMap(),
                  'analytics': analytics?.toMap(),
                  'performance': performance?.toMap(),
                };

                return PortfolioHeatmapWidget(
                  portfolioData: combinedData,
                  title: portfolio?.name ?? 'Portfolio Heatmap',
                  onTilePressed: (tileId, metadata) {
                    // Navigate to detailed view
                    _navigateToSectorDetail(context, tileId, metadata);
                  },
                  onFiltersChanged: (filters) {
                    // Update URL parameters or save preferences
                    _handleFiltersChanged(context, filters);
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, _) => Text('Performance error: $error'),
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (error, _) => Text('Analytics error: $error'),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, _) => Text('Portfolio error: $error'),
    );
  }

  void _navigateToSectorDetail(
    BuildContext context,
    String tileId,
    Map<String, dynamic>? metadata,
  ) {
    // Implement navigation to sector detail page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text('Sector: $tileId')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Sector ID: $tileId'),
                Text('Metadata: ${metadata.toString()}'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleFiltersChanged(BuildContext context, HeatmapFilters filters) {
    // Save filter preferences or update URL
    print('Saving filters: ${filters.toString()}');

    // Example: Save to shared preferences
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setString('heatmap_filters_$portfolioId', jsonEncode(filters.toMap()));
  }
}
