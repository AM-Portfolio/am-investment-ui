import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/utils/logger.dart';
import '../../models/heatmap/heatmap_tile_data.dart';
import '../../models/heatmap/heatmap_ui_data.dart';

/// Pure heatmap display template - handles only tile rendering and layout
/// Extracted from HeatmapTemplateCard for better modularity
class HeatmapDisplayTemplate extends StatelessWidget {
  const HeatmapDisplayTemplate({
    required this.data,
    super.key,
    this.isLoading = false,
    this.error,
    this.onTilePressed,
    this.customTileBuilder,
    this.layout = HeatmapLayoutType.treemap,
  });

  final HeatmapData data;
  final bool isLoading;
  final String? error;
  final VoidCallback? onTilePressed;
  final Widget Function(HeatmapTileData tile)? customTileBuilder;
  final HeatmapLayoutType layout;

  @override
  Widget build(BuildContext context) {
    AppLogger.debug(
      'HeatmapDisplayTemplate: rendering ${data.tiles.length} tiles, layout=$layout',
      tag: 'Heatmap.Display',
    );

    // Log complete heatmap tile data including children
    _logAllChildrenHeatmapTileData();

    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading heatmap...'),
          ],
        ),
      );
    }

    if (error != null) {
      return _buildErrorState(context);
    }

    if (!data.hasData) {
      return _buildEmptyState(context);
    }

    return _buildHeatmap(context);
  }

  Widget _buildErrorState(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          color: Theme.of(context).colorScheme.error,
          size: 48,
        ),
        const SizedBox(height: 8),
        Text(
          'Failed to load heatmap data',
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          error!,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  Widget _buildEmptyState(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.data_usage_outlined,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          size: 48,
        ),
        const SizedBox(height: 8),
        Text(
          'No data available',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 16,
          ),
        ),
      ],
    ),
  );

  Widget _buildHeatmap(BuildContext context) {
    switch (layout) {
      case HeatmapLayoutType.treemap:
        return _buildTreemapLayout(context);
      case HeatmapLayoutType.grid:
        return _buildGridLayout(context);
      case HeatmapLayoutType.list:
        return _buildListLayout(context);
    }
  }

  Widget _buildTreemapLayout(BuildContext context) {
    final tiles = _getUiTiles();
    final sortedTiles = List<HeatmapTileData>.from(tiles)
      ..sort((a, b) => b.weightage.compareTo(a.weightage));

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;

        return Stack(
          children: _calculateTreemapPositions(
            context,
            sortedTiles,
            availableWidth,
            availableHeight,
          ),
        );
      },
    );
  }

  Widget _buildGridLayout(BuildContext context) {
    final crossAxisCount = _calculateGridCrossAxisCount(context);
    final tiles = _getUiTiles();

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 1.2,
      ),
      itemCount: tiles.length,
      itemBuilder: (context, index) {
        final tile = tiles[index];
        return _buildHeatmapTile(context, tile, null, null);
      },
    );
  }

  Widget _buildListLayout(BuildContext context) {
    final tiles = _getUiTiles();

    return ListView.builder(
      itemCount: tiles.length,
      itemBuilder: (context, index) {
        final tile = tiles[index];
        return Container(
          height: 60,
          margin: const EdgeInsets.only(bottom: 4),
          child: _buildHeatmapTile(context, tile, null, 60),
        );
      },
    );
  }

  int _calculateGridCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) return 5;
    if (screenWidth > 800) return 4;
    if (screenWidth > 600) return 3;
    return 2;
  }

  List<Widget> _calculateTreemapPositions(
    BuildContext context,
    List<HeatmapTileData> tiles,
    double width,
    double height,
  ) {
    final widgets = <Widget>[];
    double currentX = 0;
    double currentY = 0;
    double rowHeight = 0;

    for (var i = 0; i < tiles.length; i++) {
      final tile = tiles[i];

      var tileWidth = _calculateTileWidth(tile.weightage, width);
      var tileHeight = _calculateTileHeight(tile.weightage, height);

      if (currentX + tileWidth > width && currentX > 0) {
        currentX = 0;
        currentY += rowHeight;
        rowHeight = 0;
      }

      if (currentY + tileHeight > height) {
        tileHeight = height - currentY;
      }
      if (currentX + tileWidth > width) {
        tileWidth = width - currentX;
      }

      rowHeight = math.max(rowHeight, tileHeight);

      widgets.add(
        Positioned(
          left: currentX,
          top: currentY,
          width: tileWidth,
          height: tileHeight,
          child: _buildHeatmapTile(context, tile, tileWidth, tileHeight),
        ),
      );

      currentX += tileWidth;
    }

    return widgets;
  }

  double _calculateTileWidth(double weightage, double containerWidth) {
    final baseWidth = (weightage / 100) * containerWidth;
    final minWidth = data.configuration.minTileWidth ?? containerWidth * 0.15;
    final maxWidth = data.configuration.maxTileWidth ?? containerWidth * 0.45;
    return baseWidth.clamp(minWidth, maxWidth).toDouble();
  }

  double _calculateTileHeight(double weightage, double containerHeight) {
    final baseHeight = (weightage / 100) * containerHeight;
    final minHeight =
        data.configuration.minTileHeight ?? containerHeight * 0.15;
    final maxHeight = data.configuration.maxTileHeight ?? containerHeight * 0.4;
    return baseHeight.clamp(minHeight, maxHeight).toDouble();
  }

  Widget _buildHeatmapTile(
    BuildContext context,
    HeatmapTileData tile,
    double? width,
    double? height,
  ) {
    if (customTileBuilder != null) {
      return GestureDetector(
        onTap: onTilePressed,
        child: customTileBuilder!(tile),
      );
    }

    final tileColor = _getTileColor(tile);
    final textColor = _getTextColor(tileColor);
    final config = data.configuration;

    return GestureDetector(
      onTap: () {
        AppLogger.debug(
          'Heatmap tile tapped: ${tile.name} (${tile.performance})',
          tag: 'Heatmap.Tile',
        );
        onTilePressed?.call();
      },
      child: Container(
        margin: config.tileMargin ?? const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5),
        ),
        child: Padding(
          padding: config.tilePadding ?? const EdgeInsets.all(4.0),
          child: _buildTileContent(context, tile, width, height, textColor),
        ),
      ),
    );
  }

  Widget _buildTileContent(
    BuildContext context,
    HeatmapTileData tile,
    double? width,
    double? height,
    Color textColor,
  ) {
    final config = data.configuration;
    final showSubCards = config.showSubCards;
    final effectiveHeight = height ?? 60;
    final effectiveWidth = width ?? 100;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tile name
        if (effectiveHeight > 25)
          Flexible(
            child: Text(
              tile.name,
              style: TextStyle(
                color: textColor,
                fontSize: _calculateFontSize(effectiveWidth, showSubCards),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: effectiveHeight > 80 ? 2 : 1,
            ),
          ),

        // Weightage
        if (config.showWeightage && effectiveHeight > 40)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '${tile.weightage.toStringAsFixed(1)}%',
              style: TextStyle(
                color: textColor.withOpacity(0.8),
                fontSize: _calculateFontSize(
                  effectiveWidth,
                  showSubCards,
                  isSecondary: true,
                ),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),

        // Performance
        if (config.showPerformance && showSubCards && effectiveHeight > 60)
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Text(
              '${tile.performance >= 0 ? '+' : ''}${tile.performance.toStringAsFixed(1)}%',
              style: TextStyle(
                color: textColor.withOpacity(0.9),
                fontSize: _calculateFontSize(
                  effectiveWidth,
                  showSubCards,
                  isSmall: true,
                ),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),

        // Value
        if (config.showValue &&
            showSubCards &&
            effectiveHeight > 80 &&
            tile.value != null)
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Text(
              '\$${tile.value!.toStringAsFixed(0)}',
              style: TextStyle(
                color: textColor.withOpacity(0.7),
                fontSize: _calculateFontSize(
                  effectiveWidth,
                  showSubCards,
                  isSmall: true,
                ),
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  double _calculateFontSize(
    double width,
    bool showSubCards, {
    bool isSecondary = false,
    bool isSmall = false,
  }) {
    double baseFontSize;

    if (isSmall) {
      baseFontSize = showSubCards ? (width > 120 ? 8 : 7) : 10;
    } else if (isSecondary) {
      baseFontSize = showSubCards ? (width > 120 ? 12 : 10) : 14;
    } else {
      baseFontSize = showSubCards ? (width > 120 ? 10 : 8) : 12;
    }

    return baseFontSize;
  }

  Color _getTileColor(HeatmapTileData tile) {
    switch (data.configuration.colorScheme) {
      case HeatmapColorSchemeType.performance:
        return _getPerformanceColor(tile.performance);
      case HeatmapColorSchemeType.custom:
        return tile.customColor ?? Colors.grey.shade300;
      case HeatmapColorSchemeType.weightage:
        return _getWeightageColor(tile.weightage);
      case HeatmapColorSchemeType.neutral:
        return Colors.grey.shade300;
    }
  }

  Color _getPerformanceColor(double changePercent) {
    final intensity = (changePercent.abs() / 5).clamp(0.3, 1.0);

    if (changePercent > 0) {
      return Color.lerp(
        Colors.green.shade100,
        Colors.green.shade600,
        intensity,
      )!;
    } else if (changePercent < 0) {
      return Color.lerp(Colors.red.shade100, Colors.red.shade600, intensity)!;
    } else {
      return Colors.grey.shade300;
    }
  }

  Color _getWeightageColor(double weightage) {
    final intensity = (weightage / 100).clamp(0.2, 1.0);
    return Color.lerp(Colors.blue.shade100, Colors.blue.shade600, intensity)!;
  }

  Color _getTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  List<HeatmapTileData> _getUiTiles() => data.tiles.map((tile) {
    if (tile is HeatmapTileData) {
      return tile;
    } else {
      return HeatmapTileData.fromEntity(tile);
    }
  }).toList();

  /// Logs basic information about heatmap tile data
  /// Shows count of tiles, their names, and children count
  void _logAllChildrenHeatmapTileData() {
    if (data.tiles.isEmpty) {
      AppLogger.debug(
        'No heatmap tiles available',
        tag: 'Heatmap.Display.Tiles',
      );
      return;
    }

    AppLogger.debug(
      'Heatmap has ${data.tiles.length} tiles',
      tag: 'Heatmap.Display.Tiles',
    );

    // Log each tile with basic info
    for (var i = 0; i < data.tiles.length; i++) {
      final tile = data.tiles[i];
      final uiTile = tile is HeatmapTileData
          ? tile
          : HeatmapTileData.fromEntity(tile);

      final childrenCount = uiTile.children?.length ?? 0;

      AppLogger.debug(
        'Tile ${i + 1}: ${uiTile.name} ($childrenCount children)',
        tag: 'Heatmap.Display.Tiles',
      );
    }
  }
}

/// Enum for different layout types in display template
enum HeatmapLayoutType { treemap, grid, list }
