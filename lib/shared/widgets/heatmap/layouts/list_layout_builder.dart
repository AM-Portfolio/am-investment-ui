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
          child: _buildListTile(
            context,
            tile,
            data,
            width,
            tileHeight,
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

  /// Builds a specialized list tile optimized for list layout
  Widget _buildListTile(
    BuildContext context,
    HeatmapTileData tile,
    HeatmapData data,
    double width,
    double height, {
    VoidCallback? onTilePressed,
    Widget Function(HeatmapTileData tile)? customTileBuilder,
  }) {
    if (customTileBuilder != null) {
      return GestureDetector(
        onTap: onTilePressed,
        child: customTileBuilder(tile),
      );
    }

    final tileColor = getTileColor(tile, data);
    final textColor = getTextColor(tileColor);

    return GestureDetector(
      onTap: onTilePressed,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: _buildListTileContent(
            context,
            tile,
            data,
            width,
            height,
            textColor,
          ),
        ),
      ),
    );
  }

  /// Builds optimized content layout for list tiles
  Widget _buildListTileContent(
    BuildContext context,
    HeatmapTileData tile,
    HeatmapData data,
    double width,
    double height,
    Color textColor,
  ) {
    final config = data.configuration;
    final showSubCards = config.showSubCards;
    final hierarchyLevel = _calculateHierarchyLevel(tile, data);

    return Row(
      children: [
        // Hierarchy indicator
        if (hierarchyLevel > 0) ...[
          Container(
            width:
                4 +
                (hierarchyLevel * 8.0), // Increasing indent for deeper levels
            height: height * 0.6,
            decoration: BoxDecoration(
              color: textColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
        ],

        // Leading section - Name and primary info
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Tile name with level indicator
              Row(
                children: [
                  if (hierarchyLevel > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: textColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'L${hierarchyLevel + 1}',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      tile.name,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),

              // Weightage
              if (config.showWeightage) ...[
                const SizedBox(height: 2),
                Text(
                  '${tile.weightage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: textColor.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),

        // Trailing section - Performance and value metrics
        if (showSubCards) ...[
          // Performance
          if (config.showPerformance)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${tile.performance >= 0 ? '+' : ''}${tile.performance.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (height > 70)
                    Text(
                      'Performance',
                      style: TextStyle(
                        color: textColor.withOpacity(0.7),
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),

          // Value
          if (config.showValue && tile.value != null)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '\$${_formatValue(tile.value!)}',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (height > 70)
                    Text(
                      'Value',
                      style: TextStyle(
                        color: textColor.withOpacity(0.7),
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
        ] else ...[
          // Simple layout without sub-cards
          const SizedBox(width: 16),
        ],
      ],
    );
  }

  /// Formats large values for display (e.g., 1234567 -> 1.23M)
  String _formatValue(double value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}B';
    } else if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toStringAsFixed(0);
    }
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
