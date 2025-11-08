import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/trade_internal_providers.dart';
import '../../components/dialogs/trade_detail_dialog.dart';
import '../../components/templates/trade_holdings_template.dart';
import '../../models/trade_holding_view_model.dart';

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
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.portfolioName ?? 'Holdings Dashboard'),
      actions: [IconButton(icon: const Icon(Icons.calendar_today), onPressed: () => _navigateToCalendar(context))],
    ),
    body: _buildHoldingsTab(),
  );

  Widget _buildHoldingsTab() {
    final holdingsAsync = ref.watch(
      tradeHoldingsStreamProvider((userId: widget.userId, portfolioId: widget.portfolioId)),
    );

    return holdingsAsync.when(
      data: (holdingsViewModel) => TradeHoldingsTemplate(
        holdings: holdingsViewModel.holdings,
        isLoading: false,
        isWebView: false,
        onHoldingSelected: (holding) => _navigateToHoldingDetails(context, holding),
      ),
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

  void _navigateToCalendar(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/trade/calendar/${widget.portfolioId}',
      arguments: {'userId': widget.userId, 'portfolioName': widget.portfolioName},
    );
  }

  void _navigateToHoldingDetails(BuildContext context, TradeHoldingViewModel holding) {
    TradeDetailDialog.show(context, holding);
  }
}
