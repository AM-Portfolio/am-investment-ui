import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../selectors/selectors.dart';
import '../heatmap/configurable_heatmap_widget.dart';
import '../../models/investment/investment_types.dart';
import '../../models/heatmap/heatmap_ui_data.dart';
import '../../models/heatmap/heatmap_tile_data.dart';
import '../../../core/app_logic/domain/entities/heatmap/heatmap_entities.dart';

/// Main investment heatmap widget that handles different filter types
/// and maps them to appropriate configurations and displays
class InvestmentHeatmapWidget extends ConsumerStatefulWidget {
  /// The type of investment filter to display
  final InvestmentFilterType filterType;

  /// Input data for the heatmap
  final List<InvestmentInputData> inputData;

  /// Loading state
  final bool isLoading;

  /// Error message if any
  final String? error;

  /// Callback when heatmap tile is pressed
  final Function(InvestmentInputData)? onTilePressed;

  /// Callback when filters change
  final Function({
    InvestmentFilterType? filterType,
    TimeFrame? timeFrame,
    MetricType? metric,
    SectorType? sector,
    MarketCapType? marketCap,
  })?
  onFiltersChanged;

  /// Whether to use compact view
  final bool compact;

  /// Custom accent color
  final Color? accentColor;

  /// Additional filter options
  final Map<String, dynamic>? additionalFilters;

  const InvestmentHeatmapWidget({
    super.key,
    required this.filterType,
    required this.inputData,
    this.isLoading = false,
    this.error,
    this.onTilePressed,
    this.onFiltersChanged,
    this.compact = false,
    this.accentColor,
    this.additionalFilters,
  });

  @override
  ConsumerState<InvestmentHeatmapWidget> createState() =>
      _InvestmentHeatmapWidgetState();
}

class _InvestmentHeatmapWidgetState
    extends ConsumerState<InvestmentHeatmapWidget> {
  late InvestmentTypeConfig _config;
  late TimeFrame _selectedTimeFrame;
  late MetricType _selectedMetric;
  late SectorType _selectedSector;
  late MarketCapType _selectedMarketCap;

  @override
  void initState() {
    super.initState();
    _initializeConfiguration();
  }

  @override
  void didUpdateWidget(InvestmentHeatmapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filterType != widget.filterType ||
        oldWidget.compact != widget.compact) {
      _initializeConfiguration();
    }
  }

  void _initializeConfiguration() {
    _config = InvestmentTypeConfig.getConfig(
      widget.filterType,
      compactView: widget.compact,
      accentColor: widget.accentColor,
    );

    // Initialize selectors with defaults
    _selectedTimeFrame = _config.availableTimeFrames.first;
    _selectedMetric = _config.availableMetrics.first;
    _selectedSector = _config.availableSectors?.first ?? SectorType.all;
    _selectedMarketCap =
        _config.availableMarketCaps?.first ?? MarketCapType.all;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter type selector at the top
        _buildFilterTypeSelector(context),
        const SizedBox(height: 16),

        // Main heatmap content
        Expanded(
          child: ConfigurableHeatmapWidget(
            data: _buildHeatmapData(),
            isLoading: widget.isLoading,
            error: widget.error,
            showSelectors: _config.showSelectors,
            compact: _config.compactView,
            title: _config.title,
            onTilePressed: _handleTilePressed,
            onSelectorsChanged: _handleSelectorsChanged,
            initialTimeFrame: _selectedTimeFrame,
            initialMetric: _selectedMetric,
            initialSector: _selectedSector,
            initialMarketCap: _selectedMarketCap,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTypeSelector(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _config.icon,
                  color: _config.accentColor ?? Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Investment Type',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: InvestmentFilterType.values.map((type) {
                final isSelected = type == widget.filterType;
                final config = InvestmentTypeConfig.getConfig(type);

                return FilterChip(
                  selected: isSelected,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        config.icon,
                        size: 16,
                        color: isSelected ? Colors.white : config.accentColor,
                      ),
                      const SizedBox(width: 4),
                      Text(type.displayName),
                    ],
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      widget.onFiltersChanged?.call(filterType: type);
                    }
                  },
                  selectedColor: config.accentColor,
                  checkmarkColor: Colors.white,
                  backgroundColor: config.accentColor?.withOpacity(0.1),
                );
              }).toList(),
            ),
            if (widget.filterType.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                widget.filterType.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  HeatmapData? _buildHeatmapData() {
    if (widget.inputData.isEmpty) return null;

    // Convert input data to heatmap tiles
    final tiles = widget.inputData
        .map((input) => input.toHeatmapTile())
        .toList();

    // Apply current filters and sorting
    final filteredTiles = _applyFilters(tiles);
    final sortedTiles = _applySorting(filteredTiles);

    return HeatmapData(
      id: '${widget.filterType.name}-heatmap',
      title: _config.title,
      subtitle: '${sortedTiles.length} ${_getSubtitleText()}',
      tiles: sortedTiles,
      metadata: HeatmapMetadata(
        lastUpdated: DateTime.now(),
        dataSource: widget.filterType.name,
        additionalInfo: {
          'filterType': widget.filterType.name,
          'timeFrame': _selectedTimeFrame.name,
          'metric': _selectedMetric.name,
          'sector': _selectedSector.name,
          'marketCap': _selectedMarketCap.name,
          ...?widget.additionalFilters,
        },
      ),
      configuration: HeatmapConfiguration.fromEntity(
        _config.heatmapConfig,
        showSubCards: !_config.compactView,
        tileMargin: _config.compactView
            ? const EdgeInsets.all(1)
            : const EdgeInsets.all(2),
        tilePadding: _config.compactView
            ? const EdgeInsets.all(4)
            : const EdgeInsets.all(8),
      ),
    );
  }

  List<HeatmapTileData> _applyFilters(List<HeatmapTileData> tiles) {
    var filtered = tiles;

    // Apply sector filter if applicable
    if (_selectedSector != SectorType.all &&
        _config.availableSectors != null &&
        _config.availableSectors!.contains(_selectedSector)) {
      filtered = filtered.where((tile) {
        final sector = tile.metadata['sector'] as String?;
        return sector != null &&
            sector.toLowerCase().contains(_selectedSector.name.toLowerCase());
      }).toList();
    }

    // Apply market cap filter if applicable
    if (_selectedMarketCap != MarketCapType.all &&
        _config.availableMarketCaps != null &&
        _config.availableMarketCaps!.contains(_selectedMarketCap)) {
      filtered = filtered.where((tile) {
        final marketCapStr = tile.metadata['marketCap'] as String?;
        if (marketCapStr == null) return false;

        // Simple market cap filtering logic - can be enhanced
        switch (_selectedMarketCap) {
          case MarketCapType.largeCap:
            return marketCapStr.toLowerCase().contains('large');
          case MarketCapType.midCap:
            return marketCapStr.toLowerCase().contains('mid');
          case MarketCapType.smallCap:
            return marketCapStr.toLowerCase().contains('small');
          default:
            return true;
        }
      }).toList();
    }

    return filtered;
  }

  List<HeatmapTileData> _applySorting(List<HeatmapTileData> tiles) {
    final sorted = List<HeatmapTileData>.from(tiles);

    switch (_config.heatmapConfig.defaultSorting) {
      case HeatmapSortingType.performance:
        sorted.sort((a, b) => b.performance.compareTo(a.performance));
        break;
      case HeatmapSortingType.weightage:
        sorted.sort((a, b) => b.weightage.compareTo(a.weightage));
        break;
      case HeatmapSortingType.value:
        sorted.sort((a, b) => (b.value ?? 0).compareTo(a.value ?? 0));
        break;
      case HeatmapSortingType.name:
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
      case HeatmapSortingType.custom:
        // Keep original order or implement custom logic
        break;
    }

    return sorted;
  }

  String _getSubtitleText() {
    switch (widget.filterType) {
      case InvestmentFilterType.portfolio:
        return 'holdings';
      case InvestmentFilterType.index:
        return 'indices';
      case InvestmentFilterType.mutualFunds:
        return 'funds';
      case InvestmentFilterType.etf:
        return 'ETFs';
      case InvestmentFilterType.stocks:
        return 'stocks';
      case InvestmentFilterType.sectors:
        return 'sectors';
    }
  }

  void _handleTilePressed() {
    // Find the pressed tile and call the callback
    // This is a simplified implementation - in real usage, you'd need to
    // identify which specific tile was pressed
    if (widget.inputData.isNotEmpty) {
      widget.onTilePressed?.call(widget.inputData.first);
    }
  }

  void _handleSelectorsChanged({
    TimeFrame? timeFrame,
    MetricType? metric,
    SectorType? sector,
    MarketCapType? marketCap,
  }) {
    setState(() {
      if (timeFrame != null) _selectedTimeFrame = timeFrame;
      if (metric != null) _selectedMetric = metric;
      if (sector != null) _selectedSector = sector;
      if (marketCap != null) _selectedMarketCap = marketCap;
    });

    widget.onFiltersChanged?.call(
      filterType: widget.filterType,
      timeFrame: timeFrame,
      metric: metric,
      sector: sector,
      marketCap: marketCap,
    );
  }
}

/// Extension methods for easy usage
extension InvestmentHeatmapExtensions on InvestmentHeatmapWidget {
  /// Create a portfolio heatmap
  static InvestmentHeatmapWidget portfolio({
    Key? key,
    required List<PortfolioInputData> portfolioData,
    bool isLoading = false,
    String? error,
    Function(InvestmentInputData)? onTilePressed,
    Function({
      InvestmentFilterType? filterType,
      TimeFrame? timeFrame,
      MetricType? metric,
      SectorType? sector,
      MarketCapType? marketCap,
    })?
    onFiltersChanged,
    bool compact = false,
    Color? accentColor,
  }) {
    return InvestmentHeatmapWidget(
      key: key,
      filterType: InvestmentFilterType.portfolio,
      inputData: portfolioData,
      isLoading: isLoading,
      error: error,
      onTilePressed: onTilePressed,
      onFiltersChanged: onFiltersChanged,
      compact: compact,
      accentColor: accentColor,
    );
  }

  /// Create a mutual funds heatmap
  static InvestmentHeatmapWidget mutualFunds({
    Key? key,
    required List<MutualFundInputData> fundData,
    bool isLoading = false,
    String? error,
    Function(InvestmentInputData)? onTilePressed,
    Function({
      InvestmentFilterType? filterType,
      TimeFrame? timeFrame,
      MetricType? metric,
      SectorType? sector,
      MarketCapType? marketCap,
    })?
    onFiltersChanged,
    bool compact = false,
    Color? accentColor,
  }) {
    return InvestmentHeatmapWidget(
      key: key,
      filterType: InvestmentFilterType.mutualFunds,
      inputData: fundData,
      isLoading: isLoading,
      error: error,
      onTilePressed: onTilePressed,
      onFiltersChanged: onFiltersChanged,
      compact: compact,
      accentColor: accentColor,
    );
  }

  /// Create an ETF heatmap
  static InvestmentHeatmapWidget etf({
    Key? key,
    required List<EtfInputData> etfData,
    bool isLoading = false,
    String? error,
    Function(InvestmentInputData)? onTilePressed,
    Function({
      InvestmentFilterType? filterType,
      TimeFrame? timeFrame,
      MetricType? metric,
      SectorType? sector,
      MarketCapType? marketCap,
    })?
    onFiltersChanged,
    bool compact = false,
    Color? accentColor,
  }) {
    return InvestmentHeatmapWidget(
      key: key,
      filterType: InvestmentFilterType.etf,
      inputData: etfData,
      isLoading: isLoading,
      error: error,
      onTilePressed: onTilePressed,
      onFiltersChanged: onFiltersChanged,
      compact: compact,
      accentColor: accentColor,
    );
  }
}
