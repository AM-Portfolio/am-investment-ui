import 'package:flutter/material.dart';
import '../../internal/domain/entities/portfolio_analytics.dart';
import 'sector_overview_card.dart';
import 'sector_details_card.dart';

/// Widget displaying comprehensive portfolio heatmap visualization
/// Shows sector allocation overview and detailed sector information with expandable stock lists
class HeatmapWidget extends StatelessWidget {
  final Heatmap? heatmap;
  final bool isLoading;
  final String? error;

  const HeatmapWidget({
    super.key,
    this.heatmap,
    this.isLoading = false,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // First card: Sector allocation overview with visual heatmap
          SectorOverviewCard(
            heatmap: heatmap,
            isLoading: isLoading,
            error: error,
          ),

          const SizedBox(height: 16),

          // Second card: Detailed sector list with expandable stock information
          SectorDetailsCard(
            heatmap: heatmap,
            isLoading: isLoading,
            error: error,
          ),
        ],
      ),
    );
  }
}
