import 'package:flutter/material.dart';

import '../../../../core/utils/logger.dart';
import '../../../models/heatmap/heatmap_tile_data.dart';
import '../../../models/heatmap/heatmap_ui_data.dart';
import '../../selectors/sector_selector.dart';
import 'heatmap_layout_builder.dart';

/// List layout builder that displays heatmap tiles in a vertical list
/// Optimized for detailed information display and easy scanning
class ListLayoutBuilder extends HeatmapLayoutBuilder {
  @override
  Widget build(
    BuildContext context,
    HeatmapData data,
    double width,
    double height, {
    VoidCallback? onTilePressed,
    Widget Function(HeatmapTileData tile)? customTileBuilder,
    SectorType? selectedSector,
  }) {
    // Get tiles based on selected sector using common base class method (includes sorting)
    final sortedTiles = getTilesBasedOnSector(data, selectedSector);
    final tileHeight = _calculateOptimalTileHeight(data, width);

    AppLogger.debug(
      'ListLayoutBuilder: building list with ${sortedTiles.length} tiles for sector=${selectedSector?.displayName ?? 'All'}, tileHeight=$tileHeight',
      tag: 'Heatmap.List',
    );

    return ListView.builder(
      padding: const EdgeInsets.all(4),
      itemCount: sortedTiles.length,
      itemBuilder: (context, index) {
        final tile = sortedTiles[index];
        return Container(
          height: tileHeight,
          margin: const EdgeInsets.only(bottom: 4),
          child: buildUnifiedHeatmapTileCard(
            context,
            tile,
            data,
            HeatmapTileCardType.list,
            width: width,
            height: tileHeight,
            onTilePressed: onTilePressed,
            customTileBuilder: customTileBuilder,
          ),
        );
      },
    );
  }

  /// Calculates optimal tile height based on content and screen size
  double _calculateOptimalTileHeight(HeatmapData data, double width) {
    final config = data.configuration;

    // Base height depending on content density
    double baseHeight = 60;

    // Adjust for content complexity
    if (config.showSubCards) {
      baseHeight += 20; // More space for additional info
    }

    if (config.showPerformance && config.showValue) {
      baseHeight += 15; // Extra space for multiple metrics
    }

    // Adjust for screen size
    if (width > 800) {
      baseHeight += 10; // Larger tiles on bigger screens
    } else if (width < 400) {
      baseHeight -= 10; // Smaller tiles on mobile
    }

    return baseHeight.clamp(50, 100);
  }
}

/// Configuration class for list layout customization
class ListLayoutConfig {
  const ListLayoutConfig({
    this.tileHeight = 60,
    this.spacing = 4.0,
    this.padding = const EdgeInsets.all(4),
    this.showShadows = true,
    this.borderRadius = 8.0,
  });

  /// Height of each list tile
  final double tileHeight;

  /// Spacing between tiles
  final double spacing;

  /// Padding around the list
  final EdgeInsets padding;

  /// Whether to show tile shadows
  final bool showShadows;

  /// Border radius for tiles
  final double borderRadius;

  /// Predefined configurations for different use cases
  static const compact = ListLayoutConfig(
    tileHeight: 50,
    spacing: 2.0,
    padding: EdgeInsets.all(2),
    showShadows: false,
    borderRadius: 6.0,
  );

  static const normal = ListLayoutConfig();

  static const detailed = ListLayoutConfig(
    tileHeight: 80,
    spacing: 6.0,
    padding: EdgeInsets.all(6),
    borderRadius: 10.0,
  );
}
