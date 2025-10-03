import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../shared/widgets/heatmap/heatmap_template_card.dart';
import '../../../../../shared/models/heatmap/heatmap_ui_data.dart';
import '../../../../../shared/models/heatmap/heatmap_tile_data.dart';
import '../../../../../core/app_logic/domain/entities/heatmap/heatmap_entities.dart';
import '../../../internal/domain/entities/portfolio_analytics.dart';
import '../../../providers/portfolio_providers.dart';
import '../../../../../core/utils/logger.dart';

/// Updated portfolio heatmap card that uses the new UI models
/// This is a drop-in replacement for the existing portfolio heatmap card
class UpdatedPortfolioHeatmapWebCard extends ConsumerWidget {
  final String portfolioId;
  final String? title;
  final IconData? icon;
  final VoidCallback? onTilePressed;

  const UpdatedPortfolioHeatmapWebCard({
    super.key,
    required this.portfolioId,
    this.title,
    this.icon,
    this.onTilePressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppLogger.debug(
      'Building UpdatedPortfolioHeatmapWebCard for portfolioId: $portfolioId',
      tag: 'UpdatedPortfolioHeatmapWebCard',
    );

    // Watch the portfolio heatmap provider
    final heatmapAsync = ref.watch(portfolioHeatmapProvider(portfolioId));

    return heatmapAsync.when(
      data: (heatmap) {
        if (heatmap == null) {
          return _buildEmptyHeatmap(context);
        }

        // Convert heatmap to HeatmapData for the template card
        final heatmapData = _convertToHeatmapData(heatmap, context);

        return HeatmapTemplateCard(
          data: heatmapData,
          icon: icon ?? Icons.grid_view,
          onTilePressed: onTilePressed,
        );
      },
      loading: () => _buildLoadingHeatmap(context),
      error: (error, stackTrace) {
        AppLogger.error(
          'Failed to load heatmap for portfolio: $portfolioId',
          tag: 'UpdatedPortfolioHeatmapWebCard',
          error: error,
          stackTrace: stackTrace,
        );
        return _buildErrorHeatmap(context, error.toString());
      },
    );
  }

  /// Convert the domain heatmap entity to HeatmapData for the template card
  HeatmapData _convertToHeatmapData(Heatmap heatmap, BuildContext context) {
    // Convert heatmap sectors to tiles
    final tiles = heatmap.sectors.map((sector) {
      return HeatmapTileData(
        id: sector.sectorName.toLowerCase().replaceAll(' ', '_'),
        name: sector.sectorName,
        displayName: sector.sectorName,
        weightage: sector.weightage,
        performance: sector.changePercent,
        value: sector.totalValue,
        customColor: _getSectorColor(sector.changePercent),
      );
    }).toList();

    return HeatmapData(
      id: 'portfolio-heatmap-$portfolioId',
      title: title ?? 'Portfolio Heatmap',
      subtitle: 'Sector Performance Overview',
      tiles: tiles,
      metadata: HeatmapMetadata(
        lastUpdated: DateTime.now(),
        dataSource: 'portfolio_analytics',
        additionalInfo: {
          'portfolioId': portfolioId,
          'type': 'sector_performance',
        },
      ),
      configuration: HeatmapConfiguration.web(),
    );
  }

  /// Get color for sector based on performance
  Color _getSectorColor(double changePercent) {
    if (changePercent > 0) {
      return Colors.green.withValues(alpha: 0.7);
    } else if (changePercent < 0) {
      return Colors.red.withValues(alpha: 0.7);
    } else {
      return Colors.grey.withValues(alpha: 0.5);
    }
  }

  /// Build loading state heatmap
  Widget _buildLoadingHeatmap(BuildContext context) {
    final loadingData = HeatmapData(
      id: 'loading-heatmap',
      title: title ?? 'Portfolio Heatmap',
      subtitle: 'Loading...',
      tiles: [],
      metadata: HeatmapMetadata(
        lastUpdated: DateTime.now(),
        dataSource: 'portfolio_heatmap',
        additionalInfo: const {'status': 'loading'},
      ),
      configuration: HeatmapConfiguration.web(),
    );

    return HeatmapTemplateCard(
      data: loadingData,
      isLoading: true,
      icon: icon ?? Icons.grid_view,
    );
  }

  /// Build error state heatmap
  Widget _buildErrorHeatmap(BuildContext context, String error) {
    final errorData = HeatmapData(
      id: 'error-heatmap',
      title: title ?? 'Portfolio Heatmap',
      subtitle: 'Error loading data',
      tiles: [],
      metadata: HeatmapMetadata(
        lastUpdated: DateTime.now(),
        dataSource: 'portfolio_heatmap',
        additionalInfo: {'status': 'error', 'error': error},
      ),
      configuration: HeatmapConfiguration.web(),
    );

    return HeatmapTemplateCard(
      data: errorData,
      error: error,
      icon: icon ?? Icons.grid_view,
    );
  }

  /// Build empty state heatmap
  Widget _buildEmptyHeatmap(BuildContext context) {
    final emptyData = HeatmapData(
      id: 'empty-heatmap',
      title: title ?? 'Portfolio Heatmap',
      subtitle: 'No data available',
      tiles: [],
      metadata: HeatmapMetadata(
        lastUpdated: DateTime.now(),
        dataSource: 'portfolio_heatmap',
        additionalInfo: const {'status': 'empty'},
      ),
      configuration: HeatmapConfiguration.web(),
    );

    return HeatmapTemplateCard(data: emptyData, icon: icon ?? Icons.grid_view);
  }
}

/// Migration guide for updating existing portfolio heatmap cards
/// 
/// Steps to migrate:
/// 1. Replace imports:
///    - Add: import '../../../../../shared/models/heatmap/heatmap_ui_data.dart';
///    - Add: import '../../../../../shared/models/heatmap/heatmap_tile_data.dart';
/// 
/// 2. Update _convertToHeatmapData method:
///    - Add required 'id' and 'metadata' parameters to HeatmapData constructor
///    - Use HeatmapTileData instead of generic tile data
/// 
/// 3. Update color methods:
///    - Replace .withOpacity() with .withValues(alpha: value)
/// 
/// 4. Update configuration:
///    - Use HeatmapConfiguration.web() instead of custom configuration
/// 
/// 5. Test thoroughly:
///    - Verify all states (loading, error, empty, data)
///    - Check responsive behavior
///    - Validate color schemes and interactions