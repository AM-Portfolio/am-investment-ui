import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_logic/domain/entities/heatmap/heatmap_entities.dart';
import '../../../core/utils/logger.dart';
import '../../models/heatmap/heatmap_tile_data.dart';
import '../../models/heatmap/heatmap_ui_data.dart';
import '../selectors/selectors.dart';
import 'heatmap_config.dart';
import 'heatmap_template_card.dart';

/// A configurable heatmap widget that adapts based on platform and use case
/// Combines selectors and heatmap display with full configuration control
class ConfigurableHeatmapWidget extends ConsumerStatefulWidget {
  const ConfigurableHeatmapWidget({
    super.key,
    this.data,
    this.config,
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

  /// Data provider for the heatmap
  final HeatmapData? data;

  /// Configuration for heatmap behavior and appearance
  final HeatmapConfig? config;

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

    // Log widget initialization
    AppLogger.debug(
      'ConfigurableHeatmapWidget: initialized with config=${widget.config != null}, selectors=$_effectiveShowSelectors, compact=$_effectiveCompact, hasData=${widget.data != null}',
      tag: 'Heatmap.Widget',
    );

    _initializeSelectors();
  }

  void _initializeSelectors() {
    _selectedTimeFrame = widget.initialTimeFrame ?? TimeFrame.oneMonth;
    _selectedMetric = widget.initialMetric ?? MetricType.changePercent;
    _selectedSector = widget.initialSector ?? SectorType.all;
    _selectedMarketCap = widget.initialMarketCap ?? MarketCapType.all;
  }

  /// Get effective configuration values (with sensible defaults if no config provided)
  bool get _effectiveShowSelectors => widget.config?.hasSelectors ?? true;
  bool get _effectiveCompact => widget.config?.compactView ?? false;
  String? get _effectiveTitle => widget.config?.customTitle;

  void _onTimeFrameChanged(TimeFrame timeFrame) {
    AppLogger.debug(
      'Heatmap timeframe: ${_selectedTimeFrame.code} → ${timeFrame.code}',
      tag: 'Heatmap.Filter',
    );

    setState(() {
      _selectedTimeFrame = timeFrame;
    });
    _onSelectorsChanged();
  }

  void _onMetricChanged(MetricType metric) {
    AppLogger.debug(
      'Heatmap metric: ${_selectedMetric.shortName} → ${metric.shortName}',
      tag: 'Heatmap.Filter',
    );

    setState(() {
      _selectedMetric = metric;
    });
    _onSelectorsChanged();
  }

  void _onSelectorsChanged() {
    _notifySelectorsChanged();
  }

  @override
  Widget build(BuildContext context) {
    // Log rendering phase
    AppLogger.debug(
      'ConfigurableHeatmapWidget: rendering with ${widget.data?.tiles.length ?? 0} tiles',
      tag: 'Heatmap.Render',
    );

    return Column(
      children: [
        // Selectors section (if enabled)
        if (_effectiveShowSelectors) ...[
          _buildSelectorsSection(context),
          const SizedBox(height: 16),
        ],

        // Main heatmap content
        Expanded(child: _buildHeatmapContent(context)),
      ],
    );
  }

  Widget _buildSelectorsSection(BuildContext context) {
    // Always use compact design for minimal space usage
    return Container(
      height: 60, // Fixed compact height
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Time Frame Pills
          Expanded(flex: 3, child: _buildCompactTimeFrameSelector(context)),
          const SizedBox(width: 12),

          // Metric Dropdown
          Expanded(flex: 2, child: _buildCompactMetricSelector(context)),
          const SizedBox(width: 12),

          // Reset Button
          _buildCompactResetButton(context),
        ],
      ),
    );
  }

  /// Build compact time frame selector with pills
  Widget _buildCompactTimeFrameSelector(BuildContext context) {
    final timeFrames = [
      TimeFrame.oneDay,
      TimeFrame.oneWeek,
      TimeFrame.oneMonth,
      TimeFrame.threeMonths,
      TimeFrame.oneYear,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: timeFrames.map<Widget>((timeFrame) {
          final isSelected = _selectedTimeFrame == timeFrame;
          return Container(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => _onTimeFrameChanged(timeFrame),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  timeFrame.displayName,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).primaryColor,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Build compact metric selector dropdown
  Widget _buildCompactMetricSelector(BuildContext context) => Container(
    height: 40,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: Theme.of(context).primaryColor.withOpacity(0.05),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Theme.of(context).primaryColor.withOpacity(0.2),
      ),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<MetricType>(
        value: _selectedMetric,
        isExpanded: true,
        icon: Icon(
          Icons.expand_more,
          color: Theme.of(context).primaryColor,
          size: 18,
        ),
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        items: MetricType.heatmapMetrics
            .map(
              (metric) => DropdownMenuItem<MetricType>(
                value: metric,
                child: Row(
                  children: [
                    Icon(
                      metric.icon,
                      size: 14,
                      color: Theme.of(context).primaryColor.withOpacity(0.7),
                    ),
                    const SizedBox(width: 6),
                    Text(metric.shortName),
                  ],
                ),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) {
            _onMetricChanged(value);
          }
        },
      ),
    ),
  );

  /// Build compact reset button
  Widget _buildCompactResetButton(BuildContext context) => InkWell(
    onTap: () {
      _selectedTimeFrame = TimeFrame.oneMonth;
      _selectedMetric = MetricType.changePercent;
      _selectedSector = SectorType.all;
      _selectedMarketCap = MarketCapType.all;
      _onSelectorsChanged();
    },
    borderRadius: BorderRadius.circular(12),
    child: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
        ),
      ),
      child: Icon(
        Icons.refresh,
        color: Theme.of(context).primaryColor.withOpacity(0.7),
        size: 18,
      ),
    ),
  );

  Widget _buildHeatmapContent(BuildContext context) => Container(
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
  HeatmapData _getEmptyData() => HeatmapData(
    id: 'empty-heatmap',
    title: _effectiveTitle ?? 'Portfolio Heatmap',
    subtitle: 'No data available',
    tiles: [],
    metadata: HeatmapMetadata(
      lastUpdated: DateTime.now(),
      dataSource: 'configurable_widget',
      additionalInfo: const {'status': 'empty'},
    ),
    configuration: const HeatmapConfiguration(),
  );

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
    HeatmapConfig? config,
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
  }) => ConfigurableHeatmapWidget(
    key: key,
    data: data,
    config: config ?? HeatmapConfig.mobile(title: title),
    isLoading: isLoading,
    error: error,
    onTilePressed: onTilePressed,
    onSelectorsChanged: onSelectorsChanged,
  );

  /// Create a web-optimized heatmap widget
  static ConfigurableHeatmapWidget web({
    Key? key,
    HeatmapData? data,
    HeatmapConfig? config,
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
  }) => ConfigurableHeatmapWidget(
    key: key,
    data: data,
    config: config ?? HeatmapConfig.web(title: title),
    isLoading: isLoading,
    error: error,
    onTilePressed: onTilePressed,
    onSelectorsChanged: onSelectorsChanged,
  );

  /// Create a dashboard heatmap widget
  static ConfigurableHeatmapWidget dashboard({
    Key? key,
    HeatmapData? data,
    HeatmapConfig? config,
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
  }) => ConfigurableHeatmapWidget(
    key: key,
    data: data,
    config:
        config ??
        HeatmapConfig.dashboard(title: title, interactive: interactive),
    isLoading: isLoading,
    error: error,
    onTilePressed: onTilePressed,
    onSelectorsChanged: onSelectorsChanged,
  );

  /// Create a minimal heatmap widget (for previews, widgets, etc.)
  static ConfigurableHeatmapWidget minimal({
    Key? key,
    HeatmapData? data,
    HeatmapConfig? config,
    bool isLoading = false,
    String? error,
    VoidCallback? onTilePressed,
    String? title,
  }) => ConfigurableHeatmapWidget(
    key: key,
    data: data,
    config: config ?? HeatmapConfig.minimal(title: title),
    isLoading: isLoading,
    error: error,
    onTilePressed: onTilePressed,
  );
}
