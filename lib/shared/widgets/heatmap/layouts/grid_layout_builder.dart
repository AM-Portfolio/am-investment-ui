import 'package:flutter/material.dart';

import '../../../../core/utils/logger.dart';
import '../../../models/heatmap/heatmap_tile_data.dart';
import '../../../models/heatmap/heatmap_ui_data.dart';
import '../../selectors/sector_selector.dart';
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
    SectorType? selectedSector,
  }) {
    // Get tiles based on selected sector using common base class method (includes centralized sorting)
    final displayTiles = getTilesBasedOnSector(data, selectedSector);
    final crossAxisCount = _calculateOptimalCrossAxisCount(
      context,
      displayTiles.length,
      width,
    );

    AppLogger.debug(
      'GridLayoutBuilder: building grid with ${displayTiles.length} tiles for sector=${selectedSector?.displayName ?? 'All'}, crossAxisCount=$crossAxisCount',
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
      itemCount: displayTiles.length,
      itemBuilder: (context, index) {
        final tile = displayTiles[index];
        return _buildHierarchicalTile(
          context,
          tile,
          data,
          onTilePressed: onTilePressed,
          customTileBuilder: customTileBuilder,
        );
      },
    );
  }

  /// Builds a tile with visual indication of its hierarchy level
  Widget _buildHierarchicalTile(
    BuildContext context,
    HeatmapTileData tile,
    HeatmapData data, {
    VoidCallback? onTilePressed,
    Widget Function(HeatmapTileData tile)? customTileBuilder,
  }) {
    final hierarchyLevel = _calculateHierarchyLevel(tile, data);

    return Container(
      decoration: BoxDecoration(
        border: hierarchyLevel > 0
            ? Border.all(color: Colors.grey.shade400)
            : null,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          buildHeatmapTile(
            context,
            tile,
            data,
            onTilePressed: onTilePressed,
            customTileBuilder: customTileBuilder,
          ),
          // Add hierarchy indicator
          if (hierarchyLevel > 0)
            Positioned(
              top: 2,
              left: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'L${hierarchyLevel + 1}',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Calculates the hierarchy level of a tile (0 for root, 1 for first level children, etc.)
  int _calculateHierarchyLevel(HeatmapTileData targetTile, HeatmapData data) {
    final rootTiles = getUiTiles(data);

    for (final rootTile in rootTiles) {
      final level = _findTileLevel(rootTile, targetTile, 0);
      if (level >= 0) return level;
    }

    return 0; // Default to root level if not found
  }

  /// Recursively finds the level of a target tile within a hierarchy
  int _findTileLevel(
    HeatmapTileData currentTile,
    HeatmapTileData targetTile,
    int currentLevel,
  ) {
    if (currentTile.id == targetTile.id) {
      return currentLevel;
    }

    if (currentTile.children != null) {
      for (final child in currentTile.children!) {
        final childTile = child is HeatmapTileData
            ? child
            : HeatmapTileData.fromEntity(child);
        final foundLevel = _findTileLevel(
          childTile,
          targetTile,
          currentLevel + 1,
        );
        if (foundLevel >= 0) {
          return foundLevel;
        }
      }
    }

    return -1; // Not found in this branch
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

    // Account for hierarchy indicators - make tiles slightly taller
    double baseRatio;
    if (config.showSubCards && config.showPerformance && config.showValue) {
      baseRatio =
          0.9; // Slightly taller square tiles for detailed view with hierarchy
    } else if (config.showSubCards) {
      baseRatio = 1.1; // Slightly wider for moderate detail with hierarchy
    } else {
      baseRatio = 1.3; // Wider for minimal information with hierarchy
    }

    return baseRatio;
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
