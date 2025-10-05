import 'package:flutter/material.dart';

import '../../../models/heatmap/heatmap_tile_data.dart';
import '../../../models/heatmap/heatmap_ui_data.dart';

/// Abstract base class for all heatmap layout builders
/// Provides a common interface for different layout strategies
abstract class HeatmapLayoutBuilder {
  /// Builds the heatmap widget with the specified layout
  Widget build(
    BuildContext context,
    HeatmapData data,
    double width,
    double height, {
    VoidCallback? onTilePressed,
    Widget Function(HeatmapTileData tile)? customTileBuilder,
  });

  /// Gets the display tiles from the heatmap data
  List<HeatmapTileData> getUiTiles(HeatmapData data) => data.tiles.map((tile) {
    if (tile is HeatmapTileData) {
      return tile;
    } else {
      return HeatmapTileData.fromEntity(tile);
    }
  }).toList();

  /// Builds a single heatmap tile with consistent styling
  Widget buildHeatmapTile(
    BuildContext context,
    HeatmapTileData tile,
    HeatmapData data, {
    double? width,
    double? height,
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
        margin: config.tileMargin ?? const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5),
        ),
        child: Padding(
          padding: config.tilePadding ?? const EdgeInsets.all(4.0),
          child: buildTileContent(
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

  /// Builds the content inside a heatmap tile
  Widget buildTileContent(
    BuildContext context,
    HeatmapTileData tile,
    HeatmapData data,
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
                fontSize: calculateFontSize(effectiveWidth, showSubCards),
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
                fontSize: calculateFontSize(
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
                fontSize: calculateFontSize(
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
                fontSize: calculateFontSize(
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

  /// Calculates appropriate font size based on tile dimensions
  double calculateFontSize(
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

  /// Gets the color for a heatmap tile based on configuration
  Color getTileColor(HeatmapTileData tile, HeatmapData data) {
    switch (data.configuration.colorScheme) {
      case HeatmapColorSchemeType.performance:
        return getPerformanceColor(tile.performance);
      case HeatmapColorSchemeType.custom:
        return tile.customColor ?? Colors.grey.shade300;
      case HeatmapColorSchemeType.weightage:
        return getWeightageColor(tile.weightage);
      case HeatmapColorSchemeType.neutral:
        return Colors.grey.shade300;
    }
  }

  /// Gets color based on performance value
  Color getPerformanceColor(double changePercent) {
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

  /// Gets color based on weightage value
  Color getWeightageColor(double weightage) {
    final intensity = (weightage / 100).clamp(0.2, 1.0);
    return Color.lerp(Colors.blue.shade100, Colors.blue.shade600, intensity)!;
  }

  /// Determines text color based on background luminance
  Color getTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}
