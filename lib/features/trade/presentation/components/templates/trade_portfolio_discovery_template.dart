import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/trade_portfolio_view_model.dart';

class TradePortfolioDiscoveryTemplate extends StatefulWidget {
  const TradePortfolioDiscoveryTemplate({
    required this.portfolios,
    required this.isLoading,
    required this.onPortfolioSelected,
    super.key,
    this.errorMessage,
    this.onRefresh,
    this.isWebView = true,
  });
  final List<TradePortfolioViewModel> portfolios;
  final bool isLoading;
  final String? errorMessage;
  final Function(TradePortfolioViewModel) onPortfolioSelected;
  final VoidCallback? onRefresh;
  final bool isWebView;

  @override
  State<TradePortfolioDiscoveryTemplate> createState() => _TradePortfolioDiscoveryTemplateState();
}

class _TradePortfolioDiscoveryTemplateState extends State<TradePortfolioDiscoveryTemplate> {
  String _searchQuery = '';
  String _sortBy = 'name'; // name, value, performance
  bool _showOnlyProfit = false;

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(widget.errorMessage!, style: const TextStyle(color: Colors.red)),
            if (widget.onRefresh != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(onPressed: widget.onRefresh, child: const Text('Retry')),
            ],
          ],
        ),
      );
    }

    if (widget.portfolios.isEmpty) {
      return _buildEmptyState(context);
    }

    final filteredPortfolios = _getFilteredPortfolios();

    return Column(
      children: [
        _buildHeaderSection(context),
        _buildFiltersBar(context),
        Expanded(child: widget.isWebView ? _buildGridView(filteredPortfolios) : _buildListView(filteredPortfolios)),
      ],
    );
  }

  List<TradePortfolioViewModel> _getFilteredPortfolios() {
    final filtered = widget.portfolios.where((p) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (p.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

      final matchesFilter = !_showOnlyProfit || p.isProfit;

      return matchesSearch && matchesFilter;
    }).toList();

    // Sort portfolios
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'value':
          return b.totalValue.compareTo(a.totalValue);
        case 'performance':
          return b.totalGainLossPercentage.compareTo(a.totalGainLossPercentage);
        case 'name':
        default:
          return a.name.compareTo(b.name);
      }
    });

    return filtered;
  }

  Widget _buildEmptyState(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.account_balance_wallet_outlined, size: 80, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text('No portfolios found', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[600])),
        const SizedBox(height: 8),
        Text(
          'Create your first portfolio to start tracking trades',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
        ),
      ],
    ),
  );

  Widget _buildHeaderSection(BuildContext context) {
    final totalValue = widget.portfolios.fold<double>(0.0, (sum, p) => sum + p.totalValue);
    final totalGainLoss = widget.portfolios.fold<double>(0.0, (sum, p) => sum + p.totalGainLoss);
    final profitableCount = widget.portfolios.where((p) => p.isProfit).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          Icon(Icons.dashboard, color: Theme.of(context).colorScheme.primary, size: 24),
          const SizedBox(width: 12),
          Text(
            'Portfolio Overview',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text(
            '(${widget.portfolios.length})',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
          ),
          const Spacer(),
          _buildCompactStatCard(
            context,
            'Total Value',
            '\$${totalValue.toStringAsFixed(2)}',
            Icons.account_balance,
            Colors.blue,
          ),
          const SizedBox(width: 16),
          _buildCompactStatCard(
            context,
            'Total P&L',
            '${totalGainLoss >= 0 ? '+' : ''}\$${totalGainLoss.toStringAsFixed(2)}',
            totalGainLoss >= 0 ? Icons.trending_up : Icons.trending_down,
            totalGainLoss >= 0 ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 16),
          _buildCompactStatCard(
            context,
            'Profitable',
            '$profitableCount / ${widget.portfolios.length}',
            Icons.check_circle,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStatCard(BuildContext context, String label, String value, IconData icon, Color color) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildFiltersBar(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
    ),
    child: Row(
      children: [
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 40,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search portfolios...',
                hintStyle: const TextStyle(fontSize: 14),
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: _sortBy,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down, size: 20),
            style: Theme.of(context).textTheme.bodyMedium,
            items: const [
              DropdownMenuItem(value: 'name', child: Text('Name')),
              DropdownMenuItem(value: 'value', child: Text('Value')),
              DropdownMenuItem(value: 'performance', child: Text('Performance')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _sortBy = value;
                });
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        FilterChip(
          label: const Text('Profitable', style: TextStyle(fontSize: 13)),
          selected: _showOnlyProfit,
          onSelected: (value) {
            setState(() {
              _showOnlyProfit = value;
            });
          },
          padding: const EdgeInsets.symmetric(horizontal: 8),
          visualDensity: VisualDensity.compact,
        ),
        if (widget.onRefresh != null) ...[
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            tooltip: 'Refresh',
            onPressed: widget.onRefresh,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ],
    ),
  );

  Widget _buildGridView(List<TradePortfolioViewModel> portfolios) => GridView.builder(
    padding: const EdgeInsets.all(16),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
    ),
    itemCount: portfolios.length,
    itemBuilder: (context, index) {
      final portfolio = portfolios[index];
      return _buildPortfolioCard(portfolio);
    },
  );

  Widget _buildListView(List<TradePortfolioViewModel> portfolios) => ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: portfolios.length,
    itemBuilder: (context, index) {
      final portfolio = portfolios[index];
      return _buildPortfolioCard(portfolio);
    },
  );

  Widget _buildPortfolioCard(TradePortfolioViewModel portfolio) {
    final isPositive = portfolio.isProfit;
    final formattedDate = portfolio.lastUpdated != null
        ? DateFormat('MMM dd, yyyy HH:mm').format(portfolio.lastUpdated!)
        : 'N/A';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isPositive ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3), width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => widget.onPortfolioSelected(portfolio),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isPositive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.account_balance_wallet, color: isPositive ? Colors.green : Colors.red, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          portfolio.displayName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${portfolio.displayHoldingsCount} • Updated $formattedDate',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (portfolio.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  portfolio.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
              ],
              const Spacer(),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Portfolio Value',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Text(portfolio.displayValue, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isPositive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                              size: 12,
                              color: isPositive ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              portfolio.displayGainLossPercentage,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isPositive ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${isPositive ? '+' : ''}${portfolio.displayGainLoss}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isPositive ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
