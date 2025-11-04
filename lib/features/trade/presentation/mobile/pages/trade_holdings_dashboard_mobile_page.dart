import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/trade_internal_providers.dart';
import '../../components/templates/trade_holdings_template.dart';
import '../../components/templates/trade_summary_template.dart';
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

class _TradeHoldingsDashboardMobilePageState extends ConsumerState<TradeHoldingsDashboardMobilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.portfolioName ?? 'Trade Analysis'),
      actions: [IconButton(icon: const Icon(Icons.calendar_today), onPressed: () => _navigateToCalendar(context))],
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Holdings', icon: Icon(Icons.account_balance_wallet)),
          Tab(text: 'Summary', icon: Icon(Icons.analytics)),
        ],
      ),
    ),
    body: TabBarView(controller: _tabController, children: [_buildHoldingsTab(), _buildSummaryTab()]),
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

  Widget _buildSummaryTab() {
    final summaryAsync = ref.watch(
      tradeSummaryStreamProvider((userId: widget.userId, portfolioId: widget.portfolioId)),
    );

    return summaryAsync.when(
      data: (summary) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: TradeSummaryTemplate(summary: summary, isLoading: false),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading summary: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.refresh(tradeSummaryStreamProvider((userId: widget.userId, portfolioId: widget.portfolioId))),
              child: const Text('Retry'),
            ),
          ],
        ),
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
    // Navigate to holding details page (to be implemented)
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Holding details for ${holding.symbol}')));
  }
}
