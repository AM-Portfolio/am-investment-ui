import '../../selectors/selectors.dart';

/// Different layout types for selector template
enum SelectorLayoutType {
  compact, // Horizontal compact layout with pills and dropdowns
  expanded, // Full card layout with all selectors
  pills, // Pill-based layout wrapped
  dropdown, // All dropdowns in a row
}

/// Configuration for heatmap selector visibility and available options
/// Handles which selectors to show and what options they should contain
class SelectorConfig {
  const SelectorConfig({
    // Which selectors to show
    this.showTimeFrameSelector = true,
    this.showMetricSelector = true,
    this.showSectorSelector = true,
    this.showMarketCapSelector = true,

    // Selector layout type
    this.selectorLayout = SelectorLayoutType.compact,

    // Available options (null means show all)
    this.availableTimeFrames,
    this.availableMetrics,
    this.availableSectors,
    this.availableMarketCaps,
  });

  /// Mobile-optimized selector configuration
  factory SelectorConfig.mobile({
    List<TimeFrame>? timeFrames,
    List<MetricType>? metrics,
    SelectorLayoutType? selectorLayout,
  }) => SelectorConfig(
    showSectorSelector: false,
    showMarketCapSelector: false,
    selectorLayout: selectorLayout ?? SelectorLayoutType.compact,
    availableTimeFrames: timeFrames ?? TimeFrame.mobileTimeFrames,
    availableMetrics: metrics ?? MetricType.mobileMetrics,
  );

  /// Web-optimized selector configuration
  factory SelectorConfig.web({
    List<TimeFrame>? timeFrames,
    List<MetricType>? metrics,
    List<SectorType>? sectors,
    List<MarketCapType>? marketCaps,
    SelectorLayoutType? selectorLayout,
  }) => SelectorConfig(
    selectorLayout: selectorLayout ?? SelectorLayoutType.expanded,
    availableTimeFrames: timeFrames ?? TimeFrame.webTimeFrames,
    availableMetrics: metrics ?? MetricType.webMetrics,
    availableSectors: sectors ?? SectorType.allSectors,
    availableMarketCaps: marketCaps ?? MarketCapType.allMarketCaps,
  );

  /// Minimal selector configuration (for widgets, previews)
  factory SelectorConfig.minimal({
    bool showSelectors = false,
    SelectorLayoutType? selectorLayout,
  }) => SelectorConfig(
    showTimeFrameSelector: showSelectors,
    showMetricSelector: showSelectors,
    showSectorSelector: false,
    showMarketCapSelector: false,
    selectorLayout: selectorLayout ?? SelectorLayoutType.pills,
  );

  /// Dashboard selector configuration
  factory SelectorConfig.dashboard({SelectorLayoutType? selectorLayout}) =>
      SelectorConfig(
        showMetricSelector: false,
        showSectorSelector: false,
        showMarketCapSelector: false,
        selectorLayout: selectorLayout ?? SelectorLayoutType.compact,
        availableTimeFrames: TimeFrame.dashboardTimeFrames,
      );

  /// Portfolio-specific selector configuration
  factory SelectorConfig.portfolio({SelectorLayoutType? selectorLayout}) =>
      SelectorConfig(
        showMarketCapSelector:
            false, // Portfolio doesn't typically filter by market cap
        selectorLayout: selectorLayout ?? SelectorLayoutType.expanded,
      );

  /// Index fund selector configuration
  factory SelectorConfig.index({SelectorLayoutType? selectorLayout}) =>
      SelectorConfig(
        showSectorSelector: false, // Index components are predefined
        showMarketCapSelector: false,
        selectorLayout: selectorLayout ?? SelectorLayoutType.compact,
      );

  /// Mutual funds selector configuration
  factory SelectorConfig.mutualFunds({SelectorLayoutType? selectorLayout}) =>
      SelectorConfig(
        selectorLayout: selectorLayout ?? SelectorLayoutType.expanded,
      );

  /// ETF selector configuration
  factory SelectorConfig.etf({SelectorLayoutType? selectorLayout}) =>
      SelectorConfig(
        showMarketCapSelector: false,
        selectorLayout: selectorLayout ?? SelectorLayoutType.expanded,
      );

  // Selector visibility
  final bool showTimeFrameSelector;
  final bool showMetricSelector;
  final bool showSectorSelector;
  final bool showMarketCapSelector;

  // Selector layout type
  final SelectorLayoutType selectorLayout;

  // Available options
  final List<TimeFrame>? availableTimeFrames;
  final List<MetricType>? availableMetrics;
  final List<SectorType>? availableSectors;
  final List<MarketCapType>? availableMarketCaps;

  /// Copy with modifications
  SelectorConfig copyWith({
    bool? showTimeFrameSelector,
    bool? showMetricSelector,
    bool? showSectorSelector,
    bool? showMarketCapSelector,
    SelectorLayoutType? selectorLayout,
    List<TimeFrame>? availableTimeFrames,
    List<MetricType>? availableMetrics,
    List<SectorType>? availableSectors,
    List<MarketCapType>? availableMarketCaps,
  }) => SelectorConfig(
    showTimeFrameSelector: showTimeFrameSelector ?? this.showTimeFrameSelector,
    showMetricSelector: showMetricSelector ?? this.showMetricSelector,
    showSectorSelector: showSectorSelector ?? this.showSectorSelector,
    showMarketCapSelector: showMarketCapSelector ?? this.showMarketCapSelector,
    selectorLayout: selectorLayout ?? this.selectorLayout,
    availableTimeFrames: availableTimeFrames ?? this.availableTimeFrames,
    availableMetrics: availableMetrics ?? this.availableMetrics,
    availableSectors: availableSectors ?? this.availableSectors,
    availableMarketCaps: availableMarketCaps ?? this.availableMarketCaps,
  );

  /// Check if any selectors should be shown
  bool get hasSelectors =>
      showTimeFrameSelector ||
      showMetricSelector ||
      showSectorSelector ||
      showMarketCapSelector;

  /// Check if this is minimal configuration
  bool get isMinimal =>
      !showTimeFrameSelector &&
      !showMetricSelector &&
      !showSectorSelector &&
      !showMarketCapSelector;

  /// Get count of visible selectors
  int get visibleSelectorCount {
    var count = 0;
    if (showTimeFrameSelector) count++;
    if (showMetricSelector) count++;
    if (showSectorSelector) count++;
    if (showMarketCapSelector) count++;
    return count;
  }
}
