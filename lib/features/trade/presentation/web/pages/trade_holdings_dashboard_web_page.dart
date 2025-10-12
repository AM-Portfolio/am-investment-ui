import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/unified_trade_cubit.dart';
import '../../components/templates/trade_holdings_template.dart';
import '../../../data/models/trade_portfolio.dart';
import '../../../data/models/trade_holding.dart';

class TradeHoldingsDashboardWebPage extends StatefulWidget {
  final TradePortfolio portfolio;

  const TradeHoldingsDashboardWebPage({
    super.key,
    required this.portfolio,
  });

  @override
  State<TradeHoldingsDashboardWebPage> createState() => _TradeHoldingsDashboardWebPageState();
}

class _TradeHoldingsDashboardWebPageState extends State<TradeHoldingsDashboardWebPage> {
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadHoldings();
  }

  void _loadHoldings() {
    context.read<UnifiedTradeCubit>().loadPortfolioHoldings(
      widget.portfolio.portfolioId,
      page: currentPage,
      size: 50,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Holdings - ${widget.portfolio.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _navigateToCalendar(context),
          ),
        ],
      ),
      body: BlocBuilder<UnifiedTradeCubit, UnifiedTradeState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: Text('Ready to load holdings')),
            loading: () => const Center(child: CircularProgressIndicator()),
            portfoliosLoaded: (_) => const Center(child: Text('Portfolios loaded')),
            portfolioSummaryLoaded: (_) => const Center(child: Text('Portfolio summary loaded')),
            holdingsLoaded: (holdings) => TradeHoldingsTemplate(
              holdings: holdings,
              isLoading: false,
              onTradeSelected: (trade) => _showTradeDetails(context, trade),
              onPageChanged: (page) {
                setState(() => currentPage = page);
                _loadHoldings();
              },
              isWebView: true,
            ),
            tradeDetailsLoaded: (_) => const Center(child: Text('Trade details loaded')),
            calendarLoaded: (_) => const Center(child: Text('Calendar loaded')),
            error: (message) => TradeHoldingsTemplate(
              holdings: null,
              isLoading: false,
              errorMessage: message,
              onTradeSelected: (_) {},
              isWebView: true,
            ),
          );
        },
      ),
    );
  }

  void _showTradeDetails(BuildContext context, TradeHolding trade) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(trade.instrumentInfo.symbol),
        content: SizedBox(
          width: 600,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status: ${trade.status}'),
              Text('Position: ${trade.tradePositionType}'),
              const Divider(),
              Text('Entry: ${trade.entryInfo.price} @ ${trade.entryInfo.quantity}'),
              Text('Exit: ${trade.exitInfo.price} @ ${trade.exitInfo.quantity}'),
              const Divider(),
              Text(
                'P&L: ${trade.metrics.profitLoss.toStringAsFixed(2)} (${trade.metrics.profitLossPercentage.toStringAsFixed(2)}%)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: trade.metrics.profitLoss >= 0 ? Colors.green : Colors.red,
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
      '/trade/calendar',
      arguments: widget.portfolio,
    );
  }
}
