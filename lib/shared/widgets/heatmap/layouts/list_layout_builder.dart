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

    AppLogger.debug(
      'ListLayoutBuilder: building weightage-based list with ${sortedTiles.length} tiles for sector=${selectedSector?.displayName ?? 'All'}',
      tag: 'Heatmap.List',
    );

    // Use weightage-based layout that fills the available height
    return _buildWeightageBasedList(
      context,
      sortedTiles,
      data,
      width,
      height,
      onTilePressed: onTilePressed,
      customTileBuilder: customTileBuilder,
    );
  }

  /// Builds a weightage-based list that fills the available height
  Widget _buildWeightageBasedList(
    BuildContext context,
    List<HeatmapTileData> tiles,
    HeatmapData data,
    double width,
    double height, {
    VoidCallback? onTilePressed,
    Widget Function(HeatmapTileData tile)? customTileBuilder,
  }) {
    if (tiles.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final listItems = _calculateListItemHeights(tiles, height, data);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(4),
      child: Column(
        children: listItems
            .map(
              (listItem) => Container(
                height: listItem.height,
                margin: const EdgeInsets.only(bottom: 4),
                child: buildUnifiedHeatmapTileCard(
                  context,
                  listItem.tile,
                  data,
                  HeatmapTileCardType.list,
                  width: width,
                  height: listItem.height,
                  onTilePressed: onTilePressed,
                  customTileBuilder: customTileBuilder,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  /// Calculates list item heights based on weightage distribution with mobile optimization
  List<_ListItem> _calculateListItemHeights(
    List<HeatmapTileData> tiles,
    double availableHeight,
    HeatmapData data,
  ) {
    final totalWeight = tiles.fold<double>(
      0,
      (sum, tile) => sum + tile.weightage,
    );

    // Responsive padding and spacing based on available height
    final padding = _calculateListPadding(availableHeight);
    final itemSpacing = _calculateItemSpacing(availableHeight);
    final minItemHeight = _calculateMinItemHeight(availableHeight);
    final maxItemHeight = _calculateMaxItemHeight(availableHeight);

    final totalSpacing = (tiles.length - 1) * itemSpacing;
    final usableHeight = availableHeight - padding - totalSpacing;

    if (totalWeight == 0) {
      // Equal distribution when no weights
      final equalHeight = (usableHeight / tiles.length).clamp(
        minItemHeight,
        maxItemHeight,
      );
      return tiles
          .map((tile) => _ListItem(tile: tile, height: equalHeight))
          .toList();
    }

    // Calculate heights based on weightage
    final baseHeight = usableHeight * 0.6; // 60% for base heights
    final variableHeight =
        usableHeight * 0.4; // 40% for weightage-based variation

    final baseHeightPerTile = baseHeight / tiles.length;

    return tiles.map((tile) {
      final weightRatio = tile.weightage / totalWeight;
      final weightageContribution =
          variableHeight * weightRatio * tiles.length; // Normalize
      final totalHeight = baseHeightPerTile + weightageContribution;

      return _ListItem(
        tile: tile,
        height: totalHeight.clamp(minItemHeight, maxItemHeight),
      );
    }).toList();
  }

  /// Calculates responsive padding for list layout
  double _calculateListPadding(double availableHeight) {
    if (availableHeight > 600) return 8.0; // Large screens
    if (availableHeight > 400) return 6.0; // Medium screens
    return 4.0; // Small screens
  }

  /// Calculates responsive item spacing
  double _calculateItemSpacing(double availableHeight) {
    if (availableHeight > 600) return 4.0; // Large screens
    if (availableHeight > 400) return 3.0; // Medium screens
    return 2.0; // Small screens - tight spacing
  }

  /// Calculates minimum item height based on screen size
  double _calculateMinItemHeight(double availableHeight) {
    if (availableHeight > 600) return 50.0; // Large screens - generous height
    if (availableHeight > 400) return 45.0; // Medium screens
    return 40.0; // Small screens - compact height
  }

  /// Calculates maximum item height based on screen size
  double _calculateMaxItemHeight(double availableHeight) {
    if (availableHeight > 800) return 140.0; // Very large screens
    if (availableHeight > 600) return 120.0; // Large screens
    if (availableHeight > 400) return 100.0; // Medium screens
    return 80.0; // Small screens - prevent oversized items
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

/// Helper class for list item height calculations
class _ListItem {
  const _ListItem({required this.tile, required this.height});

  final HeatmapTileData tile;
  final double height;
}
