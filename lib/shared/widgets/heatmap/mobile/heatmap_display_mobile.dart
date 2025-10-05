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
    widget.core.removeListener(_onCoreChanged);
    _refreshController.dispose();
    super.dispose();
  }

  void _onCoreChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      padding: widget.padding,
      child: _buildContent(context),
    );

    // Add pull-to-refresh if enabled
    if (widget.enablePullToRefresh && !widget.core.isLoading) {
      content = RefreshIndicator(onRefresh: _handleRefresh, child: content);
    }

    return content;
  }

  Future<void> _handleRefresh() async {
    _refreshController.forward();
    widget.core.refresh();

    // Wait for animation to complete
    await _refreshController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    _refreshController.reset();
  }

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

  Widget _buildHeatmap(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      final height = constraints.maxHeight;

      final HeatmapLayoutBuilder layoutBuilder;

      // Mobile-specific layout preferences
      switch (widget.core.layout) {
        case HeatmapLayoutType.treemap:
          // On mobile, treemap might be less effective, but still supported
          layoutBuilder = TreemapLayoutBuilder();
          break;
        case HeatmapLayoutType.grid:
          // Grid layout works well on mobile
          layoutBuilder = GridLayoutBuilder();
          break;
        case HeatmapLayoutType.list:
          // List layout is excellent for mobile
          layoutBuilder = ListLayoutBuilder();
          break;
      }

      var heatmapWidget = layoutBuilder.build(
        context,
        widget.core.data,
        width,
        height,
        onTilePressed: widget.core.handleTilePressed,
        customTileBuilder: widget.customTileBuilder,
        selectedSector: widget.core.selectedSector,
      );

      // Add mobile-specific enhancements
      if (widget.enableSwipeGestures) {
        heatmapWidget = _addSwipeGestures(heatmapWidget);
      }

      // Add header for non-compact mode
      if (!widget.compactMode && _config.showHeader) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMobileHeader(context),
            const SizedBox(height: 12),
            Expanded(child: heatmapWidget),
          ],
        );
      }

      return heatmapWidget;
    },
  );

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
