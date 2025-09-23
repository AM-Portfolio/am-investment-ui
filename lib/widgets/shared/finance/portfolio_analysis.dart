import 'package:flutter/material.dart';
import '../../../core/domain/entities/portfolio/portfolio_summary.dart';

/// A widget to display portfolio analysis metrics
class PortfolioAnalysis extends StatelessWidget {
  /// Portfolio summary data
  final PortfolioSummary summary;

  /// Whether to show detailed information
  final bool showDetails;

  /// Constructor
  const PortfolioAnalysis({
    super.key,
    required this.summary,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Placeholder for portfolio analysis
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 64,
                  color: theme.colorScheme.primary.withOpacity(0.7),
                ),
                const SizedBox(height: 16),
                Text('Portfolio Analysis', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'Advanced portfolio analysis metrics coming soon',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('This feature is coming soon'),
                      ),
                    );
                  },
                  child: const Text('Request Early Access'),
                ),
              ],
            ),
          ),
        ),

        if (showDetails) ...[
          const SizedBox(height: 24),

          // Future analysis metrics sections will be added here
          _buildComingSoonSection(context, 'Performance Metrics'),
          const SizedBox(height: 16),
          _buildComingSoonSection(context, 'Risk Analysis'),
          const SizedBox(height: 16),
          _buildComingSoonSection(context, 'Sector Allocation'),
        ],
      ],
    );
  }

  /// Build a coming soon section
  Widget _buildComingSoonSection(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.hourglass_empty,
            color: theme.colorScheme.primary.withOpacity(0.7),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Coming soon',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  /// Show the portfolio analysis dialog
  static void showDialog(BuildContext context, PortfolioSummary summary) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Portfolio Analysis',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Analysis content
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  child: PortfolioAnalysis(summary: summary, showDetails: true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
