import 'package:flutter/material.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/value_indicator.dart';
import '../../../core/models/portfolio/portfolio_models.dart';
import 'package:intl/intl.dart';

/// Widget to display portfolio summary information
class PortfolioSummaryCard extends StatelessWidget {
  /// Portfolio summary data
  final PortfolioSummary summary;
  
  /// Whether to show detailed information
  final bool showDetails;
  
  /// Callback when the card is tapped
  final VoidCallback? onTap;
  
  /// Constructor
  const PortfolioSummaryCard({
    Key? key,
    required this.summary,
    this.showDetails = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      locale: 'en_IN',
      decimalDigits: 2,
    );
    
    // Format the last updated time
    final lastUpdatedFormatted = DateFormat('MMM d, yyyy • h:mm a').format(summary.lastUpdated);
    
    return AppCard(
      title: 'Portfolio Summary',
      subtitle: 'Last updated: $lastUpdatedFormatted',
      action: onTap != null ? IconButton(
        icon: const Icon(Icons.chevron_right),
        onPressed: onTap,
      ) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Investment value
          Text(
            currencyFormat.format(summary.investmentValue),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Total Investment',
            style: theme.textTheme.bodySmall,
          ),
          
          const SizedBox(height: 16),
          
          // Key metrics in a grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              ValueIndicator(
                label: 'Total Gain/Loss',
                value: summary.totalGainLoss,
                useCompactFormat: true,
              ),
              ValueIndicator(
                label: 'Total Return',
                value: summary.totalGainLossPercentage,
                isPercentage: true,
              ),
              ValueIndicator(
                label: 'Today\'s Gain/Loss',
                value: summary.todayGainLoss,
                useCompactFormat: true,
              ),
              ValueIndicator(
                label: 'Today\'s Return',
                value: summary.todayGainLossPercentage,
                isPercentage: true,
              ),
            ],
          ),
          
          if (showDetails) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            // Portfolio statistics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(context, 'Total Assets', summary.totalAssets.toString()),
                _buildStatItem(context, 'Gainers', summary.gainersCount.toString()),
                _buildStatItem(context, 'Losers', summary.losersCount.toString()),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Broker breakdown
            if (summary.brokerPortfolios.isNotEmpty) ...[
              Text(
                'Broker Breakdown',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...summary.brokerPortfolios.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key),
                      Text(
                        currencyFormat.format(entry.value.investmentValue),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ],
        ],
      ),
    );
  }
  
  /// Build a statistic item
  Widget _buildStatItem(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
