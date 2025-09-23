import 'package:flutter/material.dart';
import '../../../core/models/portfolio/portfolio_models.dart';
import '../../../widgets/shared/finance/portfolio_summary_card.dart';
import '../../../widgets/shared/finance/holdings_breakdown.dart';

/// Android-specific implementation of the portfolio summary screen
class PortfolioAndroidScreen extends StatelessWidget {
  /// Future for portfolio summary data
  final Future<PortfolioSummary> portfolioSummaryFuture;

  /// Callback to refresh portfolio data
  final Future<void> Function() refreshPortfolio;

  /// User ID for portfolio data
  final String userId;

  /// Constructor
  const PortfolioAndroidScreen({
    super.key,
    required this.portfolioSummaryFuture,
    required this.refreshPortfolio,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio Summary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refreshPortfolio,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refreshPortfolio,
        child: FutureBuilder<PortfolioSummary>(
          future: portfolioSummaryFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _buildErrorState(context, snapshot.error.toString());
            }

            final summary = snapshot.data!;

            // Android-specific layout with Material Design
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                PortfolioSummaryCard(summary: summary, showDetails: true),
                const SizedBox(height: 16),
                HoldingsBreakdown(summary: summary),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Build error state widget with Material Design
  Widget _buildErrorState(BuildContext context, String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 24),
            Text(
              'Error loading portfolio data',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: refreshPortfolio,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
