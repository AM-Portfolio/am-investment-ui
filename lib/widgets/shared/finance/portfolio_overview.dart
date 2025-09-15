import 'package:flutter/material.dart';
import '../../../core/models/portfolio/portfolio_models.dart';
import 'portfolio_summary_card.dart';
import 'holdings_breakdown.dart';

/// A widget to display portfolio overview information
class PortfolioOverview extends StatelessWidget {
  /// Portfolio summary data
  final PortfolioSummary summary;
  
  /// Callback to refresh portfolio data
  final Future<void> Function() onRefresh;
  
  /// Constructor
  const PortfolioOverview({
    Key? key,
    required this.summary,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Portfolio summary card
        PortfolioSummaryCard(
          summary: summary,
          showDetails: true,
        ),
        
        const SizedBox(height: 32),
        
        // Holdings breakdown
        HoldingsBreakdown(
          summary: summary,
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
              icon: const Icon(Icons.download_outlined),
              label: const Text('Export'),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () async {
                // Refresh portfolio data
                await onRefresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ],
    );
  }
}
