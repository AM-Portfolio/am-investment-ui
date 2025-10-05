import 'package:flutter/material.dart';

import '../../../../core/utils/logger.dart';
import '../../../models/heatmap/heatmap_tile_data.dart';
import '../../selectors/heatmap_layout_selector.dart';
import '../configs/display_config.dart';
import '../core/heatmap_display_core.dart';
import '../layouts/layouts.dart';

/// Mobile-optimized heatmap display with touch-friendly interactions
/// Provides better touch targets, simplified layouts, and mobile-specific gestures
class HeatmapDisplayMobile extends StatefulWidget {
  const HeatmapDisplayMobile({
    required this.core,
    super.key,
    this.customTileBuilder,
    this.config,
    this.showLoadingIndicator = true,
    this.showErrorDetails = false,
    this.enableSwipeGestures = true,
    this.enablePullToRefresh = true,
    this.minTileSize = 80.0,
    this.maxTileSize = 150.0,
    this.padding = const EdgeInsets.all(12.0),
    this.spacing = 6.0,
    this.compactMode = false,
  });

  final HeatmapDisplayCore core;
  final Widget Function(HeatmapTileData tile)? customTileBuilder;
  final DisplayConfig? config;
  final bool showLoadingIndicator;
  final bool showErrorDetails;
  final bool enableSwipeGestures;
  final bool enablePullToRefresh;
  final double minTileSize;
  final double maxTileSize;
  final EdgeInsets padding;
  final double spacing;
  final bool compactMode;

  @override
  State<HeatmapDisplayMobile> createState() => _HeatmapDisplayMobileState();
}

class _HeatmapDisplayMobileState extends State<HeatmapDisplayMobile>
    with TickerProviderStateMixin {
  late AnimationController _refreshController;
  late Animation<double> _refreshAnimation;
  bool _isDisposed = false;

  DisplayConfig get _config => widget.config ?? DisplayConfig.mobile();

  @override
  void initState() {
    super.initState();
    widget.core.addListener(_onCoreChanged);

    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _refreshAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _refreshController, curve: Curves.easeInOut),
    );

    AppLogger.debug(
      'HeatmapDisplayMobile: initialized with mobile-optimized settings',
      tag: 'Heatmap.Display.Mobile',
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    widget.core.removeListener(_onCoreChanged);
    _refreshController.dispose();
    super.dispose();
  }

  void _onCoreChanged() {
    AppLogger.debug(
      'HeatmapDisplayMobile: core state changed - isLoading=${widget.core.isLoading}, hasError=${widget.core.hasError}, isEmpty=${widget.core.isEmpty}, tileCount=${widget.core.tileCount}',
      tag: 'Heatmap.Display.Mobile.StateChange',
    );

    if (widget.core.hasError) {
      AppLogger.warning(
        'HeatmapDisplayMobile: core has error - ${widget.core.error}',
        tag: 'Heatmap.Display.Mobile.StateChange',
      );
    }

    if (widget.core.isEmpty) {
      AppLogger.info(
        'HeatmapDisplayMobile: core data is empty - no tiles to display',
        tag: 'Heatmap.Display.Mobile.StateChange',
      );
    }

    if (mounted) {
      setState(() {});
    } else {
      AppLogger.warning(
        'HeatmapDisplayMobile: core changed but widget not mounted',
        tag: 'Heatmap.Display.Mobile.StateChange',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.debug(
      'HeatmapDisplayMobile: building widget - isLoading=${widget.core.isLoading}, hasError=${widget.core.hasError}, isEmpty=${widget.core.isEmpty}, tileCount=${widget.core.tileCount}',
      tag: 'Heatmap.Display.Mobile.Build',
    );

    Widget content = Container(
      padding: widget.padding,
      child: _buildContent(context),
    );

    // Add pull-to-refresh if enabled and not in error/empty state
    if (widget.enablePullToRefresh &&
        !widget.core.isLoading &&
        !widget.core.hasError &&
        !widget.core.isEmpty) {
      content = RefreshIndicator(
        onRefresh: _handleRefresh,
        // Ensure refresh indicator works with scrollable content
        displacement: 60.0,
        strokeWidth: 2.0,
        child: content,
      );
    }

    return content;
  }

  Future<void> _handleRefresh() async {
    AppLogger.info(
      'HeatmapDisplayMobile: refresh initiated by user action',
      tag: 'Heatmap.Display.Mobile.Refresh',
    );

    try {
      // Start refresh animation - check if still mounted
      if (mounted && !_isDisposed) {
        _refreshController.forward();
        AppLogger.debug(
          'HeatmapDisplayMobile: refresh animation started',
          tag: 'Heatmap.Display.Mobile.Refresh',
        );
      } else {
        AppLogger.warning(
          'HeatmapDisplayMobile: cannot start animation - mounted=$mounted, disposed=$_isDisposed',
          tag: 'Heatmap.Display.Mobile.Refresh',
        );
      }

      // Log current core state before refresh
      AppLogger.debug(
        'HeatmapDisplayMobile: pre-refresh state - isLoading=${widget.core.isLoading}, hasError=${widget.core.hasError}, isEmpty=${widget.core.isEmpty}, tileCount=${widget.core.tileCount}',
        tag: 'Heatmap.Display.Mobile.Refresh',
      );

      // Trigger actual data refresh through the core
      AppLogger.info(
        'HeatmapDisplayMobile: triggering core refresh',
        tag: 'Heatmap.Display.Mobile.Refresh',
      );
      widget.core.refresh();

      AppLogger.debug(
        'HeatmapDisplayMobile: pull-to-refresh triggered',
        tag: 'Heatmap.Display.Mobile',
      );

      // Wait for the refresh to complete (simulated delay for UX)
      await Future.delayed(const Duration(milliseconds: 500));

      // Log post-refresh state
      AppLogger.debug(
        'HeatmapDisplayMobile: post-refresh state - isLoading=${widget.core.isLoading}, hasError=${widget.core.hasError}, isEmpty=${widget.core.isEmpty}, tileCount=${widget.core.tileCount}',
        tag: 'Heatmap.Display.Mobile.Refresh',
      );
    } catch (error) {
      AppLogger.error(
        'HeatmapDisplayMobile: refresh failed - $error',
        tag: 'Heatmap.Display.Mobile.Refresh',
        error: error,
      );
    } finally {
      // Reset animation - only if controller is still valid and widget is mounted
      if (mounted && !_isDisposed) {
        _refreshController.reset();
        AppLogger.debug(
          'HeatmapDisplayMobile: refresh animation reset',
          tag: 'Heatmap.Display.Mobile.Refresh',
        );
      } else {
        AppLogger.warning(
          'HeatmapDisplayMobile: cannot reset animation - mounted=$mounted, disposed=$_isDisposed',
          tag: 'Heatmap.Display.Mobile.Refresh',
        );
      }

      AppLogger.info(
        'HeatmapDisplayMobile: refresh flow completed',
        tag: 'Heatmap.Display.Mobile.Refresh',
      );
    }
  }

  Widget _buildContent(BuildContext context) {
    if (widget.core.isLoading) {
      AppLogger.debug(
        'HeatmapDisplayMobile: rendering loading state',
        tag: 'Heatmap.Display.Mobile.UI',
      );
      return _buildLoadingState(context);
    }

    if (widget.core.hasError) {
      AppLogger.warning(
        'HeatmapDisplayMobile: rendering error state - ${widget.core.error}',
        tag: 'Heatmap.Display.Mobile.UI',
      );
      return _buildErrorState(context);
    }

    if (widget.core.isEmpty) {
      AppLogger.info(
        'HeatmapDisplayMobile: rendering empty state - no data available',
        tag: 'Heatmap.Display.Mobile.UI',
      );
      return _buildEmptyState(context);
    }

    AppLogger.debug(
      'HeatmapDisplayMobile: rendering heatmap with ${widget.core.tileCount} tiles',
      tag: 'Heatmap.Display.Mobile.UI',
    );
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
            width: 32,
            height: 32,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(height: 12),
          Text(
            'Loading...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            'Failed to load data',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.showErrorDetails && widget.core.error != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.core.error!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => widget.core.refresh(),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildEmptyState(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dashboard_outlined,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'No data available',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pull down to refresh',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );

  Widget _buildHeatmap(BuildContext context) {
    // Build scrollable content for mobile with many items
    final scrollableContent = _buildScrollableHeatmapContent(context);

    // Add header for non-compact mode
    if (!widget.compactMode && _config.showHeader) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMobileHeader(context),
          const SizedBox(height: 12),
          Expanded(child: scrollableContent),
        ],
      );
    }

    return scrollableContent;
  }

  Widget _buildScrollableHeatmapContent(BuildContext context) {
    final tileCount = widget.core.tileCount;

    // For mobile, always make content scrollable to handle large datasets
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          // Calculate dynamic height based on content and layout type
          final calculatedHeight = _calculateContentHeight(width, tileCount);

          final HeatmapLayoutBuilder layoutBuilder;

          // Mobile-specific layout preferences
          switch (widget.core.layout) {
            case HeatmapLayoutType.treemap:
              // On mobile, treemap might be less effective, but still supported
              layoutBuilder = TreemapLayoutBuilder();
              break;
            case HeatmapLayoutType.grid:
              // Grid layout works well on mobile - allow vertical scrolling
              layoutBuilder = GridLayoutBuilder();
              break;
            case HeatmapLayoutType.list:
              // List layout is excellent for mobile - natural vertical scrolling
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

          // Add mobile-specific enhancements
          if (widget.enableSwipeGestures) {
            heatmapWidget = _addSwipeGestures(heatmapWidget);
          }

          return heatmapWidget;
        },
      ),
    );
  }

  /// Calculate appropriate content height based on layout type and item count
  double _calculateContentHeight(double width, int tileCount) {
    if (tileCount == 0) return 300.0; // Default height for empty state

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
        final columnsCount = (availableWidth / itemWidth).floor().clamp(1, 4);
        final rowsCount = (tileCount / columnsCount).ceil();
        final itemHeight = widget.minTileSize + widget.spacing;
        return (rowsCount * itemHeight) + (widget.spacing * 2);

      case HeatmapLayoutType.treemap:
        // Treemap layout: provide flexible height that can expand
        // Base height + additional height per item
        const baseHeight = 400.0;
        final additionalHeight = tileCount * 20.0; // 20px per additional item
        return baseHeight + additionalHeight;
    }
  }

  Widget _buildMobileHeader(BuildContext context) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Heatmap', style: Theme.of(context).textTheme.titleMedium),
            if (_config.showSubCards) ...[
              const SizedBox(height: 2),
              Text(
                '${widget.core.tileCount} items',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
      if (_config.showRefreshButton) ...[
        AnimatedBuilder(
          animation: _refreshAnimation,
          builder: (context, child) => Transform.rotate(
            angle: _refreshAnimation.value * 2 * 3.14159,
            child: IconButton(
              onPressed: () => widget.core.refresh(),
              icon: const Icon(Icons.refresh),
              iconSize: 20,
              tooltip: 'Refresh',
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ),
        ),
      ],
    ],
  );

  Widget _addSwipeGestures(Widget child) =>
      GestureDetector(onHorizontalDragEnd: _handleSwipe, child: child);

  void _handleSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;

    if (velocity.abs() > 500) {
      // Fast swipe detected
      if (velocity > 0) {
        // Swipe right - maybe previous layout
        _cycleToPreviousLayout();
      } else {
        // Swipe left - maybe next layout
        _cycleToNextLayout();
      }
    }

    AppLogger.debug(
      'HeatmapDisplayMobile: swipe gesture detected, velocity: $velocity',
      tag: 'Heatmap.Display.Mobile',
    );
  }

  void _cycleToPreviousLayout() {
    const layouts = HeatmapLayoutType.values;
    final currentIndex = layouts.indexOf(widget.core.layout);
    final previousIndex = (currentIndex - 1 + layouts.length) % layouts.length;
    widget.core.setLayout(layouts[previousIndex]);
  }

  void _cycleToNextLayout() {
    const layouts = HeatmapLayoutType.values;
    final currentIndex = layouts.indexOf(widget.core.layout);
    final nextIndex = (currentIndex + 1) % layouts.length;
    widget.core.setLayout(layouts[nextIndex]);
  }
}
