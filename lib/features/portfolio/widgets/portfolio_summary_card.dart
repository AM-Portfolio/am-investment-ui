import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and last updated
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Portfolio Summary',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (onTap != null)
                    Icon(
                      CupertinoIcons.chevron_right,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                ],
              ),
              
              // Last updated info
              Padding(
                padding: const EdgeInsets.only(left: 32, top: 4, bottom: 16),
                child: Text(
                  'Last updated: $lastUpdatedFormatted',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
              
              // Investment value with decorative background
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Investment',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currencyFormat.format(summary.investmentValue),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Key metrics in a more compact layout
              Row(
                children: [
                  Expanded(
                    child: _buildCompactMetricCard(
                      context,
                      'Total Gain/Loss',
                      summary.totalGainLoss,
                      isPercentage: false,
                      useCompactFormat: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildCompactMetricCard(
                      context,
                      'Total Return',
                      summary.totalGainLossPercentage,
                      isPercentage: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildCompactMetricCard(
                      context,
                      'Today\'s Gain/Loss',
                      summary.todayGainLoss,
                      isPercentage: false,
                      useCompactFormat: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildCompactMetricCard(
                      context,
                      'Today\'s Return',
                      summary.todayGainLossPercentage,
                      isPercentage: true,
                    ),
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
        ),
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
  
  /// Build a compact metric card with value indicator
  Widget _buildCompactMetricCard(BuildContext context, String label, double value, {
    bool isPercentage = false,
    bool useCompactFormat = false,
  }) {
    final theme = Theme.of(context);
    
    // Determine color based on value
    Color textColor;
    IconData? indicatorIcon;
    
    if (value > 0) {
      textColor = Colors.green;
      indicatorIcon = Icons.arrow_upward;
    } else if (value < 0) {
      textColor = Colors.red;
      indicatorIcon = Icons.arrow_downward;
    } else {
      textColor = theme.colorScheme.onSurface;
      indicatorIcon = null;
    }
    
    // Format the value
    String formattedValue;
    if (isPercentage) {
      formattedValue = '${value.abs().toStringAsFixed(2)}%';
    } else if (useCompactFormat) {
      if (value.abs() >= 1000000) {
        formattedValue = '₹${(value.abs() / 1000000).toStringAsFixed(2)}M';
      } else if (value.abs() >= 1000) {
        formattedValue = '₹${(value.abs() / 1000).toStringAsFixed(2)}K';
      } else {
        formattedValue = '₹${value.abs().toStringAsFixed(2)}';
      }
    } else {
      formattedValue = '₹${value.abs().toStringAsFixed(2)}';
    }
    
    // Add sign if needed
    if (value > 0) {
      formattedValue = '+$formattedValue';
    } else if (value < 0 && !isPercentage) {
      formattedValue = '-$formattedValue';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: value > 0 ? Colors.green.shade50 : 
               value < 0 ? Colors.red.shade50 : 
               theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: value > 0 ? Colors.green.shade200 : 
                 value < 0 ? Colors.red.shade200 : 
                 theme.colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (indicatorIcon != null)
                Icon(
                  indicatorIcon,
                  size: 14,
                  color: textColor,
                ),
              if (indicatorIcon != null) const SizedBox(width: 2),
              Expanded(
                child: Text(
                  formattedValue,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Build a metric card with value indicator
  Widget _buildMetricCard(BuildContext context, String label, double value, {
    bool isPercentage = false,
    bool useCompactFormat = false,
  }) {
    final theme = Theme.of(context);
    
    // Determine color based on value
    Color cardColor;
    IconData? indicatorIcon;
    
    if (value > 0) {
      cardColor = Colors.green.shade50;
      indicatorIcon = Icons.arrow_upward;
    } else if (value < 0) {
      cardColor = Colors.red.shade50;
      indicatorIcon = Icons.arrow_downward;
    } else {
      cardColor = theme.colorScheme.surfaceVariant;
      indicatorIcon = null;
    }
    
    return Card(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            Text(
              label,
              style: theme.textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            // Value with indicator
            Row(
              children: [
                if (indicatorIcon != null)
                  Icon(
                    indicatorIcon,
                    size: 16,
                    color: value > 0 ? Colors.green : Colors.red,
                  ),
                const SizedBox(width: 4),
                Expanded(
                  child: ValueIndicator(
                    label: '',
                    value: value,
                    isPercentage: isPercentage,
                    useCompactFormat: useCompactFormat,
                    showIndicator: false,
                    valueStyle: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
