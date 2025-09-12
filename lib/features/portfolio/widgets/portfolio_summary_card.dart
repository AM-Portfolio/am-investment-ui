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
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modern header with glass effect
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.08),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet_outlined,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Portfolio Summary',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Last updated: $lastUpdatedFormatted',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (onTap != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          CupertinoIcons.chevron_right,
                          color: theme.colorScheme.primary,
                          size: 16,
                        ),
                      ),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Investment value with modern design
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          currencyFormat.format(summary.investmentValue),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            'Total Investment',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Modern metrics layout with cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // First row of metrics
                    Row(
                      children: [
                        Expanded(
                          child: _buildModernMetricCard(
                            context,
                            'Total Gain/Loss',
                            summary.totalGainLoss,
                            icon: Icons.trending_up,
                            isPercentage: false,
                            useCompactFormat: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildModernMetricCard(
                            context,
                            'Total Return',
                            summary.totalGainLossPercentage,
                            icon: Icons.percent,
                            isPercentage: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Second row of metrics
                    Row(
                      children: [
                        Expanded(
                          child: _buildModernMetricCard(
                            context,
                            'Today\'s Gain/Loss',
                            summary.todayGainLoss,
                            icon: Icons.today,
                            isPercentage: false,
                            useCompactFormat: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildModernMetricCard(
                            context,
                            'Today\'s Return',
                            summary.todayGainLossPercentage,
                            icon: Icons.show_chart,
                            isPercentage: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              if (showDetails) ...[
                const SizedBox(height: 24),
                
                // Portfolio statistics in modern cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section title with subtle divider
                      Row(
                        children: [
                          Container(
                            width: 30,
                            height: 2,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Portfolio Statistics',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Stats in a modern row
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildModernStatItem(
                              context, 
                              'Assets',
                              summary.totalAssets.toString(),
                              Icons.pie_chart_outline,
                            ),
                            _buildModernStatItem(
                              context, 
                              'Gainers',
                              summary.gainersCount.toString(),
                              Icons.trending_up_outlined,
                              color: Colors.green,
                            ),
                            _buildModernStatItem(
                              context, 
                              'Losers',
                              summary.losersCount.toString(),
                              Icons.trending_down_outlined,
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Broker breakdown with modern styling
                      if (summary.brokerPortfolios.isNotEmpty) ...[
                        // Section title with subtle divider
                        Row(
                          children: [
                            Container(
                              width: 30,
                              height: 2,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Broker Breakdown',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Broker list with modern styling
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.colorScheme.outline.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            children: [
                              ...summary.brokerPortfolios.entries.map((entry) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primary.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.account_balance_outlined,
                                              size: 14,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            entry.key,
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        currencyFormat.format(entry.value.investmentValue),
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  /// Build a modern statistic item
  Widget _buildModernStatItem(BuildContext context, String label, String value, IconData icon, {
    Color? color,
  }) {
    final theme = Theme.of(context);
    final accentColor = color ?? theme.colorScheme.primary;
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: accentColor,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
  
  /// Build a modern metric card with value indicator
  Widget _buildModernMetricCard(BuildContext context, String label, double value, {
    required IconData icon,
    bool isPercentage = false,
    bool useCompactFormat = false,
  }) {
    final theme = Theme.of(context);
    
    // Determine color based on value
    Color accentColor;
    IconData indicatorIcon = icon;
    
    if (value > 0) {
      accentColor = Colors.green.shade600;
    } else if (value < 0) {
      accentColor = Colors.red.shade600;
    } else {
      accentColor = theme.colorScheme.primary;
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: accentColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label and icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  indicatorIcon,
                  size: 14,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Value
          Text(
            formattedValue,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: accentColor,
              letterSpacing: -0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
