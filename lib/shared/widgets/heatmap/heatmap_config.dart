import 'package:flutter/material.dart';
import '../selectors/selectors.dart';

/// Configuration class that defines what heatmap features are visible
/// Allows customization for different platforms (mobile/web) and use cases
class HeatmapConfig {
  // Selector visibility
  final bool showTimeFrameSelector;
  final bool showMetricSelector;
  final bool showSectorSelector;
  final bool showMarketCapSelector;
  
  // Selector customization
  final List<TimeFrame>? availableTimeFrames;
  final List<MetricType>? availableMetrics;
  final List<SectorType>? availableSectors;
  final List<MarketCapType>? availableMarketCaps;
  
  // Card display options
  final bool showSubCards;
  final bool showPerformance;
  final bool showWeightage;
  final bool showValue;
  final bool showLegend;
  final bool showHeader;
  final bool showRefreshButton;
  
  // Layout options
  final HeatmapLayoutType layoutType;
  final bool compactView;
  final bool showTitle;
  final String? customTitle;
  
  // Interaction options
  final bool enableTileInteraction;
  final bool enableSelectorInteraction;
  final bool showLoadingStates;
  final bool showErrorStates;
  
  // Visual customization
  final EdgeInsets? selectorPadding;
  final EdgeInsets? cardPadding;
  final double? selectorSpacing;
  final Color? accentColor;

  const HeatmapConfig({
    // Selector visibility defaults
    this.showTimeFrameSelector = true,
    this.showMetricSelector = true,
    this.showSectorSelector = true,
    this.showMarketCapSelector = true,
    
    // Available options (null means show all)
    this.availableTimeFrames,
    this.availableMetrics,
    this.availableSectors,
    this.availableMarketCaps,
    
    // Card display defaults
    this.showSubCards = true,
    this.showPerformance = true,
    this.showWeightage = true,
    this.showValue = true,
    this.showLegend = true,
    this.showHeader = true,
    this.showRefreshButton = true,
    
    // Layout defaults
    this.layoutType = HeatmapLayoutType.treemap,
    this.compactView = false,
    this.showTitle = true,
    this.customTitle,
    
    // Interaction defaults
    this.enableTileInteraction = true,
    this.enableSelectorInteraction = true,
    this.showLoadingStates = true,
    this.showErrorStates = true,
    
    // Visual defaults
    this.selectorPadding,
    this.cardPadding,
    this.selectorSpacing,
    this.accentColor,
  });

  /// Create a mobile-optimized heatmap configuration
  factory HeatmapConfig.mobile({
    String? title,
    List<TimeFrame>? timeFrames,
    List<MetricType>? metrics,
  }) {
    return HeatmapConfig(
      // Limited selectors for mobile
      showTimeFrameSelector: true,
      showMetricSelector: true,
      showSectorSelector: false, // Hidden on mobile for space
      showMarketCapSelector: false, // Hidden on mobile for space
      
      // Simplified available options
      availableTimeFrames: timeFrames ?? TimeFrame.mobileTimeFrames,
      availableMetrics: metrics ?? MetricType.mobileMetrics,
      
      // Mobile-friendly card settings
      showSubCards: false, // Simplified view
      showPerformance: true,
      showWeightage: true,
      showValue: false, // Hidden for space
      showLegend: false, // Hidden for space
      showHeader: true,
      showRefreshButton: false, // Usually in app bar
      
      // Mobile layout
      layoutType: HeatmapLayoutType.grid,
      compactView: true,
      showTitle: title != null,
      customTitle: title,
      
      // Mobile interactions
      enableTileInteraction: true,
      enableSelectorInteraction: true,
      
      // Mobile spacing
      selectorPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      cardPadding: const EdgeInsets.all(12),
      selectorSpacing: 8,
    );
  }

  /// Create a web-optimized heatmap configuration
  factory HeatmapConfig.web({
    String? title,
    List<TimeFrame>? timeFrames,
    List<MetricType>? metrics,
    List<SectorType>? sectors,
    List<MarketCapType>? marketCaps,
  }) {
    return HeatmapConfig(
      // All selectors available on web
      showTimeFrameSelector: true,
      showMetricSelector: true,
      showSectorSelector: true,
      showMarketCapSelector: true,
      
      // Full available options
      availableTimeFrames: timeFrames ?? TimeFrame.webTimeFrames,
      availableMetrics: metrics ?? MetricType.webMetrics,
      availableSectors: sectors ?? SectorType.allSectors,
      availableMarketCaps: marketCaps ?? MarketCapType.allMarketCaps,
      
      // Full-featured card settings
      showSubCards: true,
      showPerformance: true,
      showWeightage: true,
      showValue: true,
      showLegend: true,
      showHeader: true,
      showRefreshButton: true,
      
      // Web layout
      layoutType: HeatmapLayoutType.treemap,
      compactView: false,
      showTitle: title != null,
      customTitle: title,
      
      // Web interactions
      enableTileInteraction: true,
      enableSelectorInteraction: true,
      
      // Web spacing
      selectorPadding: const EdgeInsets.all(16),
      cardPadding: const EdgeInsets.all(16),
      selectorSpacing: 16,
    );
  }

  /// Create a minimal heatmap configuration (for widgets, previews, etc.)
  factory HeatmapConfig.minimal({
    String? title,
    bool showSelectors = false,
  }) {
    return HeatmapConfig(
      // No selectors in minimal view
      showTimeFrameSelector: showSelectors,
      showMetricSelector: showSelectors,
      showSectorSelector: false,
      showMarketCapSelector: false,
      
      // Minimal card settings
      showSubCards: false,
      showPerformance: true,
      showWeightage: false,
      showValue: false,
      showLegend: false,
      showHeader: title != null,
      showRefreshButton: false,
      
      // Minimal layout
      layoutType: HeatmapLayoutType.grid,
      compactView: true,
      showTitle: title != null,
      customTitle: title,
      
      // Minimal interactions
      enableTileInteraction: false,
      enableSelectorInteraction: showSelectors,
      showLoadingStates: false,
      showErrorStates: false,
      
      // Minimal spacing
      selectorPadding: const EdgeInsets.all(8),
      cardPadding: const EdgeInsets.all(8),
      selectorSpacing: 4,
    );
  }

  /// Create a dashboard widget configuration
  factory HeatmapConfig.dashboard({
    String? title,
    bool interactive = true,
  }) {
    return HeatmapConfig(
      // Limited selectors for dashboard
      showTimeFrameSelector: true,
      showMetricSelector: false,
      showSectorSelector: false,
      showMarketCapSelector: false,
      
      // Dashboard time frames
      availableTimeFrames: TimeFrame.dashboardTimeFrames,
      
      // Dashboard card settings
      showSubCards: true,
      showPerformance: true,
      showWeightage: true,
      showValue: false,
      showLegend: true,
      showHeader: true,
      showRefreshButton: false,
      
      // Dashboard layout
      layoutType: HeatmapLayoutType.treemap,
      compactView: false,
      showTitle: title != null,
      customTitle: title,
      
      // Dashboard interactions
      enableTileInteraction: interactive,
      enableSelectorInteraction: interactive,
      
      // Dashboard spacing
      selectorPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      cardPadding: const EdgeInsets.all(12),
      selectorSpacing: 12,
    );
  }

  /// Copy this configuration with some properties overridden
  HeatmapConfig copyWith({
    bool? showTimeFrameSelector,
    bool? showMetricSelector,
    bool? showSectorSelector,
    bool? showMarketCapSelector,
    List<TimeFrame>? availableTimeFrames,
    List<MetricType>? availableMetrics,
    List<SectorType>? availableSectors,
    List<MarketCapType>? availableMarketCaps,
    bool? showSubCards,
    bool? showPerformance,
    bool? showWeightage,
    bool? showValue,
    bool? showLegend,
    bool? showHeader,
    bool? showRefreshButton,
    HeatmapLayoutType? layoutType,
    bool? compactView,
    bool? showTitle,
    String? customTitle,
    bool? enableTileInteraction,
    bool? enableSelectorInteraction,
    bool? showLoadingStates,
    bool? showErrorStates,
    EdgeInsets? selectorPadding,
    EdgeInsets? cardPadding,
    double? selectorSpacing,
    Color? accentColor,
  }) {
    return HeatmapConfig(
      showTimeFrameSelector: showTimeFrameSelector ?? this.showTimeFrameSelector,
      showMetricSelector: showMetricSelector ?? this.showMetricSelector,
      showSectorSelector: showSectorSelector ?? this.showSectorSelector,
      showMarketCapSelector: showMarketCapSelector ?? this.showMarketCapSelector,
      availableTimeFrames: availableTimeFrames ?? this.availableTimeFrames,
      availableMetrics: availableMetrics ?? this.availableMetrics,
      availableSectors: availableSectors ?? this.availableSectors,
      availableMarketCaps: availableMarketCaps ?? this.availableMarketCaps,
      showSubCards: showSubCards ?? this.showSubCards,
      showPerformance: showPerformance ?? this.showPerformance,
      showWeightage: showWeightage ?? this.showWeightage,
      showValue: showValue ?? this.showValue,
      showLegend: showLegend ?? this.showLegend,
      showHeader: showHeader ?? this.showHeader,
      showRefreshButton: showRefreshButton ?? this.showRefreshButton,
      layoutType: layoutType ?? this.layoutType,
      compactView: compactView ?? this.compactView,
      showTitle: showTitle ?? this.showTitle,
      customTitle: customTitle ?? this.customTitle,
      enableTileInteraction: enableTileInteraction ?? this.enableTileInteraction,
      enableSelectorInteraction: enableSelectorInteraction ?? this.enableSelectorInteraction,
      showLoadingStates: showLoadingStates ?? this.showLoadingStates,
      showErrorStates: showErrorStates ?? this.showErrorStates,
      selectorPadding: selectorPadding ?? this.selectorPadding,
      cardPadding: cardPadding ?? this.cardPadding,
      selectorSpacing: selectorSpacing ?? this.selectorSpacing,
      accentColor: accentColor ?? this.accentColor,
    );
  }

  /// Check if any selectors should be shown
  bool get hasSelectors => showTimeFrameSelector || 
                          showMetricSelector || 
                          showSectorSelector || 
                          showMarketCapSelector;

  /// Check if this is a minimal configuration
  bool get isMinimal => !showSubCards && !showLegend && compactView;

  /// Check if this is a mobile configuration
  bool get isMobile => compactView && !showSectorSelector && !showMarketCapSelector;

  /// Check if this is a web configuration
  bool get isWeb => !compactView && showSectorSelector && showMarketCapSelector;
}

/// Enum for heatmap layout types
enum HeatmapLayoutType {
  treemap,
  grid,
  list,
}