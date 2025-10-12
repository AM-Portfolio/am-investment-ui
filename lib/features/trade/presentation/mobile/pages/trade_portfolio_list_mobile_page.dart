import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/utils/logger.dart';
import '../../cubit/unified_trade_cubit.dart';

class TradePortfolioListMobilePage extends StatefulWidget {
  const TradePortfolioListMobilePage({
    required this.userId,
    super.key,
  });

  final String userId;

  @override
  State<TradePortfolioListMobilePage> createState() =>
      _TradePortfolioListMobilePageState();
}

class _TradePortfolioListMobilePageState
    extends State<TradePortfolioListMobilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UnifiedTradeCubit>().loadPortfoliosByOwner(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UnifiedTradeCubit, UnifiedTradeState>(
      builder: (context, state) {
        return state.when(
          initial: () => const Center(
            child: Text('Pull to refresh to load portfolios'),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (message) => _buildErrorWidget(message),
          portfoliosLoaded: (portfolios) => _buildPortfolioList(portfolios),
          portfolioSummaryLoaded: (_) => const SizedBox(),
          holdingsLoaded: (_) => const SizedBox(),
          tradeDetailsLoaded: (_) => const SizedBox(),
          calendarLoaded: (_) => const SizedBox(),
        );
      },
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context
                  .read<UnifiedTradeCubit>()
                  .loadPortfoliosByOwner(widget.userId);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioList(List portfolios) {
    if (portfolios.isEmpty) {
      return const Center(
        child: Text('No trade portfolios available'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        AppLogger.userAction(
          'Pull to Refresh Trade Portfolios',
          tag: 'TradePortfolioListMobile',
          context: {'userId': widget.userId},
        );
        context.read<UnifiedTradeCubit>().loadPortfoliosByOwner(widget.userId);
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: portfolios.length,
        itemBuilder: (context, index) {
          final portfolio = portfolios[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  portfolio.portfolioName?.substring(0, 1).toUpperCase() ?? 'P',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                portfolio.portfolioName ?? 'Unnamed Portfolio',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('ID: ${portfolio.portfolioId}'),
                  if (portfolio.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      portfolio.description!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                AppLogger.userAction(
                  'Navigate to Trade Holdings',
                  tag: 'TradePortfolioListMobile',
                  context: {
                    'portfolioId': portfolio.portfolioId,
                    'portfolioName': portfolio.portfolioName,
                  },
                );
                Navigator.pushNamed(
                  context,
                  '/trade/holdings/${portfolio.portfolioId}',
                  arguments: {
                    'portfolioName': portfolio.portfolioName,
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
