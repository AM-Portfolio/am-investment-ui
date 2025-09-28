import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../widgets/shared/ui/enhanced_portfolio_quick_actions.dart';
import '../../../di/app_providers.dart';

/// Example integration of portfolio quick actions in an existing screen
class PortfolioScreenWithQuickActions extends ConsumerStatefulWidget {
  final String userId;
  final String? selectedPortfolioId;

  const PortfolioScreenWithQuickActions({
    super.key,
    required this.userId,
    this.selectedPortfolioId,
  });

  @override
  ConsumerState<PortfolioScreenWithQuickActions> createState() => _PortfolioScreenWithQuickActionsState();
}

class _PortfolioScreenWithQuickActionsState extends ConsumerState<PortfolioScreenWithQuickActions> {
  String? _currentPortfolioId;
  bool _showQuickActions = true;

  @override
  void initState() {
    super.initState();
    _currentPortfolioId = widget.selectedPortfolioId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       // title: const Text('Portfolio Management'),
        actions: [
          IconButton(
            icon: Icon(_showQuickActions ? Icons.expand_less : Icons.expand_more),
            onPressed: () {
              setState(() {
                _showQuickActions = !_showQuickActions;
              });
            },
            tooltip: _showQuickActions ? 'Hide Quick Actions' : 'Show Quick Actions',
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Actions Section
          if (_showQuickActions) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: EnhancedPortfolioQuickActions(
                userId: widget.userId,
                portfolioId: _currentPortfolioId,
                onPortfolioCreated: _handlePortfolioCreated,
                onTradeDetailsAdded: _handleTradeDetailsAdded,
                onError: _handleError,
              ),
            ),
            const Divider(),
          ],
          
          // Portfolio Content
          Expanded(
            child: _buildPortfolioContent(),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildPortfolioContent() {
    if (_currentPortfolioId == null) {
      return _buildEmptyPortfolioState();
    }

    return _buildPortfolioDetails();
  }

  Widget _buildEmptyPortfolioState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: Theme.of(context).primaryColor.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'No Portfolio Selected',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a new portfolio by uploading your holdings or trade history documents using the quick actions above.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (!_showQuickActions)
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _showQuickActions = true;
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Show Quick Actions'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortfolioDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Portfolio Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Portfolio ${_currentPortfolioId?.split('-').last ?? 'Unknown'}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Portfolio ID: $_currentPortfolioId',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _refreshPortfolio,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh Portfolio',
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Portfolio Statistics
          _buildPortfolioStats(),
          
          const SizedBox(height: 16),
          
          // Holdings Table (placeholder)
          _buildHoldingsSection(),
        ],
      ),
    );
  }

  Widget _buildPortfolioStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Portfolio Statistics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Value',
                    '₹1,25,000',
                    Icons.account_balance,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Total Gain/Loss',
                    '+₹15,000',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Holdings',
                    '12 Stocks',
                    Icons.pie_chart,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Total Trades',
                    '45 Trades',
                    Icons.swap_horiz,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
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
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.list,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Holdings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Placeholder for holdings table
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.table_chart,
                      size: 48,
                      color: Theme.of(context).primaryColor.withOpacity(0.6),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Holdings table will appear here',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    if (_currentPortfolioId == null) return null;
    
    return FloatingActionButton.extended(
      onPressed: () {
        setState(() {
          _showQuickActions = !_showQuickActions;
        });
      },
      icon: Icon(_showQuickActions ? Icons.close : Icons.add),
      label: Text(_showQuickActions ? 'Hide Actions' : 'Quick Actions'),
    );
  }

  void _handlePortfolioCreated(PortfolioCreationResult result) {
    if (result.isSuccess) {
      setState(() {
        _currentPortfolioId = result.portfolioId;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Portfolio "${result.portfolioName}" created successfully!'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'View',
            onPressed: () {
              // Additional actions if needed
            },
          ),
        ),
      );
      
      // Refresh portfolio data
      _refreshPortfolio();
    }
  }

  void _handleTradeDetailsAdded(TradeDetailsResult result) {
    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${result.tradesAdded} trades successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Refresh portfolio data
      _refreshPortfolio();
    }
  }

  void _handleError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $error'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _refreshPortfolio() async {
    // Invalidate relevant providers to refresh data
    ref.invalidate(portfolioSummaryProvider);
    ref.invalidate(portfolioHoldingsProvider);
    
    // You can add additional refresh logic here
    debugPrint('Refreshing portfolio data for: $_currentPortfolioId');
  }
}