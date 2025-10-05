import 'package:flutter/material.dart';

import '../../../../core/utils/logger.dart';
import '../../../models/heatmap/heatmap_tile_data.dart';
import '../../../models/heatmap/heatmap_ui_data.dart';
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
  }) {
    final tiles = getUiTiles(data);
    final sortedTiles = _sortTilesForListView(tiles, data);
    final tileHeight = _calculateOptimalTileHeight(data, width);

    AppLogger.debug(
      'ListLayoutBuilder: building list with ${sortedTiles.length} tiles, tileHeight=$tileHeight',
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

  /// Sorts tiles for optimal list display based on configuration
  List<HeatmapTileData> _sortTilesForListView(
    List<HeatmapTileData> tiles,
    HeatmapData data,
  ) {
    final config = data.configuration;

    // Sort by different criteria based on what's being emphasized
    if (config.colorScheme == HeatmapColorSchemeType.performance) {
      // Sort by performance (best to worst)
      return tiles..sort((a, b) => b.performance.compareTo(a.performance));
    } else if (config.colorScheme == HeatmapColorSchemeType.weightage) {
      // Sort by weightage (highest to lowest)
      return tiles..sort((a, b) => b.weightage.compareTo(a.weightage));
    } else {
      // Default alphabetical sort for neutral views
      return tiles..sort((a, b) => a.name.compareTo(b.name));
    }
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
    final config = data.configuration;

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

    return Row(
      children: [
        // Leading section - Name and primary info
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Tile name
              Text(
                tile.name,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
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
