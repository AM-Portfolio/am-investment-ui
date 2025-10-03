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
  })?
  onSelectorsChanged;

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

  /// Whether to use compact layout
  final bool compact;

  const ConfigurableHeatmapWidget({
    super.key,
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
    this.showSelectors = true,
    this.title,
    this.compact = false,
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
    _selectedTimeFrame = widget.initialTimeFrame ?? TimeFrame.oneMonth;
    _selectedMetric = widget.initialMetric ?? MetricType.changePercent;
    _selectedSector = widget.initialSector ?? SectorType.all;
    _selectedMarketCap = widget.initialMarketCap ?? MarketCapType.all;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Selectors section (if enabled)
        if (widget.showSelectors) ...[
          _buildSelectorsSection(context),
          const SizedBox(height: 16),
        ],

        // Main heatmap content
        Expanded(child: _buildHeatmapContent(context)),
      ],
    );
  }

  Widget _buildSelectorsSection(BuildContext context) {
    if (widget.compact) {
      return _buildCompactSelectors(context);
    } else {
      return _buildFullSelectors(context);
    }
  }

  Widget _buildCompactSelectors(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          // Time frame
          Expanded(
            child: TimeFrameSelector(
              selectedTimeFrame: _selectedTimeFrame,
              onTimeFrameChanged: (timeFrame) {
                setState(() {
                  _selectedTimeFrame = timeFrame;
                });
                _notifySelectorsChanged();
              },
              compact: true,
            ),
          ),
          const SizedBox(width: 8),

          // Metric
          Expanded(
            child: MetricSelector(
              selectedMetric: _selectedMetric,
              onMetricChanged: (metric) {
                setState(() {
                  _selectedMetric = metric;
                });
                _notifySelectorsChanged();
              },
              compact: true,
            ),
          ),
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
      title: widget.title,
      compact: widget.compact,
      margin: EdgeInsets.zero,
    );
  }

  Widget _buildHeatmapContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: HeatmapTemplateCard(
        data: widget.data ?? _getEmptyData(),
        isLoading: widget.isLoading,
        error: widget.error,
        onTilePressed: widget.onTilePressed,
        customTileBuilder: widget.customTileBuilder,
        icon: Icons.grid_view,
      ),
    );
  }

  HeatmapData _getEmptyData() {
    return HeatmapData(
      id: 'empty-heatmap',
      title: widget.title ?? 'Portfolio Heatmap',
      subtitle: 'No data available',
      tiles: [],
      metadata: HeatmapMetadata(
        lastUpdated: DateTime.now(),
        dataSource: 'configurable_widget',
        additionalInfo: const {'status': 'empty'},
      ),
      configuration: HeatmapConfiguration(
        showPerformance: true,
        showWeightage: true,
        showValue: false,
        layout: HeatmapLayoutType.treemap,
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
    })?
    onSelectorsChanged,
    String? title,
  }) {
    return ConfigurableHeatmapWidget(
      key: key,
      data: data,
      isLoading: isLoading,
      error: error,
      onTilePressed: onTilePressed,
      onSelectorsChanged: onSelectorsChanged,
      title: title,
      compact: true,
      showSelectors: true,
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
    })?
    onSelectorsChanged,
    String? title,
  }) {
    return ConfigurableHeatmapWidget(
      key: key,
      data: data,
      isLoading: isLoading,
      error: error,
      onTilePressed: onTilePressed,
      onSelectorsChanged: onSelectorsChanged,
      title: title,
      compact: false,
      showSelectors: true,
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
    })?
    onSelectorsChanged,
    String? title,
    bool interactive = true,
  }) {
    return ConfigurableHeatmapWidget(
      key: key,
      data: data,
      isLoading: isLoading,
      error: error,
      onTilePressed: onTilePressed,
      onSelectorsChanged: onSelectorsChanged,
      title: title,
      compact: true,
      showSelectors: interactive,
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
      data: data,
      isLoading: isLoading,
      error: error,
      onTilePressed: onTilePressed,
      title: title,
      compact: true,
      showSelectors: false,
    );
  }
}
