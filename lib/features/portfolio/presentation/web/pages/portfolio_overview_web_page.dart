import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/portfolio_providers.dart';

/// Web-specific portfolio overview page with comprehensive dashboard
class PortfolioOverviewWebPage extends ConsumerWidget {
  const PortfolioOverviewWebPage({
    required this.userId,
    required this.portfolioId,
    super.key,
    this.portfolioName,
  });
  final String userId;
  final String portfolioId;
  final String? portfolioName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(portfolioSummaryProvider(portfolioId));
    final holdingsAsync = ref.watch(portfolioHoldingsProvider(portfolioId));

    return Scaffold(
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

            // Holdings Overview
            holdingsAsync.when(
              data: (holdings) => _buildHoldingsOverview(context, holdings),
              loading: () => _buildLoadingCard('Loading holdings...'),
              error: (error, stack) => _buildErrorCard(
                context,
                'Failed to load holdings',
                error.toString(),
                () => ref.invalidate(portfolioHoldingsProvider(portfolioId)),
              ),
            ),

            const SizedBox(height: 24),

            // Quick Actions Section
            _buildQuickActionsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, summary) => Card(
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Portfolio Summary',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  context,
                  'Total Value',
                  '\$${summary.totalValue.toStringAsFixed(2)}',
                  Icons.account_balance_wallet,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  context,
                  "Today's Change",
                  '\$${summary.todayChange.toStringAsFixed(2)}',
                  summary.todayChange >= 0
                      ? Icons.trending_up
                      : Icons.trending_down,
                  summary.todayChange >= 0 ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  context,
                  'Total Return',
                  '\$${summary.totalValue.toStringAsFixed(2)}',
                  summary.totalValue >= 0
                      ? Icons.trending_up
                      : Icons.trending_down,
                  summary.totalValue >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _buildHoldingsOverview(BuildContext context, holdings) {
    final holdingsList = holdings.holdings as List<dynamic>;
    final topHoldings = holdingsList.take(5).toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Holdings',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            ...topHoldings.map((holding) => _buildHoldingRow(context, holding)),

            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  // Navigate to full holdings view
                },
                child: const Text('View All Holdings'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHoldingRow(BuildContext context, holding) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              holding.symbol?.substring(0, 2) ?? 'N/A',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                holding.symbol ?? 'Unknown',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '${holding.quantity ?? 0} shares',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${(holding.marketValue ?? 0).toStringAsFixed(2)}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '${(holding.changePercent ?? 0) >= 0 ? '+' : ''}${(holding.changePercent ?? 0).toStringAsFixed(2)}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: (holding.changePercent ?? 0) >= 0
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
        const SizedBox(height: 8),
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

  Widget _buildQuickActionsSection(BuildContext context) => Card(
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(20),
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
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) => ElevatedButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, color: Colors.white),
    label: Text(label, style: const TextStyle(color: Colors.white)),
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  Widget _buildLoadingCard(String message) => Card(
    elevation: 2,
    child: SizedBox(
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

  Widget _buildErrorCard(
    BuildContext context,
    String title,
    String error,
    VoidCallback onRetry,
  ) => Card(
    elevation: 2,
    child: SizedBox(
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
