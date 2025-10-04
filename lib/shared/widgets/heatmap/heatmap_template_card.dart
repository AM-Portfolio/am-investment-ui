import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/app_logic/domain/entities/heatmap/heatmap_entities.dart';
import '../../models/heatmap/heatmap_tile_data.dart';
import '../../models/heatmap/heatmap_ui_data.dart';
import 'heatmap_logger.dart';
import 'heatmap_selector_card.dart';

/// A reusable heatmap template card widget that displays data in a treemap or grid layout
/// with configurable sub-card visibility for responsive design
class HeatmapTemplateCard extends StatelessWidget {
  const HeatmapTemplateCard({
    required this.data,
    super.key,
    this.isLoading = false,
    this.error,
    this.icon,
    this.onTilePressed,
    this.customTileBuilder,
    this.selectorConfig,
    this.selectorCallbacks,
    this.showSelectors = false,
  });
  final HeatmapData data;
  final bool isLoading;
  final String? error;
  final IconData? icon;
  final VoidCallback? onTilePressed;
  final Widget Function(HeatmapTileData tile)? customTileBuilder;

  /// Optional selector configuration
  final HeatmapSelectorConfig? selectorConfig;

  /// Optional selector callbacks
  final HeatmapSelectorCallbacks? selectorCallbacks;

  /// Whether to show selectors above the heatmap
  final bool showSelectors;

  @override
  Widget build(BuildContext context) {
    // Log rendering performance
    HeatmapLogger.logRendering(
      component: 'HeatmapTemplateCard',
      phase: 'build',
      itemCount: data.tiles.length,
    );

    return Column(
      children: [
        // Optional selector card
        if (showSelectors &&
            selectorConfig != null &&
            selectorCallbacks != null)
          HeatmapSelectorCard(
            config: selectorConfig!,
            callbacks: selectorCallbacks!,
            compact: true,
            margin: const EdgeInsets.only(bottom: 8),
          ),

        // Main heatmap card
        Expanded(
          child: Card(
            elevation: 4,
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 16),
                  Expanded(child: _buildContent(context)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) => Row(
    children: [
      if (icon != null) ...[
        Icon(icon, color: Theme.of(context).primaryColor, size: 24),
        const SizedBox(width: 8),
      ],
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (data.subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                data.subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    ],
  );

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return _buildErrorState(context);
    }

    if (!data.hasData) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        if (data.configuration.showPerformance) ...[
          _buildColorLegend(context),
          const SizedBox(height: 16),
        ],
        Expanded(child: _buildHeatmap(context)),
      ],
    );
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

  Widget _buildColorLegend(BuildContext context) {
    if (data.configuration.colorScheme != HeatmapColorSchemeType.performance) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Text('Performance: ', style: Theme.of(context).textTheme.bodySmall),
        Expanded(
          child: Row(
            children: [
              _buildLegendItem(context, 'Loss', Colors.red.shade300),
              const SizedBox(width: 8),
              _buildLegendItem(context, 'Neutral', Colors.grey.shade300),
              const SizedBox(width: 8),
              _buildLegendItem(context, 'Gain', Colors.green.shade300),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) =>
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      );

  Widget _buildHeatmap(BuildContext context) {
    switch (data.configuration.layout) {
      case HeatmapLayoutType.treemap:
        return _buildTreemapLayout(context);
      case HeatmapLayoutType.grid:
        return _buildGridLayout(context);
      case HeatmapLayoutType.list:
        return _buildListLayout(context);
    }
  }

  Widget _buildTreemapLayout(BuildContext context) {
    // Sort tiles by weightage for better visualization
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

      // Calculate tile dimensions based on weightage
      var tileWidth = _calculateTileWidth(tile.weightage, width);
      var tileHeight = _calculateTileHeight(tile.weightage, height);

      // Check if we need to move to next row
      if (currentX + tileWidth > width && currentX > 0) {
        currentX = 0;
        currentY += rowHeight;
        rowHeight = 0;
      }

      // Ensure we don't exceed bounds
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
    // Base width calculation - larger weightage gets more width
    final baseWidth = (weightage / 100) * containerWidth;

    // Apply configuration constraints
    final minWidth = data.configuration.minTileWidth ?? containerWidth * 0.15;
    final maxWidth = data.configuration.maxTileWidth ?? containerWidth * 0.45;

    return baseWidth.clamp(minWidth, maxWidth);
  }

  double _calculateTileHeight(double weightage, double containerHeight) {
    // Base height calculation
    final baseHeight = (weightage / 100) * containerHeight;

    // Apply configuration constraints
    final minHeight =
        data.configuration.minTileHeight ?? containerHeight * 0.15;
    final maxHeight = data.configuration.maxTileHeight ?? containerHeight * 0.4;

    return baseHeight.clamp(minHeight, maxHeight);
  }

  Widget _buildHeatmapTile(
    BuildContext context,
    HeatmapTileData tile,
    double? width,
    double? height,
  ) {
    // Use custom tile builder if provided
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
        // Log tile interaction
        HeatmapLogger.logTileInteraction(
          action: 'tile_tapped',
          tileId: tile.id,
          tileData: {
            'name': tile.name,
            'value': tile.value,
            'performance': tile.performance,
            'weightage': tile.weightage,
          },
          component: 'HeatmapTemplateCard',
        );

        onTilePressed?.call();
      },
      child: Container(
        margin: config.tileMargin ?? const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: 0.5,
          ),
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
        // Tile name - always shown if height allows
        if (effectiveHeight > 25)
          Flexible(
            child: Text(
              tile.displayName,
              style: TextStyle(
                fontSize: _calculateFontSize(effectiveWidth, showSubCards),
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
              maxLines: effectiveHeight > 60 ? 2 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

        // Weightage - shown based on configuration and space
        if (config.showWeightage && effectiveHeight > 40)
          Padding(
            padding: EdgeInsets.only(top: effectiveHeight > 60 ? 2 : 0),
            child: Text(
              tile.formattedWeightage,
              style: TextStyle(
                fontSize: _calculateFontSize(
                  effectiveWidth,
                  showSubCards,
                  isSecondary: true,
                ),
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),

        // Performance - shown based on configuration and space
        if (config.showPerformance && showSubCards && effectiveHeight > 60)
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Text(
              tile.formattedPerformance,
              style: TextStyle(
                fontSize: _calculateFontSize(
                  effectiveWidth,
                  showSubCards,
                  isSmall: true,
                ),
                fontWeight: FontWeight.w500,
                color: textColor.withValues(alpha: 0.9),
              ),
            ),
          ),

        // Value - shown based on configuration and space
        if (config.showValue &&
            showSubCards &&
            effectiveHeight > 80 &&
            tile.value != null)
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Text(
              tile.formattedValue,
              style: TextStyle(
                fontSize: _calculateFontSize(
                  effectiveWidth,
                  showSubCards,
                  isSmall: true,
                ),
                fontWeight: FontWeight.w400,
                color: textColor.withValues(alpha: 0.8),
              ),
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

  /// Get UI tiles from data, converting if necessary
  List<HeatmapTileData> _getUiTiles() => data.tiles.map((tile) {
    if (tile is HeatmapTileData) {
      return tile;
    } else {
      // Convert entity to UI data
      return HeatmapTileData.fromEntity(tile);
    }
  }).toList();
}
