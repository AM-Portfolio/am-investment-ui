import 'package:flutter/material.dart';

import '../../../core/utils/logger.dart';
import '../../models/heatmap/heatmap_tile_data.dart';
import '../../models/heatmap/heatmap_ui_data.dart';
import '../selectors/heatmap_layout_selector.dart';
import '../selectors/sector_selector.dart';
import 'configs/display_config.dart';
import 'core/heatmap_display_core.dart';
import 'mobile/heatmap_display_mobile.dart';
import 'web/heatmap_display_web.dart';

/// A template widget that provides adaptive heatmap display functionality.
///
/// This widget acts as a smart wrapper that chooses between [HeatmapDisplayWeb]
/// and [HeatmapDisplayMobile] based on screen size and configuration.
///
/// Key Features:
/// - Automatically adapts between web and mobile implementations
/// - Configurable breakpoints for responsive behavior
/// - Smart layout selection based on screen size
/// - Proper delegation to existing web/mobile components
/// - Centralized state management through HeatmapDisplayCore
///
/// Usage:
/// ```dart
/// HeatmapDisplayTemplate(
///   core: myHeatmapCore,
///   enableAdaptiveLayout: true,
///   mobileBreakpoint: 768,
/// )
/// ```
class HeatmapDisplayTemplate extends StatefulWidget {
  const HeatmapDisplayTemplate({
    super.key,
    // New clean interface
    this.core,
    this.config,
    this.enableAdaptiveLayout = true,
    this.mobileBreakpoint = 768.0,
    this.tabletBreakpoint = 1024.0,
    this.forceLayout,
    this.onLayoutChanged,
    // Legacy interface for backwards compatibility
    this.data,
    this.isLoading = false,
    this.error,
    this.onTilePressed,
    this.customTileBuilder,
    this.layout = HeatmapLayoutType.treemap,
    this.selectedSector,
    this.onRefreshRequested,
  });

  /// The core heatmap display state manager (new interface)
  final HeatmapDisplayCore? core;

  /// Optional configuration - if null, auto-generates based on platform
  final DisplayConfig? config;

  /// Enable adaptive layout switching based on screen size
  final bool enableAdaptiveLayout;

  /// Breakpoint below which mobile layout is used (in logical pixels)
  final double mobileBreakpoint;

  /// Breakpoint above which desktop layout is used (in logical pixels)
  final double tabletBreakpoint;

  /// Force a specific layout type (overrides adaptive behavior)
  final HeatmapLayoutType? forceLayout;

  /// Callback when layout changes due to responsive behavior
  final ValueChanged<HeatmapLayoutType>? onLayoutChanged;

  // Legacy interface parameters
  final HeatmapData? data;
  final bool isLoading;
  final String? error;
  final VoidCallback? onTilePressed;
  final Widget Function(HeatmapTileData tile)? customTileBuilder;
  final HeatmapLayoutType layout;
  final SectorType? selectedSector;
  final VoidCallback? onRefreshRequested;

  @override
  State<HeatmapDisplayTemplate> createState() => _HeatmapDisplayTemplateState();
}

class _HeatmapDisplayTemplateState extends State<HeatmapDisplayTemplate> {
  late HeatmapDisplayCore _effectiveCore;

  @override
  void initState() {
    super.initState();

    // Create core if not provided (legacy interface)
    if (widget.core != null) {
      _effectiveCore = widget.core!;
    } else {
      _effectiveCore = HeatmapDisplayCore(
        initialData: widget.data,
        initialIsLoading: widget.isLoading,
        initialError: widget.error,
        initialLayout: widget.layout,
        initialSelectedSector: widget.selectedSector,
        onTilePressed: widget.onTilePressed,
        onRefreshRequested: widget.onRefreshRequested,
      );
    }

    AppLogger.debug(
      'HeatmapDisplayTemplate: initialized with adaptive layout=${widget.enableAdaptiveLayout}',
      tag: 'Heatmap.Display.Template',
    );
  }

  @override
  void didUpdateWidget(HeatmapDisplayTemplate oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update core with new legacy parameters if core is internally managed
    if (widget.core == null) {
      if (widget.data != oldWidget.data) {
        if (widget.data != null) {
          _effectiveCore.updateData(widget.data!);
        }
      }
      if (widget.isLoading != oldWidget.isLoading) {
        _effectiveCore.setLoading(widget.isLoading);
      }
      if (widget.error != oldWidget.error) {
        _effectiveCore.setError(widget.error);
      }
      if (widget.layout != oldWidget.layout) {
        _effectiveCore.setLayout(widget.layout);
      }
      if (widget.selectedSector != oldWidget.selectedSector) {
        _effectiveCore.setSelectedSector(widget.selectedSector);
      }
    }
  }

  @override
  void dispose() {
    if (widget.core == null) {
      _effectiveCore.dispose();
    }
    super.dispose();
  }

  /// Determine the appropriate platform based on screen size
  _PlatformType get _platformType {
    if (!widget.enableAdaptiveLayout) {
      // If adaptive layout is disabled, use web as default
      return _PlatformType.web;
    }

    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < widget.mobileBreakpoint) {
      return _PlatformType.mobile;
    } else {
      return _PlatformType.web;
    }
  }

  /// Get the appropriate configuration based on platform
  DisplayConfig get _effectiveConfig {
    if (widget.config != null) {
      return widget.config!;
    }

    // Auto-generate config based on platform
    switch (_platformType) {
      case _PlatformType.mobile:
        return DisplayConfig.mobile();
      case _PlatformType.web:
        return DisplayConfig.web();
    }
  }

  /// Get the effective layout type considering forced layout and adaptive behavior
  HeatmapLayoutType get _effectiveLayout {
    if (widget.forceLayout != null) {
      return widget.forceLayout!;
    }

    return _effectiveCore.layout;
  }

  @override
  Widget build(BuildContext context) {
    final config = _effectiveConfig;

    final layout = _effectiveLayout;

    // Notify layout changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onLayoutChanged?.call(layout);
    });

    switch (_platformType) {
      case _PlatformType.mobile:
        return _buildMobileDisplay(config);
      case _PlatformType.web:
        return _buildWebDisplay(config);
    }
  }

  Widget _buildMobileDisplay(DisplayConfig config) => HeatmapDisplayMobile(
    core: _effectiveCore,
    config: config,
    customTileBuilder: widget.customTileBuilder,
    compactMode: MediaQuery.of(context).size.width < widget.mobileBreakpoint,
  );

  Widget _buildWebDisplay(DisplayConfig config) => HeatmapDisplayWeb(
    core: _effectiveCore,
    config: config,
    customTileBuilder: widget.customTileBuilder,
  );
}

/// Internal enum to represent platform types
enum _PlatformType { mobile, web }

/// Extension methods for easy template usage
extension HeatmapDisplayTemplateExtensions on HeatmapDisplayTemplate {
  /// Create a mobile-optimized template
  static HeatmapDisplayTemplate mobile({
    required HeatmapDisplayCore core,
    DisplayConfig? config,
    Widget Function(HeatmapTileData tile)? customTileBuilder,
  }) => HeatmapDisplayTemplate(
    core: core,
    config: config ?? DisplayConfig.mobile(),
    customTileBuilder: customTileBuilder,
    enableAdaptiveLayout: false,
    forceLayout: HeatmapLayoutType.list, // Lists work best on mobile
  );

  /// Create a web-optimized template
  static HeatmapDisplayTemplate web({
    required HeatmapDisplayCore core,
    DisplayConfig? config,
    Widget Function(HeatmapTileData tile)? customTileBuilder,
    HeatmapLayoutType layout = HeatmapLayoutType.treemap,
  }) => HeatmapDisplayTemplate(
    core: core,
    config: config ?? DisplayConfig.web(),
    customTileBuilder: customTileBuilder,
    enableAdaptiveLayout: false,
    forceLayout: layout,
  );

  /// Create a fully adaptive template that switches based on screen size
  static HeatmapDisplayTemplate adaptive({
    required HeatmapDisplayCore core,
    DisplayConfig? config,
    Widget Function(HeatmapTileData tile)? customTileBuilder,
    double mobileBreakpoint = 768.0,
    double tabletBreakpoint = 1024.0,
    ValueChanged<HeatmapLayoutType>? onLayoutChanged,
  }) => HeatmapDisplayTemplate(
    core: core,
    config: config,
    customTileBuilder: customTileBuilder,
    mobileBreakpoint: mobileBreakpoint,
    tabletBreakpoint: tabletBreakpoint,
    onLayoutChanged: onLayoutChanged,
  );
}
