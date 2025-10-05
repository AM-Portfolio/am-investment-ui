import 'package:flutter/material.dart';

import '../../../../core/utils/logger.dart';
import '../../../models/heatmap/heatmap_tile_data.dart';
import '../../../models/heatmap/heatmap_ui_data.dart';
import 'heatmap_layout_builder.dart';

/// Treemap layout builder that implements a space-filling tree visualization
/// Uses a squarified treemap algorithm for better aspect ratios
class TreemapLayoutBuilder extends HeatmapLayoutBuilder {
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
    final sortedTiles = List<HeatmapTileData>.from(tiles)
      ..sort((a, b) => b.weightage.compareTo(a.weightage));

    AppLogger.debug(
      'TreemapLayoutBuilder: building treemap with ${sortedTiles.length} tiles',
      tag: 'Heatmap.Treemap',
    );

    return Stack(
      children: _buildTreemapRectangles(
        context,
        data,
        sortedTiles,
        width,
        height,
        onTilePressed: onTilePressed,
        customTileBuilder: customTileBuilder,
      ),
    );
  }

  /// Builds treemap rectangles using a simplified squarified algorithm
  List<Widget> _buildTreemapRectangles(
    BuildContext context,
    HeatmapData data,
    List<HeatmapTileData> tiles,
    double width,
    double height, {
    VoidCallback? onTilePressed,
    Widget Function(HeatmapTileData tile)? customTileBuilder,
  }) {
    if (tiles.isEmpty) return [];

    final widgets = <Widget>[];
    final rectangles = _calculateTreemapLayout(tiles, width, height, data);

    for (var i = 0; i < rectangles.length; i++) {
      final rect = rectangles[i];
      final tile = tiles[i];

      widgets.add(
        Positioned(
          left: rect.left,
          top: rect.top,
          width: rect.width,
          height: rect.height,
          child: buildHeatmapTile(
            context,
            tile,
            data,
            width: rect.width,
            height: rect.height,
            onTilePressed: onTilePressed,
            customTileBuilder: customTileBuilder,
          ),
        ),
      );
    }

    return widgets;
  }

  /// Calculates treemap layout using a row-based algorithm
  List<TreemapRectangle> _calculateTreemapLayout(
    List<HeatmapTileData> tiles,
    double width,
    double height,
    HeatmapData data,
  ) {
    if (tiles.isEmpty) return [];

    final rectangles = <TreemapRectangle>[];
    final totalWeight = tiles.fold<double>(
      0,
      (sum, tile) => sum + tile.weightage,
    );

    // Normalize weights to match the total area
    final totalArea = width * height;
    final normalizedTiles = tiles.map((tile) {
      final normalizedWeight = (tile.weightage / totalWeight) * totalArea;
      return _TileWithArea(tile, normalizedWeight);
    }).toList();

    // Use row-based layout algorithm
    _layoutRows(normalizedTiles, 0, 0, width, height, rectangles, data);

    return rectangles;
  }

  /// Recursively layouts tiles in rows for better aspect ratios
  void _layoutRows(
    List<_TileWithArea> tiles,
    double x,
    double y,
    double width,
    double height,
    List<TreemapRectangle> rectangles,
    HeatmapData data,
  ) {
    if (tiles.isEmpty) return;

    if (tiles.length == 1) {
      // Single tile - use the entire remaining space
      rectangles.add(TreemapRectangle(x, y, width, height));
      return;
    }

    // Determine if we should split horizontally or vertically
    final shouldSplitHorizontally = width > height;

    if (shouldSplitHorizontally) {
      _splitHorizontally(tiles, x, y, width, height, rectangles, data);
    } else {
      _splitVertically(tiles, x, y, width, height, rectangles, data);
    }
  }

  /// Splits the area horizontally
  void _splitHorizontally(
    List<_TileWithArea> tiles,
    double x,
    double y,
    double width,
    double height,
    List<TreemapRectangle> rectangles,
    HeatmapData data,
  ) {
    final totalArea = tiles.fold<double>(0, (sum, tile) => sum + tile.area);
    var currentX = x;

    for (var i = 0; i < tiles.length; i++) {
      final tile = tiles[i];
      final tileWidth = (tile.area / totalArea) * width;
      final clampedWidth = _clampTileWidth(tileWidth, width, data);

      rectangles.add(TreemapRectangle(currentX, y, clampedWidth, height));

      currentX += clampedWidth;
    }
  }

  /// Splits the area vertically
  void _splitVertically(
    List<_TileWithArea> tiles,
    double x,
    double y,
    double width,
    double height,
    List<TreemapRectangle> rectangles,
    HeatmapData data,
  ) {
    final totalArea = tiles.fold<double>(0, (sum, tile) => sum + tile.area);
    var currentY = y;

    for (var i = 0; i < tiles.length; i++) {
      final tile = tiles[i];
      final tileHeight = (tile.area / totalArea) * height;
      final clampedHeight = _clampTileHeight(tileHeight, height, data);

      rectangles.add(TreemapRectangle(x, currentY, width, clampedHeight));

      currentY += clampedHeight;
    }
  }

  /// Clamps tile width based on configuration constraints
  double _clampTileWidth(
    double width,
    double containerWidth,
    HeatmapData data,
  ) {
    final minWidth = data.configuration.minTileWidth ?? containerWidth * 0.1;
    final maxWidth = data.configuration.maxTileWidth ?? containerWidth * 0.6;
    return width.clamp(minWidth, maxWidth);
  }

  /// Clamps tile height based on configuration constraints
  double _clampTileHeight(
    double height,
    double containerHeight,
    HeatmapData data,
  ) {
    final minHeight = data.configuration.minTileHeight ?? containerHeight * 0.1;
    final maxHeight = data.configuration.maxTileHeight ?? containerHeight * 0.6;
    return height.clamp(minHeight, maxHeight);
  }
}

/// Represents a rectangle in the treemap layout
class TreemapRectangle {
  const TreemapRectangle(this.left, this.top, this.width, this.height);

  final double left;
  final double top;
  final double width;
  final double height;

  double get right => left + width;
  double get bottom => top + height;
  double get area => width * height;
  double get aspectRatio => width / height;

  @override
  String toString() =>
      'TreemapRectangle(left: $left, top: $top, width: $width, height: $height)';
}

/// Helper class to associate tiles with their calculated area
class _TileWithArea {
  const _TileWithArea(this.tile, this.area);

  final HeatmapTileData tile;
  final double area;

  @override
  String toString() => 'TileWithArea(${tile.name}, area: $area)';
}
