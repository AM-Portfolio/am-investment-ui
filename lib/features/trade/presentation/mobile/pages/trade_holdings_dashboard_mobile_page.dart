import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../favorite_filter_providers.dart';
import '../../../internal/domain/entities/metrics_filter_config.dart';
import '../../../providers/trade_internal_providers.dart';
import '../../components/dialogs/trade_detail_dialog.dart';
import '../../components/templates/trade_holdings_template.dart';
import '../../models/trade_holding_view_model.dart';
import '../widgets/mobile_filter_panel.dart';

class TradeHoldingsDashboardMobilePage extends ConsumerStatefulWidget {
  const TradeHoldingsDashboardMobilePage({
    required this.userId,
    required this.portfolioId,
    super.key,
    this.portfolioName,
  });
  final String userId;
  final String portfolioId;
  final String? portfolioName;

  @override
  ConsumerState<TradeHoldingsDashboardMobilePage> createState() => _TradeHoldingsDashboardMobilePageState();
}

class _TradeHoldingsDashboardMobilePageState extends ConsumerState<TradeHoldingsDashboardMobilePage> {
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
  Widget build(BuildContext context) => _buildHoldingsTab();

  Widget _buildHoldingsTab() {
    final holdingsAsync = ref.watch(
      tradeHoldingsStreamProvider((userId: widget.userId, portfolioId: widget.portfolioId)),
    );

    return holdingsAsync.when(
      data: (holdingsViewModel) {
        // Apply filters to holdings
        final filteredHoldings = _applyFilters(holdingsViewModel.holdings, _currentFilter);

        return Column(
          children: [
            // Mobile Filter Panel
            BlocProvider(
              create: (context) => ref.read(favoriteFilterCubitProvider),
              child: MobileFilterPanel(
                userId: widget.userId,
                initialConfig: _currentFilter,
                onApplyFilter: (filter) {
                  setState(() => _currentFilter = filter);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Filters applied'), duration: Duration(seconds: 1)));
                },
                onReset: () {
                  setState(() => _currentFilter = MetricsFilterConfig.empty());
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Filters reset'), duration: Duration(seconds: 1)));
                },
              ),
            ),
            // Holdings List
            Expanded(
              child: TradeHoldingsTemplate(
                holdings: filteredHoldings,
                isLoading: false,
                isWebView: false,
                onHoldingSelected: (holding) => _navigateToHoldingDetails(context, holding),
              ),
            ),
          ],
        );
      },
      loading: () => const TradeHoldingsTemplate(holdings: [], isLoading: true, isWebView: false),
      error: (error, stack) => TradeHoldingsTemplate(
        holdings: const [],
        isLoading: false,
        isWebView: false,
        errorMessage: 'Error loading holdings: $error',
        onRefresh: () =>
            ref.refresh(tradeHoldingsStreamProvider((userId: widget.userId, portfolioId: widget.portfolioId))),
      ),
    );
  }

  List<TradeHoldingViewModel> _applyFilters(List<TradeHoldingViewModel> holdings, MetricsFilterConfig filter) {
    var result = holdings;

    // Apply date range filter
    if (filter.dateRange != null) {
      result = result.where((h) {
        final tradeDate = h.entryTimestamp;
        if (tradeDate == null) return true;

        final startDate = filter.dateRange!.startDate;
        final endDate = filter.dateRange!.endDate;

        if (tradeDate.isBefore(startDate)) return false;
        if (tradeDate.isAfter(endDate)) return false;

        return true;
      }).toList();
    }

    // Apply instrument filters
    if (filter.instrumentFilters != null) {
      final instrumentFilter = filter.instrumentFilters!;

      // Base Symbols (partial match)
      if (instrumentFilter.baseSymbols.isNotEmpty) {
        result = result
            .where(
              (h) =>
                  instrumentFilter.baseSymbols.any((symbol) => h.symbol.toUpperCase().contains(symbol.toUpperCase())),
            )
            .toList();
      }
    }

    // Apply trade characteristics filters
    if (filter.tradeCharacteristics != null) {
      final tradeChar = filter.tradeCharacteristics!;

      // Statuses
      if (tradeChar.statuses.isNotEmpty) {
        result = result.where((h) {
          if (h.status == null) return false;
          return tradeChar.statuses.any((status) => h.status!.toLowerCase() == status.name.toLowerCase());
        }).toList();
      }

      // Strategies
      if (tradeChar.strategies.isNotEmpty) {
        result = result.where((h) {
          if (h.strategy == null) return false;
          return tradeChar.strategies.contains(h.strategy);
        }).toList();
      }

      // Tags
      if (tradeChar.tags.isNotEmpty) {
        result = result.where((h) {
          if (h.tags == null || h.tags!.isEmpty) return false;
          return tradeChar.tags.any((tag) => h.tags!.contains(tag));
        }).toList();
      }
    }

    // Apply profit/loss filters
    if (filter.profitLossFilters != null) {
      result = result.where((h) {
        final pnl = h.profitLoss;
        if (pnl == null) return true;

        final min = filter.profitLossFilters!.minProfitLoss;
        final max = filter.profitLossFilters!.maxProfitLoss;

        if (min != null && pnl < min) return false;
        if (max != null && pnl > max) return false;

        return true;
      }).toList();
    }

    return result;
  }

  void _navigateToHoldingDetails(BuildContext context, TradeHoldingViewModel holding) {
    TradeDetailDialog.show(context, holding);
  }
}
