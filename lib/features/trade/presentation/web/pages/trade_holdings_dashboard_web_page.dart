import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../favorite_filter_providers.dart';
import '../../../internal/domain/entities/metrics_filter_config.dart';
import '../../../providers/trade_internal_providers.dart';
import '../../components/dialogs/trade_detail_dialog.dart';
import '../../components/templates/trade_holdings_template.dart';
import '../../models/trade_holding_view_model.dart';
import '../../widgets/compact_advanced_filter_panel.dart';
import '../../widgets/favorite_filter_panel.dart';

class TradeHoldingsDashboardWebPage extends ConsumerStatefulWidget {
  const TradeHoldingsDashboardWebPage({required this.userId, required this.portfolioId, super.key});
  final String userId;
  final String portfolioId;

  @override
  ConsumerState<TradeHoldingsDashboardWebPage> createState() => _TradeHoldingsDashboardWebPageState();
}

class _TradeHoldingsDashboardWebPageState extends ConsumerState<TradeHoldingsDashboardWebPage> {
  // Current active filter configuration
  MetricsFilterConfig _currentFilter = MetricsFilterConfig.empty();

  @override
  void initState() {
    super.initState();
    // Load favorite filters when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = ref.read(favoriteFilterCubitProvider);
      cubit.loadFilters(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Holdings Dashboard'),
      actions: [IconButton(icon: const Icon(Icons.calendar_today), onPressed: () => _navigateToCalendar(context))],
    ),
    body: _buildHoldingsTab(),
  );

  Widget _buildHoldingsTab() {
    final params = (userId: widget.userId, portfolioId: widget.portfolioId);
    final holdingsAsync = ref.watch(tradeHoldingsStreamProvider(params));

    return Column(
      children: [
        // Favorite Filter Panel at the top
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocProvider(
            create: (_) => ref.read(favoriteFilterCubitProvider),
            child: FavoriteFilterPanel(
              userId: widget.userId,
              onFilterSelected: (filter) {
                setState(() {
                  _currentFilter = filter.filterConfig;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Applied filter: "${filter.name}"'), duration: const Duration(seconds: 2)),
                );
              },
              onCreateNew: () {
                // TODO: Show dialog to create new filter
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Create filter dialog coming soon')));
              },
              onManageFilters: () {
                // TODO: Navigate to filter management page
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Manage filters page coming soon')));
              },
            ),
          ),
        ),

        // Advanced Filter Panel
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: CompactAdvancedFilterPanel(
            initialConfig: _currentFilter,
            onApplyFilter: (config) {
              setState(() {
                _currentFilter = config;
              });
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Custom filters applied'), duration: Duration(seconds: 2)));
            },
            onReset: () {
              setState(() {
                _currentFilter = MetricsFilterConfig.empty();
              });
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Filters reset'), duration: Duration(seconds: 1)));
            },
          ),
        ),

        const SizedBox(height: 16),

        // Holdings List
        Expanded(
          child: holdingsAsync.when(
            data: (tradeHoldings) {
              // Apply filters to holdings
              final filteredHoldings = _applyFilters(tradeHoldings.holdings, _currentFilter);

              return TradeHoldingsTemplate(
                holdings: filteredHoldings,
                isLoading: false,
                onHoldingSelected: (holding) => _showHoldingDetails(context, holding),
                onRefresh: () {
                  ref.invalidate(tradeHoldingsStreamProvider(params));
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => TradeHoldingsTemplate(
              holdings: const [],
              isLoading: false,
              errorMessage: error.toString(),
              onRefresh: () {
                ref.invalidate(tradeHoldingsStreamProvider(params));
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Apply filters to holdings list
  List<TradeHoldingViewModel> _applyFilters(List<TradeHoldingViewModel> holdings, MetricsFilterConfig filter) {
    var filtered = holdings;

    // Date Range Filter
    if (filter.dateRange != null) {
      filtered = filtered.where((h) {
        // Assuming holding has entryDate field
        // You may need to adjust based on your actual TradeHoldingViewModel structure
        return true; // TODO: Implement date filtering based on your model
      }).toList();
    }

    // Instrument Filters
    if (filter.instrumentFilters != null) {
      final instrumentFilter = filter.instrumentFilters!;

      // Market Segments
      if (instrumentFilter.marketSegments.isNotEmpty) {
        filtered = filtered.where((h) {
          // TODO: Check if holding's market segment matches
          return true; // Placeholder
        }).toList();
      }

      // Base Symbols
      if (instrumentFilter.baseSymbols.isNotEmpty) {
        filtered = filtered
            .where(
              (h) =>
                  instrumentFilter.baseSymbols.any((symbol) => h.symbol.toUpperCase().contains(symbol.toUpperCase())),
            )
            .toList();
      }

      // Index Types
      if (instrumentFilter.indexTypes.isNotEmpty) {
        filtered = filtered.where((h) {
          // TODO: Check if holding's index type matches
          return true; // Placeholder
        }).toList();
      }

      // Derivative Types
      if (instrumentFilter.derivativeTypes.isNotEmpty) {
        filtered = filtered.where((h) {
          // TODO: Check if holding's derivative type matches
          return true; // Placeholder
        }).toList();
      }
    }

    // Trade Characteristics Filter
    if (filter.tradeCharacteristics != null) {
      final tradeFilter = filter.tradeCharacteristics!;

      // Directions
      if (tradeFilter.directions.isNotEmpty) {
        filtered = filtered.where((h) {
          // TODO: Check if holding's direction matches
          return true; // Placeholder
        }).toList();
      }

      // Statuses
      if (tradeFilter.statuses.isNotEmpty) {
        filtered = filtered.where((h) {
          if (h.status == null) return false;
          return tradeFilter.statuses.any((status) => h.status!.toLowerCase() == status.name.toLowerCase());
        }).toList();
      }

      // Strategies
      if (tradeFilter.strategies.isNotEmpty) {
        filtered = filtered.where((h) {
          // TODO: Check if holding's strategy matches
          return true; // Placeholder
        }).toList();
      }

      // Tags
      if (tradeFilter.tags.isNotEmpty) {
        filtered = filtered.where((h) {
          // TODO: Check if holding has matching tags
          return true; // Placeholder
        }).toList();
      }

      // Holding Time
      if (tradeFilter.minHoldingTimeHours != null || tradeFilter.maxHoldingTimeHours != null) {
        filtered = filtered.where((h) {
          // TODO: Calculate holding time and filter
          return true; // Placeholder
        }).toList();
      }
    }

    // Profit/Loss Filter
    if (filter.profitLossFilters != null) {
      final pnlFilter = filter.profitLossFilters!;

      // P&L Range (using profitLoss field from view model)
      if (pnlFilter.minProfitLoss != null) {
        filtered = filtered.where((h) {
          if (h.profitLoss == null) return false;
          return h.profitLoss! >= pnlFilter.minProfitLoss!;
        }).toList();
      }
      if (pnlFilter.maxProfitLoss != null) {
        filtered = filtered.where((h) {
          if (h.profitLoss == null) return false;
          return h.profitLoss! <= pnlFilter.maxProfitLoss!;
        }).toList();
      }

      // Position Size Range
      if (pnlFilter.minPositionSize != null) {
        filtered = filtered.where((h) {
          if (h.currentValue == null) return false;
          return h.currentValue! >= pnlFilter.minPositionSize!;
        }).toList();
      }
      if (pnlFilter.maxPositionSize != null) {
        filtered = filtered.where((h) {
          if (h.currentValue == null) return false;
          return h.currentValue! <= pnlFilter.maxPositionSize!;
        }).toList();
      }
    }

    return filtered;
  }

  void _showHoldingDetails(BuildContext context, TradeHoldingViewModel holding) {
    TradeDetailDialog.show(context, holding);
  }

  void _navigateToCalendar(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/trade/calendar/${widget.portfolioId}',
      arguments: {'userId': widget.userId, 'portfolioId': widget.portfolioId},
    );
  }
}
