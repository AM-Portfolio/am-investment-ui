import 'package:flutter/material.dart';
import '../selectors/selectors.dart';

/// Configuration class for heatmap selector settings
class HeatmapSelectorConfig {
  final TimeFrame selectedTimeFrame;
  final MetricType selectedMetric;
  final SectorType selectedSector;
  final MarketCapType selectedMarketCap;

  const HeatmapSelectorConfig({
    this.selectedTimeFrame = TimeFrame.oneMonth,
    this.selectedMetric = MetricType.changePercent,
    this.selectedSector = SectorType.all,
    this.selectedMarketCap = MarketCapType.all,
  });

  HeatmapSelectorConfig copyWith({
    TimeFrame? selectedTimeFrame,
    MetricType? selectedMetric,
    SectorType? selectedSector,
    MarketCapType? selectedMarketCap,
  }) {
    return HeatmapSelectorConfig(
      selectedTimeFrame: selectedTimeFrame ?? this.selectedTimeFrame,
      selectedMetric: selectedMetric ?? this.selectedMetric,
      selectedSector: selectedSector ?? this.selectedSector,
      selectedMarketCap: selectedMarketCap ?? this.selectedMarketCap,
    );
  }
}

/// Callbacks for heatmap selector changes
class HeatmapSelectorCallbacks {
  final ValueChanged<TimeFrame> onTimeFrameChanged;
  final ValueChanged<MetricType> onMetricChanged;
  final ValueChanged<SectorType> onSectorChanged;
  final ValueChanged<MarketCapType> onMarketCapChanged;

  const HeatmapSelectorCallbacks({
    required this.onTimeFrameChanged,
    required this.onMetricChanged,
    required this.onSectorChanged,
    required this.onMarketCapChanged,
  });
}

/// A common selector card widget for heatmap controls
/// Combines time frame, metric, sector, and market cap selectors in a responsive layout
class HeatmapSelectorCard extends StatelessWidget {
  /// Current configuration values
  final HeatmapSelectorConfig config;

  /// Callbacks for selector changes
  final HeatmapSelectorCallbacks callbacks;

  /// Card title
  final String? title;

  /// Card subtitle
  final String? subtitle;

  /// Primary color theme
  final Color? primaryColor;

  /// Whether to show in compact mode (smaller spacing)
  final bool compact;

  /// Whether to show reset button
  final bool showResetButton;

  /// Callback for reset action
  final VoidCallback? onReset;

  /// Whether to show export button
  final bool showExportButton;

  /// Callback for export action
  final VoidCallback? onExport;

  /// Custom card elevation
  final double? elevation;

  /// Custom card margin
  final EdgeInsetsGeometry? margin;

  /// Custom card padding
  final EdgeInsetsGeometry? padding;

  const HeatmapSelectorCard({
    super.key,
    required this.config,
    required this.callbacks,
    this.title,
    this.subtitle,
    this.primaryColor,
    this.compact = false,
    this.showResetButton = false,
    this.onReset,
    this.showExportButton = false,
    this.onExport,
    this.elevation,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation ?? 2,
      margin: margin ?? const EdgeInsets.all(8),
      child: Padding(
        padding: padding ?? EdgeInsets.all(compact ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null || subtitle != null) ...[
              _buildHeader(context),
              SizedBox(height: compact ? 12 : 16),
            ],
            _buildSelectorGrid(context),
            if (showResetButton || showExportButton) ...[
              SizedBox(height: compact ? 12 : 16),
              _buildActionButtons(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Text(
            title!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ],
    );
  }

  Widget _buildSelectorGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;

        if (isWide) {
          return _buildWideLayout(context);
        } else {
          return _buildNarrowLayout(context);
        }
      },
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Row(
      children: [
        // Time Frame Selector
        Expanded(
          flex: 2,
          child: TimeFrameSelector.heatmap(
            selectedTimeFrame: config.selectedTimeFrame,
            onTimeFrameChanged: callbacks.onTimeFrameChanged,
            primaryColor: primaryColor,
            title: 'Time Frame',
          ),
        ),
        SizedBox(width: compact ? 12 : 16),

        // Metric Selector
        Expanded(
          flex: 2,
          child: MetricSelector.heatmap(
            selectedMetric: config.selectedMetric,
            onMetricChanged: callbacks.onMetricChanged,
            primaryColor: primaryColor,
            title: 'Metric',
          ),
        ),
        SizedBox(width: compact ? 12 : 16),

        // Sector Selector
        Expanded(
          flex: 2,
          child: SectorSelector.heatmap(
            selectedSector: config.selectedSector,
            onSectorChanged: callbacks.onSectorChanged,
            primaryColor: primaryColor,
            title: 'Sector',
          ),
        ),
        SizedBox(width: compact ? 12 : 16),

        // Market Cap Selector
        Expanded(
          flex: 2,
          child: MarketCapSelector.heatmap(
            selectedMarketCap: config.selectedMarketCap,
            onMarketCapChanged: callbacks.onMarketCapChanged,
            primaryColor: primaryColor,
            title: 'Market Cap',
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return Column(
      children: [
        // First Row - Time Frame and Metric
        Row(
          children: [
            Expanded(
              child: TimeFrameSelector.heatmap(
                selectedTimeFrame: config.selectedTimeFrame,
                onTimeFrameChanged: callbacks.onTimeFrameChanged,
                primaryColor: primaryColor,
                title: 'Time Frame',
              ),
            ),
            SizedBox(width: compact ? 12 : 16),
            Expanded(
              child: MetricSelector.heatmap(
                selectedMetric: config.selectedMetric,
                onMetricChanged: callbacks.onMetricChanged,
                primaryColor: primaryColor,
                title: 'Metric',
              ),
            ),
          ],
        ),
        SizedBox(height: compact ? 12 : 16),

        // Second Row - Sector and Market Cap
        Row(
          children: [
            Expanded(
              child: SectorSelector.heatmap(
                selectedSector: config.selectedSector,
                onSectorChanged: callbacks.onSectorChanged,
                primaryColor: primaryColor,
                title: 'Sector',
              ),
            ),
            SizedBox(width: compact ? 12 : 16),
            Expanded(
              child: MarketCapSelector.heatmap(
                selectedMarketCap: config.selectedMarketCap,
                onMarketCapChanged: callbacks.onMarketCapChanged,
                primaryColor: primaryColor,
                title: 'Market Cap',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        if (showResetButton)
          OutlinedButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Reset'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 12 : 16,
                vertical: compact ? 8 : 12,
              ),
            ),
          ),
        if (showResetButton && showExportButton)
          SizedBox(width: compact ? 8 : 12),
        if (showExportButton)
          ElevatedButton.icon(
            onPressed: onExport,
            icon: const Icon(Icons.download, size: 16),
            label: const Text('Export'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 12 : 16,
                vertical: compact ? 8 : 12,
              ),
            ),
          ),
      ],
    );
  }
}

/// A simplified version of the heatmap selector card with fewer options
class CompactHeatmapSelectorCard extends StatelessWidget {
  /// Current configuration values
  final HeatmapSelectorConfig config;

  /// Callbacks for selector changes
  final HeatmapSelectorCallbacks callbacks;

  /// Primary color theme
  final Color? primaryColor;

  /// Whether to show time frame selector
  final bool showTimeFrame;

  /// Whether to show metric selector
  final bool showMetric;

  /// Whether to show sector selector
  final bool showSector;

  /// Whether to show market cap selector
  final bool showMarketCap;

  const CompactHeatmapSelectorCard({
    super.key,
    required this.config,
    required this.callbacks,
    this.primaryColor,
    this.showTimeFrame = true,
    this.showMetric = true,
    this.showSector = false,
    this.showMarketCap = false,
  });

  @override
  Widget build(BuildContext context) {
    final selectors = <Widget>[];

    if (showTimeFrame) {
      selectors.add(
        TimeFrameSelector.heatmap(
          selectedTimeFrame: config.selectedTimeFrame,
          onTimeFrameChanged: callbacks.onTimeFrameChanged,
          primaryColor: primaryColor,
        ),
      );
    }

    if (showMetric) {
      selectors.add(
        MetricSelector.heatmap(
          selectedMetric: config.selectedMetric,
          onMetricChanged: callbacks.onMetricChanged,
          primaryColor: primaryColor,
        ),
      );
    }

    if (showSector) {
      selectors.add(
        SectorSelector.heatmap(
          selectedSector: config.selectedSector,
          onSectorChanged: callbacks.onSectorChanged,
          primaryColor: primaryColor,
        ),
      );
    }

    if (showMarketCap) {
      selectors.add(
        MarketCapSelector.heatmap(
          selectedMarketCap: config.selectedMarketCap,
          onMarketCapChanged: callbacks.onMarketCapChanged,
          primaryColor: primaryColor,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: selectors,
      ),
    );
  }
}
