import 'package:flutter/material.dart';

import '../../../core/utils/logger.dart';
import '../../models/heatmap/heatmap_ui_data.dart';
import 'mobile/heatmap_layout_mobile.dart';
import 'web/heatmap_layout_web.dart';

class HeatmapLayoutTemplate extends StatefulWidget {
  const HeatmapLayoutTemplate({
    // Core parameters
    required this.data,
    required this.displayWidget,
    super.key,
    this.selectorWidget,
    // Layout configuration
    this.title,
    this.subtitle,
    this.icon,
    this.showHeader = true,
    this.showLegend = true,
    this.showSelectors = true,
    this.headerActions,
    this.customHeader,
    this.padding,
    this.backgroundColor,
    // Adaptive behavior
    this.enableAdaptiveLayout = true,
    this.mobileBreakpoint = 768.0,
    this.tabletBreakpoint = 1024.0,
    this.forceLayoutType,
    this.onLayoutChanged,
  });

  // Core parameters
  final HeatmapData data;
  final Widget displayWidget;
  final Widget? selectorWidget;

  // Layout configuration
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final bool showHeader;
  final bool showLegend;
  final bool showSelectors;
  final List<Widget>? headerActions;
  final Widget? customHeader;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  // Adaptive behavior
  final bool enableAdaptiveLayout;
  final double mobileBreakpoint;
  final double tabletBreakpoint;
  final LayoutType? forceLayoutType;
  final ValueChanged<LayoutType>? onLayoutChanged;

  @override
  State<HeatmapLayoutTemplate> createState() => _HeatmapLayoutTemplateState();
}

class _HeatmapLayoutTemplateState extends State<HeatmapLayoutTemplate> {
  @override
  void initState() {
    super.initState();

    AppLogger.debug(
      'HeatmapLayoutTemplate: initialized with adaptive layout=${widget.enableAdaptiveLayout}',
      tag: 'Heatmap.Layout.Template',
    );
  }

  /// Determine the appropriate platform based on screen size
  LayoutType get _layoutType {
    if (!widget.enableAdaptiveLayout) {
      // If adaptive layout is disabled, use web as default
      return LayoutType.web;
    }

    if (widget.forceLayoutType != null) {
      return widget.forceLayoutType!;
    }

    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < widget.mobileBreakpoint) {
      return LayoutType.mobile;
    } else {
      return LayoutType.web;
    }
  }

  @override
  Widget build(BuildContext context) {
    final layoutType = _layoutType;

    // Notify layout changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onLayoutChanged?.call(layoutType);
    });

    switch (layoutType) {
      case LayoutType.mobile:
        return _buildMobileLayout(context);
      case LayoutType.web:
        return _buildWebLayout(context);
    }
  }

  Widget _buildMobileLayout(BuildContext context) => HeatmapLayoutMobile(
    data: widget.data,
    displayWidget: widget.displayWidget,
    selectorWidget: widget.selectorWidget,
    title: widget.title,
    subtitle: widget.subtitle,
    icon: widget.icon,
    showHeader: widget.showHeader,
    showLegend: widget.showLegend,
    showSelectors: widget.showSelectors,
    headerActions: widget.headerActions,
    customHeader: widget.customHeader,
    padding: widget.padding,
    backgroundColor: widget.backgroundColor,
  );

  Widget _buildWebLayout(BuildContext context) => HeatmapLayoutWeb(
    data: widget.data,
    displayWidget: widget.displayWidget,
    selectorWidget: widget.selectorWidget,
    title: widget.title,
    subtitle: widget.subtitle,
    icon: widget.icon,
    showHeader: widget.showHeader,
    showLegend: widget.showLegend,
    showSelectors: widget.showSelectors,
    headerActions: widget.headerActions,
    customHeader: widget.customHeader,
    padding: widget.padding,
    backgroundColor: widget.backgroundColor,
  );
}

/// Enum to represent layout types for heatmap templates
enum LayoutType { mobile, web }

/// Extension methods for easy template usage
extension HeatmapLayoutTemplateExtensions on HeatmapLayoutTemplate {
  /// Create a mobile-optimized layout template
  static HeatmapLayoutTemplate mobile({
    required HeatmapData data,
    required Widget displayWidget,
    Widget? selectorWidget,
    String? title,
    String? subtitle,
    IconData? icon,
    List<Widget>? headerActions,
  }) => HeatmapLayoutTemplate(
    data: data,
    displayWidget: displayWidget,
    selectorWidget: selectorWidget,
    title: title,
    subtitle: subtitle,
    icon: icon,
    headerActions: headerActions,
    enableAdaptiveLayout: false,
    forceLayoutType: LayoutType.mobile,
  );

  /// Create a web-optimized layout template
  static HeatmapLayoutTemplate web({
    required HeatmapData data,
    required Widget displayWidget,
    Widget? selectorWidget,
    String? title,
    String? subtitle,
    IconData? icon,
    List<Widget>? headerActions,
  }) => HeatmapLayoutTemplate(
    data: data,
    displayWidget: displayWidget,
    selectorWidget: selectorWidget,
    title: title,
    subtitle: subtitle,
    icon: icon,
    headerActions: headerActions,
    enableAdaptiveLayout: false,
    forceLayoutType: LayoutType.web,
  );

  /// Create a fully adaptive layout template that switches based on screen size
  static HeatmapLayoutTemplate adaptive({
    required HeatmapData data,
    required Widget displayWidget,
    Widget? selectorWidget,
    String? title,
    String? subtitle,
    IconData? icon,
    List<Widget>? headerActions,
    double mobileBreakpoint = 768.0,
    double tabletBreakpoint = 1024.0,
    ValueChanged<LayoutType>? onLayoutChanged,
  }) => HeatmapLayoutTemplate(
    data: data,
    displayWidget: displayWidget,
    selectorWidget: selectorWidget,
    title: title,
    subtitle: subtitle,
    icon: icon,
    headerActions: headerActions,
    mobileBreakpoint: mobileBreakpoint,
    tabletBreakpoint: tabletBreakpoint,
    onLayoutChanged: onLayoutChanged,
  );

  /// Create a minimal layout (no selectors, simple header)
  static HeatmapLayoutTemplate minimal({
    required HeatmapData data,
    required Widget displayWidget,
    String? title,
    IconData? icon,
  }) => HeatmapLayoutTemplate(
    data: data,
    displayWidget: displayWidget,
    title: title,
    icon: icon,
    showSelectors: false,
    showLegend: false,
  );

  /// Create a compact layout (minimal padding, compact design)
  static HeatmapLayoutTemplate compact({
    required HeatmapData data,
    required Widget displayWidget,
    Widget? selectorWidget,
    String? title,
    IconData? icon,
  }) => HeatmapLayoutTemplate(
    data: data,
    displayWidget: displayWidget,
    selectorWidget: selectorWidget,
    title: title,
    icon: icon,
    showSelectors: selectorWidget != null,
    padding: const EdgeInsets.all(4),
  );

  /// Create a full layout (all features enabled)
  static HeatmapLayoutTemplate full({
    required HeatmapData data,
    required Widget displayWidget,
    Widget? selectorWidget,
    String? title,
    String? subtitle,
    IconData? icon,
    List<Widget>? headerActions,
  }) => HeatmapLayoutTemplate(
    data: data,
    displayWidget: displayWidget,
    selectorWidget: selectorWidget,
    title: title,
    subtitle: subtitle,
    icon: icon,
    showSelectors: selectorWidget != null,
    headerActions: headerActions,
    padding: const EdgeInsets.all(8),
  );

  /// Create a dashboard layout (optimized for dashboard widgets)
  static HeatmapLayoutTemplate dashboard({
    required HeatmapData data,
    required Widget displayWidget,
    Widget? selectorWidget,
    String? title,
    IconData? icon,
  }) => HeatmapLayoutTemplate(
    data: data,
    displayWidget: displayWidget,
    selectorWidget: selectorWidget,
    title: title,
    icon: icon,
    showSelectors: selectorWidget != null,
    showLegend: false,
    padding: const EdgeInsets.all(6),
  );
}
