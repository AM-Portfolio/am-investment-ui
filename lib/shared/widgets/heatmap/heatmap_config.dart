import 'package:flutter/material.dart';

import '../selectors/selectors.dart';
import 'configs/display_config.dart';
import 'configs/interaction_config.dart';
import 'configs/layout_config.dart' as layout_config;
import 'configs/selector_config.dart';
import 'configs/visual_config.dart';
import 'templates/mobile_heatmap_defaults.dart';
import 'templates/web_heatmap_defaults.dart';

/// Main heatmap configuration that composes smaller, focused config objects
/// This provides a clean API while breaking down complexity into manageable pieces
class HeatmapConfig {
  const HeatmapConfig({
    this.selectors,
    this.display,
    this.layout,
    this.interactions,
    this.visual,
  });

  /// Create from mobile defaults configuration
  factory HeatmapConfig.fromMobile(HeatmapConfig mobileConfig) => mobileConfig;

  /// Create from web defaults configuration
  factory HeatmapConfig.fromWeb(HeatmapConfig webConfig) => webConfig;

  /// Create a mobile-optimized heatmap configuration using MobileHeatmapDefaults
  factory HeatmapConfig.mobile({
    String? title,
    List<TimeFrame>? timeFrames,
    List<MetricType>? metrics,
    Color? accentColor,
  }) => MobileHeatmapDefaults.standard(
    title: title,
    timeFrames: timeFrames,
    metrics: metrics,
    accentColor: accentColor,
  );

  /// Create a web-optimized heatmap configuration using WebHeatmapDefaults
  factory HeatmapConfig.web({
    String? title,
    List<TimeFrame>? timeFrames,
    List<MetricType>? metrics,
    List<SectorType>? sectors,
    List<MarketCapType>? marketCaps,
    Color? accentColor,
  }) => WebHeatmapDefaults.standard(
    title: title,
    timeFrames: timeFrames,
    metrics: metrics,
    sectors: sectors,
    marketCaps: marketCaps,
    accentColor: accentColor,
  );

  /// Create a minimal heatmap configuration using WebHeatmapDefaults
  factory HeatmapConfig.minimal({
    String? title,
    bool showSelectors = false,
    Color? accentColor,
  }) => WebHeatmapDefaults.minimal(
    title: title,
    showSelectors: showSelectors,
    accentColor: accentColor,
  );

  /// Create a dashboard widget configuration using WebHeatmapDefaults
  factory HeatmapConfig.dashboard({
    String? title,
    bool interactive = true,
    Color? accentColor,
  }) => WebHeatmapDefaults.dashboard(
    title: title,
    interactive: interactive,
    accentColor: accentColor,
  );

  /// Create portfolio-specific configuration using WebHeatmapDefaults
  factory HeatmapConfig.portfolio({String? title, Color? accentColor}) =>
      WebHeatmapDefaults.portfolio(title: title, accentColor: accentColor);

  /// Create analytics configuration using WebHeatmapDefaults
  factory HeatmapConfig.analytics({String? title, Color? accentColor}) =>
      WebHeatmapDefaults.analytics(title: title, accentColor: accentColor);

  /// Create trading configuration using WebHeatmapDefaults
  factory HeatmapConfig.trading({String? title, Color? accentColor}) =>
      WebHeatmapDefaults.trading(title: title, accentColor: accentColor);

  /// Create from any mobile default configuration
  factory HeatmapConfig.mobileDefaults(
    String type, {
    String? title,
    Color? accentColor,
  }) {
    switch (type.toLowerCase()) {
      case 'standard':
        return MobileHeatmapDefaults.standard(
          title: title,
          accentColor: accentColor,
        );
      case 'minimal':
        return MobileHeatmapDefaults.minimal(
          title: title,
          accentColor: accentColor,
        );
      case 'dashboard':
        return MobileHeatmapDefaults.dashboard(
          title: title,
          accentColor: accentColor,
        );
      case 'portfolio':
        return MobileHeatmapDefaults.portfolio(
          title: title,
          accentColor: accentColor,
        );
      default:
        return MobileHeatmapDefaults.standard(
          title: title,
          accentColor: accentColor,
        );
    }
  }

  /// Create from any web default configuration
  factory HeatmapConfig.webDefaults(
    String type, {
    String? title,
    Color? accentColor,
  }) {
    switch (type.toLowerCase()) {
      case 'standard':
        return WebHeatmapDefaults.standard(
          title: title,
          accentColor: accentColor,
        );
      case 'analytics':
        return WebHeatmapDefaults.analytics(
          title: title,
          accentColor: accentColor,
        );
      case 'dashboard':
        return WebHeatmapDefaults.dashboard(
          title: title,
          accentColor: accentColor,
        );
      case 'portfolio':
        return WebHeatmapDefaults.portfolio(
          title: title,
          accentColor: accentColor,
        );
      case 'minimal':
        return WebHeatmapDefaults.minimal(
          title: title,
          accentColor: accentColor,
        );
      case 'trading':
        return WebHeatmapDefaults.trading(
          title: title,
          accentColor: accentColor,
        );
      default:
        return WebHeatmapDefaults.standard(
          title: title,
          accentColor: accentColor,
        );
    }
  }

  /// Selector configuration (what selectors to show and their options) - nullable
  final SelectorConfig? selectors;

  /// Display configuration (what information to show on tiles) - nullable
  final DisplayConfig? display;

  /// Layout configuration (how to arrange the heatmap) - nullable
  final layout_config.LayoutConfig? layout;

  /// Interaction configuration (how users can interact) - nullable
  final InteractionConfig? interactions;

  /// Visual configuration (styling, spacing, colors) - nullable
  final VisualConfig? visual;

  /// Get effective selector configuration with fallbacks
  SelectorConfig get effectiveSelectors => selectors ?? const SelectorConfig();

  /// Get effective display configuration with fallbacks
  DisplayConfig get effectiveDisplay => display ?? const DisplayConfig();

  /// Get effective layout configuration with fallbacks
  layout_config.LayoutConfig get effectiveLayout =>
      layout ?? const layout_config.LayoutConfig();

  /// Get effective interaction configuration with fallbacks
  InteractionConfig get effectiveInteractions =>
      interactions ?? const InteractionConfig();

  /// Get effective visual configuration with fallbacks
  VisualConfig get effectiveVisual => visual ?? const VisualConfig();

  // Backward compatibility getters (delegate to sub-configs)
  bool get showTimeFrameSelector => effectiveSelectors.showTimeFrameSelector;
  bool get showMetricSelector => effectiveSelectors.showMetricSelector;
  bool get showSectorSelector => effectiveSelectors.showSectorSelector;
  bool get showMarketCapSelector => effectiveSelectors.showMarketCapSelector;

  List<TimeFrame>? get availableTimeFrames =>
      effectiveSelectors.availableTimeFrames;
  List<MetricType>? get availableMetrics => effectiveSelectors.availableMetrics;
  List<SectorType>? get availableSectors => effectiveSelectors.availableSectors;
  List<MarketCapType>? get availableMarketCaps =>
      effectiveSelectors.availableMarketCaps;

  bool get showSubCards => effectiveDisplay.showSubCards;
  bool get showPerformance => effectiveDisplay.showPerformance;
  bool get showWeightage => effectiveDisplay.showWeightage;
  bool get showValue => effectiveDisplay.showValue;
  bool get showLegend => effectiveDisplay.showLegend;
  bool get showHeader => effectiveDisplay.showHeader;
  bool get showRefreshButton => effectiveDisplay.showRefreshButton;

  HeatmapLayoutType get layoutType =>
      HeatmapLayoutType.values[effectiveLayout.layoutType.index];
  bool get compactView => effectiveLayout.compactView;
  bool get showTitle => effectiveLayout.showTitle;
  String? get customTitle => effectiveLayout.customTitle;

  bool get enableTileInteraction => effectiveInteractions.enableTileInteraction;
  bool get enableSelectorInteraction =>
      effectiveInteractions.enableSelectorInteraction;
  bool get showLoadingStates => effectiveInteractions.showLoadingStates;
  bool get showErrorStates => effectiveInteractions.showErrorStates;
  bool get enableHoverEffects => effectiveInteractions.enableHoverEffects;
  bool get enableMultiSelect => effectiveInteractions.enableMultiSelect;
  bool get enableDragAndDrop => effectiveInteractions.enableDragAndDrop;

  EdgeInsets? get selectorPadding => effectiveVisual.selectorPadding;
  EdgeInsets? get cardPadding => effectiveVisual.cardPadding;
  double? get selectorSpacing => effectiveVisual.selectorSpacing;
  Color? get accentColor => effectiveVisual.accentColor;
  double? get borderRadius => effectiveVisual.borderRadius;
  double? get elevation => effectiveVisual.elevation;
  Duration? get animationDuration => effectiveVisual.animationDuration;
  double? get tileSpacing => effectiveVisual.tileSpacing;

  /// Copy this configuration with some sub-configs overridden
  HeatmapConfig copyWith({
    SelectorConfig? selectors,
    DisplayConfig? display,
    layout_config.LayoutConfig? layout,
    InteractionConfig? interactions,
    VisualConfig? visual,
  }) => HeatmapConfig(
    selectors: selectors ?? this.selectors,
    display: display ?? this.display,
    layout: layout ?? this.layout,
    interactions: interactions ?? this.interactions,
    visual: visual ?? this.visual,
  );

  /// Merge with mobile defaults as base
  HeatmapConfig mergeWithMobileDefaults(
    String type, {
    String? title,
    Color? accentColor,
  }) {
    final mobileBase = HeatmapConfig.mobileDefaults(
      type,
      title: title,
      accentColor: accentColor,
    );
    return HeatmapConfig(
      selectors: selectors ?? mobileBase.selectors,
      display: display ?? mobileBase.display,
      layout: layout ?? mobileBase.layout,
      interactions: interactions ?? mobileBase.interactions,
      visual: visual ?? mobileBase.visual,
    );
  }

  /// Merge with web defaults as base
  HeatmapConfig mergeWithWebDefaults(
    String type, {
    String? title,
    Color? accentColor,
  }) {
    final webBase = HeatmapConfig.webDefaults(
      type,
      title: title,
      accentColor: accentColor,
    );
    return HeatmapConfig(
      selectors: selectors ?? webBase.selectors,
      display: display ?? webBase.display,
      layout: layout ?? webBase.layout,
      interactions: interactions ?? webBase.interactions,
      visual: visual ?? webBase.visual,
    );
  }

  /// Create configuration with modified selectors
  HeatmapConfig withSelectors({
    bool timeFrame = true,
    bool metric = true,
    bool sector = false,
    bool marketCap = false,
  }) => copyWith(
    selectors: effectiveSelectors.copyWith(
      showTimeFrameSelector: timeFrame,
      showMetricSelector: metric,
      showSectorSelector: sector,
      showMarketCapSelector: marketCap,
    ),
  );

  /// Create configuration with specific display features
  HeatmapConfig withDisplay({
    bool? subCards,
    bool? performance,
    bool? weightage,
    bool? value,
    bool? legend,
    bool? header,
  }) => copyWith(
    display: effectiveDisplay.copyWith(
      showSubCards: subCards,
      showPerformance: performance,
      showWeightage: weightage,
      showValue: value,
      showLegend: legend,
      showHeader: header,
    ),
  );

  /// Create configuration with specific layout settings
  HeatmapConfig withLayout({
    HeatmapLayoutType? type,
    bool? compact,
    String? title,
  }) => copyWith(
    layout: effectiveLayout.copyWith(
      layoutType: type != null
          ? layout_config.HeatmapLayoutType.values[type.index]
          : null,
      compactView: compact,
      customTitle: title,
      showTitle: title != null,
    ),
  );

  /// Create configuration with specific interaction settings
  HeatmapConfig withInteractions({
    bool? tileInteraction,
    bool? selectorInteraction,
    bool? loadingStates,
    bool? errorStates,
    bool? hoverEffects,
    bool? multiSelect,
    bool? dragAndDrop,
  }) => copyWith(
    interactions: effectiveInteractions.copyWith(
      enableTileInteraction: tileInteraction,
      enableSelectorInteraction: selectorInteraction,
      showLoadingStates: loadingStates,
      showErrorStates: errorStates,
      enableHoverEffects: hoverEffects,
      enableMultiSelect: multiSelect,
      enableDragAndDrop: dragAndDrop,
    ),
  );

  /// Create configuration with specific visual settings
  HeatmapConfig withVisual({
    EdgeInsets? selectorPadding,
    EdgeInsets? cardPadding,
    double? selectorSpacing,
    Color? accentColor,
    double? borderRadius,
    double? elevation,
    Duration? animationDuration,
    double? tileSpacing,
  }) => copyWith(
    visual: effectiveVisual.copyWith(
      selectorPadding: selectorPadding,
      cardPadding: cardPadding,
      selectorSpacing: selectorSpacing,
      accentColor: accentColor,
      borderRadius: borderRadius,
      elevation: elevation,
      animationDuration: animationDuration,
      tileSpacing: tileSpacing,
    ),
  );

  /// Check if any selectors should be shown
  bool get hasSelectors =>
      showTimeFrameSelector ||
      showMetricSelector ||
      showSectorSelector ||
      showMarketCapSelector;

  /// Check if this is a minimal configuration
  bool get isMinimal => !showSubCards && !showLegend && compactView;

  /// Check if this is a mobile configuration
  bool get isMobile =>
      compactView && !showSectorSelector && !showMarketCapSelector;

  /// Check if this is a web configuration
  bool get isWeb => !compactView && showSectorSelector && showMarketCapSelector;
}

/// Enum for heatmap layout types (kept for backward compatibility)
enum HeatmapLayoutType { treemap, grid, list }
