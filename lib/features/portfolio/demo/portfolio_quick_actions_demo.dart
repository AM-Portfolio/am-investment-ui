import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../widgets/shared/ui/enhanced_portfolio_quick_actions.dart';

/// Demo page showing how to integrate the portfolio quick actions widget
class PortfolioQuickActionsDemo extends ConsumerStatefulWidget {
  const PortfolioQuickActionsDemo({super.key});

  @override
  ConsumerState<PortfolioQuickActionsDemo> createState() => _PortfolioQuickActionsDemoState();
}

class _PortfolioQuickActionsDemoState extends ConsumerState<PortfolioQuickActionsDemo> {
  String? _selectedPortfolioId;
  final List<String> _availablePortfolios = [
    'portfolio-001',
    'portfolio-002',
    'portfolio-003',
  ];
  
  final List<String> _recentResults = [];
  final String _currentUserId = 'user-demo-123';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio Quick Actions Demo'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPortfolioSelector(),
            const SizedBox(height: 24),
            _buildQuickActionsWidget(),
            const SizedBox(height: 24),
            _buildResultsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPortfolioSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Portfolio Selection',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Select a portfolio to add trade details, or create a new one using the quick actions below.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String?>(
              value: _selectedPortfolioId,
              decoration: const InputDecoration(
                labelText: 'Select Portfolio',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.folder),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('No portfolio selected'),
                ),
                ..._availablePortfolios.map((portfolioId) => DropdownMenuItem(
                  value: portfolioId,
                  child: Text('Portfolio ${portfolioId.split('-').last}'),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPortfolioId = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsWidget() {
    return EnhancedPortfolioQuickActions(
      userId: _currentUserId,
      portfolioId: _selectedPortfolioId,
      onPortfolioCreated: _handlePortfolioCreated,
      onTradeDetailsAdded: _handleTradeDetailsAdded,
      onError: _handleError,
    );
  }

  Widget _buildResultsSection() {
    if (_recentResults.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                Icons.info_outline,
                size: 48,
                color: Theme.of(context).primaryColor.withOpacity(0.6),
              ),
              const SizedBox(height: 12),
              Text(
                'No actions performed yet',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Use the quick actions above to upload documents and create portfolios or add trade details.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recent Results',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._recentResults.asMap().entries.map((entry) {
              final index = entry.key;
              final result = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          result,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            if (_recentResults.length > 3) ...[
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: _clearResults,
                  child: const Text('Clear Results'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handlePortfolioCreated(PortfolioCreationResult result) {
    if (result.isSuccess) {
      setState(() {
        _recentResults.insert(0, 
          '✅ Portfolio "${result.portfolioName}" created successfully! '
          'ID: ${result.portfolioId}\n'
          '📊 ${result.summary}'
        );
        // Add the new portfolio to available portfolios
        if (result.portfolioId != null && !_availablePortfolios.contains(result.portfolioId)) {
          _availablePortfolios.add(result.portfolioId!);
        }
      });
      
      // Show option to select the new portfolio
      _showNewPortfolioDialog(result);
    } else {
      _addErrorResult('❌ Portfolio creation failed: ${result.errorMessage}');
    }
  }

  void _handleTradeDetailsAdded(TradeDetailsResult result) {
    if (result.isSuccess) {
      setState(() {
        _recentResults.insert(0, 
          '✅ Trade details added to portfolio ${result.portfolioId}!\n'
          '📈 Added ${result.tradesAdded} trades\n'
          '📋 ${result.summary}'
        );
      });
    } else {
      _addErrorResult('❌ Trade details addition failed: ${result.errorMessage}');
    }
  }

  void _handleError(String error) {
    _addErrorResult('❌ Error: $error');
  }

  void _addErrorResult(String error) {
    setState(() {
      _recentResults.insert(0, error);
    });
  }

  void _showNewPortfolioDialog(PortfolioCreationResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Portfolio Created!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your new portfolio "${result.portfolioName}" has been created successfully.'),
            const SizedBox(height: 16),
            Text('Would you like to select it as your active portfolio?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedPortfolioId = result.portfolioId;
              });
              Navigator.of(context).pop();
            },
            child: const Text('Select Portfolio'),
          ),
        ],
      ),
    );
  }

  void _clearResults() {
    setState(() {
      _recentResults.clear();
    });
  }
}

/// Extension to provide demo route
extension PortfolioQuickActionsDemoRoute on PortfolioQuickActionsDemo {
  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const PortfolioQuickActionsDemo(),
    );
  }
}