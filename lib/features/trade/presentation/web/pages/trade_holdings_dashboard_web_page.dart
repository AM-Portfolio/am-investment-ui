import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/templates/trade_holdings_template.dart';
import '../../components/templates/trade_summary_template.dart';
import '../../../providers/trade_internal_providers.dart';
import '../../models/trade_holding_view_model.dart';

class TradeHoldingsDashboardWebPage extends ConsumerStatefulWidget {
  final String userId;
  final String portfolioId;

  const TradeHoldingsDashboardWebPage({
    super.key,
    required this.userId,
    required this.portfolioId,
  });

  @override
  ConsumerState<TradeHoldingsDashboardWebPage> createState() => _TradeHoldingsDashboardWebPageState();
}

class _TradeHoldingsDashboardWebPageState extends ConsumerState<TradeHoldingsDashboardWebPage> 
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trade Analysis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _navigateToCalendar(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Holdings'),
            Tab(text: 'Summary'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHoldingsTab(),
          _buildSummaryTab(),
        ],
      ),
    );
  }

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
        isWebView: true,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => TradeHoldingsTemplate(
        holdings: const [],
        isLoading: false,
        errorMessage: error.toString(),
        onRefresh: () {
          ref.invalidate(tradeHoldingsStreamProvider(params));
        },
        isWebView: true,
      ),
    );
  }

  Widget _buildSummaryTab() {
    final params = (userId: widget.userId, portfolioId: widget.portfolioId);
    final summaryAsync = ref.watch(tradeSummaryStreamProvider(params));

    return summaryAsync.when(
      data: (summary) => TradeSummaryTemplate(
        summary: summary,
        isLoading: false,
        onRefresh: () {
          ref.invalidate(tradeSummaryStreamProvider(params));
        },
        isWebView: true,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(error.toString(), style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(tradeSummaryStreamProvider(params));
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showHoldingDetails(BuildContext context, TradeHoldingViewModel holding) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(holding.displaySymbol),
        content: SizedBox(
          width: 600,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Company: ${holding.displayCompanyName}'),
              Text('Sector: ${holding.displaySector}'),
              Text('Industry: ${holding.displayIndustry}'),
              Text('Exchange: ${holding.displayExchange}'),
              Text('Status: ${holding.displayStatus}'),
              const Divider(),
              Text('Quantity: ${holding.displayQuantity}'),
              Text('Entry Price: ${holding.displayEntryPrice}'),
              if (holding.exitPrice != null) Text('Exit Price: ${holding.displayExitPrice}'),
              Text('Current Price: ${holding.displayCurrentPrice}'),
              const Divider(),
              Text(
                'P&L: ${holding.displayProfitLoss} (${holding.displayProfitLossPercentage})',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: holding.isProfit ? Colors.green : Colors.red,
                ),
              ),
              const Divider(),
              Text('Risk/Reward: ${holding.displayRiskRewardRatio}'),
              Text('Holding Period: ${holding.displayHoldingPeriod}'),
              if (holding.broker != null) Text('Broker: ${holding.broker}'),
              Text('Executions: ${holding.executionCount}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _navigateToCalendar(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/trade/calendar/${widget.portfolioId}',
      arguments: {'userId': widget.userId, 'portfolioId': widget.portfolioId},
    );
  }
}
