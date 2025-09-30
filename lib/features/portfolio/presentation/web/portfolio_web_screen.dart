import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/portfolio_holdings_web_card.dart';
import '../../providers/portfolio_providers.dart';

/// Web-specific portfolio screen implementation
class PortfolioWebScreen extends ConsumerWidget {
  /// User ID for portfolio data
  final String userId;

  const PortfolioWebScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(portfolioSummaryProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(portfolioSummaryProvider(userId));
              ref.invalidate(portfolioHoldingsProvider(userId));
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Left sidebar for summary
          Container(
            width: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: _buildSummarySection(context, summaryAsync),
          ),
          // Main content area for holdings
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Holdings',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Expanded(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final holdingsAsync = ref.watch(portfolioHoldingsProvider(userId));
                      return holdingsAsync.when(
                        data: (portfolioHoldings) => PortfolioHoldingsWebCard(
                          holdings: portfolioHoldings,
                          showDetails: true,
                          maxHoldings: 50,
                          onHoldingTap: (holding) {
                            // Handle holding tap - could show details dialog
                          },
                        ),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (error, stack) => Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error loading holdings',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$error',
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => ref.invalidate(portfolioHoldingsProvider(userId)),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, AsyncValue summaryAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Portfolio Summary',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        summaryAsync.when(
          data: (summary) => _buildSummaryCards(context, summary),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildSummaryError(context, error.toString()),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(BuildContext context, dynamic summary) {
    return Column(
      children: [
        _buildSummaryCard(
          context,
          'Total Value',
          '\$${summary.totalValue.toStringAsFixed(2)}',
          Icons.account_balance_wallet,
          Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildSummaryCard(
          context,
          'Today\'s Change',
          '\$${summary.dailyChange.toStringAsFixed(2)}',
          summary.dailyChange >= 0 ? Icons.trending_up : Icons.trending_down,
          summary.dailyChange >= 0 ? Colors.green : Colors.red,
        ),
        const SizedBox(height: 12),
        _buildSummaryCard(
          context,
          'Total Return',
          '\$${summary.totalValue.toStringAsFixed(2)}',
          summary.totalValue >= 0 ? Icons.trending_up : Icons.trending_down,
          summary.totalValue >= 0 ? Colors.green : Colors.red,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryError(BuildContext context, String error) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 32),
            const SizedBox(height: 8),
            Text(
              'Failed to load summary',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              error,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}