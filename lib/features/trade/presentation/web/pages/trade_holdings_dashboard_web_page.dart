import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/templates/trade_holdings_template.dart';
import '../../components/templates/trade_summary_template.dart';
import '../../../providers/trade_internal_providers.dart';
import '../../../internal/domain/entities/trade_holding.dart';

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

  void _showHoldingDetails(BuildContext context, TradeHolding holding) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(holding.symbol),
        content: SizedBox(
          width: 600,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Company: ${holding.companyName}'),
              if (holding.sector != null) Text('Sector: ${holding.sector}'),
              if (holding.industry != null) Text('Industry: ${holding.industry}'),
              const Divider(),
              Text('Quantity: ${holding.quantity.toStringAsFixed(0)}'),
              Text('Avg Price: \$${holding.avgPrice.toStringAsFixed(2)}'),
              Text('Current Price: \$${holding.currentPrice.toStringAsFixed(2)}'),
              const Divider(),
              Text(
                'P&L: \$${holding.totalGainLoss.toStringAsFixed(2)} (${holding.totalGainLossPercentage.toStringAsFixed(2)}%)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: holding.totalGainLoss >= 0 ? Colors.green : Colors.red,
                ),
              ),
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
