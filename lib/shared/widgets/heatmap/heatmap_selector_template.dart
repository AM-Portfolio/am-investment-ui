import 'package:flutter/material.dart';

import '../../../core/utils/logger.dart';
import '../selectors/selectors.dart';
import 'configs/selector_config.dart';

/// Pure heatmap selector template - handles only selector UI and interactions
/// Extracted for better modularity and reusability
class HeatmapSelectorTemplate extends StatefulWidget {
  const HeatmapSelectorTemplate({
    super.key,
    this.initialTimeFrame,
    this.initialMetric,
    this.initialSector,
    this.initialMarketCap,
    this.onTimeFrameChanged,
    this.onMetricChanged,
    this.onSectorChanged,
    this.onMarketCapChanged,
    this.onFiltersChanged,
    this.showTimeFrame = true,
    this.showMetric = true,
    this.showSector = true,
    this.showMarketCap = true,
    this.layout = SelectorLayoutType.compact,
    this.primaryColor,
    this.title,
    this.showResetButton = true,
  });

  final TimeFrame? initialTimeFrame;
  final MetricType? initialMetric;
  final SectorType? initialSector;
  final MarketCapType? initialMarketCap;

  final ValueChanged<TimeFrame>? onTimeFrameChanged;
  final ValueChanged<MetricType>? onMetricChanged;
  final ValueChanged<SectorType>? onSectorChanged;
  final ValueChanged<MarketCapType>? onMarketCapChanged;

  /// Combined callback for all filter changes
  final Function({
    TimeFrame? timeFrame,
    MetricType? metric,
    SectorType? sector,
    MarketCapType? marketCap,
  })?
  onFiltersChanged;

  final bool showTimeFrame;
  final bool showMetric;
  final bool showSector;
  final bool showMarketCap;
  final SelectorLayoutType layout;
  final Color? primaryColor;
  final String? title;
  final bool showResetButton;

  @override
  State<HeatmapSelectorTemplate> createState() =>
      _HeatmapSelectorTemplateState();
}

class _HeatmapSelectorTemplateState extends State<HeatmapSelectorTemplate> {
  late TimeFrame _selectedTimeFrame;
  late MetricType _selectedMetric;
  late SectorType _selectedSector;
  late MarketCapType _selectedMarketCap;

  @override
  void initState() {
    super.initState();
    _initializeSelectors();

    AppLogger.debug(
      'HeatmapSelectorTemplate: initialized with layout=${widget.layout}',
      tag: 'Heatmap.Selector',
    );
  }

  void _initializeSelectors() {
    _selectedTimeFrame = widget.initialTimeFrame ?? TimeFrame.oneMonth;
    _selectedMetric = widget.initialMetric ?? MetricType.changePercent;
    _selectedSector = widget.initialSector ?? SectorType.all;
    _selectedMarketCap = widget.initialMarketCap ?? MarketCapType.all;
  }

  void _onTimeFrameChanged(TimeFrame timeFrame) {
    setState(() {
      _selectedTimeFrame = timeFrame;
    });

    AppLogger.debug(
      'Selector timeframe changed: ${timeFrame.code}',
      tag: 'Heatmap.Selector',
    );

    widget.onTimeFrameChanged?.call(timeFrame);
    _notifyFiltersChanged();
  }

  void _onMetricChanged(MetricType metric) {
    setState(() {
      _selectedMetric = metric;
    });

    AppLogger.debug(
      'Selector metric changed: ${metric.shortName}',
      tag: 'Heatmap.Selector',
    );

    widget.onMetricChanged?.call(metric);
    _notifyFiltersChanged();
  }

  void _onSectorChanged(SectorType sector) {
    setState(() {
      _selectedSector = sector;
    });

    AppLogger.debug(
      'Selector sector changed: ${sector.name}',
      tag: 'Heatmap.Selector',
    );

    widget.onSectorChanged?.call(sector);
    _notifyFiltersChanged();
  }

  void _onMarketCapChanged(MarketCapType marketCap) {
    setState(() {
      _selectedMarketCap = marketCap;
    });

    AppLogger.debug(
      'Selector market cap changed: ${marketCap.name}',
      tag: 'Heatmap.Selector',
    );

    widget.onMarketCapChanged?.call(marketCap);
    _notifyFiltersChanged();
  }

  void _resetFilters() {
    setState(() {
      _selectedTimeFrame = TimeFrame.oneMonth;
      _selectedMetric = MetricType.changePercent;
      _selectedSector = SectorType.all;
      _selectedMarketCap = MarketCapType.all;
    });

    AppLogger.debug('Selector filters reset', tag: 'Heatmap.Selector');
    _notifyFiltersChanged();
  }

  void _notifyFiltersChanged() {
    widget.onFiltersChanged?.call(
      timeFrame: _selectedTimeFrame,
      metric: _selectedMetric,
      sector: _selectedSector,
      marketCap: _selectedMarketCap,
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.layout) {
      case SelectorLayoutType.compact:
        return _buildCompactLayout(context);
      case SelectorLayoutType.expanded:
        return _buildExpandedLayout(context);
      case SelectorLayoutType.pills:
        return _buildPillsLayout(context);
      case SelectorLayoutType.dropdown:
        return _buildDropdownLayout(context);
    }
  }

  Widget _buildCompactLayout(BuildContext context) => Container(
    height: 60,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: (widget.primaryColor ?? Theme.of(context).primaryColor)
            .withOpacity(0.1),
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
        if (widget.showTimeFrame) ...[
          Expanded(flex: 3, child: _buildTimeFramePills(context)),
          const SizedBox(width: 12),
        ],
        if (widget.showMetric) ...[
          Expanded(flex: 2, child: _buildMetricDropdown(context)),
          const SizedBox(width: 12),
        ],
        if (widget.showResetButton) _buildResetButton(context),
      ],
    ),
  );

  Widget _buildExpandedLayout(BuildContext context) => Card(
    elevation: 2,
    margin: const EdgeInsets.all(8),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title != null) ...[
            Text(
              widget.title!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: widget.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
          ],
          _buildExpandedSelectors(context),
          if (widget.showResetButton) ...[
            const SizedBox(height: 16),
            _buildExpandedResetButton(context),
          ],
        ],
      ),
    ),
  );

  Widget _buildPillsLayout(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (widget.showTimeFrame) _buildTimeFramePills(context),
        if (widget.showMetric) _buildMetricPills(context),
        if (widget.showSector) _buildSectorPills(context),
        if (widget.showMarketCap) _buildMarketCapPills(context),
      ],
    ),
  );

  Widget _buildDropdownLayout(BuildContext context) => Container(
    padding: const EdgeInsets.all(8),
    child: Row(
      children: [
        if (widget.showTimeFrame) ...[
          Expanded(child: _buildTimeFrameDropdown(context)),
          const SizedBox(width: 8),
        ],
        if (widget.showMetric) ...[
          Expanded(child: _buildMetricDropdown(context)),
          const SizedBox(width: 8),
        ],
        if (widget.showSector) ...[
          Expanded(child: _buildSectorDropdown(context)),
          const SizedBox(width: 8),
        ],
        if (widget.showMarketCap) ...[
          Expanded(child: _buildMarketCapDropdown(context)),
          const SizedBox(width: 8),
        ],
        if (widget.showResetButton) _buildIconResetButton(context),
      ],
    ),
  );

  Widget _buildTimeFramePills(BuildContext context) {
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
        children: timeFrames.map((timeFrame) {
          final isSelected = _selectedTimeFrame == timeFrame;
          return Container(
            margin: const EdgeInsets.only(right: 6),
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
                      ? (widget.primaryColor ?? Theme.of(context).primaryColor)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? (widget.primaryColor ??
                              Theme.of(context).primaryColor)
                        : (widget.primaryColor ??
                                  Theme.of(context).primaryColor)
                              .withOpacity(0.3),
                  ),
                ),
                child: Text(
                  timeFrame.displayName,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (widget.primaryColor ??
                              Theme.of(context).primaryColor),
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

  Widget _buildMetricDropdown(BuildContext context) => Container(
    height: 40,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: (widget.primaryColor ?? Theme.of(context).primaryColor)
          .withOpacity(0.05),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: (widget.primaryColor ?? Theme.of(context).primaryColor)
            .withOpacity(0.2),
      ),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<MetricType>(
        value: _selectedMetric,
        isExpanded: true,
        icon: Icon(
          Icons.expand_more,
          color: widget.primaryColor ?? Theme.of(context).primaryColor,
          size: 18,
        ),
        style: TextStyle(
          color: widget.primaryColor ?? Theme.of(context).primaryColor,
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
                      color:
                          (widget.primaryColor ??
                                  Theme.of(context).primaryColor)
                              .withOpacity(0.7),
                    ),
                    const SizedBox(width: 6),
                    Text(metric.shortName),
                  ],
                ),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) _onMetricChanged(value);
        },
      ),
    ),
  );

  Widget _buildResetButton(BuildContext context) => InkWell(
    onTap: _resetFilters,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (widget.primaryColor ?? Theme.of(context).primaryColor)
              .withOpacity(0.3),
        ),
      ),
      child: Icon(
        Icons.refresh,
        color: (widget.primaryColor ?? Theme.of(context).primaryColor)
            .withOpacity(0.7),
        size: 18,
      ),
    ),
  );

  Widget _buildExpandedSelectors(BuildContext context) => Column(
    children: [
      Row(
        children: [
          if (widget.showTimeFrame) ...[
            Expanded(
              child: TimeFrameSelector.heatmap(
                selectedTimeFrame: _selectedTimeFrame,
                onTimeFrameChanged: _onTimeFrameChanged,
                primaryColor: widget.primaryColor,
                title: 'Time Frame',
              ),
            ),
            const SizedBox(width: 16),
          ],
          if (widget.showMetric)
            Expanded(
              child: MetricSelector.heatmap(
                selectedMetric: _selectedMetric,
                onMetricChanged: _onMetricChanged,
                primaryColor: widget.primaryColor,
                title: 'Metric',
              ),
            ),
        ],
      ),
      if (widget.showSector || widget.showMarketCap) ...[
        const SizedBox(height: 16),
        Row(
          children: [
            if (widget.showSector) ...[
              Expanded(
                child: SectorSelector.heatmap(
                  selectedSector: _selectedSector,
                  onSectorChanged: _onSectorChanged,
                  primaryColor: widget.primaryColor,
                  title: 'Sector',
                ),
              ),
              const SizedBox(width: 16),
            ],
            if (widget.showMarketCap)
              Expanded(
                child: MarketCapSelector.heatmap(
                  selectedMarketCap: _selectedMarketCap,
                  onMarketCapChanged: _onMarketCapChanged,
                  primaryColor: widget.primaryColor,
                  title: 'Market Cap',
                ),
              ),
          ],
        ),
      ],
    ],
  );

  Widget _buildExpandedResetButton(BuildContext context) => Align(
    alignment: Alignment.centerRight,
    child: OutlinedButton.icon(
      onPressed: _resetFilters,
      icon: const Icon(Icons.refresh, size: 16),
      label: const Text('Reset Filters'),
      style: OutlinedButton.styleFrom(
        foregroundColor: widget.primaryColor,
        side: BorderSide(
          color: (widget.primaryColor ?? Theme.of(context).primaryColor)
              .withOpacity(0.5),
        ),
      ),
    ),
  );

  // Additional pill and dropdown builders for other selectors
  Widget _buildMetricPills(BuildContext context) => Wrap(
    spacing: 6,
    children: MetricType.heatmapMetrics.map((metric) {
      final isSelected = _selectedMetric == metric;
      return InkWell(
        onTap: () => _onMetricChanged(metric),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? (widget.primaryColor ?? Theme.of(context).primaryColor)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? (widget.primaryColor ?? Theme.of(context).primaryColor)
                  : Colors.grey.shade400,
            ),
          ),
          child: Text(
            metric.shortName,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade700,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      );
    }).toList(),
  );

  Widget _buildSectorPills(BuildContext context) {
    final sectors = [
      SectorType.all,
      SectorType.technology,
      SectorType.healthcare,
      SectorType.finance,
    ];
    return Wrap(
      spacing: 6,
      children: sectors.map((sector) {
        final isSelected = _selectedSector == sector;
        return InkWell(
          onTap: () => _onSectorChanged(sector),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected
                  ? (widget.primaryColor ?? Theme.of(context).primaryColor)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? (widget.primaryColor ?? Theme.of(context).primaryColor)
                    : Colors.grey.shade400,
              ),
            ),
            child: Text(
              sector.displayName,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMarketCapPills(BuildContext context) {
    final marketCaps = [
      MarketCapType.all,
      MarketCapType.largeCap,
      MarketCapType.midCap,
      MarketCapType.smallCap,
    ];
    return Wrap(
      spacing: 6,
      children: marketCaps.map((marketCap) {
        final isSelected = _selectedMarketCap == marketCap;
        return InkWell(
          onTap: () => _onMarketCapChanged(marketCap),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected
                  ? (widget.primaryColor ?? Theme.of(context).primaryColor)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? (widget.primaryColor ?? Theme.of(context).primaryColor)
                    : Colors.grey.shade400,
              ),
            ),
            child: Text(
              marketCap.displayName,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimeFrameDropdown(BuildContext context) =>
      DropdownButtonFormField<TimeFrame>(
        value: _selectedTimeFrame,
        decoration: const InputDecoration(
          labelText: 'Time Frame',
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: OutlineInputBorder(),
        ),
        items:
            [
                  TimeFrame.oneDay,
                  TimeFrame.oneWeek,
                  TimeFrame.oneMonth,
                  TimeFrame.threeMonths,
                  TimeFrame.oneYear,
                ]
                .map(
                  (timeFrame) => DropdownMenuItem(
                    value: timeFrame,
                    child: Text(timeFrame.displayName),
                  ),
                )
                .toList(),
        onChanged: (value) {
          if (value != null) _onTimeFrameChanged(value);
        },
      );

  Widget _buildSectorDropdown(BuildContext context) =>
      DropdownButtonFormField<SectorType>(
        value: _selectedSector,
        decoration: const InputDecoration(
          labelText: 'Sector',
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: OutlineInputBorder(),
        ),
        items:
            [
                  SectorType.all,
                  SectorType.technology,
                  SectorType.healthcare,
                  SectorType.finance,
                ]
                .map(
                  (sector) => DropdownMenuItem(
                    value: sector,
                    child: Text(sector.displayName),
                  ),
                )
                .toList(),
        onChanged: (value) {
          if (value != null) _onSectorChanged(value);
        },
      );

  Widget _buildMarketCapDropdown(BuildContext context) =>
      DropdownButtonFormField<MarketCapType>(
        value: _selectedMarketCap,
        decoration: const InputDecoration(
          labelText: 'Market Cap',
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: OutlineInputBorder(),
        ),
        items:
            [
                  MarketCapType.all,
                  MarketCapType.largeCap,
                  MarketCapType.midCap,
                  MarketCapType.smallCap,
                ]
                .map(
                  (marketCap) => DropdownMenuItem(
                    value: marketCap,
                    child: Text(marketCap.displayName),
                  ),
                )
                .toList(),
        onChanged: (value) {
          if (value != null) _onMarketCapChanged(value);
        },
      );

  Widget _buildIconResetButton(BuildContext context) => IconButton(
    onPressed: _resetFilters,
    icon: const Icon(Icons.refresh),
    tooltip: 'Reset Filters',
    style: IconButton.styleFrom(
      foregroundColor: widget.primaryColor ?? Theme.of(context).primaryColor,
    ),
  );
}
