import 'package:flutter/material.dart';

import '../../selectors/selectors.dart';
import '../configs/display_config.dart';
import '../configs/interaction_config.dart';
import '../configs/layout_config.dart' as layout_config;
import '../configs/selector_config.dart';
import '../configs/visual_config.dart';
import '../heatmap_config.dart';

/// Web-optimized heatmap default configurations
/// Provides sensible defaults for web/desktop with full features enabled
/// Use these default configs as the base for most web heatmap implementations
class WebHeatmapDefaults {
  /// Standard web configuration with full features enabled
  /// - All selectors available
  /// - Treemap layout for detailed visualization
  /// - Complete display information
  /// - Full interaction capabilities
  /// - Desktop-optimized spacing
  static HeatmapConfig standard({
    String? title,
    Color? accentColor,
    List<TimeFrame>? timeFrames,
    List<MetricType>? metrics,
    List<SectorType>? sectors,
    List<MarketCapType>? marketCaps,
  }) => HeatmapConfig(
    selectors: SelectorConfig(
      showTimeFrameSelector: true,
      showMetricSelector: true,
      showSectorSelector: true,
      showMarketCapSelector: true,
      availableTimeFrames: timeFrames ?? TimeFrame.webTimeFrames,
      availableMetrics: metrics ?? MetricType.webMetrics,
      availableSectors: sectors ?? SectorType.allSectors,
      availableMarketCaps: marketCaps ?? MarketCapType.allMarketCaps,
    ),
    display: const DisplayConfig(
      showSubCards: true, // Rich information display
      showPerformance: true,
      showWeightage: true,
      showValue: true,
      showLegend: true, // Helpful for understanding
      showHeader: true,
      showRefreshButton: true,
    ),
    layout: layout_config.LayoutConfig(
      layoutType: layout_config.HeatmapLayoutType.treemap, // Best for web
      compactView: false, // Spacious for desktop
      showTitle: true,
      customTitle: title,
    ),
    interactions: const InteractionConfig(
      enableTileInteraction: true,
      enableSelectorInteraction: true,
      showLoadingStates: true,
      showErrorStates: true,
      enableHoverEffects: true, // Great for web
      enableMultiSelect: true, // Useful for comparison
      enableDragAndDrop: false, // Optional advanced feature
    ),
    visual: VisualConfig(
      selectorPadding: const EdgeInsets.all(16),
      cardPadding: const EdgeInsets.all(16),
      selectorSpacing: 16,
      accentColor: accentColor,
      borderRadius: 12,
      elevation: 4,
      animationDuration: const Duration(milliseconds: 300),
      tileSpacing: 4,
    ),
  );

  /// Analytics web configuration for detailed analysis
  /// - All selectors enabled
  /// - Comprehensive display
  /// - Advanced interactions
  /// - Optimized for data analysis
  static HeatmapConfig analytics({
    String? title,
    Color? accentColor,
  }) => HeatmapConfig(
    selectors: const SelectorConfig(
      showTimeFrameSelector: true,
      showMetricSelector: true,
      showSectorSelector: true,
      showMarketCapSelector: true,
    ),
    display: const DisplayConfig(
      showSubCards: true,
      showPerformance: true,
      showWeightage: true,
      showValue: true,
      showLegend: true,
      showHeader: true,
      showRefreshButton: true,
    ),
    layout: layout_config.LayoutConfig(
      layoutType: layout_config.HeatmapLayoutType.treemap,
      compactView: false,
      showTitle: true,
      customTitle: title ?? 'Analytics Dashboard',
    ),
    interactions: const InteractionConfig(
      enableTileInteraction: true,
      enableSelectorInteraction: true,
      showLoadingStates: true,
      showErrorStates: true,
      enableHoverEffects: true,
      enableMultiSelect: true,
      enableDragAndDrop: true, // Advanced feature for analysis
    ),
    visual: VisualConfig(
      selectorPadding: const EdgeInsets.all(20),
      cardPadding: const EdgeInsets.all(20),
      selectorSpacing: 20,
      accentColor: accentColor ?? Colors.indigo,
      borderRadius: 12,
      elevation: 6,
      animationDuration: const Duration(milliseconds: 350),
      tileSpacing: 6,
    ),
  );

  /// Dashboard web configuration for overview displays
  /// - Essential selectors only
  /// - Clear, readable display
  /// - Interactive but not overwhelming
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
    display: const DisplayConfig(
      showSubCards: false, // Clean dashboard look
      showPerformance: true,
      showWeightage: true,
      showValue: false,
      showLegend: false,
      showHeader: true,
      showRefreshButton: false,
    ),
    layout: layout_config.LayoutConfig(
      layoutType: layout_config.HeatmapLayoutType.treemap,
      compactView: false,
      showTitle: true,
      customTitle: title,
    ),
    interactions: InteractionConfig(
      enableTileInteraction: interactive,
      enableSelectorInteraction: interactive,
      showLoadingStates: true,
      showErrorStates: true,
      enableHoverEffects: interactive,
      enableMultiSelect: false,
      enableDragAndDrop: false,
    ),
    visual: VisualConfig(
      selectorPadding: const EdgeInsets.all(16),
      cardPadding: const EdgeInsets.all(16),
      selectorSpacing: 16,
      accentColor: accentColor,
      borderRadius: 10,
      elevation: 3,
      animationDuration: const Duration(milliseconds: 250),
      tileSpacing: 3,
    ),
  );

  /// Portfolio-specific web configuration
  /// - Portfolio-relevant selectors
  /// - Complete performance display
  /// - Enhanced interactions for portfolio management
  static HeatmapConfig portfolio({
    String? title,
    Color? accentColor,
  }) => HeatmapConfig(
    selectors: const SelectorConfig(
      showTimeFrameSelector: true,
      showMetricSelector: true,
      showSectorSelector: true, // Important for portfolio analysis
      showMarketCapSelector: false, // Less relevant for personal portfolios
    ),
    display: const DisplayConfig(
      showSubCards: true,
      showPerformance: true,
      showWeightage: true, // Critical for portfolio allocation
      showValue: true, // Important for portfolio value
      showLegend: true,
      showHeader: true,
      showRefreshButton: true,
    ),
    layout: layout_config.LayoutConfig(
      layoutType: layout_config.HeatmapLayoutType.treemap,
      compactView: false,
      showTitle: true,
      customTitle: title ?? 'Portfolio Overview',
    ),
    interactions: const InteractionConfig(
      enableTileInteraction: true,
      enableSelectorInteraction: true,
      showLoadingStates: true,
      showErrorStates: true,
      enableHoverEffects: true,
      enableMultiSelect: true, // Useful for comparing holdings
      enableDragAndDrop: false,
    ),
    visual: VisualConfig(
      selectorPadding: const EdgeInsets.all(18),
      cardPadding: const EdgeInsets.all(18),
      selectorSpacing: 18,
      accentColor: accentColor ?? Colors.blue,
      borderRadius: 12,
      elevation: 4,
      animationDuration: const Duration(milliseconds: 300),
      tileSpacing: 4,
    ),
  );

  /// Minimal web configuration for embeds and widgets
  /// - Limited selectors
  /// - Essential display only
  /// - Basic interactions
  static HeatmapConfig minimal({
    String? title,
    Color? accentColor,
    bool showSelectors = false,
  }) => HeatmapConfig(
    selectors: SelectorConfig(
      showTimeFrameSelector: showSelectors,
      showMetricSelector: showSelectors,
      showSectorSelector: false,
      showMarketCapSelector: false,
    ),
    display: DisplayConfig(
      showSubCards: false,
      showPerformance: true,
      showWeightage: showSelectors, // Only if selectors are shown
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
      enableTileInteraction: showSelectors,
      enableSelectorInteraction: showSelectors,
      showLoadingStates: false,
      showErrorStates: false,
      enableHoverEffects: showSelectors,
      enableMultiSelect: false,
      enableDragAndDrop: false,
    ),
    visual: VisualConfig(
      selectorPadding: const EdgeInsets.all(12),
      cardPadding: const EdgeInsets.all(12),
      selectorSpacing: 12,
      accentColor: accentColor,
      borderRadius: 8,
      elevation: 2,
      animationDuration: const Duration(milliseconds: 200),
      tileSpacing: 2,
    ),
  );

  /// Trading-focused web configuration
  /// - All market selectors enabled
  /// - Real-time focused display
  /// - Advanced interactions for trading
  static HeatmapConfig trading({
    String? title,
    Color? accentColor,
  }) => HeatmapConfig(
    selectors: const SelectorConfig(
      showTimeFrameSelector: true,
      showMetricSelector: true,
      showSectorSelector: true,
      showMarketCapSelector: true, // Important for trading analysis
    ),
    display: const DisplayConfig(
      showSubCards: true,
      showPerformance: true,
      showWeightage: false, // Less relevant for trading
      showValue: true, // Important for trade sizing
      showLegend: true,
      showHeader: true,
      showRefreshButton: true, // Important for real-time data
    ),
    layout: layout_config.LayoutConfig(
      layoutType: layout_config.HeatmapLayoutType.treemap,
      compactView: false,
      showTitle: true,
      customTitle: title ?? 'Market Heatmap',
    ),
    interactions: const InteractionConfig(
      enableTileInteraction: true,
      enableSelectorInteraction: true,
      showLoadingStates: true,
      showErrorStates: true,
      enableHoverEffects: true,
      enableMultiSelect: true, // Useful for watchlists
      enableDragAndDrop: true, // Advanced feature for organizing
    ),
    visual: VisualConfig(
      selectorPadding: const EdgeInsets.all(16),
      cardPadding: const EdgeInsets.all(16),
      selectorSpacing: 16,
      accentColor: accentColor ?? Colors.green,
      borderRadius: 10,
      elevation: 4,
      animationDuration: const Duration(milliseconds: 250),
      tileSpacing: 3,
    ),
  );

  /// List all available web default configurations
  static Map<String, HeatmapConfig Function({String? title, Color? accentColor})> get defaults => {
    'standard': ({String? title, Color? accentColor}) => standard(title: title, accentColor: accentColor),
    'analytics': ({String? title, Color? accentColor}) => analytics(title: title, accentColor: accentColor),
    'dashboard': ({String? title, Color? accentColor}) => dashboard(title: title, accentColor: accentColor),
    'portfolio': ({String? title, Color? accentColor}) => portfolio(title: title, accentColor: accentColor),
    'minimal': ({String? title, Color? accentColor}) => minimal(title: title, accentColor: accentColor),
    'trading': ({String? title, Color? accentColor}) => trading(title: title, accentColor: accentColor),
  };
}