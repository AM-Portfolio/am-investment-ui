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

  /// Logs comprehensive information about all heatmap tile data
  /// Includes complete tile details, configuration, and hierarchical children structure
  void _logAllChildrenHeatmapTileData() {
    if (data.tiles.isEmpty) {
      AppLogger.debug(
        'No heatmap tiles available to log',
        tag: 'Heatmap.Display.Complete',
      );
      return;
    }

    AppLogger.debug(
      '================ COMPLETE HEATMAP DATA LOG ================',
      tag: 'Heatmap.Display.Complete',
    );

    // Log heatmap configuration
    AppLogger.debug(
      '--- Heatmap Configuration ---\n'
      'ID: ${data.id}\n'
      'Total Tiles: ${data.tiles.length}\n'
      'Layout Type: $layout\n'
      'Color Scheme: ${data.configuration.colorScheme.name}\n'
      'Show Sub Cards: ${data.configuration.showSubCards}\n'
      'Show Weightage: ${data.configuration.showWeightage}\n'
      'Show Performance: ${data.configuration.showPerformance}\n'
      'Show Value: ${data.configuration.showValue}\n'
      'Min Tile Width: ${data.configuration.minTileWidth}\n'
      'Max Tile Width: ${data.configuration.maxTileWidth}\n'
      'Min Tile Height: ${data.configuration.minTileHeight}\n'
      'Max Tile Height: ${data.configuration.maxTileHeight}',
      tag: 'Heatmap.Display.Complete',
    );

    // Calculate total statistics
    double totalWeightage = 0;
    double totalPerformance = 0;
    double? totalValue = 0;
    var totalChildren = 0;
    var tilesWithCustomColors = 0;

    for (final tile in data.tiles) {
      final uiTile = tile is HeatmapTileData
          ? tile
          : HeatmapTileData.fromEntity(tile);
      totalWeightage += uiTile.weightage;
      totalPerformance += uiTile.performance;
      if (uiTile.value != null) {
        totalValue = (totalValue ?? 0) + uiTile.value!;
      } else {
        totalValue = null;
      }
      totalChildren += uiTile.children?.length ?? 0;
      if (uiTile.customColor != null) tilesWithCustomColors++;
    }

    AppLogger.debug(
      '--- Aggregated Statistics ---\n'
      'Total Weightage: ${totalWeightage.toStringAsFixed(2)}%\n'
      'Average Performance: ${(totalPerformance / data.tiles.length).toStringAsFixed(2)}%\n'
      'Total Value: ${totalValue?.toStringAsFixed(2) ?? 'N/A'}\n'
      'Total Children Across All Tiles: $totalChildren\n'
      'Tiles with Custom Colors: $tilesWithCustomColors/${data.tiles.length}',
      tag: 'Heatmap.Display.Complete',
    );

    // Log each tile with complete details
    for (var i = 0; i < data.tiles.length; i++) {
      final tile = data.tiles[i];
      final uiTile = tile is HeatmapTileData
          ? tile
          : HeatmapTileData.fromEntity(tile);

      AppLogger.debug(
        '========== TILE ${i + 1}/${data.tiles.length}: ${uiTile.name} ==========\n'
        '🆔 ID: ${uiTile.id}\n'
        '📛 Name: ${uiTile.name}\n'
        '📈 Performance: ${uiTile.performance.toStringAsFixed(3)}%\n'
        '⚖️ Weightage: ${uiTile.weightage.toStringAsFixed(3)}%\n'
        '💰 Value: ${uiTile.value?.toStringAsFixed(2) ?? 'N/A'}\n'
        '👥 Children Count: ${uiTile.children?.length ?? 0}\n'
        '🎨 Custom Color: ${uiTile.customColor?.toString() ?? 'None'}\n'
        '🔗 Tile Type: ${uiTile.runtimeType}\n'
        '📊 Performance Range: ${uiTile.performance >= 0 ? 'Positive' : 'Negative'}\n'
        '📏 Size Category: ${_getTileSizeCategory(uiTile.weightage)}',
        tag: 'Heatmap.Display.Complete',
      );

      // Log complete children details if present
      if (uiTile.children != null && uiTile.children!.isNotEmpty) {
        AppLogger.debug(
          '--- CHILDREN OF ${uiTile.name} (${uiTile.children!.length} total) ---',
          tag: 'Heatmap.Display.Complete.Children',
        );

        double childrenTotalPerformance = 0;
        double childrenTotalWeightage = 0;

        for (var j = 0; j < uiTile.children!.length; j++) {
          final child = uiTile.children![j];
          final childUiTile = child is HeatmapTileData
              ? child
              : HeatmapTileData.fromEntity(child);
          childrenTotalPerformance += childUiTile.performance;
          childrenTotalWeightage += childUiTile.weightage;

          AppLogger.debug(
            '  📍 Child ${j + 1}/${uiTile.children!.length}:\n'
            '    🆔 ID: ${childUiTile.id}\n'
            '    📛 Name: ${childUiTile.name}\n'
            '    📈 Performance: ${childUiTile.performance.toStringAsFixed(3)}%\n'
            '    ⚖️ Weightage: ${childUiTile.weightage.toStringAsFixed(3)}%\n'
            '    💰 Value: ${childUiTile.value?.toStringAsFixed(2) ?? 'N/A'}\n'
            '    🎨 Custom Color: ${childUiTile.customColor?.toString() ?? 'None'}\n'
            '    📊 Performance Impact: ${_getPerformanceImpact(childUiTile.performance)}',
            tag: 'Heatmap.Display.Complete.Children',
          );
        }

        final childrenUiTiles = uiTile.children!
            .map(
              (child) => child is HeatmapTileData
                  ? child
                  : HeatmapTileData.fromEntity(child),
            )
            .toList();

        AppLogger.debug(
          '  📋 Children Summary for ${uiTile.name}:\n'
          '    📈 Average Performance: ${(childrenTotalPerformance / uiTile.children!.length).toStringAsFixed(2)}%\n'
          '    ⚖️ Total Weightage: ${childrenTotalWeightage.toStringAsFixed(2)}%\n'
          '    🎯 Best Performer: ${_getBestPerformer(childrenUiTiles)}\n'
          '    📉 Worst Performer: ${_getWorstPerformer(childrenUiTiles)}',
          tag: 'Heatmap.Display.Complete.Children',
        );
      } else {
        AppLogger.debug(
          '--- NO CHILDREN for ${uiTile.name} ---',
          tag: 'Heatmap.Display.Complete.Children',
        );
      }

      AppLogger.debug(
        '========== END TILE ${i + 1} ==========',
        tag: 'Heatmap.Display.Complete',
      );
    }

    AppLogger.debug(
      '================== END COMPLETE HEATMAP DATA LOG ==================',
      tag: 'Heatmap.Display.Complete',
    );
  }

  /// Helper method to categorize tile size based on weightage
  String _getTileSizeCategory(double weightage) {
    if (weightage >= 20) return 'Large (≥20%)';
    if (weightage >= 10) return 'Medium (10-19%)';
    if (weightage >= 5) return 'Small (5-9%)';
    return 'Tiny (<5%)';
  }

  /// Helper method to categorize performance impact
  String _getPerformanceImpact(double performance) {
    if (performance >= 5) return 'High Positive (≥5%)';
    if (performance >= 1) return 'Moderate Positive (1-4%)';
    if (performance >= -1) return 'Neutral (-1% to 1%)';
    if (performance >= -5) return 'Moderate Negative (-1% to -5%)';
    return 'High Negative (≤-5%)';
  }

  /// Helper method to find best performing child
  String _getBestPerformer(List<HeatmapTileData> children) {
    if (children.isEmpty) return 'None';
    final best = children.reduce(
      (a, b) => a.performance > b.performance ? a : b,
    );
    return '${best.name} (${best.performance.toStringAsFixed(2)}%)';
  }

  /// Helper method to find worst performing child
  String _getWorstPerformer(List<HeatmapTileData> children) {
    if (children.isEmpty) return 'None';
    final worst = children.reduce(
      (a, b) => a.performance < b.performance ? a : b,
    );
    return '${worst.name} (${worst.performance.toStringAsFixed(2)}%)';
  }
}

/// Enum for different layout types in display template
enum HeatmapLayoutType { treemap, grid, list }
