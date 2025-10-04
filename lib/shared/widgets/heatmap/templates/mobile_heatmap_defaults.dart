import 'package:flutter/material.dart';

import '../../selectors/selectors.dart';
import '../configs/display_config.dart';
import '../configs/interaction_config.dart';
import '../configs/layout_config.dart' as layout_config;
import '../configs/selector_config.dart';
import '../configs/visual_config.dart';
import '../heatmap_config.dart';

/// Mobile-optimized heatmap default configurations
/// Provides sensible defaults for mobile devices with commonly needed features enabled
/// Use these default configs as the base for most mobile heatmap implementations
class MobileHeatmapDefaults {
  /// Standard mobile configuration with essential features enabled
  /// - Time frame and metric selectors enabled
  /// - Compact grid layout
  /// - Performance and weightage display
  /// - Touch-friendly interactions
  /// - Mobile-optimized spacing
  static HeatmapConfig standard({
    String? title,
    Color? accentColor,
    List<TimeFrame>? timeFrames,
    List<MetricType>? metrics,
  }) => HeatmapConfig(
    selectors: SelectorConfig(
      showTimeFrameSelector: true,
      showMetricSelector: true,
      showSectorSelector: false, // Too crowded on mobile
      showMarketCapSelector: false, // Too crowded on mobile
      availableTimeFrames: timeFrames ?? TimeFrame.mobileTimeFrames,
      availableMetrics: metrics ?? MetricType.mobileMetrics,
    ),
    display: DisplayConfig(
      showSubCards: false, // Simplified for mobile
      showPerformance: true, // Essential metric
      showWeightage: true, // Essential metric
      showValue: false, // Secondary info, hidden to save space
      showLegend: false, // Takes up too much space
      showHeader: title != null,
      showRefreshButton: false, // Can use pull-to-refresh instead
    ),
    layout: layout_config.LayoutConfig(
      layoutType: layout_config.HeatmapLayoutType.grid, // Better for touch
      compactView: true, // Essential for mobile
      showTitle: title != null,
      customTitle: title,
    ),
    interactions: InteractionConfig(
      enableTileInteraction: true,
      enableSelectorInteraction: true,
      showLoadingStates: true,
      showErrorStates: true,
      enableHoverEffects: false, // No hover on mobile
      enableMultiSelect: false, // Complex for mobile UI
      enableDragAndDrop: false, // Complex for mobile UI
    ),
    visual: VisualConfig(
      selectorPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      cardPadding: const EdgeInsets.all(12),
      selectorSpacing: 8,
      accentColor: accentColor,
      borderRadius: 8,
      elevation: 2,
      animationDuration: const Duration(milliseconds: 200),
      tileSpacing: 2,
    ),
  );

  /// Minimal mobile configuration for widgets and previews
  /// - No selectors
  /// - Minimal display info
  /// - Compact layout
  /// - No interactions
  static HeatmapConfig minimal({
    String? title,
    Color? accentColor,
  }) => HeatmapConfig(
    selectors: const SelectorConfig(
      showTimeFrameSelector: false,
      showMetricSelector: false,
      showSectorSelector: false,
      showMarketCapSelector: false,
    ),
    display: DisplayConfig(
      showSubCards: false,
      showPerformance: true, // Only essential metric
      showWeightage: false,
      showValue: false,
      showLegend: false,
      showHeader: title != null,
      showRefreshButton: false,
    ),
    layout: layout_config.LayoutConfig(
      layoutType: layout_config.HeatmapLayoutType.grid,
      compactView: true,
      showTitle: title != null,
      customTitle: title,
    ),
    interactions: const InteractionConfig(
      enableTileInteraction: false,
      enableSelectorInteraction: false,
      showLoadingStates: false,
      showErrorStates: false,
      enableHoverEffects: false,
      enableMultiSelect: false,
      enableDragAndDrop: false,
    ),
    visual: VisualConfig(
      selectorPadding: const EdgeInsets.all(8),
      cardPadding: const EdgeInsets.all(8),
      selectorSpacing: 4,
      accentColor: accentColor,
      borderRadius: 6,
      elevation: 1,
      animationDuration: const Duration(milliseconds: 150),
      tileSpacing: 1,
    ),
  );

  /// Dashboard mobile configuration for dashboard widgets
  /// - Time frame selector only
  /// - Essential display features
  /// - Compact but readable
  static HeatmapConfig dashboard({
    String? title,
    Color? accentColor,
    bool interactive = true,
  }) => HeatmapConfig(
    selectors: SelectorConfig(
      showTimeFrameSelector: true,
      showMetricSelector: false, // Simplified for dashboard
      showSectorSelector: false,
      showMarketCapSelector: false,
      availableTimeFrames: TimeFrame.dashboardTimeFrames,
    ),
    display: DisplayConfig(
      showSubCards: false,
      showPerformance: true,
      showWeightage: true,
      showValue: false,
      showLegend: false,
      showHeader: title != null,
      showRefreshButton: false,
    ),
    layout: layout_config.LayoutConfig(
      layoutType: layout_config.HeatmapLayoutType.grid,
      compactView: true,
      showTitle: title != null,
      customTitle: title,
    ),
    interactions: InteractionConfig(
      enableTileInteraction: interactive,
      enableSelectorInteraction: interactive,
      showLoadingStates: true,
      showErrorStates: true,
      enableHoverEffects: false,
      enableMultiSelect: false,
      enableDragAndDrop: false,
    ),
    visual: VisualConfig(
      selectorPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      cardPadding: const EdgeInsets.all(10),
      selectorSpacing: 6,
      accentColor: accentColor,
      borderRadius: 6,
      elevation: 1,
      animationDuration: const Duration(milliseconds: 200),
      tileSpacing: 2,
    ),
  );

  /// Portfolio-specific mobile configuration
  /// - Portfolio-relevant selectors enabled
  /// - Full performance display
  /// - Optimized for portfolio viewing
  static HeatmapConfig portfolio({
    String? title,
    Color? accentColor,
  }) => HeatmapConfig(
    selectors: const SelectorConfig(
      showTimeFrameSelector: true,
      showMetricSelector: true,
      showSectorSelector: true, // Useful for portfolio analysis
      showMarketCapSelector: false, // Less relevant for personal portfolios
    ),
    display: const DisplayConfig(
      showSubCards: false,
      showPerformance: true,
      showWeightage: true, // Important for portfolio allocation
      showValue: true, // Important for portfolio value
      showLegend: false,
      showHeader: true,
      showRefreshButton: false,
    ),
    layout: layout_config.LayoutConfig(
      layoutType: layout_config.HeatmapLayoutType.treemap, // Better for portfolio visualization
      compactView: true,
      showTitle: true,
      customTitle: title ?? 'Portfolio',
    ),
    interactions: const InteractionConfig(
      enableTileInteraction: true,
      enableSelectorInteraction: true,
      showLoadingStates: true,
      showErrorStates: true,
      enableHoverEffects: false,
      enableMultiSelect: false,
      enableDragAndDrop: false,
    ),
    visual: VisualConfig(
      selectorPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      cardPadding: const EdgeInsets.all(12),
      selectorSpacing: 8,
      accentColor: accentColor ?? Colors.blue,
      borderRadius: 8,
      elevation: 2,
      animationDuration: const Duration(milliseconds: 250),
      tileSpacing: 2,
    ),
  );

  /// List all available mobile default configurations
  static Map<String, HeatmapConfig Function({String? title, Color? accentColor})> get defaults => {
    'standard': ({String? title, Color? accentColor}) => standard(title: title, accentColor: accentColor),
    'minimal': ({String? title, Color? accentColor}) => minimal(title: title, accentColor: accentColor),
    'dashboard': ({String? title, Color? accentColor}) => dashboard(title: title, accentColor: accentColor),
    'portfolio': ({String? title, Color? accentColor}) => portfolio(title: title, accentColor: accentColor),
  };
}