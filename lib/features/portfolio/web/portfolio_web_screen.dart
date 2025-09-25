import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../widgets/portfolio_holdings_widget.dart';

/// Web-specific portfolio screen implementation
class PortfolioWebScreen extends ConsumerWidget {
  /// User ID for portfolio data
  final String userId;
  
  /// Refresh callback for portfolio data
  final Future<void> Function() refreshPortfolio;

  const PortfolioWebScreen({
    super.key,
    required this.userId,
    required this.refreshPortfolio,
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
              ref.refresh(portfolioSummaryProvider(userId));
              ref.refresh(portfolioHoldingsProvider(userId));
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
                  child: PortfolioHoldingsWidget(
                    userId: userId,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
          '\$${summary.todayChange.toStringAsFixed(2)}',
          summary.todayChange >= 0 ? Icons.trending_up : Icons.trending_down,
          summary.todayChange >= 0 ? Colors.green : Colors.red,
        ),
        const SizedBox(height: 12),
        _buildSummaryCard(
          context,
          'Total Return',
          '\$${summary.totalReturn.toStringAsFixed(2)}',
          summary.totalReturn >= 0 ? Icons.trending_up : Icons.trending_down,
          summary.totalReturn >= 0 ? Colors.green : Colors.red,
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.analytics_outlined,
                                    size: 64,
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Portfolio Analysis',
                                    style: Theme.of(context).textTheme.headlineMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Advanced portfolio analysis features coming soon.',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
