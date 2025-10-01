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
          // Main Portfolio Value Card
          _buildMainValueCard(context),
          const SizedBox(height: 12),

          // Performance Cards Row
          _buildPerformanceRow(context),
          const SizedBox(height: 12),

          // Investment Overview
          _buildInvestmentOverviewCard(context),
          const SizedBox(height: 12),

          // Portfolio Statistics
          _buildStatisticsCard(context),
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
            Text(
              summary.formattedTotalValue,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '${isPositive ? '+' : ''}${summary.formattedGainLoss}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${summary.totalGainLossPercentage.toStringAsFixed(2)}%)',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build performance row showing today's and total performance
  Widget _buildPerformanceRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildPerformanceCard(
            context,
            'Today\'s Change',
            summary.formattedTodayChange,
            '${summary.todayChangePercentage.toStringAsFixed(2)}%',
            summary.isTodayPositive,
            Icons.today,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPerformanceCard(
            context,
            'Total Returns',
            summary.formattedGainLoss,
            '${summary.totalGainLossPercentage.toStringAsFixed(2)}%',
            summary.isProfitable,
            Icons.trending_up,
          ),
        ),
      ],
    );
  }

  /// Build individual performance card
  Widget _buildPerformanceCard(
    BuildContext context,
    String title,
    String value,
    String percentage,
    bool isPositive,
    IconData icon,
  ) {
    final color = isPositive ? Colors.green : Colors.red;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              percentage,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }

  /// Build investment overview card
  Widget _buildInvestmentOverviewCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: _buildOverviewItem(
                context,
                'Invested',
                '₹${summary.totalInvested.toStringAsFixed(0)}',
                Colors.blue,
              ),
            ),
            Expanded(
              child: _buildOverviewItem(
                context,
                'Current',
                '₹${summary.totalValue.toStringAsFixed(0)}',
                Colors.orange,
              ),
            ),
          ],
        ),
      ),
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

  /// Build statistics card with holdings and performance metrics
  Widget _buildStatisticsCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Total Assets',
                    summary.totalAssets.toString(),
                    Icons.account_balance,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Holdings',
                    summary.totalHoldings.toString(),
                    Icons.folder,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Gainers',
                    '${summary.todayGainersCount}/${summary.gainersCount}',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Losers',
                    '${summary.todayLosersCount}/${summary.losersCount}',
                    Icons.trending_down,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
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

  /// Build individual statistic item
  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon, [
    Color? iconColor,
  ]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: iconColor ?? Colors.grey[600]),
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
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
