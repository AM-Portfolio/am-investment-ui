import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../shared/widgets/heatmap/heatmap_template_card.dart';
import '../../../../../shared/models/heatmap/heatmap_data.dart';
import '../../../internal/domain/entities/portfolio_analytics.dart';
import '../../../providers/portfolio_providers.dart';
import '../../../../../core/utils/logger.dart';

/// Web-specific portfolio heatmap card that uses the template card for display
class PortfolioHeatmapWebCard extends ConsumerWidget {
  final String portfolioId;
  final String? title;
  final IconData? icon;
  final VoidCallback? onTilePressed;

  const PortfolioHeatmapWebCard({
    super.key,
    required this.portfolioId,
    this.title,
    this.icon,
    this.onTilePressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppLogger.debug(
      'Building PortfolioHeatmapWebCard for portfolioId: $portfolioId',
      tag: 'PortfolioHeatmapWebCard',
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
          tag: 'PortfolioHeatmapWebCard',
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
      title: title ?? 'Portfolio Heatmap',
      subtitle: 'Sector Performance Overview',
      tiles: tiles,
      configuration: HeatmapConfiguration.web(),
    );
  }

  /// Get color for sector based on performance
  Color _getSectorColor(double changePercent) {
    if (changePercent > 0) {
      return Colors.green.withOpacity(0.7);
    } else if (changePercent < 0) {
      return Colors.red.withOpacity(0.7);
    } else {
      return Colors.grey.withOpacity(0.5);
    }
  }

  /// Build loading state heatmap
  Widget _buildLoadingHeatmap(BuildContext context) {
    final loadingData = HeatmapData(
      title: title ?? 'Portfolio Heatmap',
      subtitle: 'Loading...',
      tiles: [],
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
      title: title ?? 'Portfolio Heatmap',
      subtitle: 'Error loading data',
      tiles: [],
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
      title: title ?? 'Portfolio Heatmap',
      subtitle: 'No data available',
      tiles: [],
      configuration: HeatmapConfiguration.web(),
    );

    return HeatmapTemplateCard(data: emptyData, icon: icon ?? Icons.grid_view);
  }
}
