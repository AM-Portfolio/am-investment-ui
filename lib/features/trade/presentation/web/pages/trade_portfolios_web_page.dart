import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Web page for displaying available portfolios for trade analysis
class TradePortfoliosWebPage extends ConsumerStatefulWidget {
  const TradePortfoliosWebPage({
    required this.onPortfolioSelected,
    super.key,
  });

  final Function(String portfolioId, String portfolioName) onPortfolioSelected;

  @override
  ConsumerState<TradePortfoliosWebPage> createState() => _TradePortfoliosWebPageState();
}

class _TradePortfoliosWebPageState extends ConsumerState<TradePortfoliosWebPage> {
  String _searchQuery = '';
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trade Portfolios',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Select a portfolio to analyze trading activities',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Search and Filter Bar
                Row(
                  children: [
                    // Search Field
                    Expanded(
                      flex: 2,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search portfolios...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Filter Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      child: DropdownButton<String>(
                        value: _selectedFilter,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.filter_list),
                        hint: const Text('Filter'),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('All Portfolios')),
                          DropdownMenuItem(value: 'active', child: Text('Active')),
                          DropdownMenuItem(value: 'high_volume', child: Text('High Volume')),
                          DropdownMenuItem(value: 'recent', child: Text('Recent Activity')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedFilter = value ?? 'all';
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Portfolio Grid
          Expanded(
            child: _buildPortfolioGrid(context),
          ),
        ],
      ),
    );
  }

  /// Build the portfolio grid
  Widget _buildPortfolioGrid(BuildContext context) {
    // Mock portfolios data - replace with actual provider
    final portfolios = _getMockPortfolios();
    
    // Filter portfolios based on search and filter
    final filteredPortfolios = portfolios.where((portfolio) {
      final matchesSearch = portfolio.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          portfolio.id.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesFilter = _selectedFilter == 'all' ||
          (_selectedFilter == 'active' && portfolio.isActive) ||
          (_selectedFilter == 'high_volume' && portfolio.tradeCount > 50) ||
          (_selectedFilter == 'recent' && portfolio.lastTradeDate.isAfter(
            DateTime.now().subtract(const Duration(days: 30))
          ));

      return matchesSearch && matchesFilter;
    }).toList();

    if (filteredPortfolios.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No portfolios found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filter criteria',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: filteredPortfolios.length,
        itemBuilder: (context, index) {
          final portfolio = filteredPortfolios[index];
          return _buildPortfolioCard(context, portfolio);
        },
      ),
    );
  }

  /// Build individual portfolio card
  Widget _buildPortfolioCard(BuildContext context, _MockPortfolio portfolio) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => widget.onPortfolioSelected(portfolio.id, portfolio.name),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Portfolio Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: portfolio.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      portfolio.icon,
                      color: portfolio.color,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: portfolio.isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      portfolio.isActive ? 'Active' : 'Inactive',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: portfolio.isActive ? Colors.green.shade700 : Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Portfolio Name
              Text(
                portfolio.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Portfolio ID
              Text(
                portfolio.id,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontFamily: 'monospace',
                ),
              ),

              const Spacer(),

              // Portfolio Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${portfolio.tradeCount}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: portfolio.color,
                        ),
                      ),
                      Text(
                        'Trades',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        portfolio.totalValue,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Total Value',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Last Trade Date
              Text(
                'Last trade: ${_formatDate(portfolio.lastTradeDate)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  /// Get mock portfolios - replace with actual data
  List<_MockPortfolio> _getMockPortfolios() {
    return [
      _MockPortfolio(
        id: 'PORT001',
        name: 'Growth Portfolio',
        isActive: true,
        tradeCount: 142,
        totalValue: '\$2.4M',
        lastTradeDate: DateTime.now().subtract(const Duration(days: 2)),
        icon: Icons.trending_up,
        color: Colors.green,
      ),
      _MockPortfolio(
        id: 'PORT002',
        name: 'Conservative Portfolio',
        isActive: true,
        tradeCount: 87,
        totalValue: '\$1.8M',
        lastTradeDate: DateTime.now().subtract(const Duration(days: 5)),
        icon: Icons.shield,
        color: Colors.blue,
      ),
      _MockPortfolio(
        id: 'PORT003',
        name: 'Tech Focused',
        isActive: true,
        tradeCount: 203,
        totalValue: '\$3.1M',
        lastTradeDate: DateTime.now().subtract(const Duration(hours: 6)),
        icon: Icons.computer,
        color: Colors.purple,
      ),
      _MockPortfolio(
        id: 'PORT004',
        name: 'Dividend Strategy',
        isActive: false,
        tradeCount: 45,
        totalValue: '\$950K',
        lastTradeDate: DateTime.now().subtract(const Duration(days: 45)),
        icon: Icons.account_balance,
        color: Colors.orange,
      ),
      _MockPortfolio(
        id: 'PORT005',
        name: 'International Equity',
        isActive: true,
        tradeCount: 156,
        totalValue: '\$2.7M',
        lastTradeDate: DateTime.now().subtract(const Duration(days: 1)),
        icon: Icons.public,
        color: Colors.teal,
      ),
      _MockPortfolio(
        id: 'PORT006',
        name: 'Emerging Markets',
        isActive: true,
        tradeCount: 98,
        totalValue: '\$1.2M',
        lastTradeDate: DateTime.now().subtract(const Duration(days: 8)),
        icon: Icons.explore,
        color: Colors.red,
      ),
    ];
  }
}

/// Mock portfolio model for demonstration
class _MockPortfolio {
  final String id;
  final String name;
  final bool isActive;
  final int tradeCount;
  final String totalValue;
  final DateTime lastTradeDate;
  final IconData icon;
  final Color color;

  const _MockPortfolio({
    required this.id,
    required this.name,
    required this.isActive,
    required this.tradeCount,
    required this.totalValue,
    required this.lastTradeDate,
    required this.icon,
    required this.color,
  });
}