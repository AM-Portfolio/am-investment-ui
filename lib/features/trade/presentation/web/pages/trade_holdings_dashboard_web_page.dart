import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/trade_internal_providers.dart';
import '../../components/dialogs/trade_detail_dialog.dart';
import '../../components/templates/trade_holdings_template.dart';
import '../../models/trade_holding_view_model.dart';

class TradeHoldingsDashboardWebPage extends ConsumerStatefulWidget {
  const TradeHoldingsDashboardWebPage({required this.userId, required this.portfolioId, super.key});
  final String userId;
  final String portfolioId;

  @override
  ConsumerState<TradeHoldingsDashboardWebPage> createState() => _TradeHoldingsDashboardWebPageState();
}

class _TradeHoldingsDashboardWebPageState extends ConsumerState<TradeHoldingsDashboardWebPage> {
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

    return holdingsAsync.when(
      data: (tradeHoldings) => TradeHoldingsTemplate(
        holdings: tradeHoldings.holdings,
        isLoading: false,
        onHoldingSelected: (holding) => _showHoldingDetails(context, holding),
        onRefresh: () {
          ref.invalidate(tradeHoldingsStreamProvider(params));
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => TradeHoldingsTemplate(
        holdings: const [],
        isLoading: false,
        errorMessage: error.toString(),
        onRefresh: () {
          ref.invalidate(tradeHoldingsStreamProvider(params));
        },
      ),
    );
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
