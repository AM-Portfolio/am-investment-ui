import 'package:flutter/material.dart';

/// Reusable portfolio summary widget that displays key portfolio metrics
class PortfolioSummaryWidget extends StatelessWidget {
  final double totalValue;
  final double todayChange;
  final double totalGainLoss;
  final VoidCallback? onViewHoldings;
  final VoidCallback? onViewAnalysis;

  const PortfolioSummaryWidget({
    Key? key,
    required this.totalValue,
    required this.todayChange,
    required this.totalGainLoss,
    this.onViewHoldings,
    this.onViewAnalysis,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Portfolio Summary Cards
          _buildSummaryCard(
            context,
            'Total Value',
            '₹${totalValue.toStringAsFixed(2)}',
            Icons.account_balance_wallet,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildSummaryCard(
            context,
            'Today\'s Change',
            '₹${todayChange.toStringAsFixed(2)}',
            todayChange >= 0 ? Icons.trending_up : Icons.trending_down,
            todayChange >= 0 ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 12),
          _buildSummaryCard(
            context,
            'Total Return',
            '₹${totalGainLoss.toStringAsFixed(2)}',
            totalGainLoss >= 0 ? Icons.trending_up : Icons.trending_down,
            totalGainLoss >= 0 ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 24),

          // Quick Actions
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
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

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}