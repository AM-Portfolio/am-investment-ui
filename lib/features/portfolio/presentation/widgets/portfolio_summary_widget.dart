import 'package:flutter/material.dart';
import '../../internal/domain/entities/portfolio_summary.dart';

/// Reusable portfolio summary widget that displays comprehensive portfolio metrics
class PortfolioSummaryWidget extends StatelessWidget {
  final PortfolioSummary summary;
  final VoidCallback? onViewHoldings;
  final VoidCallback? onViewAnalysis;

  const PortfolioSummaryWidget({
    Key? key,
    required this.summary,
    this.onViewHoldings,
    this.onViewAnalysis,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Portfolio Value Card with fixed values
          _buildMainValueCard(context),
          const SizedBox(height: 12),

          // Dynamic Market Data Card
          _buildDynamicMarketCard(context),
          const SizedBox(height: 16),

          // Quick Actions
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  context,
                  'View Holdings',
                  Icons.list_alt,
                  onViewHoldings,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  context,
                  'Analysis',
                  Icons.analytics,
                  onViewAnalysis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build the main portfolio value card with total value and percentage
  Widget _buildMainValueCard(BuildContext context) {
    final isPositive = summary.totalGainLoss >= 0;
    final color = isPositive ? Colors.green : Colors.red;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Theme.of(context).primaryColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total value and percentage in same row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  summary.formattedTotalValue,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      color: color,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${summary.totalGainLossPercentage.toStringAsFixed(2)}%)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Investment Overview within main card
            Row(
              children: [
                Expanded(
                  child: _buildOverviewItem(
                    context,
                    'Invested',
                    '₹${summary.totalInvested.toStringAsFixed(0)}',
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildOverviewItem(
                    context,
                    'Current',
                    '₹${summary.totalValue.toStringAsFixed(0)}',
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildOverviewItem(
                    context,
                    'Total Holdings',
                    summary.totalHoldings.toString(),
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build dynamic market data card that changes frequently
  Widget _buildDynamicMarketCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today's Change and Total Returns Row
            Row(
              children: [
                Expanded(
                  child: _buildPerformanceItem(
                    context,
                    'Today\'s Change',
                    summary.formattedTodayChange,
                    '${summary.todayChangePercentage.toStringAsFixed(2)}%',
                    summary.isTodayPositive,
                    Icons.today,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPerformanceItem(
                    context,
                    'Total Returns',
                    summary.formattedGainLoss,
                    '${summary.totalGainLossPercentage.toStringAsFixed(2)}%',
                    summary.isProfitable,
                    Icons.trending_up,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Today's Gainers/Losers Row
            Row(
              children: [
                Expanded(
                  child: _buildSimpleGainerLoserItem(
                    context,
                    'Today',
                    summary.todayGainersCount,
                    summary.todayLosersCount,
                    Icons.today,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSimpleGainerLoserItem(
                    context,
                    'Overall',
                    summary.gainersCount,
                    summary.losersCount,
                    Icons.trending_up,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Last updated time
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Last updated: ${_formatDateTime(summary.lastUpdated)}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build individual performance item for dynamic card
  Widget _buildPerformanceItem(
    BuildContext context,
    String title,
    String value,
    String percentage,
    bool isPositive,
    IconData icon,
  ) {
    final color = isPositive ? Colors.green : Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
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
        const SizedBox(height: 2),
        Text(
          percentage,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
        ),
      ],
    );
  }

  /// Build individual overview item
  Widget _buildOverviewItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Build simple gainer/loser item with XX/XX format
  Widget _buildSimpleGainerLoserItem(
    BuildContext context,
    String label,
    int gainersCount,
    int losersCount,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            children: [
              TextSpan(
                text: gainersCount.toString(),
                style: const TextStyle(color: Colors.green),
              ),
              TextSpan(
                text: '/',
                style: TextStyle(color: Colors.grey[600]),
              ),
              TextSpan(
                text: losersCount.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Format datetime for display
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback? onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, size: 28, color: Theme.of(context).primaryColor),
              const SizedBox(height: 6),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
