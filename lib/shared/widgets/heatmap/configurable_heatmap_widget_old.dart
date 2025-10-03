import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../selectors/selectors.dart';
import 'heatmap_selector_card.dart';
import 'heatmap_template_card.dart';
import '../../models/heatmap/heatmap_ui_data.dart';
import '../../models/heatmap/heatmap_tile_data.dart';
import '../../../core/app_logic/domain/entities/heatmap/heatmap_entities.dart';

/// A configurable heatmap widget that adapts based on platform and use case
/// Combines selectors and heatmap display with full configuration control
class ConfigurableHeatmapWidget extends ConsumerStatefulWidget {
  /// Data provider for the heatmap
  final HeatmapData? data;
  
  /// Loading state
  final bool isLoading;
  
  /// Error message if any
  final String? error;
  
  /// Callback when heatmap tile is pressed
  final VoidCallback? onTilePressed;
  
  /// Callback when selectors change
  final Function({
    TimeFrame? timeFrame,
    MetricType? metric,
    SectorType? sector,
    MarketCapType? marketCap,
  })? onSelectorsChanged;
  
  /// Initial selector values
  final TimeFrame? initialTimeFrame;
  final MetricType? initialMetric;
  final SectorType? initialSector;
  final MarketCapType? initialMarketCap;
  
  /// Custom widget builder for tiles
  final Widget Function(HeatmapTileData tile)? customTileBuilder;
  
  /// Whether to show selectors
  final bool showSelectors;
  
  /// Widget title
  final String? title;
  
  const ConfigurableHeatmapWidget({
    super.key,
    required this.config,
    this.data,
    this.isLoading = false,
    this.error,
    this.onTilePressed,
    this.onSelectorsChanged,
    this.initialTimeFrame,
    this.initialMetric,
    this.initialSector,
    this.initialMarketCap,
    this.customTileBuilder,
  });

  @override
  ConsumerState<ConfigurableHeatmapWidget> createState() =>
      _ConfigurableHeatmapWidgetState();
}

class _ConfigurableHeatmapWidgetState
    extends ConsumerState<ConfigurableHeatmapWidget> {
  late TimeFrame _selectedTimeFrame;
  late MetricType _selectedMetric;
  late SectorType _selectedSector;
  late MarketCapType _selectedMarketCap;

  @override
  void initState() {
    super.initState();
    _initializeSelectors();
  }

  void _initializeSelectors() {
    // Initialize with provided values or defaults
    _selectedTimeFrame = widget.initialTimeFrame ?? 
                        (widget.config.availableTimeFrames?.first ?? TimeFrame.oneMonth);
                        
    _selectedMetric = widget.initialMetric ?? 
                     (widget.config.availableMetrics?.first ?? MetricType.changePercent);
                     
    _selectedSector = widget.initialSector ?? 
                     (widget.config.availableSectors?.first ?? SectorType.all);
                     
    _selectedMarketCap = widget.initialMarketCap ?? 
                        (widget.config.availableMarketCaps?.first ?? MarketCapType.all);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Selectors section (if enabled)
        if (widget.config.hasSelectors) ...[
          _buildSelectorsSection(context),
          if (widget.config.selectorSpacing != null)
            SizedBox(height: widget.config.selectorSpacing!),
        ],

        // Main heatmap content
        Expanded(child: _buildHeatmapContent(context)),
      ],
    );
  }

  Widget _buildSelectorsSection(BuildContext context) {
    if (widget.config.compactView) {
      return _buildCompactSelectors(context);
    } else {
      return _buildFullSelectors(context);
    }
  }

  Widget _buildCompactSelectors(BuildContext context) {
    return Container(
      padding: widget.config.selectorPadding ?? const EdgeInsets.all(8),
      child: Row(
        children: [
          // Time frame (if enabled)
          if (widget.config.showTimeFrameSelector) ...[
            Expanded(
              child: TimeFrameSelector(
                selectedTimeFrame: _selectedTimeFrame,
                onTimeFrameChanged: (timeFrame) {
                  setState(() {
                    _selectedTimeFrame = timeFrame;
                  });
                  _notifySelectorsChanged();
                },
                availableTimeFrames: widget.config.availableTimeFrames,
                compact: true,
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Metric (if enabled)
          if (widget.config.showMetricSelector) ...[
            Expanded(
              child: MetricSelector(
                selectedMetric: _selectedMetric,
                onMetricChanged: (metric) {
                  setState(() {
                    _selectedMetric = metric;
                  });
                  _notifySelectorsChanged();
                },
                availableMetrics: widget.config.availableMetrics,
                compact: true,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFullSelectors(BuildContext context) {
    return HeatmapSelectorCard(
      config: HeatmapSelectorConfig(
        selectedTimeFrame: _selectedTimeFrame,
        selectedMetric: _selectedMetric,
        selectedSector: _selectedSector,
        selectedMarketCap: _selectedMarketCap,
      ),
      title: widget.config.customTitle,
      callbacks: HeatmapSelectorCallbacks(
        onTimeFrameChanged: (timeFrame) {
          setState(() {
            _selectedTimeFrame = timeFrame;
          });
          _notifySelectorsChanged();
        },
        onMetricChanged: (metric) {
          setState(() {
            _selectedMetric = metric;
          });
          _notifySelectorsChanged();
        },
        onSectorChanged: (sector) {
          setState(() {
            _selectedSector = sector;
          });
          _notifySelectorsChanged();
        },
        onMarketCapChanged: (marketCap) {
          setState(() {
            _selectedMarketCap = marketCap;
          });
          _notifySelectorsChanged();
        },
      ),
      compact: widget.config.compactView,
      margin: EdgeInsets.zero,
    );
  }

  Widget _buildHeatmapContent(BuildContext context) {
    return Container(
      padding: widget.config.cardPadding,
      child: HeatmapTemplateCard(
        data: widget.data ?? _getEmptyData(),
        isLoading: widget.isLoading,
        error: widget.error,
        onTilePressed: widget.onTilePressed,
        customTileBuilder: widget.customTileBuilder,
        icon: _getHeatmapIcon(),
      ),
    );
  }

  IconData _getHeatmapIcon() {
    switch (widget.config.layoutType) {
      case HeatmapLayoutType.treemap:
        return Icons.grid_view;
      case HeatmapLayoutType.grid:
        return Icons.apps;
      case HeatmapLayoutType.list:
        return Icons.list;
    }
  }

  HeatmapData _getEmptyData() {
    return HeatmapData(
      title: widget.config.customTitle ?? 'Portfolio Heatmap',
      subtitle: widget.config.showTitle ? 
                'No data available' : 
                null,
      tiles: [],
      configuration: HeatmapConfiguration(
        layout: widget.config.layoutType,
        showPerformance: widget.config.showPerformance,
        showWeightage: widget.config.showWeightage,
        showValue: widget.config.showValue,
        colorScheme: HeatmapColorSchemeType.performance,
      ),
    );
  }



  void _notifySelectorsChanged() {
    widget.onSelectorsChanged?.call(
      timeFrame: _selectedTimeFrame,
      metric: _selectedMetric,
      sector: _selectedSector,
      marketCap: _selectedMarketCap,
    );
  }
}

/// Extension to add factory constructors for common use cases
extension ConfigurableHeatmapExtensions on ConfigurableHeatmapWidget {
  /// Create a mobile-optimized heatmap widget
  static ConfigurableHeatmapWidget mobile({
    Key? key,
    HeatmapData? data,
    bool isLoading = false,
    String? error,
    VoidCallback? onTilePressed,
    Function({
      TimeFrame? timeFrame,
      MetricType? metric,
      SectorType? sector,
      MarketCapType? marketCap,
    })? onSelectorsChanged,
    String? title,
  }) {
    return ConfigurableHeatmapWidget(
      key: key,
      config: HeatmapConfig.mobile(title: title),
      data: data,
      isLoading: isLoading,
      error: error,
      onTilePressed: onTilePressed,
      onSelectorsChanged: onSelectorsChanged,
    );
  }

  /// Create a web-optimized heatmap widget
  static ConfigurableHeatmapWidget web({
    Key? key,
    HeatmapData? data,
    bool isLoading = false,
    String? error,
    VoidCallback? onTilePressed,
    Function({
      TimeFrame? timeFrame,
      MetricType? metric,
      SectorType? sector,
      MarketCapType? marketCap,
    })? onSelectorsChanged,
    String? title,
  }) {
    return ConfigurableHeatmapWidget(
      key: key,
      config: HeatmapConfig.web(title: title),
      data: data,
      isLoading: isLoading,
      error: error,
      onTilePressed: onTilePressed,
      onSelectorsChanged: onSelectorsChanged,
    );
  }

  /// Create a dashboard heatmap widget
  static ConfigurableHeatmapWidget dashboard({
    Key? key,
    HeatmapData? data,
    bool isLoading = false,
    String? error,
    VoidCallback? onTilePressed,
    Function({
      TimeFrame? timeFrame,
      MetricType? metric,
      SectorType? sector,
      MarketCapType? marketCap,
    })? onSelectorsChanged,
    String? title,
    bool interactive = true,
  }) {
    return ConfigurableHeatmapWidget(
      key: key,
      config: HeatmapConfig.dashboard(title: title, interactive: interactive),
      data: data,
      isLoading: isLoading,
      error: error,
      onTilePressed: onTilePressed,
      onSelectorsChanged: onSelectorsChanged,
    );
  }

  /// Create a minimal heatmap widget (for previews, widgets, etc.)
  static ConfigurableHeatmapWidget minimal({
    Key? key,
    HeatmapData? data,
    bool isLoading = false,
    String? error,
    VoidCallback? onTilePressed,
    String? title,
  }) {
    return ConfigurableHeatmapWidget(
      key: key,
      config: HeatmapConfig.minimal(title: title),
      data: data,
      isLoading: isLoading,
      error: error,
      onTilePressed: onTilePressed,
    );
  }
}