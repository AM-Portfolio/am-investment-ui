import 'package:flutter/material.dart';
import '../../internal/domain/entities/portfolio_analytics.dart';
import '../../../../shared/widgets/heatmap/heatmap_template_card.dart';
import '../../../../shared/utils/sector_heatmap_converter.dart';

/// Widget displaying sector allocation overview with visual heatmap
/// Shows sector performance with color-coded rectangles representing sector weightage
class SectorOverviewCard extends StatelessWidget {
  final Heatmap? heatmap;
  final bool isLoading;
  final String? error;
  final bool showSubCards;

  const SectorOverviewCard({
    super.key,
    this.heatmap,
    this.isLoading = false,
    this.error,
    this.showSubCards = true,
  });

  @override
  Widget build(BuildContext context) {
    // Convert sector data to generic heatmap data
    final heatmapData = SectorHeatmapConverter.convertToHeatmapData(
      heatmap: heatmap,
      showSubCards: showSubCards,
      title: 'Sector Allocation',
    );

    return HeatmapTemplateCard(
      data: heatmapData,
      isLoading: isLoading,
      error: error,
      icon: Icons.pie_chart,
      onTilePressed: () {
        // Handle tile press - can be customized for navigation or details
      },
    );
  }
}
