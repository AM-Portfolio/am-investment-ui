import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../favorite_filter_providers.dart';
import '../../../internal/domain/entities/favorite_filter.dart';
import '../../../internal/domain/entities/metrics_filter_config.dart';
import '../../cubits/favorite_filter/favorite_filter_cubit.dart';
import '../../widgets/filters/date_range_filter_group.dart';
import '../../widgets/filters/instrument_filter_group.dart';
import '../../widgets/filters/profit_loss_filter_group.dart';
import '../../widgets/filters/trade_characteristics_filter_group.dart';

/// Mobile-optimized filter panel with bottom sheet and tabs
/// Now used as a utility class to show filter bottom sheet
class MobileFilterPanel {
  /// Show filter bottom sheet - can be called from anywhere
  static Future<void> show({
    required BuildContext context,
    required WidgetRef ref,
    required String userId,
    required MetricsFilterConfig initialConfig,
    required Function(MetricsFilterConfig) onApplyFilter,
    VoidCallback? onReset,
  }) async {
    // Get the cubit from the existing provider - don't create a new one
    final cubit = ref.read(favoriteFilterCubitProvider);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: cubit,
        child: _FilterBottomSheetContent(
          ref: ref,
          userId: userId,
          initialConfig: initialConfig,
          onApplyFilter: onApplyFilter,
          onReset: onReset,
        ),
      ),
    );
  }
}

/// Internal stateful widget for filter bottom sheet content
class _FilterBottomSheetContent extends ConsumerStatefulWidget {
  const _FilterBottomSheetContent({
    required this.ref,
    required this.userId,
    required this.initialConfig,
    required this.onApplyFilter,
    this.onReset,
  });

  final WidgetRef ref;
  final String userId;
  final MetricsFilterConfig initialConfig;
  final Function(MetricsFilterConfig) onApplyFilter;
  final VoidCallback? onReset;

  @override
  ConsumerState<_FilterBottomSheetContent> createState() => _FilterBottomSheetContentState();
}

class _FilterBottomSheetContentState extends ConsumerState<_FilterBottomSheetContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Filter groups
  DateRangeFilterGroup? _dateRangeGroup;
  InstrumentFilterGroup? _instrumentGroup;
  TradeCharacteristicsFilterGroup? _tradeCharGroup;
  ProfitLossFilterGroup? _profitLossGroup;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeFilters();
  }

  void _initializeFilters() {
    final config = widget.initialConfig;

    // Always initialize all filter groups (even if empty) for better UX
    _dateRangeGroup = DateRangeFilterGroup(
      startDate: config.dateRange?.startDate,
      endDate: config.dateRange?.endDate,
      onChanged: (start, end) => setState(() {}),
    );

    _instrumentGroup = InstrumentFilterGroup(onChanged: () => setState(() {}));
    if (config.instrumentFilters != null) {
      _instrumentGroup!.selectedSegments = List.from(config.instrumentFilters!.marketSegments);
      _instrumentGroup!.selectedIndexTypes = List.from(config.instrumentFilters!.indexTypes);
      _instrumentGroup!.selectedDerivativeTypes = List.from(config.instrumentFilters!.derivativeTypes);
      _instrumentGroup!.symbolsController.text = config.instrumentFilters!.baseSymbols.join(', ');
    }

    _tradeCharGroup = TradeCharacteristicsFilterGroup(onChanged: () => setState(() {}));
    if (config.tradeCharacteristics != null) {
      _tradeCharGroup!.selectedDirections = List.from(config.tradeCharacteristics!.directions);
      _tradeCharGroup!.selectedStatuses = List.from(config.tradeCharacteristics!.statuses);
      _tradeCharGroup!.strategiesController.text = config.tradeCharacteristics!.strategies.join(', ');
      _tradeCharGroup!.tagsController.text = config.tradeCharacteristics!.tags.join(', ');
      if (config.tradeCharacteristics!.minHoldingTimeHours != null) {
        _tradeCharGroup!.minHoldingHoursController.text = config.tradeCharacteristics!.minHoldingTimeHours.toString();
      }
      if (config.tradeCharacteristics!.maxHoldingTimeHours != null) {
        _tradeCharGroup!.maxHoldingHoursController.text = config.tradeCharacteristics!.maxHoldingTimeHours.toString();
      }
    }

    _profitLossGroup = ProfitLossFilterGroup(onChanged: () => setState(() {}));
    if (config.profitLossFilters != null) {
      if (config.profitLossFilters!.minProfitLoss != null) {
        _profitLossGroup!.minPnLController.text = config.profitLossFilters!.minProfitLoss.toString();
      }
      if (config.profitLossFilters!.maxProfitLoss != null) {
        _profitLossGroup!.maxPnLController.text = config.profitLossFilters!.maxProfitLoss.toString();
      }
      if (config.profitLossFilters!.minPositionSize != null) {
        _profitLossGroup!.minPositionSizeController.text = config.profitLossFilters!.minPositionSize.toString();
      }
      if (config.profitLossFilters!.maxPositionSize != null) {
        _profitLossGroup!.maxPositionSizeController.text = config.profitLossFilters!.maxPositionSize.toString();
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    // Note: DateRangeFilterGroup doesn't have dispose method
    _instrumentGroup?.dispose();
    _tradeCharGroup?.dispose();
    _profitLossGroup?.dispose();
    super.dispose();
  }

  int get _activeFilterCount {
    var count = 0;
    if (_dateRangeGroup?.hasActiveFilters ?? false) count++;
    if (_instrumentGroup?.hasActiveFilters ?? false) count++;
    if (_tradeCharGroup?.hasActiveFilters ?? false) count++;
    if (_profitLossGroup?.hasActiveFilters ?? false) count++;
    return count;
  }

  void _applyFilters() {
    final config = MetricsFilterConfig(
      dateRange: _dateRangeGroup?.toFilterCriteria(),
      instrumentFilters: _instrumentGroup?.toFilterCriteria(),
      tradeCharacteristics: _tradeCharGroup?.toFilterCriteria(),
      profitLossFilters: _profitLossGroup?.toFilterCriteria(),
    );
    widget.onApplyFilter(config);
    Navigator.of(context).pop();
  }

  void _resetFilters() {
    setState(() {
      _dateRangeGroup?.reset();
      _instrumentGroup?.reset();
      _tradeCharGroup?.reset();
      _profitLossGroup?.reset();
    });
    widget.onReset?.call();
  }

  void _showSaveDialog() {
    if (!mounted) return;
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final cubit = context.read<FavoriteFilterCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: AlertDialog(
          title: const Text('Save as Favorite'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Filter Name',
                    hintText: 'e.g., Last Month Profitable Trades',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'Brief description of this filter',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Please enter a filter name')));
                  return;
                }

                final config = MetricsFilterConfig(
                  dateRange: _dateRangeGroup?.toFilterCriteria(),
                  instrumentFilters: _instrumentGroup?.toFilterCriteria(),
                  tradeCharacteristics: _tradeCharGroup?.toFilterCriteria(),
                  profitLossFilters: _profitLossGroup?.toFilterCriteria(),
                );

                cubit.createFilter(
                  userId: widget.userId,
                  name: name,
                  filterConfig: config,
                  description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
                  isDefault: false,
                );

                Navigator.of(dialogContext).pop();

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved filter "$name"')));
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _applyFavoriteFilter(FavoriteFilter filter) {
    setState(() {
      // Dispose existing filters
      _instrumentGroup?.dispose();
      _tradeCharGroup?.dispose();
      _profitLossGroup?.dispose();

      // Reload from favorite config
      final config = filter.filterConfig;

      // Always initialize all filter groups (even if empty)
      _dateRangeGroup = DateRangeFilterGroup(
        startDate: config.dateRange?.startDate,
        endDate: config.dateRange?.endDate,
        onChanged: (start, end) => setState(() {}),
      );

      _instrumentGroup = InstrumentFilterGroup(onChanged: () => setState(() {}));
      if (config.instrumentFilters != null) {
        _instrumentGroup!.selectedSegments = List.from(config.instrumentFilters!.marketSegments);
        _instrumentGroup!.selectedIndexTypes = List.from(config.instrumentFilters!.indexTypes);
        _instrumentGroup!.selectedDerivativeTypes = List.from(config.instrumentFilters!.derivativeTypes);
        _instrumentGroup!.symbolsController.text = config.instrumentFilters!.baseSymbols.join(', ');
      }

      _tradeCharGroup = TradeCharacteristicsFilterGroup(onChanged: () => setState(() {}));
      if (config.tradeCharacteristics != null) {
        _tradeCharGroup!.selectedDirections = List.from(config.tradeCharacteristics!.directions);
        _tradeCharGroup!.selectedStatuses = List.from(config.tradeCharacteristics!.statuses);
        _tradeCharGroup!.strategiesController.text = config.tradeCharacteristics!.strategies.join(', ');
        _tradeCharGroup!.tagsController.text = config.tradeCharacteristics!.tags.join(', ');
        if (config.tradeCharacteristics!.minHoldingTimeHours != null) {
          _tradeCharGroup!.minHoldingHoursController.text = config.tradeCharacteristics!.minHoldingTimeHours.toString();
        }
        if (config.tradeCharacteristics!.maxHoldingTimeHours != null) {
          _tradeCharGroup!.maxHoldingHoursController.text = config.tradeCharacteristics!.maxHoldingTimeHours.toString();
        }
      }

      _profitLossGroup = ProfitLossFilterGroup(onChanged: () => setState(() {}));
      if (config.profitLossFilters != null) {
        if (config.profitLossFilters!.minProfitLoss != null) {
          _profitLossGroup!.minPnLController.text = config.profitLossFilters!.minProfitLoss.toString();
        }
        if (config.profitLossFilters!.maxProfitLoss != null) {
          _profitLossGroup!.maxPnLController.text = config.profitLossFilters!.maxProfitLoss.toString();
        }
        if (config.profitLossFilters!.minPositionSize != null) {
          _profitLossGroup!.minPositionSizeController.text = config.profitLossFilters!.minPositionSize.toString();
        }
        if (config.profitLossFilters!.maxPositionSize != null) {
          _profitLossGroup!.maxPositionSizeController.text = config.profitLossFilters!.maxPositionSize.toString();
        }
      }
    });

    widget.onApplyFilter(filter.filterConfig);
  }

  Widget _buildBottomSheet() {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.5, // Maximum 50% of screen - stays at bottom!
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar - slightly bigger for easier dragging
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 48,
            height: 4,
            decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(2)),
          ),

          // Header with better spacing
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.filter_list_rounded, size: 22, color: theme.primaryColor),
                const SizedBox(width: 10),
                Text(
                  'Filters',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (_activeFilterCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(color: theme.primaryColor, borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      '$_activeFilterCount',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
                const SizedBox(width: 10),
                // Favorite Filters Button
                BlocBuilder<FavoriteFilterCubit, FavoriteFilterState>(
                  builder: (context, state) => state.when(
                    initial: () => const SizedBox.shrink(),
                    loading: () => const SizedBox.shrink(),
                    loaded: (filterList, selectedFilter) {
                      if (filterList.filters.isEmpty) return const SizedBox.shrink();
                      return _buildFavoriteButton(theme, filterList, selectedFilter);
                    },
                    error: (message) => const SizedBox.shrink(),
                  ),
                ),
                const Spacer(),
                // Close button - bigger touch target
                IconButton(
                  icon: const Icon(Icons.close, size: 24),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Tab Bar - Thumb-friendly for large phones
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: theme.primaryColor,
            unselectedLabelColor: theme.hintColor,
            indicatorColor: theme.primaryColor,
            indicatorWeight: 3,
            // Larger horizontal padding for better touch targets
            labelPadding: const EdgeInsets.symmetric(horizontal: 20),
            // Bigger text for easier reading
            labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            // Add vertical padding to increase touch area
            padding: const EdgeInsets.symmetric(vertical: 8),
            tabs: const [
              Tab(
                text: 'Date',
                height: 48, // Minimum touch target height
              ),
              Tab(text: 'Instrument', height: 48),
              Tab(text: 'Trade', height: 48),
              Tab(text: 'P&L', height: 48),
            ],
          ),

          // Tab Content - Compact with limited height
          SizedBox(
            height: 180, // Fixed height for filter content
            child: TabBarView(
              controller: _tabController,
              children: [_buildDateTab(theme), _buildInstrumentTab(theme), _buildTradeTab(theme), _buildPnLTab(theme)],
            ),
          ),

          // Bottom Action Bar - Thumb-friendly buttons
          Container(
            padding: EdgeInsets.fromLTRB(16, 10, 16, 12 + bottomPadding),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(top: BorderSide(color: theme.dividerColor.withOpacity(0.3))),
            ),
            child: Row(
              children: [
                if (_activeFilterCount > 0) ...[
                  // Save as Favorite button - larger touch target
                  IconButton(
                    onPressed: _showSaveDialog,
                    icon: const Icon(Icons.bookmark_add_outlined, size: 22),
                    tooltip: 'Save as Favorite',
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.primaryColor.withOpacity(0.1),
                      foregroundColor: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Reset button - bigger and easier to tap
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _resetFilters,
                      icon: const Icon(Icons.clear_all, size: 18),
                      label: const Text('Reset', style: TextStyle(fontSize: 14)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        minimumSize: const Size(0, 48),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                // Apply button - bigger and more prominent
                Expanded(
                  flex: _activeFilterCount > 0 ? 2 : 1,
                  child: FilledButton.icon(
                    onPressed: _applyFilters,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Apply', style: TextStyle(fontSize: 14)),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      minimumSize: const Size(0, 48),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTab(ThemeData theme) => SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    child: _dateRangeGroup!.buildContent(context),
  );

  Widget _buildInstrumentTab(ThemeData theme) => SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    child: _instrumentGroup!.buildContent(context),
  );

  Widget _buildTradeTab(ThemeData theme) => SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    child: _tradeCharGroup!.buildContent(context),
  );

  Widget _buildPnLTab(ThemeData theme) => SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    child: _profitLossGroup!.buildContent(context),
  );
  @override
  Widget build(BuildContext context) => _buildBottomSheet();

  Widget _buildFavoriteButton(
    ThemeData theme,
    FavoriteFilterList filterList,
    FavoriteFilter? selectedFilter,
  ) => PopupMenuButton<String>(
    icon: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: selectedFilter != null ? theme.primaryColor.withOpacity(0.15) : theme.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: selectedFilter != null ? theme.primaryColor : theme.dividerColor),
      ),
      child: Icon(
        Icons.bookmark_rounded,
        size: 22,
        color: selectedFilter != null ? theme.primaryColor : theme.hintColor,
      ),
    ),
    padding: EdgeInsets.zero,
    constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
    tooltip: 'Favorite Filters',
    itemBuilder: (context) => [
      PopupMenuItem<String>(
        enabled: false,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.bookmark_rounded, size: 20, color: theme.primaryColor),
            const SizedBox(width: 10),
            Text(
              'Favorites',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: theme.primaryColor),
            ),
            const Spacer(),
            Text('${filterList.filters.length}', style: TextStyle(fontSize: 13, color: theme.hintColor)),
          ],
        ),
      ),
      const PopupMenuDivider(),
      ...filterList.filters.map((filter) {
        final isSelected = selectedFilter?.id == filter.id;
        return PopupMenuItem<String>(
          value: filter.id,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              if (isSelected)
                Icon(Icons.check_circle, size: 18, color: theme.primaryColor)
              else
                const SizedBox(width: 18),
              const SizedBox(width: 10),
              if (filter.isDefault) ...[Icon(Icons.star, size: 16, color: Colors.amber[700]), const SizedBox(width: 6)],
              Expanded(
                child: Text(
                  filter.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? theme.primaryColor : null,
                  ),
                ),
              ),
              // Long press menu for each filter
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, size: 18, color: theme.hintColor),
                tooltip: 'Filter options',
                itemBuilder: (context) => [
                  if (!filter.isDefault)
                    PopupMenuItem<String>(
                      value: 'set_default_${filter.id}',
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Icon(Icons.star_outline, size: 18, color: theme.hintColor),
                          const SizedBox(width: 10),
                          const Text('Set as Default', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  PopupMenuItem<String>(
                    value: 'delete_${filter.id}',
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 18, color: Colors.red.shade400),
                        const SizedBox(width: 10),
                        Text('Delete', style: TextStyle(fontSize: 14, color: Colors.red.shade400)),
                      ],
                    ),
                  ),
                ],
                onSelected: (action) {
                  if (action.startsWith('set_default_')) {
                    _setAsDefault(filter);
                  } else if (action.startsWith('delete_')) {
                    _confirmDelete(filter);
                  }
                },
              ),
            ],
          ),
        );
      }),
      const PopupMenuDivider(),
      PopupMenuItem<String>(
        value: 'manage',
        child: Row(
          children: [
            Icon(Icons.settings_outlined, size: 18, color: theme.hintColor),
            const SizedBox(width: 12),
            Text(
              'Manage Filters',
              style: TextStyle(fontWeight: FontWeight.w500, color: theme.hintColor),
            ),
          ],
        ),
      ),
    ],
    onSelected: (value) {
      if (value == 'manage') {
        _showManageDialog(filterList);
      } else {
        final filter = filterList.filters.firstWhere((f) => f.id == value);
        // Check if widget is still mounted before updating cubit
        if (mounted) {
          context.read<FavoriteFilterCubit>().selectFilter(filter);
          _applyFavoriteFilter(filter);
        }
      }
    },
  );

  void _setAsDefault(FavoriteFilter filter) {
    if (!mounted) return;
    context.read<FavoriteFilterCubit>().setAsDefault(widget.userId, filter.id);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('"${filter.name}" set as default')));
  }

  void _confirmDelete(FavoriteFilter filter) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Favorite Filter'),
        content: Text('Are you sure you want to delete "${filter.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (mounted) {
                context.read<FavoriteFilterCubit>().deleteFilter(widget.userId, filter.id);
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('"${filter.name}" deleted')));
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showManageDialog(FavoriteFilterList filterList) {
    final cubit = context.read<FavoriteFilterCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: AlertDialog(
          title: const Text('Manage Favorite Filters'),
          content: SizedBox(
            width: 500,
            height: 400,
            child: filterList.filters.isEmpty
                ? const Center(child: Text('No favorite filters yet'))
                : ListView.builder(
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
                                  onPressed: () => _setAsDefault(filter),
                                  tooltip: 'Set as default',
                                ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () {
                                  Navigator.of(dialogContext).pop();
                                  _confirmDelete(filter);
                                },
                                tooltip: 'Delete',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Close'))],
        ),
      ),
    );
  }
}
