import 'package:flutter/material.dart';

import '../../../../core/utils/logger.dart';
import '../../../models/heatmap/heatmap_tile_data.dart';
import '../../../models/heatmap/heatmap_ui_data.dart';
import '../../selectors/sector_selector.dart';
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
    SectorType? selectedSector,
  }) {
    // Get tiles based on selected sector using common base class method (includes centralized sorting)
    final sortedTiles = getTilesBasedOnSector(data, selectedSector);

    AppLogger.debug(
      'TreemapLayoutBuilder: building treemap with ${sortedTiles.length} tiles for sector=${selectedSector?.displayName ?? 'All'}',
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
          child: buildUnifiedHeatmapTileCard(
            context,
            tile,
            data,
            HeatmapTileCardType.treemap,
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

  /// Calculates treemap layout using a proper squarified algorithm
  /// Ensures tiles are sized according to weightage and fill the entire space
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

    if (totalWeight == 0) {
      // If all weights are 0, distribute equally
      return _distributeEqually(tiles, width, height);
    }

    // Calculate area for each tile based on its weightage proportion
    final totalArea = width * height;
    final tilesWithArea = tiles.map((tile) {
      final proportionalArea = (tile.weightage / totalWeight) * totalArea;
      return _TileWithArea(tile, proportionalArea);
    }).toList();

    // Sort by area (largest first) for better squarification
    tilesWithArea.sort((a, b) => b.area.compareTo(a.area));

    // Apply mobile optimization: ensure minimum tile sizes for readability
    final optimizedTiles = _applyMobileSizeConstraints(
      tilesWithArea,
      width,
      height,
    );

    // Use squarified treemap algorithm
    _squarify(optimizedTiles, [], width, height, 0, 0, rectangles);

    return rectangles;
  }

  /// Distributes tiles equally when all weights are zero
  List<TreemapRectangle> _distributeEqually(
    List<HeatmapTileData> tiles,
    double width,
    double height,
  ) {
    final rectangles = <TreemapRectangle>[];
    final tilesWithArea = tiles
        .map((tile) => _TileWithArea(tile, 1.0))
        .toList();
    _squarify(tilesWithArea, [], width, height, 0, 0, rectangles);
    return rectangles;
  }

  /// Implements the squarified treemap algorithm for better aspect ratios
  void _squarify(
    List<_TileWithArea> children,
    List<_TileWithArea> row,
    double width,
    double height,
    double x,
    double y,
    List<TreemapRectangle> rectangles,
  ) {
    if (children.isEmpty) {
      if (row.isNotEmpty) {
        _addRowToLayout(row, width, height, x, y, rectangles);
      }
      return;
    }

    final child = children.first;
    final newRow = [...row, child];
    final remainingChildren = children.sublist(1);

    if (row.isEmpty || _isWorseAspectRatio(row, newRow, width, height)) {
      _squarify(remainingChildren, newRow, width, height, x, y, rectangles);
    } else {
      // Add current row and start new one
      final rowSum = row.fold<double>(0, (sum, tile) => sum + tile.area);
      final totalSum =
          children.fold<double>(0, (sum, tile) => sum + tile.area) + rowSum;

      if (width >= height) {
        // Horizontal layout
        final rowWidth = (rowSum / totalSum) * width;
        _addRowToLayout(row, rowWidth, height, x, y, rectangles);
        _squarify(
          children,
          [],
          width - rowWidth,
          height,
          x + rowWidth,
          y,
          rectangles,
        );
      } else {
        // Vertical layout
        final rowHeight = (rowSum / totalSum) * height;
        _addRowToLayout(row, width, rowHeight, x, y, rectangles);
        _squarify(
          children,
          [],
          width,
          height - rowHeight,
          x,
          y + rowHeight,
          rectangles,
        );
      }
    }
  }

  /// Checks if the new row has worse aspect ratio than the current row
  bool _isWorseAspectRatio(
    List<_TileWithArea> currentRow,
    List<_TileWithArea> newRow,
    double width,
    double height,
  ) {
    if (currentRow.isEmpty) return false;

    final currentWorst = _worstAspectRatio(currentRow, width, height);
    final newWorst = _worstAspectRatio(newRow, width, height);

    return currentWorst < newWorst;
  }

  /// Calculates the worst aspect ratio in a row
  double _worstAspectRatio(
    List<_TileWithArea> row,
    double width,
    double height,
  ) {
    if (row.isEmpty) return double.infinity;

    final rowSum = row.fold<double>(0, (sum, tile) => sum + tile.area);
    final minArea = row
        .map((tile) => tile.area)
        .reduce((a, b) => a < b ? a : b);
    final maxArea = row
        .map((tile) => tile.area)
        .reduce((a, b) => a > b ? a : b);

    final s2 = rowSum * rowSum;
    final w2 = width * width;
    final h2 = height * height;

    final horizontal = (w2 * maxArea) / s2;
    final vertical = s2 / (h2 * minArea);

    return horizontal > vertical ? horizontal : vertical;
  }

  /// Adds a row of tiles to the layout
  void _addRowToLayout(
    List<_TileWithArea> row,
    double width,
    double height,
    double x,
    double y,
    List<TreemapRectangle> rectangles,
  ) {
    if (row.isEmpty) return;

    final rowSum = row.fold<double>(0, (sum, tile) => sum + tile.area);

    if (width >= height) {
      // Horizontal row
      var currentY = y;
      for (final tile in row) {
        final tileHeight = (tile.area / rowSum) * height;
        rectangles.add(TreemapRectangle(x, currentY, width, tileHeight));
        currentY += tileHeight;
      }
    } else {
      // Vertical row
      var currentX = x;
      for (final tile in row) {
        final tileWidth = (tile.area / rowSum) * width;
        rectangles.add(TreemapRectangle(currentX, y, tileWidth, height));
        currentX += tileWidth;
      }
    }
  }

  /// Applies mobile size constraints to ensure tiles are readable on small screens
  List<_TileWithArea> _applyMobileSizeConstraints(
    List<_TileWithArea> tiles,
    double width,
    double height,
  ) {
    // Mobile optimization: minimum tile dimensions for readability
    final minTileArea = _calculateMinimumTileArea(width, height);

    // If screen is large enough, no constraints needed
    if (width > 600) return tiles;

    final constrainedTiles = <_TileWithArea>[];
    final totalArea = width * height;
    var remainingArea = totalArea;

    for (final tile in tiles) {
      var constrainedArea = tile.area;

      // Ensure minimum area for mobile readability
      if (constrainedArea < minTileArea) {
        constrainedArea = minTileArea;
      }

      // Don't let any single tile take more than 40% of screen on mobile
      final maxArea = totalArea * 0.4;
      if (constrainedArea > maxArea) {
        constrainedArea = maxArea;
      }

      constrainedTiles.add(_TileWithArea(tile.tile, constrainedArea));
      remainingArea -= constrainedArea;
    }

    // Redistribute any leftover area proportionally
    if (remainingArea > 0) {
      final totalConstrainedArea = constrainedTiles.fold<double>(
        0,
        (sum, tile) => sum + tile.area,
      );

      if (totalConstrainedArea > 0) {
        for (var i = 0; i < constrainedTiles.length; i++) {
          final proportion = constrainedTiles[i].area / totalConstrainedArea;
          final additionalArea = remainingArea * proportion;
          constrainedTiles[i] = _TileWithArea(
            constrainedTiles[i].tile,
            constrainedTiles[i].area + additionalArea,
          );
        }
      }
    }

    return constrainedTiles;
  }

  /// Calculates minimum tile area based on screen size for mobile readability
  double _calculateMinimumTileArea(double width, double height) {
    final totalArea = width * height;

    // Mobile screens: minimum 15% of total area per tile
    if (width < 400) return totalArea * 0.15;

    // Small tablets: minimum 12% of total area per tile
    if (width < 600) return totalArea * 0.12;

    // Larger screens: minimum 8% of total area per tile
    return totalArea * 0.08;
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
