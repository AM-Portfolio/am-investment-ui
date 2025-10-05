import 'package:flutter/material.dart';

import '../../../core/utils/logger.dart';
import '../../models/heatmap/heatmap_tile_data.dart';
import '../../models/heatmap/heatmap_ui_data.dart';
import '../selectors/heatmap_layout_selector.dart';
import 'layouts/layouts.dart';

/// Pure heatmap display template - coordinates layout builders for different display styles
/// Now uses modular layout builders for better maintainability and extensibility
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

  Widget _buildHeatmap(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      final height = constraints.maxHeight;

      final HeatmapLayoutBuilder layoutBuilder;

      switch (layout) {
        case HeatmapLayoutType.treemap:
          layoutBuilder = TreemapLayoutBuilder();
          break;
        case HeatmapLayoutType.grid:
          layoutBuilder = GridLayoutBuilder();
          break;
        case HeatmapLayoutType.list:
          layoutBuilder = ListLayoutBuilder();
          break;
      }

      return layoutBuilder.build(
        context,
        data,
        width,
        height,
        onTilePressed: onTilePressed,
        customTileBuilder: customTileBuilder,
      );
    },
  );

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
