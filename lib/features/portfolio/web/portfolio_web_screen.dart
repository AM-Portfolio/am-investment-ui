import 'package:flutter/material.dart';
import '../../../core/models/portfolio/portfolio_models.dart';
import '../../../core/services/api/api_client.dart';
import '../../../widgets/shared/finance/portfolio_summary_card.dart';
import '../../../widgets/shared/finance/holdings_breakdown.dart';
import '../../../widgets/shared/layouts/web_layout.dart';

/// Web-specific implementation of the portfolio summary screen
class PortfolioWebScreen extends StatelessWidget {
  /// Future for portfolio summary data
  final Future<ApiResponse<PortfolioSummary>> portfolioSummaryFuture;
  
  /// Callback to refresh portfolio data
  final Future<void> Function() refreshPortfolio;
  
  /// Constructor
  const PortfolioWebScreen({
    Key? key,
    required this.portfolioSummaryFuture,
    required this.refreshPortfolio,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WebLayout(
      title: 'Portfolio Summary',
      activeNavItem: 'Portfolio',
      child: _buildPortfolioContent(context),
    );
  }
  
  /// Build the portfolio content
  Widget _buildPortfolioContent(BuildContext context) {
    return FutureBuilder<ApiResponse<PortfolioSummary>>(
      future: portfolioSummaryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (snapshot.hasError) {
          return _buildErrorState(context, snapshot.error.toString());
        }
        
        final response = snapshot.data!;
        
        if (!response.isSuccess) {
          return _buildErrorState(context, response.error ?? 'Unknown error');
        }
        
        final summary = response.data!;
        
        // Web-specific layout with responsive design
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page title
                  Text(
                    'Portfolio Summary',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Portfolio content
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left column - Summary card
                      Expanded(
                        flex: 3,
                        child: PortfolioSummaryCard(
                          summary: summary,
                          showDetails: true,
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Right column - Holdings breakdown
                      Expanded(
                        flex: 4,
                        child: HoldingsBreakdown(
                          summary: summary,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          // Export portfolio
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Export feature coming soon')),
                          );
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('Export'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: refreshPortfolio,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build error state widget
  Widget _buildErrorState(BuildContext context, String errorMessage) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 24),
                Text(
                  'Error loading portfolio data',
                  style: Theme.of(context).textTheme.headlineSmall,
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
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
