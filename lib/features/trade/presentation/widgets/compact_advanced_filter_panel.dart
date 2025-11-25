import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../favorite_filter_providers.dart';
import '../../internal/domain/entities/favorite_filter.dart';
import '../../internal/domain/entities/metrics_filter_config.dart';
import '../cubits/favorite_filter/favorite_filter_cubit.dart';
import 'filters/date_range_filter_group.dart';
import 'filters/filter_group.dart';
import 'filters/filter_group_card.dart';
import 'filters/instrument_filter_group.dart';
import 'filters/profit_loss_filter_group.dart';
import 'filters/trade_characteristics_filter_group.dart';

enum FilterGroupType { dateRange, instrument, tradeCharacteristics, profitLoss }

/// Modern Compact Advanced Filter Panel with smooth animations
class CompactAdvancedFilterPanel extends ConsumerStatefulWidget {
  const CompactAdvancedFilterPanel({
    required this.initialConfig,
    required this.onApplyFilter,
    super.key,
    this.onReset,
    this.userId,
  });
  final MetricsFilterConfig initialConfig;
  final Function(MetricsFilterConfig) onApplyFilter;
  final VoidCallback? onReset;
  final String? userId;

  @override
  ConsumerState<CompactAdvancedFilterPanel> createState() => _CompactAdvancedFilterPanelState();
}

class _CompactAdvancedFilterPanelState extends ConsumerState<CompactAdvancedFilterPanel>
    with SingleTickerProviderStateMixin {
  final List<FilterGroup> _activeGroups = [];
  bool _isExpanded = false; // Start collapsed
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _initializeFromConfig();
    // Expand if there are active groups
    if (_activeGroups.isNotEmpty) {
      _isExpanded = true;
      _animationController.forward();
    }

    // Load favorite filters when userId is provided
    if (widget.userId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(favoriteFilterCubitProvider).loadFilters(widget.userId!);
      });
    }
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
    _animationController.dispose();
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

      // Auto-expand the panel when a filter group is added
      if (!_isExpanded) {
        _isExpanded = true;
        _animationController.forward();
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

  Future<void> _saveAsFavorite() async {
    if (widget.userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot save filter: User not logged in'), duration: Duration(seconds: 2)),
        );
      }
      return;
    }

    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Filter as Favorite'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Filter Name *',
                hintText: 'e.g., High Profit Trades',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Add details about this filter',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a filter name')));
                return;
              }
              Navigator.of(context).pop(true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.trim().isNotEmpty) {
      final config = MetricsFilterConfig(
        dateRange: _activeGroups.whereType<DateRangeFilterGroup>().firstOrNull?.toFilterCriteria(),
        instrumentFilters: _activeGroups.whereType<InstrumentFilterGroup>().firstOrNull?.toFilterCriteria(),
        tradeCharacteristics: _activeGroups
            .whereType<TradeCharacteristicsFilterGroup>()
            .firstOrNull
            ?.toFilterCriteria(),
        profitLossFilters: _activeGroups.whereType<ProfitLossFilterGroup>().firstOrNull?.toFilterCriteria(),
      );

      try {
        final cubit = ref.read(favoriteFilterCubitProvider);
        await cubit.createFilter(
          userId: widget.userId!,
          name: nameController.text.trim(),
          filterConfig: config,
          description: descriptionController.text.trim().isNotEmpty ? descriptionController.text.trim() : null,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Filter "${nameController.text.trim()}" saved successfully'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to save filter: $e'), duration: const Duration(seconds: 3)));
        }
      }
    }

    nameController.dispose();
    descriptionController.dispose();
  }

  int get _activeFilterCount => _activeGroups.where((g) => g.hasActiveFilters).length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Modern Compact Header
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() => _isExpanded = !_isExpanded);
                _isExpanded ? _animationController.forward() : _animationController.reverse();
              },
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.primaryColor.withOpacity(0.05), theme.primaryColor.withOpacity(0.02)],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    // Left Section: Icon + Title + Stats
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.tune_rounded, color: theme.primaryColor, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Filters',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                letterSpacing: 0.2,
                              ),
                            ),
                            if (_activeGroups.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$_activeFilterCount active',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: theme.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (_activeGroups.isNotEmpty)
                          Text(
                            '${_activeGroups.length} group${_activeGroups.length > 1 ? 's' : ''}',
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor, fontSize: 11),
                          ),
                      ],
                    ),
                    const Spacer(),

                    // Right Section: Action Buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Favorite Filters Dropdown
                        if (widget.userId != null) ...[
                          _buildFavoriteFiltersDropdown(theme),
                          Container(
                            height: 24,
                            width: 1,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            color: theme.dividerColor.withOpacity(0.3),
                          ),
                        ],

                        // Add Filter Group Button
                        PopupMenuButton<FilterGroupType>(
                          itemBuilder: (context) => [
                            if (!_activeGroups.any((g) => g is DateRangeFilterGroup))
                              PopupMenuItem(
                                value: FilterGroupType.dateRange,
                                child: _buildMenuTile(Icons.date_range_rounded, 'Date Range', theme),
                              ),
                            if (!_activeGroups.any((g) => g is InstrumentFilterGroup))
                              PopupMenuItem(
                                value: FilterGroupType.instrument,
                                child: _buildMenuTile(Icons.candlestick_chart_rounded, 'Instruments', theme),
                              ),
                            if (!_activeGroups.any((g) => g is TradeCharacteristicsFilterGroup))
                              PopupMenuItem(
                                value: FilterGroupType.tradeCharacteristics,
                                child: _buildMenuTile(Icons.insights_rounded, 'Trade Characteristics', theme),
                              ),
                            if (!_activeGroups.any((g) => g is ProfitLossFilterGroup))
                              PopupMenuItem(
                                value: FilterGroupType.profitLoss,
                                child: _buildMenuTile(Icons.account_balance_wallet_rounded, 'Profit & Loss', theme),
                              ),
                          ],
                          onSelected: _addFilterGroup,
                          offset: const Offset(0, 40),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          tooltip: 'Add Filter Group',
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add_circle_outline_rounded, size: 16, color: theme.primaryColor),
                                const SizedBox(width: 6),
                                Text(
                                  'Add',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: theme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (_activeGroups.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          // Save as Favorite Button
                          if (widget.userId != null && _activeFilterCount > 0)
                            Tooltip(
                              message: 'Save as favorite',
                              child: InkWell(
                                onTap: _saveAsFavorite,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.amber.withOpacity(0.3)),
                                  ),
                                  child: Icon(Icons.bookmark_add_outlined, size: 18, color: Colors.amber[700]),
                                ),
                              ),
                            ),
                          const SizedBox(width: 8),
                          // Reset Button
                          Tooltip(
                            message: 'Reset all filters',
                            child: InkWell(
                              onTap: _resetAllFilters,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: theme.colorScheme.error.withOpacity(0.3)),
                                ),
                                child: Icon(Icons.refresh_rounded, size: 18, color: theme.colorScheme.error),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Apply Button
                          FilledButton.icon(
                            onPressed: _applyFilters,
                            icon: const Icon(Icons.check_rounded, size: 16),
                            label: const Text('Apply'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              minimumSize: const Size(0, 32),
                              visualDensity: VisualDensity.compact,
                              textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],

                        const SizedBox(width: 8),
                        // Expand/Collapse Indicator
                        RotationTransition(
                          turns: _rotationAnimation,
                          child: Icon(Icons.expand_more_rounded, size: 20, color: theme.hintColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Animated Content
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _isExpanded
                ? Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_activeGroups.isEmpty)
                          _buildEmptyState(theme)
                        else
                          // Filter Groups in Single Row Layout for Web
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isMobile = constraints.maxWidth < 800;

                              if (isMobile) {
                                // Mobile: Stack vertically
                                return Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _activeGroups.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final group = entry.value;
                                    return SizedBox(
                                      width: constraints.maxWidth,
                                      child: AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 200),
                                        child: FilterGroupCard(
                                          key: ValueKey(group),
                                          filterGroup: group,
                                          onRemove: () => _removeFilterGroup(index),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              } else {
                                // Web: Single row with equal widths
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _activeGroups.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final group = entry.value;
                                    return Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(left: index > 0 ? 6 : 0),
                                        child: AnimatedSwitcher(
                                          duration: const Duration(milliseconds: 200),
                                          child: FilterGroupCard(
                                            key: ValueKey(group),
                                            filterGroup: group,
                                            onRemove: () => _removeFilterGroup(index),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              }
                            },
                          ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteFiltersDropdown(ThemeData theme) => BlocBuilder<FavoriteFilterCubit, FavoriteFilterState>(
    builder: (context, state) => state.when(
      initial: () => const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
      loaded: (filterList, selectedFilter) {
        if (filterList.filters.isEmpty) {
          return const SizedBox.shrink();
        }

        return PopupMenuButton<String>(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.bookmark_rounded, color: theme.primaryColor, size: 20),
              if (selectedFilter != null)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.scaffoldBackgroundColor, width: 1.5),
                    ),
                    child: const Icon(Icons.check, size: 8, color: Colors.white),
                  ),
                ),
            ],
          ),
          tooltip: 'Favorite Filters',
          itemBuilder: (context) => [
            // Header
            PopupMenuItem<String>(
              enabled: false,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.bookmark_rounded, size: 18, color: theme.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Favorite Filters',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor),
                  ),
                  const Spacer(),
                  Text(
                    '${filterList.filters.length}',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(),
            // Filter items
            ...filterList.filters.map((filter) {
              final isSelected = selectedFilter?.id == filter.id;
              final isDefault = filter.isDefault;

              return PopupMenuItem<String>(
                value: filter.id,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    if (isSelected)
                      Icon(Icons.check_circle, size: 16, color: theme.primaryColor)
                    else
                      const SizedBox(width: 16),
                    const SizedBox(width: 8),
                    if (isDefault) ...[Icon(Icons.star, size: 14, color: Colors.amber[700]), const SizedBox(width: 4)],
                    Expanded(
                      child: Text(
                        filter.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? theme.primaryColor : null,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _confirmDeleteFilter(context, filter);
                      },
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              );
            }),
            const PopupMenuDivider(),
            // Manage action
            PopupMenuItem<String>(
              value: 'manage',
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.settings_outlined, size: 18, color: theme.hintColor),
                  const SizedBox(width: 12),
                  Text(
                    'Manage Filters',
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: theme.hintColor),
                  ),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'manage') {
              _showManageFiltersDialog(context, filterList);
            } else {
              // Find and apply the selected filter
              final filter = filterList.filters.firstWhere((f) => f.id == value);
              _applyFavoriteFilter(filter);
              context.read<FavoriteFilterCubit>().selectFilter(filter);
            }
          },
        );
      },
      error: (message) => const SizedBox.shrink(),
    ),
  );

  void _applyFavoriteFilter(FavoriteFilter filter) {
    // Clear existing groups
    setState(() {
      for (final group in _activeGroups) {
        if (group is InstrumentFilterGroup) {
          group.dispose();
        } else if (group is TradeCharacteristicsFilterGroup) {
          group.dispose();
        } else if (group is ProfitLossFilterGroup) {
          group.dispose();
        }
      }
      _activeGroups.clear();
    });

    // Reinitialize from the filter config
    final config = filter.filterConfig;

    setState(() {
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

      // Auto-expand and apply
      if (!_isExpanded) {
        _isExpanded = true;
        _animationController.forward();
      }
    });

    // Apply the filter
    _applyFilters();

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Applied filter: "${filter.name}"'), duration: const Duration(seconds: 2)));
    }
  }

  void _showManageFiltersDialog(BuildContext context, FavoriteFilterList filterList) {
    final cubit = context.read<FavoriteFilterCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: AlertDialog(
          title: const Text('Manage Favorite Filters'),
          content: SizedBox(
            width: 500,
            child: BlocBuilder<FavoriteFilterCubit, FavoriteFilterState>(
              builder: (context, state) => state.when(
                initial: () => const SizedBox.shrink(),
                loading: () => const Center(child: CircularProgressIndicator()),
                loaded: (filterList, selectedFilter) => filterList.filters.isEmpty
                    ? const Center(child: Text('No favorite filters yet'))
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: filterList.filters.length,
                        itemBuilder: (context, index) {
                          final filter = filterList.filters[index];
                          final isDefault = filter.isDefault;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Icon(
                                isDefault ? Icons.star : Icons.bookmark_outline,
                                color: isDefault ? Colors.amber[700] : null,
                              ),
                              title: Text(filter.name),
                              subtitle: filter.description != null ? Text(filter.description!) : null,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (!isDefault)
                                    IconButton(
                                      icon: const Icon(Icons.star_outline),
                                      onPressed: () {
                                        cubit.setAsDefault(widget.userId!, filter.id);
                                      },
                                      tooltip: 'Set as default',
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop();
                                      _confirmDeleteFilter(context, filter);
                                    },
                                    tooltip: 'Delete',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                error: (message) => Center(child: Text('Error: $message')),
              ),
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Close'))],
        ),
      ),
    );
  }

  void _confirmDeleteFilter(BuildContext context, FavoriteFilter filter) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Favorite Filter'),
        content: Text('Are you sure you want to delete "${filter.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<FavoriteFilterCubit>().deleteFilter(widget.userId!, filter.id);
              Navigator.of(dialogContext).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, ThemeData theme) => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
        child: Icon(icon, size: 16, color: theme.primaryColor),
      ),
      const SizedBox(width: 12),
      Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
    ],
  );

  Widget _buildEmptyState(ThemeData theme) => Container(
    margin: const EdgeInsets.only(top: 12),
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: theme.primaryColor.withOpacity(0.03),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: theme.primaryColor.withOpacity(0.1)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(Icons.filter_alt_off_rounded, size: 32, color: theme.primaryColor.withOpacity(0.6)),
        ),
        const SizedBox(height: 12),
        Text(
          'No filter groups active',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: theme.hintColor),
        ),
        const SizedBox(height: 4),
        Text(
          'Add filter groups to refine your holdings',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
