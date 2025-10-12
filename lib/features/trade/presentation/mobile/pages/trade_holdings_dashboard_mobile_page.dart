import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/utils/logger.dart';
import '../../../providers/trade_internal_providers.dart';

/// Mobile page for trade holdings dashboard using Riverpod streams
class TradeHoldingsDashboardMobilePage extends ConsumerWidget {
  const TradeHoldingsDashboardMobilePage({
    required this.userId,
    required this.portfolioId,
    this.portfolioName,
    super.key,
  });

  final String userId;
  final String portfolioId;
  final String? portfolioName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holdingsStream = ref.watch(
      tradeHoldingsStreamProvider((userId: userId, portfolioId: portfolioId)),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(portfolioName ?? 'Trade Holdings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              AppLogger.userAction(
                'Navigate to Trade Calendar',
                tag: 'TradeHoldingsMobile',
                context: {'portfolioId': portfolioId},
              );
              Navigator.pushNamed(
                context,
                '/trade/calendar/$portfolioId',
                arguments: {
                  'userId': userId,
                  'portfolioName': portfolioName,
                },
              );
            },
            tooltip: 'View Calendar',
          ),
        ],
      ),
      body: holdingsStream.when(
        data: (holdingsWrapper) {
          final holdings = holdingsWrapper.holdings;
          
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
                context: {'portfolioId': portfolioId},
              );
              ref.invalidate(
                tradeHoldingsStreamProvider(
                  (userId: userId, portfolioId: portfolioId),
                ),
              );
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: holdings.length,
              itemBuilder: (context, index) {
                final holding = holdings[index];
                final isProfit = holding.totalGainLoss >= 0;

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
                                    holding.symbol,
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
                                  '\$${holding.currentPrice.toStringAsFixed(2)}',
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
                                    '${isProfit ? '+' : ''}\$${holding.totalGainLoss.toStringAsFixed(2)}',
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
                              holding.quantity.toString(),
                            ),
                            _buildInfoColumn(
                              'Avg Price',
                              '\$${holding.avgPrice.toStringAsFixed(2)}',
                            ),
                            _buildInfoColumn(
                              'Current Value',
                              '\$${holding.currentValue.toStringAsFixed(2)}',
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
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
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
                  error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(
                    tradeHoldingsStreamProvider(
                      (userId: userId, portfolioId: portfolioId),
                    ),
                  );
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
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
