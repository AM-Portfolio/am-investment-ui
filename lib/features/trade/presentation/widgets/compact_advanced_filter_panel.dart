import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../internal/domain/entities/metrics_filter_config.dart';
import 'filters/date_range_filter_group.dart';
import 'filters/filter_group.dart';
import 'filters/filter_group_card.dart';
import 'filters/instrument_filter_group.dart';
import 'filters/profit_loss_filter_group.dart';
import 'filters/trade_characteristics_filter_group.dart';

enum FilterGroupType { dateRange, instrument, tradeCharacteristics, profitLoss }

/// Modern Compact Advanced Filter Panel with smooth animations
class CompactAdvancedFilterPanel extends ConsumerStatefulWidget {
  const CompactAdvancedFilterPanel({required this.initialConfig, required this.onApplyFilter, super.key, this.onReset});
  final MetricsFilterConfig initialConfig;
  final Function(MetricsFilterConfig) onApplyFilter;
  final VoidCallback? onReset;

  @override
  ConsumerState<CompactAdvancedFilterPanel> createState() => _CompactAdvancedFilterPanelState();
}

class _CompactAdvancedFilterPanelState extends ConsumerState<CompactAdvancedFilterPanel> with SingleTickerProviderStateMixin {
  final List<FilterGroup> _activeGroups = [];
  bool _isExpanded = true;
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    if (_isExpanded) _animationController.forward();
    _initializeFromConfig();
  }

  void _initializeFromConfig() {
    final config = widget.initialConfig;

    // Only add groups that have data in the initial config
    if (config.dateRange != null) {
      _activeGroups.add(
        DateRangeFilterGroup(
          startDate: config.dateRange!.startDate,
          endDate: config.dateRange!.endDate,
          onChanged: (start, end) => setState(() {}),
        ),
      );
    }

    if (config.instrumentFilters != null && _hasInstrumentFilters(config.instrumentFilters)) {
      final group = InstrumentFilterGroup(onChanged: () => setState(() {}));
      group.selectedSegments = List.from(config.instrumentFilters!.marketSegments);
      group.selectedIndexTypes = List.from(config.instrumentFilters!.indexTypes);
      group.selectedDerivativeTypes = List.from(config.instrumentFilters!.derivativeTypes);
      group.symbolsController.text = config.instrumentFilters!.baseSymbols.join(', ');
      _activeGroups.add(group);
    }

    if (config.tradeCharacteristics != null && _hasTradeCharacteristics(config.tradeCharacteristics)) {
      final group = TradeCharacteristicsFilterGroup(onChanged: () => setState(() {}));
      group.selectedDirections = List.from(config.tradeCharacteristics!.directions);
      group.selectedStatuses = List.from(config.tradeCharacteristics!.statuses);
      group.strategiesController.text = config.tradeCharacteristics!.strategies.join(', ');
      group.tagsController.text = config.tradeCharacteristics!.tags.join(', ');
      if (config.tradeCharacteristics!.minHoldingTimeHours != null) {
        group.minHoldingHoursController.text = config.tradeCharacteristics!.minHoldingTimeHours.toString();
      }
      if (config.tradeCharacteristics!.maxHoldingTimeHours != null) {
        group.maxHoldingHoursController.text = config.tradeCharacteristics!.maxHoldingTimeHours.toString();
      }
      _activeGroups.add(group);
    }

    if (config.profitLossFilters != null && _hasProfitLossFilters(config.profitLossFilters)) {
      final group = ProfitLossFilterGroup(onChanged: () => setState(() {}));
      if (config.profitLossFilters!.minProfitLoss != null) {
        group.minPnLController.text = config.profitLossFilters!.minProfitLoss.toString();
      }
      if (config.profitLossFilters!.maxProfitLoss != null) {
        group.maxPnLController.text = config.profitLossFilters!.maxProfitLoss.toString();
      }
      if (config.profitLossFilters!.minPositionSize != null) {
        group.minPositionSizeController.text = config.profitLossFilters!.minPositionSize.toString();
      }
      if (config.profitLossFilters!.maxPositionSize != null) {
        group.maxPositionSizeController.text = config.profitLossFilters!.maxPositionSize.toString();
      }
      _activeGroups.add(group);
    }
  }

  bool _hasInstrumentFilters(filter) =>
      filter.marketSegments.isNotEmpty ||
      filter.indexTypes.isNotEmpty ||
      filter.derivativeTypes.isNotEmpty ||
      filter.baseSymbols.isNotEmpty;

  bool _hasTradeCharacteristics(filter) =>
      filter.directions.isNotEmpty ||
      filter.statuses.isNotEmpty ||
      filter.strategies.isNotEmpty ||
      filter.tags.isNotEmpty ||
      filter.minHoldingTimeHours != null ||
      filter.maxHoldingTimeHours != null;

  bool _hasProfitLossFilters(filter) =>
      filter.minProfitLoss != null ||
      filter.maxProfitLoss != null ||
      filter.minPositionSize != null ||
      filter.maxPositionSize != null;

  @override
  void dispose() {
    for (final group in _activeGroups) {
      if (group is InstrumentFilterGroup) {
        group.dispose();
      } else if (group is TradeCharacteristicsFilterGroup) {
        group.dispose();
      } else if (group is ProfitLossFilterGroup) {
        group.dispose();
      }
    }
    super.dispose();
  }

  void _addFilterGroup(FilterGroupType type) {
    setState(() {
      switch (type) {
        case FilterGroupType.dateRange:
          if (!_activeGroups.any((g) => g is DateRangeFilterGroup)) {
            _activeGroups.add(DateRangeFilterGroup(onChanged: (start, end) => setState(() {})));
          }
          break;
        case FilterGroupType.instrument:
          if (!_activeGroups.any((g) => g is InstrumentFilterGroup)) {
            _activeGroups.add(InstrumentFilterGroup(onChanged: () => setState(() {})));
          }
          break;
        case FilterGroupType.tradeCharacteristics:
          if (!_activeGroups.any((g) => g is TradeCharacteristicsFilterGroup)) {
            _activeGroups.add(TradeCharacteristicsFilterGroup(onChanged: () => setState(() {})));
          }
          break;
        case FilterGroupType.profitLoss:
          if (!_activeGroups.any((g) => g is ProfitLossFilterGroup)) {
            _activeGroups.add(ProfitLossFilterGroup(onChanged: () => setState(() {})));
          }
          break;
      }
    });
  }

  void _removeFilterGroup(int index) {
    setState(() {
      final group = _activeGroups[index];
      if (group is InstrumentFilterGroup) {
        group.dispose();
      } else if (group is TradeCharacteristicsFilterGroup) {
        group.dispose();
      } else if (group is ProfitLossFilterGroup) {
        group.dispose();
      }
      _activeGroups.removeAt(index);
    });
  }

  void _applyFilters() {
    final config = MetricsFilterConfig(
      dateRange: _activeGroups.whereType<DateRangeFilterGroup>().firstOrNull?.toFilterCriteria(),
      instrumentFilters: _activeGroups.whereType<InstrumentFilterGroup>().firstOrNull?.toFilterCriteria(),
      tradeCharacteristics: _activeGroups.whereType<TradeCharacteristicsFilterGroup>().firstOrNull?.toFilterCriteria(),
      profitLossFilters: _activeGroups.whereType<ProfitLossFilterGroup>().firstOrNull?.toFilterCriteria(),
    );

    widget.onApplyFilter(config);
  }

  void _resetAllFilters() {
    setState(() {
      for (final group in _activeGroups) {
        group.reset();
      }
      _activeGroups.clear();
    });
    widget.onReset?.call();
  }

  int get _activeFilterCount => _activeGroups.where((g) => g.hasActiveFilters).length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.tune, color: theme.primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Advanced Filters',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (_activeFilterCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$_activeFilterCount active',
                        style: TextStyle(fontSize: 12, color: theme.primaryColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),

          // Filter Groups and Actions
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Add Filter Group Button
                  _buildAddFilterButton(),
                  const SizedBox(height: 12),

                  // Active Filter Groups
                  if (_activeGroups.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          children: [
                            Icon(Icons.filter_alt_outlined, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text(
                              'No filter groups added',
                              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Click "Add Filter Group" to start',
                              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _activeGroups.length,
                      itemBuilder: (context, index) =>
                          FilterGroupCard(filterGroup: _activeGroups[index], onRemove: () => _removeFilterGroup(index)),
                    ),

                  // Action Buttons
                  if (_activeGroups.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _resetAllFilters,
                            icon: const Icon(Icons.clear_all, size: 18),
                            label: const Text('Reset All'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: _applyFilters,
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('Apply Filters'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddFilterButton() => PopupMenuButton<FilterGroupType>(
    itemBuilder: (context) => [
      if (!_activeGroups.any((g) => g is DateRangeFilterGroup))
        const PopupMenuItem(
          value: FilterGroupType.dateRange,
          child: Row(children: [Icon(Icons.date_range, size: 18), SizedBox(width: 8), Text('Date Range')]),
        ),
      if (!_activeGroups.any((g) => g is InstrumentFilterGroup))
        const PopupMenuItem(
          value: FilterGroupType.instrument,
          child: Row(children: [Icon(Icons.analytics_outlined, size: 18), SizedBox(width: 8), Text('Instrument')]),
        ),
      if (!_activeGroups.any((g) => g is TradeCharacteristicsFilterGroup))
        const PopupMenuItem(
          value: FilterGroupType.tradeCharacteristics,
          child: Row(children: [Icon(Icons.trending_up, size: 18), SizedBox(width: 8), Text('Trade Characteristics')]),
        ),
      if (!_activeGroups.any((g) => g is ProfitLossFilterGroup))
        const PopupMenuItem(
          value: FilterGroupType.profitLoss,
          child: Row(
            children: [Icon(Icons.attach_money, size: 18), SizedBox(width: 8), Text('Profit/Loss & Position')],
          ),
        ),
    ],
    onSelected: _addFilterGroup,
    child: OutlinedButton.icon(
      onPressed: null,
      icon: const Icon(Icons.add, size: 18),
      label: const Text('Add Filter Group'),
    ),
  );
}
