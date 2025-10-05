import 'package:flutter/material.dart';

import '../../../core/utils/logger.dart';
import '../../core/ui/components.dart';
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
    this.initialLayout,
    this.onTimeFrameChanged,
    this.onMetricChanged,
    this.onSectorChanged,
    this.onMarketCapChanged,
    this.onLayoutChanged,
    this.onFiltersChanged,
    this.showTimeFrame = true,
    this.showMetric = true,
    this.showSector = true,
    this.showMarketCap = true,
    this.showLayout = false,
    this.layout = SelectorLayoutType.compact,
    this.primaryColor,
    this.title,
    this.showResetButton = true,
    this.availableTimeFrames,
    this.availableMetrics,
    this.availableSectors,
    this.availableMarketCaps,
    this.availableLayouts,
  });

  final TimeFrame? initialTimeFrame;
  final MetricType? initialMetric;
  final SectorType? initialSector;
  final MarketCapType? initialMarketCap;
  final HeatmapLayoutType? initialLayout;

  final ValueChanged<TimeFrame>? onTimeFrameChanged;
  final ValueChanged<MetricType>? onMetricChanged;
  final ValueChanged<SectorType>? onSectorChanged;
  final ValueChanged<MarketCapType>? onMarketCapChanged;
  final ValueChanged<HeatmapLayoutType>? onLayoutChanged;

  /// Combined callback for all filter changes
  final Function({
    TimeFrame? timeFrame,
    MetricType? metric,
    SectorType? sector,
    MarketCapType? marketCap,
    HeatmapLayoutType? layout,
  })?
  onFiltersChanged;

  final bool showTimeFrame;
  final bool showMetric;
  final bool showSector;
  final bool showMarketCap;
  final bool showLayout;
  final SelectorLayoutType layout;
  final Color? primaryColor;
  final String? title;
  final bool showResetButton;

  // Available options from configuration
  final List<TimeFrame>? availableTimeFrames;
  final List<MetricType>? availableMetrics;
  final List<SectorType>? availableSectors;
  final List<MarketCapType>? availableMarketCaps;
  final List<HeatmapLayoutType>? availableLayouts;

  @override
  State<HeatmapSelectorTemplate> createState() =>
      _HeatmapSelectorTemplateState();
}

class _HeatmapSelectorTemplateState extends State<HeatmapSelectorTemplate> {
  late TimeFrame _selectedTimeFrame;
  late MetricType _selectedMetric;
  late SectorType _selectedSector;
  late MarketCapType _selectedMarketCap;
  late HeatmapLayoutType _selectedLayout;

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
    _selectedLayout = widget.initialLayout ?? HeatmapLayoutType.treemap;
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

  void _onLayoutChanged(HeatmapLayoutType layout) {
    setState(() {
      _selectedLayout = layout;
    });

    AppLogger.debug(
      'Selector layout changed: ${layout.displayName}',
      tag: 'Heatmap.Selector',
    );

    widget.onLayoutChanged?.call(layout);
    _notifyFiltersChanged();
  }

  void _resetFilters() {
    setState(() {
      _selectedTimeFrame = TimeFrame.oneMonth;
      _selectedMetric = MetricType.changePercent;
      _selectedSector = SectorType.all;
      _selectedMarketCap = MarketCapType.all;
      _selectedLayout = HeatmapLayoutType.treemap;
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
      layout: _selectedLayout,
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
        if (widget.showSector) ...[
          Expanded(flex: 2, child: _buildSectorDropdown(context)),
          const SizedBox(width: 12),
        ],
        if (widget.showMarketCap) ...[
          Expanded(flex: 2, child: _buildMarketCapDropdown(context)),
          const SizedBox(width: 12),
        ],
        if (widget.showLayout) ...[
          Expanded(flex: 2, child: _buildLayoutDropdown(context)),
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
    child: SelectorContainerConfigs.responsiveGrid(
      children: [
        if (widget.showTimeFrame) _buildTimeFramePills(context),
        if (widget.showMetric) _buildMetricPills(context),
        if (widget.showSector) _buildSectorPills(context),
        if (widget.showMarketCap) _buildMarketCapPills(context),
        if (widget.showLayout) _buildLayoutPills(context),
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
        if (widget.showLayout) ...[
          Expanded(child: _buildLayoutDropdown(context)),
          const SizedBox(width: 8),
        ],
        if (widget.showResetButton) _buildIconResetButton(context),
      ],
    ),
  );

  Widget _buildTimeFramePills(BuildContext context) {
    final timeFrames =
        widget.availableTimeFrames ??
        [
          TimeFrame.oneDay,
          TimeFrame.oneWeek,
          TimeFrame.oneMonth,
          TimeFrame.threeMonths,
          TimeFrame.oneYear,
        ];

    return PillSelector<TimeFrame>(
      items: timeFrames,
      selectedItem: _selectedTimeFrame,
      onSelectionChanged: _onTimeFrameChanged,
      itemDisplayText: (timeFrame) => timeFrame.displayName,
      primaryColor: widget.primaryColor,
      scrollable: true,
    );
  }

  Widget _buildMetricDropdown(BuildContext context) =>
      CustomDropdown<MetricType>(
        value: _selectedMetric,
        primaryColor: widget.primaryColor,
        hint: 'Metric',
        items: (widget.availableMetrics ?? MetricType.heatmapMetrics)
            .map(
              (metric) => metric.toDropdownItem(
                text: metric.shortName,
                icon: metric.icon,
                iconColor:
                    (widget.primaryColor ?? Theme.of(context).primaryColor)
                        .withOpacity(0.7),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) _onMetricChanged(value);
        },
      );

  Widget _buildResetButton(BuildContext context) => ResetButton(
    onPressed: _resetFilters,
    style: ResetButtonStyle.compact,
    primaryColor: widget.primaryColor,
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
    child: ResetButton(
      onPressed: _resetFilters,
      style: ResetButtonStyle.outlined,
      primaryColor: widget.primaryColor,
    ),
  );

  // Additional pill and dropdown builders for other selectors
  Widget _buildMetricPills(BuildContext context) {
    final metrics = widget.availableMetrics ?? MetricType.heatmapMetrics;
    return PillSelector<MetricType>(
      items: metrics,
      selectedItem: _selectedMetric,
      onSelectionChanged: _onMetricChanged,
      itemDisplayText: (metric) => metric.shortName,
      primaryColor: widget.primaryColor,
    );
  }

  Widget _buildSectorPills(BuildContext context) {
    final sectors =
        widget.availableSectors ??
        [
          SectorType.all,
          SectorType.technology,
          SectorType.healthcare,
          SectorType.finance,
        ];
    return PillSelector<SectorType>(
      items: sectors,
      selectedItem: _selectedSector,
      onSelectionChanged: _onSectorChanged,
      itemDisplayText: (sector) => sector.displayName,
      primaryColor: widget.primaryColor,
    );
  }

  Widget _buildMarketCapPills(BuildContext context) {
    final marketCaps =
        widget.availableMarketCaps ??
        [
          MarketCapType.all,
          MarketCapType.largeCap,
          MarketCapType.midCap,
          MarketCapType.smallCap,
        ];
    return PillSelector<MarketCapType>(
      items: marketCaps,
      selectedItem: _selectedMarketCap,
      onSelectionChanged: _onMarketCapChanged,
      itemDisplayText: (marketCap) => marketCap.displayName,
      primaryColor: widget.primaryColor,
    );
  }

  Widget _buildLayoutPills(BuildContext context) {
    final layouts =
        widget.availableLayouts ??
        [
          HeatmapLayoutType.treemap,
          HeatmapLayoutType.grid,
          HeatmapLayoutType.list,
        ];
    return PillSelector<HeatmapLayoutType>(
      items: layouts,
      selectedItem: _selectedLayout,
      onSelectionChanged: _onLayoutChanged,
      itemDisplayText: (layout) => layout.displayName,
      itemIcon: (layout) => layout.icon,
      primaryColor: widget.primaryColor,
    );
  }

  Widget _buildTimeFrameDropdown(
    BuildContext context,
  ) => CustomDropdown<TimeFrame>(
    value: _selectedTimeFrame,
    primaryColor: widget.primaryColor,
    hint: 'Time Frame',
    items:
        (widget.availableTimeFrames ??
                [
                  TimeFrame.oneDay,
                  TimeFrame.oneWeek,
                  TimeFrame.oneMonth,
                  TimeFrame.threeMonths,
                  TimeFrame.oneYear,
                ])
            .map(
              (timeFrame) =>
                  timeFrame.toSimpleDropdownItem(text: timeFrame.displayName),
            )
            .toList(),
    onChanged: (value) {
      if (value != null) _onTimeFrameChanged(value);
    },
  );

  Widget _buildSectorDropdown(BuildContext context) =>
      CustomDropdown<SectorType>(
        value: _selectedSector,
        primaryColor: widget.primaryColor,
        hint: 'Sector',
        items:
            (widget.availableSectors ??
                    [
                      SectorType.all,
                      SectorType.technology,
                      SectorType.healthcare,
                      SectorType.finance,
                    ])
                .map(
                  (sector) => sector.toDropdownItem(
                    text: sector.shortName,
                    icon: sector.icon,
                    iconColor:
                        (widget.primaryColor ?? Theme.of(context).primaryColor)
                            .withOpacity(0.7),
                  ),
                )
                .toList(),
        onChanged: (value) {
          if (value != null) _onSectorChanged(value);
        },
      );

  Widget _buildMarketCapDropdown(BuildContext context) =>
      CustomDropdown<MarketCapType>(
        value: _selectedMarketCap,
        primaryColor: widget.primaryColor,
        hint: 'Market Cap',
        items:
            (widget.availableMarketCaps ??
                    [
                      MarketCapType.all,
                      MarketCapType.largeCap,
                      MarketCapType.midCap,
                      MarketCapType.smallCap,
                    ])
                .map(
                  (marketCap) => marketCap.toDropdownItem(
                    text: marketCap.shortName,
                    icon: marketCap.icon,
                    iconColor:
                        (widget.primaryColor ?? Theme.of(context).primaryColor)
                            .withOpacity(0.7),
                  ),
                )
                .toList(),
        onChanged: (value) {
          if (value != null) _onMarketCapChanged(value);
        },
      );

  Widget _buildIconResetButton(BuildContext context) =>
      ResetButton(onPressed: _resetFilters, primaryColor: widget.primaryColor);

  Widget _buildLayoutDropdown(BuildContext context) =>
      CustomDropdown<HeatmapLayoutType>(
        value: _selectedLayout,
        primaryColor: widget.primaryColor,
        hint: 'Layout',
        items:
            (widget.availableLayouts ??
                    [
                      HeatmapLayoutType.treemap,
                      HeatmapLayoutType.grid,
                      HeatmapLayoutType.list,
                    ])
                .map(
                  (layout) => layout.toDropdownItem(
                    text: layout.displayName,
                    icon: layout.icon,
                    iconColor: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.8),
                  ),
                )
                .toList(),
        onChanged: (value) {
          if (value != null) _onLayoutChanged(value);
        },
      );
}
