import '../../selectors/selectors.dart';

/// Configuration for heatmap selector visibility and available options    showSectorSelector: showSectorSelector ?? this.showSectorSelector,/// Handles which selectors to show and what options they should contain
class SelectorConfig {
  const SelectorConfig({
    // Which selectors to show
    this.showTimeFrameSelector = true,
    this.showMetricSelector = true,
    this.showSectorSelector = true,
    this.showMarketCapSelector = true,

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
  }) => SelectorConfig(
    showSectorSelector: false,
    showMarketCapSelector: false,
    availableTimeFrames: timeFrames ?? TimeFrame.mobileTimeFrames,
    availableMetrics: metrics ?? MetricType.mobileMetrics,
  );

  /// Web-optimized selector configuration
  factory SelectorConfig.web({
    List<TimeFrame>? timeFrames,
    List<MetricType>? metrics,
    List<SectorType>? sectors,
    List<MarketCapType>? marketCaps,
  }) => SelectorConfig(
    availableTimeFrames: timeFrames ?? TimeFrame.webTimeFrames,
    availableMetrics: metrics ?? MetricType.webMetrics,
    availableSectors: sectors ?? SectorType.allSectors,
    availableMarketCaps: marketCaps ?? MarketCapType.allMarketCaps,
  );

  /// Minimal selector configuration (for widgets, previews)
  factory SelectorConfig.minimal({bool showSelectors = false}) =>
      SelectorConfig(
        showTimeFrameSelector: showSelectors,
        showMetricSelector: showSelectors,
        showSectorSelector: false,
        showMarketCapSelector: false,
      );

  /// Dashboard selector configuration
  factory SelectorConfig.dashboard() => SelectorConfig(
    showMetricSelector: false,
    showSectorSelector: false,
    showMarketCapSelector: false,
    availableTimeFrames: TimeFrame.dashboardTimeFrames,
  );

  /// Portfolio-specific selector configuration
  factory SelectorConfig.portfolio() => const SelectorConfig(
    showMarketCapSelector:
        false, // Portfolio doesn't typically filter by market cap
  );

  /// Index fund selector configuration
  factory SelectorConfig.index() => const SelectorConfig(
    showSectorSelector: false, // Index components are predefined
    showMarketCapSelector: false,
  );

  /// Mutual funds selector configuration
  factory SelectorConfig.mutualFunds() => const SelectorConfig();

  /// ETF selector configuration
  factory SelectorConfig.etf() =>
      const SelectorConfig(showMarketCapSelector: false);

  // Selector visibility
  final bool showTimeFrameSelector;
  final bool showMetricSelector;
  final bool showSectorSelector;
  final bool showMarketCapSelector;

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
    List<TimeFrame>? availableTimeFrames,
    List<MetricType>? availableMetrics,
    List<SectorType>? availableSectors,
    List<MarketCapType>? availableMarketCaps,
  }) => SelectorConfig(
    showTimeFrameSelector: showTimeFrameSelector ?? this.showTimeFrameSelector,
    showMetricSelector: showMetricSelector ?? this.showMetricSelector,
    showSectorSelector: showSelectorSelector ?? this.showSectorSelector,
    showMarketCapSelector: showMarketCapSelector ?? this.showMarketCapSelector,
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
