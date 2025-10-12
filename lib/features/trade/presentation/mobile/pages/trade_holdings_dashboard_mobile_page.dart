import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/utils/logger.dart';
import '../../cubit/unified_trade_cubit.dart';
import '../../cubit/unified_trade_state.dart';

class TradeHoldingsDashboardMobilePage extends StatefulWidget {
  const TradeHoldingsDashboardMobilePage({
    required this.portfolioId,
    this.portfolioName,
    super.key,
  });

  final String portfolioId;
  final String? portfolioName;

  @override
  State<TradeHoldingsDashboardMobilePage> createState() =>
      _TradeHoldingsDashboardMobilePageState();
}

class _TradeHoldingsDashboardMobilePageState
    extends State<TradeHoldingsDashboardMobilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UnifiedTradeCubit>().loadPortfolioHoldings(
            widget.portfolioId,
            page: 0,
            size: 50,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.portfolioName ?? 'Trade Holdings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              AppLogger.userAction(
                'Navigate to Trade Calendar',
                tag: 'TradeHoldingsMobile',
                context: {'portfolioId': widget.portfolioId},
              );
              Navigator.pushNamed(
                context,
                '/trade/calendar/${widget.portfolioId}',
                arguments: {
                  'portfolioName': widget.portfolioName,
                },
              );
            },
            tooltip: 'View Calendar',
          ),
        ],
      ),
      body: BlocBuilder<UnifiedTradeCubit, UnifiedTradeState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(
              child: Text('Pull to refresh to load holdings'),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (message) => _buildErrorWidget(message),
            portfoliosLoaded: (_) => const SizedBox(),
            portfolioSummaryLoaded: (_) => const SizedBox(),
            holdingsLoaded: (response) => _buildHoldingsList(response),
            tradeDetailsLoaded: (_) => const SizedBox(),
            calendarLoaded: (_) => const SizedBox(),
          );
        },
      ),
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
              context.read<UnifiedTradeCubit>().loadPortfolioHoldings(
                    widget.portfolioId,
                    page: 0,
                    size: 50,
                  );
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingsList(dynamic response) {
    final holdings = response.content ?? [];

    if (holdings.isEmpty) {
      return const Center(
        child: Text('No holdings available'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        AppLogger.userAction(
          'Pull to Refresh Trade Holdings',
          tag: 'TradeHoldingsMobile',
          context: {'portfolioId': widget.portfolioId},
        );
        context.read<UnifiedTradeCubit>().loadPortfolioHoldings(
              widget.portfolioId,
              page: 0,
              size: 50,
            );
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: holdings.length,
        itemBuilder: (context, index) {
          final holding = holdings[index];
          final isProfit = (holding.unrealizedGainLoss ?? 0) >= 0;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              holding.symbol ?? 'N/A',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            if (holding.companyName != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                holding.companyName!,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${holding.currentPrice?.toStringAsFixed(2) ?? '0.00'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isProfit
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${isProfit ? '+' : ''}\$${holding.unrealizedGainLoss?.toStringAsFixed(2) ?? '0.00'}',
                              style: TextStyle(
                                color: isProfit ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoColumn(
                        'Quantity',
                        holding.quantity?.toString() ?? '0',
                      ),
                      _buildInfoColumn(
                        'Avg Cost',
                        '\$${holding.averageCost?.toStringAsFixed(2) ?? '0.00'}',
                      ),
                      _buildInfoColumn(
                        'Market Value',
                        '\$${holding.marketValue?.toStringAsFixed(2) ?? '0.00'}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
