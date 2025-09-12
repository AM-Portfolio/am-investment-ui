import 'package:flutter/material.dart';
import '../../../core/models/portfolio/portfolio_models.dart';
import '../widgets/stock_details_item.dart';
import 'package:intl/intl.dart';

/// Screen to display details of a specific category (market cap or sector)
class CategoryDetailsScreen extends StatefulWidget {
  /// Category name
  final String categoryName;
  
  /// List of assets in this category
  final List<AssetHolding> assets;
  
  /// Category type (market cap or sector)
  final CategoryType categoryType;
  
  /// Constructor
  const CategoryDetailsScreen({
    Key? key,
    required this.categoryName,
    required this.assets,
    required this.categoryType,
  }) : super(key: key);

  @override
  State<CategoryDetailsScreen> createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  /// Set of expanded asset IDs
  final Set<String> _expandedAssets = {};
  
  /// Toggle asset expansion
  void _toggleAssetExpansion(String assetId) {
    setState(() {
      if (_expandedAssets.contains(assetId)) {
        _expandedAssets.remove(assetId);
      } else {
        _expandedAssets.add(assetId);
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      locale: 'en_IN',
      decimalDigits: 2,
    );
    
    // Calculate total investment for this category
    final totalInvestment = widget.assets.fold<double>(
      0,
      (sum, asset) => sum + asset.investmentCost,
    );
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        actions: [
          // Toggle all button
          IconButton(
            icon: Icon(
              _expandedAssets.length == widget.assets.length 
                  ? Icons.unfold_less 
                  : Icons.unfold_more
            ),
            onPressed: () {
              setState(() {
                if (_expandedAssets.length == widget.assets.length) {
                  _expandedAssets.clear();
                } else {
                  _expandedAssets.addAll(
                    widget.assets.map((asset) => asset.isin),
                  );
                }
              });
            },
            tooltip: _expandedAssets.length == widget.assets.length 
                ? 'Collapse all' 
                : 'Expand all',
          ),
        ],
      ),
      body: Column(
        children: [
          // Category summary card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category type and name
                  Text(
                    '${widget.categoryType == CategoryType.marketCap ? 'Market Cap' : 'Sector'} Category',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    widget.categoryName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Category stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem(
                        context, 
                        'Total Investment', 
                        currencyFormat.format(totalInvestment),
                      ),
                      _buildStatItem(
                        context, 
                        'Assets', 
                        widget.assets.length.toString(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Assets list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.assets.length,
              itemBuilder: (context, index) {
                final asset = widget.assets[index];
                final isExpanded = _expandedAssets.contains(asset.isin);
                
                return StockDetailsItem(
                  asset: asset,
                  showDetails: isExpanded,
                  onTap: () => _toggleAssetExpansion(asset.isin),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build a statistic item
  Widget _buildStatItem(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Category type enum
enum CategoryType {
  /// Market capitalization category
  marketCap,
  
  /// Sector category
  sector,
}
