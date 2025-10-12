import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/unified_trade_cubit.dart';
import '../../components/templates/trade_portfolio_discovery_template.dart';
import '../../../data/models/trade_portfolio.dart';

class TradePortfolioListWebPage extends StatefulWidget {
  final String ownerId;

  const TradePortfolioListWebPage({
    super.key,
    required this.ownerId,
  });

  @override
  State<TradePortfolioListWebPage> createState() => _TradePortfolioListWebPageState();
}

class _TradePortfolioListWebPageState extends State<TradePortfolioListWebPage> {
  @override
  void initState() {
    super.initState();
    context.read<UnifiedTradeCubit>().loadPortfoliosByOwner(widget.ownerId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trade Portfolios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<UnifiedTradeCubit>().loadPortfoliosByOwner(widget.ownerId);
            },
          ),
        ],
      ),
      body: BlocBuilder<UnifiedTradeCubit, UnifiedTradeState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: Text('Ready to load portfolios')),
            loading: () => const Center(child: CircularProgressIndicator()),
            portfoliosLoaded: (portfolios) => TradePortfolioDiscoveryTemplate(
              portfolios: portfolios,
              isLoading: false,
              onPortfolioSelected: (portfolio) => _navigateToHoldings(context, portfolio),
              onRefresh: () {
                context.read<UnifiedTradeCubit>().loadPortfoliosByOwner(widget.ownerId);
              },
              isWebView: true,
            ),
            portfolioSummaryLoaded: (_) => const Center(child: Text('Portfolio summary loaded')),
            holdingsLoaded: (_) => const Center(child: Text('Holdings loaded')),
            tradeDetailsLoaded: (_) => const Center(child: Text('Trade details loaded')),
            calendarLoaded: (_) => const Center(child: Text('Calendar loaded')),
            error: (message) => TradePortfolioDiscoveryTemplate(
              portfolios: const [],
              isLoading: false,
              errorMessage: message,
              onPortfolioSelected: (_) {},
              onRefresh: () {
                context.read<UnifiedTradeCubit>().loadPortfoliosByOwner(widget.ownerId);
              },
              isWebView: true,
            ),
          );
        },
      ),
    );
  }

  void _navigateToHoldings(BuildContext context, TradePortfolio portfolio) {
    Navigator.pushNamed(
      context,
      '/trade/holdings',
      arguments: portfolio,
    );
  }
}
