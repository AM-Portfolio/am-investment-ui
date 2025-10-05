import 'package:flutter/material.dart';

import '../../../../core/utils/logger.dart';
import '../../../models/heatmap/heatmap_tile_data.dart';
import '../../selectors/heatmap_layout_selector.dart';
import '../configs/display_config.dart';
import '../core/heatmap_display_core.dart';
import '../layouts/layouts.dart';

/// Web-optimized heatmap display with desktop-friendly layouts and interactions
/// Provides better mouse interaction, hover effects, and utilizes available screen space
class HeatmapDisplayWeb extends StatefulWidget {
  const HeatmapDisplayWeb({
    required this.core,
    super.key,
    this.customTileBuilder,
    this.config,
    this.showLoadingIndicator = true,
    this.showErrorDetails = true,
    this.enableHoverEffects = true,
    this.enableKeyboardNavigation = true,
    this.minTileSize = 50.0,
    this.maxTileSize = 200.0,
    this.padding = const EdgeInsets.all(16.0),
    this.spacing = 8.0,
  });

  final HeatmapDisplayCore core;
  final Widget Function(HeatmapTileData tile)? customTileBuilder;
  final DisplayConfig? config;
  final bool showLoadingIndicator;
  final bool showErrorDetails;
  final bool enableHoverEffects;
  final bool enableKeyboardNavigation;
  final double minTileSize;
  final double maxTileSize;
  final EdgeInsets padding;
  final double spacing;

  @override
  State<HeatmapDisplayWeb> createState() => _HeatmapDisplayWebState();
}

class _HeatmapDisplayWebState extends State<HeatmapDisplayWeb> {
  DisplayConfig get _config => widget.config ?? DisplayConfig.web();

  @override
  void initState() {
    super.initState();
    widget.core.addListener(_onCoreChanged);

    AppLogger.debug(
      'HeatmapDisplayWeb: initialized with web-optimized settings',
      tag: 'Heatmap.Display.Web',
    );
  }

  @override
  void dispose() {
    widget.core.removeListener(_onCoreChanged);
    super.dispose();
  }

  void _onCoreChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) =>
      Container(padding: widget.padding, child: _buildContent(context));

  Widget _buildContent(BuildContext context) {
    if (widget.core.isLoading) {
      return _buildLoadingState(context);
    }

    if (widget.core.hasError) {
      return _buildErrorState(context);
    }

    if (widget.core.isEmpty) {
      return _buildEmptyState(context);
    }

    return _buildHeatmap(context);
  }

  Widget _buildLoadingState(BuildContext context) {
    if (!widget.showLoadingIndicator) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading heatmap...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (_config.showSubCards) ...[
            const SizedBox(height: 8),
            Text(
              'Fetching ${widget.core.tileCount} tiles',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) => Center(
    child: Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load heatmap data',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            if (widget.showErrorDetails && widget.core.error != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.core.error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => widget.core.refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildEmptyState(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.dashboard_outlined,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          size: 64,
        ),
        const SizedBox(height: 16),
        Text(
          'No data available',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Try adjusting your filters or check back later',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  Widget _buildHeatmap(BuildContext context) {
    // Build scrollable content for web with many items
    final scrollableContent = _buildScrollableHeatmapContent(context);

    // Add header if configured
    if (_config.showHeader) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          Expanded(child: scrollableContent),
        ],
      );
    }

    return scrollableContent;
  }

  Widget _buildScrollableHeatmapContent(BuildContext context) {
    final tileCount = widget.core.tileCount;

    // For large datasets, provide scrollable content
    return Scrollbar(
      thumbVisibility: tileCount > 20, // Show scrollbar for large datasets
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            // Calculate dynamic height based on content and layout type
            final calculatedHeight = _calculateContentHeight(width, tileCount);

            final HeatmapLayoutBuilder layoutBuilder;

            switch (widget.core.layout) {
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

            var heatmapWidget = layoutBuilder.build(
              context,
              widget.core.data,
              width,
              calculatedHeight,
              onTilePressed: widget.core.handleTilePressed,
              customTileBuilder: widget.customTileBuilder,
              selectedSector: widget.core.selectedSector,
            );

            // Add web-specific enhancements
            if (widget.enableHoverEffects) {
              heatmapWidget = _addHoverEffects(heatmapWidget);
            }

            if (widget.enableKeyboardNavigation) {
              heatmapWidget = _addKeyboardNavigation(heatmapWidget);
            }

            return heatmapWidget;
          },
        ),
      ),
    );
  }

  /// Calculate appropriate content height based on layout type and item count
  double _calculateContentHeight(double width, int tileCount) {
    if (tileCount == 0) return 400.0; // Default height for empty state

    switch (widget.core.layout) {
      case HeatmapLayoutType.list:
        // List layout: calculate height based on item count
        // Each list item needs minimum height + spacing
        final itemHeight = widget.minTileSize + widget.spacing;
        return (tileCount * itemHeight) + (widget.spacing * 2);

      case HeatmapLayoutType.grid:
        // Grid layout: calculate height based on columns and rows
        final availableWidth = width - (widget.padding.horizontal);
        final itemWidth = widget.minTileSize + widget.spacing;
        final columnsCount = (availableWidth / itemWidth).floor().clamp(
          2,
          6,
        ); // More columns on web
        final rowsCount = (tileCount / columnsCount).ceil();
        final itemHeight = widget.minTileSize + widget.spacing;
        return (rowsCount * itemHeight) + (widget.spacing * 2);

      case HeatmapLayoutType.treemap:
        // Treemap layout: provide flexible height that can expand
        // Base height + additional height per item (less aggressive than mobile)
        const baseHeight = 600.0; // Larger base height for web
        final additionalHeight = tileCount * 15.0; // 15px per additional item
        return baseHeight + additionalHeight;
    }
  }

  Widget _buildHeader(BuildContext context) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Investment Heatmap',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (_config.showSubCards) ...[
              const SizedBox(height: 4),
              Text(
                '${widget.core.tileCount} items • ${widget.core.layout.name} view',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
      if (_config.showRefreshButton) ...[
        IconButton(
          onPressed: widget.core.isLoading
              ? null
              : () {
                  widget.core.refresh();
                  AppLogger.debug(
                    'HeatmapDisplayWeb: refresh button pressed',
                    tag: 'Heatmap.Display.Web',
                  );
                },
          icon: AnimatedRotation(
            turns: widget.core.isLoading ? 1 : 0,
            duration: const Duration(milliseconds: 600),
            child: const Icon(Icons.refresh),
          ),
          tooltip: 'Refresh data',
        ),
      ],
    ],
  );

  Widget _addHoverEffects(Widget child) =>
      MouseRegion(cursor: SystemMouseCursors.click, child: child);

  Widget _addKeyboardNavigation(Widget child) => Focus(
    child: Builder(
      builder: (context) => GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(),
        child: KeyboardListener(
          focusNode: FocusNode(),
          onKeyEvent: _handleKeyEvent,
          child: child,
        ),
      ),
    ),
  );

  void _handleKeyEvent(KeyEvent event) {
    // Add keyboard navigation logic here
    // For example: arrow keys to navigate tiles, Enter to select, etc.
    AppLogger.debug(
      'HeatmapDisplayWeb: keyboard event - ${event.runtimeType}',
      tag: 'Heatmap.Display.Web',
    );
  }
}
