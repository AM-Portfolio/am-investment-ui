import 'package:flutter/material.dart';
import '../../../core/models/portfolio/portfolio_models.dart';
import '../../../core/widgets/value_indicator.dart';
import 'package:intl/intl.dart';

/// Widget to display detailed information about a stock
class StockDetailsItem extends StatelessWidget {
  /// The asset holding data
  final AssetHolding asset;
  
  /// Whether to show expanded details
  final bool showDetails;
  
  /// Callback when the item is tapped
  final VoidCallback? onTap;
  
  /// Constructor
  const StockDetailsItem({
    Key? key,
    required this.asset,
    this.showDetails = false,
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
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stock header with symbol and investment cost
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          asset.symbol,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (asset.marketCap != null)
                        _buildChip(
                          context, 
                          _formatMarketCap(asset.marketCap!),
                          color: _getMarketCapColor(context, asset.marketCap!),
                        ),
                    ],
                  ),
                  Text(
                    currencyFormat.format(asset.investmentCost),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Quantity and sector info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quantity: ${asset.quantity.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (asset.sector != null)
                    Text(
                      asset.sector!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
              
              // Expanded details section
              if (showDetails) ...[
                const Divider(height: 24),
                
                // ISIN code
                _buildDetailRow(context, 'ISIN', asset.isin),
                
                // Industry if different from sector
                if (asset.industry != null && asset.industry != asset.sector)
                  _buildDetailRow(context, 'Industry', asset.industry!),
                
                // Broker breakdown
                if (asset.brokerPortfolios.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Broker Breakdown',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  ...asset.brokerPortfolios.map((broker) => 
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(broker.brokerType),
                          Text(
                            '${broker.quantity.toStringAsFixed(2)} units',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
              
              // Show more/less button
              if (onTap != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onTap,
                    child: Text(showDetails ? 'Show less' : 'Show more'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Build a detail row with label and value
  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
  
  /// Build a chip with text
  Widget _buildChip(BuildContext context, String text, {Color? color}) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color ?? theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
  
  /// Format market cap category for display
  String _formatMarketCap(String marketCap) {
    final parts = marketCap.split('_');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[0].substring(1).toLowerCase()} ${parts[1][0]}${parts[1].substring(1).toLowerCase()}';
    }
    return marketCap[0] + marketCap.substring(1).toLowerCase();
  }
  
  /// Get color based on market cap
  Color _getMarketCapColor(BuildContext context, String marketCap) {
    final theme = Theme.of(context);
    
    switch (marketCap) {
      case 'LARGE_CAP':
        return Colors.blue.shade700;
      case 'MID_CAP':
        return Colors.green.shade700;
      case 'SMALL_CAP':
        return Colors.orange.shade700;
      case 'MICRO_CAP':
        return Colors.purple.shade700;
      default:
        return theme.colorScheme.secondaryContainer;
    }
  }
}
