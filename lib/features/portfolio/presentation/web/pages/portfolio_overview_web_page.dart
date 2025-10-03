import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/portfolio_providers.dart';

/// Web-specific portfolio overview page with comprehensive dashboard
class PortfolioOverviewWebPage extends ConsumerWidget {
  final String userId;
  final String portfolioId;
  final String? portfolioName;

  const PortfolioOverviewWebPage({
    super.key,
    required this.userId,
    required this.portfolioId,
    this.portfolioName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(portfolioSummaryProvider(portfolioId));
    final holdingsAsync = ref.watch(portfolioHoldingsProvider(portfolioId));

    return Scaffold(
      appBar: AppBar(
        title: Text(portfolioName ?? 'Portfolio Overview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(portfolioSummaryProvider(portfolioId));
              ref.invalidate(portfolioHoldingsProvider(portfolioId));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Title
            Text(
              'Portfolio Overview',
              style: Theme.of(
                context,
              ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Summary Section
            summaryAsync.when(
              data: (summary) => _buildSummarySection(context, summary),
              loading: () => _buildLoadingCard('Loading portfolio summary...'),
              error: (error, stack) => _buildErrorCard(
                context,
                'Failed to load portfolio summary',
                error.toString(),
                () => ref.invalidate(portfolioSummaryProvider(portfolioId)),
              ),
            ),

            const SizedBox(height: 24),

            // Charts and Analytics Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column - Allocation Charts
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildSectionTitle(context, 'Allocation Breakdown'),
                      const SizedBox(height: 16),

                      // Sectorial Allocation
                      holdingsAsync.when(
                        data: (holdings) => SectorialAllocationWidget(
                          holdings: holdings.holdings,
                        ),
                        loading: () =>
                            _buildLoadingCard('Loading sector allocation...'),
                        error: (error, stack) => _buildErrorCard(
                          context,
                          'Failed to load sector allocation',
                          error.toString(),
                          () => ref.invalidate(
                            portfolioHoldingsProvider(portfolioId),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Market Cap Allocation
                      holdingsAsync.when(
                        data: (holdings) => MarketCapAllocationWidget(
                          holdings: holdings.holdings,
                        ),
                        loading: () => _buildLoadingCard(
                          'Loading market cap allocation...',
                        ),
                        error: (error, stack) => _buildErrorCard(
                          context,
                          'Failed to load market cap allocation',
                          error.toString(),
                          () => ref.invalidate(
                            portfolioHoldingsProvider(portfolioId),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 24),

                // Right Column - Performance Metrics
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildSectionTitle(context, 'Performance Metrics'),
                      const SizedBox(height: 16),

                      summaryAsync.when(
                        data: (summary) =>
                            _buildPerformanceMetrics(context, summary),
                        loading: () =>
                            _buildLoadingCard('Loading performance metrics...'),
                        error: (error, stack) => _buildErrorCard(
                          context,
                          'Failed to load performance metrics',
                          error.toString(),
                          () => ref.invalidate(
                            portfolioSummaryProvider(portfolioId),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Quick Actions Section
            _buildQuickActionsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, dynamic summary) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: PortfolioSummaryWidget(
          summary: summary,
          onViewHoldings: () {
            // Navigate to holdings view
            AppLogger.userAction(
              'Navigate to Holdings from Overview',
              tag: 'PortfolioOverviewWebPage',
              context: {'portfolioId': portfolioId},
            );
          },
          onViewAnalysis: () {
            // Navigate to analysis view
            AppLogger.userAction(
              'Navigate to Analysis from Overview',
              tag: 'PortfolioOverviewWebPage',
              context: {'portfolioId': portfolioId},
            );
          },
        ),
      ),
    );
  }

  Widget _buildPerformanceMetrics(BuildContext context, dynamic summary) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Key Metrics',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildMetricRow(
              context,
              'Total Return',
              '\$${summary.totalValue.toStringAsFixed(2)}',
              summary.totalValue >= 0 ? Colors.green : Colors.red,
              summary.totalValue >= 0 ? Icons.trending_up : Icons.trending_down,
            ),
            const Divider(),

            _buildMetricRow(
              context,
              'Today\'s Change',
              '\$${summary.todayChange.toStringAsFixed(2)}',
              summary.todayChange >= 0 ? Colors.green : Colors.red,
              summary.todayChange >= 0
                  ? Icons.trending_up
                  : Icons.trending_down,
            ),
            const Divider(),

            _buildMetricRow(
              context,
              'Portfolio Value',
              '\$${summary.totalValue.toStringAsFixed(2)}',
              Colors.blue,
              Icons.account_balance_wallet,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
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
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    'View Holdings',
                    Icons.list_alt,
                    Colors.blue,
                    () {
                      // Navigate to holdings
                      AppLogger.userAction(
                        'Quick Action: View Holdings',
                        tag: 'PortfolioOverviewWebPage',
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    context,
                    'View Analysis',
                    Icons.analytics,
                    Colors.green,
                    () {
                      // Navigate to analysis
                      AppLogger.userAction(
                        'Quick Action: View Analysis',
                        tag: 'PortfolioOverviewWebPage',
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    context,
                    'View Heatmap',
                    Icons.grid_view,
                    Colors.orange,
                    () {
                      // Navigate to heatmap
                      AppLogger.userAction(
                        'Quick Action: View Heatmap',
                        tag: 'PortfolioOverviewWebPage',
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildLoadingCard(String message) {
    return Card(
      elevation: 2,
      child: Container(
        height: 150,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(message),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(
    BuildContext context,
    String title,
    String error,
    VoidCallback onRetry,
  ) {
    return Card(
      elevation: 2,
      child: Container(
        height: 150,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 32,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                error,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
      ),
    );
  }
}
