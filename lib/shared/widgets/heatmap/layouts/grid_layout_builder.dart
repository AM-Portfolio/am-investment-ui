import 'package:flutter/material.dart';

import '../../../../core/utils/logger.dart';
import '../../../models/heatmap/heatmap_tile_data.dart';
import '../../../models/heatmap/heatmap_ui_data.dart';
import 'heatmap_layout_builder.dart';

/// Grid layout builder that arranges heatmap tiles in a responsive grid
/// Automatically adjusts column count based on screen size and tile count
class GridLayoutBuilder extends HeatmapLayoutBuilder {
  @override
  Widget build(
    BuildContext context,
    HeatmapData data,
    double width,
    double height, {
    VoidCallback? onTilePressed,
    Widget Function(HeatmapTileData tile)? customTileBuilder,
  }) {
    final tiles = getUiTiles(data);
    final crossAxisCount = _calculateOptimalCrossAxisCount(
      context,
      tiles.length,
      width,
    );

    AppLogger.debug(
      'GridLayoutBuilder: building grid with ${tiles.length} tiles, crossAxisCount=$crossAxisCount',
      tag: 'Heatmap.Grid',
    );

    return GridView.builder(
      padding: const EdgeInsets.all(4),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: _calculateSpacing(width),
        mainAxisSpacing: _calculateSpacing(width),
        childAspectRatio: _calculateOptimalAspectRatio(data),
      ),
      itemCount: tiles.length,
      itemBuilder: (context, index) {
        final tile = tiles[index];
        return buildHeatmapTile(
          context,
          tile,
          data,
          onTilePressed: onTilePressed,
          customTileBuilder: customTileBuilder,
        );
      },
    );
  }

  /// Calculates optimal number of columns based on screen width and tile count
  int _calculateOptimalCrossAxisCount(
    BuildContext context,
    int tileCount,
    double width,
  ) {
    // Base calculation on width
    int crossAxisCount;
    if (width > 1200) {
      crossAxisCount = 6;
    } else if (width > 900) {
      crossAxisCount = 5;
    } else if (width > 600) {
      crossAxisCount = 4;
    } else if (width > 400) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 2;
    }

    // Adjust based on tile count to avoid having too few tiles per row
    if (tileCount < crossAxisCount) {
      crossAxisCount = tileCount;
    }

    // Ensure minimum of 1 column
    return crossAxisCount.clamp(1, 6);
  }

  /// Calculates spacing between grid tiles based on available width
  double _calculateSpacing(double width) {
    if (width > 1200) return 8.0;
    if (width > 800) return 6.0;
    if (width > 400) return 4.0;
    return 2.0;
  }

  /// Calculates optimal aspect ratio for grid tiles based on configuration
  double _calculateOptimalAspectRatio(HeatmapData data) {
    final config = data.configuration;

    // If showing detailed information, make tiles taller
    if (config.showSubCards && config.showPerformance && config.showValue) {
      return 1.0; // Square tiles for detailed view
    } else if (config.showSubCards) {
      return 1.2; // Slightly wider for moderate detail
    } else {
      return 1.4; // Wider for minimal information
    }
  }
}

/// Configuration class for grid layout customization
class GridLayoutConfig {
  const GridLayoutConfig({
    this.minTileWidth = 100,
    this.maxTileWidth = 200,
    this.preferredAspectRatio = 1.2,
    this.spacing = 4.0,
    this.padding = const EdgeInsets.all(4),
  });

  /// Minimum width for each grid tile
  final double minTileWidth;

  /// Maximum width for each grid tile
  final double maxTileWidth;

  /// Preferred aspect ratio for tiles (width/height)
  final double preferredAspectRatio;

  /// Spacing between tiles
  final double spacing;

  /// Padding around the grid
  final EdgeInsets padding;

  /// Predefined configurations for different use cases
  static const compact = GridLayoutConfig(
    minTileWidth: 80,
    maxTileWidth: 150,
    preferredAspectRatio: 1.4,
    spacing: 2.0,
    padding: EdgeInsets.all(2),
  );

  static const normal = GridLayoutConfig();

  static const detailed = GridLayoutConfig(
    minTileWidth: 120,
    maxTileWidth: 250,
    preferredAspectRatio: 1.0,
    spacing: 6.0,
    padding: EdgeInsets.all(6),
  );
}
