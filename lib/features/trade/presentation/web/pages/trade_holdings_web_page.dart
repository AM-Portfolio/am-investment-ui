import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Web page for displaying detailed trade holdings for a selected portfolio
class TradeHoldingsWebPage extends ConsumerStatefulWidget {
  const TradeHoldingsWebPage({
    required this.portfolioId,
    required this.portfolioName,
    super.key,
  });

  final String portfolioId;
  final String portfolioName;

  @override
  ConsumerState<TradeHoldingsWebPage> createState() => _TradeHoldingsWebPageState();
}

class _TradeHoldingsWebPageState extends ConsumerState<TradeHoldingsWebPage> {
  String _searchQuery = '';
  String _selectedFilter = 'all';
  String _sortBy = 'symbol';
  bool _sortAscending = true;

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
                // Portfolio Info
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
                            'Trade Holdings',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                widget.portfolioName,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  widget.portfolioId,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Portfolio Summary Stats
                    Row(
                      children: [
                        _buildSummaryCard(
                          context,
                          title: 'Total Holdings',
                          value: '24',
                          subtitle: 'Positions',
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 16),
                        _buildSummaryCard(
                          context,
                          title: 'Total Value',
                          value: '\$2.4M',
                          subtitle: 'Market Value',
                          color: Colors.green,
                        ),
                        const SizedBox(width: 16),
                        _buildSummaryCard(
                          context,
                          title: 'P&L',
                          value: '+\$145K',
                          subtitle: 'Unrealized',
                          color: Colors.orange,
                        ),
                      ],
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
                          hintText: 'Search by symbol, company name...',
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
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('All Holdings')),
                          DropdownMenuItem(value: 'profitable', child: Text('Profitable')),
                          DropdownMenuItem(value: 'losing', child: Text('Losing')),
                          DropdownMenuItem(value: 'large_positions', child: Text('Large Positions')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedFilter = value ?? 'all';
                          });
                        },
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Sort Dropdown
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
                        value: _sortBy,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.sort),
                        items: const [
                          DropdownMenuItem(value: 'symbol', child: Text('Symbol')),
                          DropdownMenuItem(value: 'value', child: Text('Market Value')),
                          DropdownMenuItem(value: 'pnl', child: Text('P&L')),
                          DropdownMenuItem(value: 'quantity', child: Text('Quantity')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _sortBy = value ?? 'symbol';
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Holdings Table
          Expanded(
            child: _buildHoldingsTable(context),
          ),
        ],
      ),
    );
  }

  /// Build summary card widget
  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// Build the holdings table
  Widget _buildHoldingsTable(BuildContext context) {
    final holdings = _getMockHoldings();
    
    // Apply filtering and sorting
    var filteredHoldings = holdings.where((holding) {
      final matchesSearch = holding.symbol.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          holding.companyName.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesFilter = _selectedFilter == 'all' ||
          (_selectedFilter == 'profitable' && holding.unrealizedPnL > 0) ||
          (_selectedFilter == 'losing' && holding.unrealizedPnL < 0) ||
          (_selectedFilter == 'large_positions' && holding.marketValue > 100000);

      return matchesSearch && matchesFilter;
    }).toList();

    // Sort holdings
    filteredHoldings.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'symbol':
          comparison = a.symbol.compareTo(b.symbol);
          break;
        case 'value':
          comparison = a.marketValue.compareTo(b.marketValue);
          break;
        case 'pnl':
          comparison = a.unrealizedPnL.compareTo(b.unrealizedPnL);
          break;
        case 'quantity':
          comparison = a.quantity.compareTo(b.quantity);
          break;
        default:
          comparison = a.symbol.compareTo(b.symbol);
      }
      return _sortAscending ? comparison : -comparison;
    });

    if (filteredHoldings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No holdings found',
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: DataTable(
        columns: [
          DataColumn(
            label: const Text('Symbol'),
            onSort: (columnIndex, ascending) {
              setState(() {
                _sortBy = 'symbol';
                _sortAscending = ascending;
              });
            },
          ),
          const DataColumn(label: Text('Company')),
          DataColumn(
            label: const Text('Quantity'),
            numeric: true,
            onSort: (columnIndex, ascending) {
              setState(() {
                _sortBy = 'quantity';
                _sortAscending = ascending;
              });
            },
          ),
          const DataColumn(
            label: Text('Avg Cost'),
            numeric: true,
          ),
          const DataColumn(
            label: Text('Current Price'),
            numeric: true,
          ),
          DataColumn(
            label: const Text('Market Value'),
            numeric: true,
            onSort: (columnIndex, ascending) {
              setState(() {
                _sortBy = 'value';
                _sortAscending = ascending;
              });
            },
          ),
          DataColumn(
            label: const Text('Unrealized P&L'),
            numeric: true,
            onSort: (columnIndex, ascending) {
              setState(() {
                _sortBy = 'pnl';
                _sortAscending = ascending;
              });
            },
          ),
          const DataColumn(label: Text('% Change')),
          const DataColumn(label: Text('Actions')),
        ],
        rows: filteredHoldings.map((holding) {
          return DataRow(
            cells: [
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: holding.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          holding.symbol.substring(0, 2),
                          style: TextStyle(
                            color: holding.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      holding.symbol,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              DataCell(
                Text(
                  holding.companyName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              DataCell(
                Text(
                  holding.quantity.toStringAsFixed(0),
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
              DataCell(
                Text(
                  '\$${holding.avgCost.toStringAsFixed(2)}',
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
              DataCell(
                Text(
                  '\$${holding.currentPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
              DataCell(
                Text(
                  '\$${(holding.marketValue / 1000).toStringAsFixed(1)}K',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: holding.unrealizedPnL >= 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${holding.unrealizedPnL >= 0 ? '+' : ''}\$${(holding.unrealizedPnL / 1000).toStringAsFixed(1)}K',
                    style: TextStyle(
                      color: holding.unrealizedPnL >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: holding.percentChange >= 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        holding.percentChange >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 12,
                        color: holding.percentChange >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${holding.percentChange.abs().toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: holding.percentChange >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.info_outline, size: 16),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('View details for ${holding.symbol}'),
                          ),
                        );
                      },
                      tooltip: 'View Details',
                    ),
                    IconButton(
                      icon: const Icon(Icons.analytics_outlined, size: 16),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('View analytics for ${holding.symbol}'),
                          ),
                        );
                      },
                      tooltip: 'View Analytics',
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  /// Get mock holdings data
  List<_MockHolding> _getMockHoldings() {
    return [
      _MockHolding(
        symbol: 'AAPL',
        companyName: 'Apple Inc.',
        quantity: 500,
        avgCost: 145.30,
        currentPrice: 173.50,
        marketValue: 86750,
        unrealizedPnL: 14100,
        percentChange: 19.4,
        color: Colors.blue,
      ),
      _MockHolding(
        symbol: 'MSFT',
        companyName: 'Microsoft Corporation',
        quantity: 300,
        avgCost: 285.20,
        currentPrice: 332.89,
        marketValue: 99867,
        unrealizedPnL: 14307,
        percentChange: 16.7,
        color: Colors.green,
      ),
      _MockHolding(
        symbol: 'GOOGL',
        companyName: 'Alphabet Inc.',
        quantity: 200,
        avgCost: 2450.75,
        currentPrice: 2287.44,
        marketValue: 457488,
        unrealizedPnL: -32662,
        percentChange: -6.7,
        color: Colors.red,
      ),
      _MockHolding(
        symbol: 'TSLA',
        companyName: 'Tesla, Inc.',
        quantity: 150,
        avgCost: 785.60,
        currentPrice: 891.23,
        marketValue: 133684,
        unrealizedPnL: 15844,
        percentChange: 13.4,
        color: Colors.purple,
      ),
      _MockHolding(
        symbol: 'AMZN',
        companyName: 'Amazon.com Inc.',
        quantity: 100,
        avgCost: 3245.67,
        currentPrice: 3089.11,
        marketValue: 308911,
        unrealizedPnL: -15656,
        percentChange: -4.8,
        color: Colors.orange,
      ),
    ];
  }
}

/// Mock holding model
class _MockHolding {
  final String symbol;
  final String companyName;
  final double quantity;
  final double avgCost;
  final double currentPrice;
  final double marketValue;
  final double unrealizedPnL;
  final double percentChange;
  final Color color;

  const _MockHolding({
    required this.symbol,
    required this.companyName,
    required this.quantity,
    required this.avgCost,
    required this.currentPrice,
    required this.marketValue,
    required this.unrealizedPnL,
    required this.percentChange,
    required this.color,
  });
}