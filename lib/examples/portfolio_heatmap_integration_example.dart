import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/investment/investment_heatmap_widget.dart';
import '../../shared/models/investment/investment_types.dart';
import '../../shared/converters/portfolio_analytics_converter.dart';

/// Complete example showing all integration steps from portfolio to heatmap display
class PortfolioHeatmapIntegrationExample extends ConsumerStatefulWidget {
  final String portfolioId;

  const PortfolioHeatmapIntegrationExample({
    super.key,
    required this.portfolioId,
  });

  @override
  ConsumerState<PortfolioHeatmapIntegrationExample> createState() =>
      _PortfolioHeatmapIntegrationExampleState();
}

class _PortfolioHeatmapIntegrationExampleState
    extends ConsumerState<PortfolioHeatmapIntegrationExample> {
  InvestmentFilterType _selectedFilterType = InvestmentFilterType.portfolio;
  List<InvestmentInputData> _inputData = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPortfolioData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio Heatmap Integration'),
        actions: [_buildFilterTypeSelector()],
      ),
      body: Column(
        children: [
          // Step indicators
          _buildStepIndicators(context),

          // Main heatmap display
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildHeatmapDisplay(context),
            ),
          ),

          // Debug information
          if (kDebugMode) _buildDebugInfo(context),
        ],
      ),
    );
  }

  Widget _buildStepIndicators(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          _buildStepIndicator(
            context,
            'Step 1: Data Input',
            _inputData.isNotEmpty
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            _inputData.isNotEmpty ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 16),
          _buildStepIndicator(
            context,
            'Step 2: Configuration',
            _selectedFilterType != null
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            _selectedFilterType != null ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 16),
          _buildStepIndicator(
            context,
            'Step 3: Display',
            !_isLoading && _error == null
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            !_isLoading && _error == null ? Colors.green : Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildFilterTypeSelector() {
    return PopupMenuButton<InvestmentFilterType>(
      icon: const Icon(Icons.filter_list),
      onSelected: (type) {
        setState(() {
          _selectedFilterType = type;
        });
      },
      itemBuilder: (context) => InvestmentFilterType.values.map((type) {
        return PopupMenuItem(
          value: type,
          child: Row(
            children: [
              Icon(_getFilterTypeIcon(type)),
              const SizedBox(width: 8),
              Text(_getFilterTypeLabel(type)),
              if (type == _selectedFilterType) ...[
                const Spacer(),
                const Icon(Icons.check, color: Colors.green),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHeatmapDisplay(BuildContext context) {
    return InvestmentHeatmapWidget(
      filterType: _selectedFilterType,
      inputData: _inputData,
      isLoading: _isLoading,
      error: _error,
      onTilePressed: (data) {
        _showTileDetails(context, data);
      },
      onFiltersChanged: ({filterType, timeFrame, metric, sector, marketCap}) {
        _showFiltersChanged(context, {
          'filterType': filterType,
          'timeFrame': timeFrame,
          'metric': metric,
          'sector': sector,
          'marketCap': marketCap,
        });
      },
    );
  }

  Widget _buildDebugInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Debug Information',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Portfolio ID: ${widget.portfolioId}'),
          Text('Filter Type: ${_selectedFilterType.name}'),
          Text('Input Data Count: ${_inputData.length}'),
          Text('Loading: $_isLoading'),
          if (_error != null)
            Text('Error: $_error', style: const TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  /// Step 1: Load portfolio data from provider or JSON
  Future<void> _loadPortfolioData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // This would typically come from a provider
      // For demo purposes, we'll create mock data
      final mockPortfolioAnalytics = _createMockPortfolioAnalytics();

      // Step 2: Convert to investment input data
      final inputData = PortfolioAnalyticsConverter.convertToInvestmentData(
        mockPortfolioAnalytics,
        portfolioId: widget.portfolioId,
      );

      setState(() {
        _inputData = inputData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Create mock portfolio analytics for demonstration
  Map<String, dynamic> _createMockPortfolioAnalytics() {
    return {
      'portfolioId': widget.portfolioId,
      'timestamp': DateTime.now().toIso8601String(),
      'analytics': {
        'heatmap': {
          'sectors': [
            {
              'sectorName': 'Technology',
              'weightage': 35.5,
              'changePercent': 2.4,
              'totalValue': 35500.0,
            },
            {
              'sectorName': 'Healthcare',
              'weightage': 25.2,
              'changePercent': -1.2,
              'totalValue': 25200.0,
            },
            {
              'sectorName': 'Financial Services',
              'weightage': 20.8,
              'changePercent': 1.8,
              'totalValue': 20800.0,
            },
            {
              'sectorName': 'Consumer Discretionary',
              'weightage': 18.5,
              'changePercent': -0.5,
              'totalValue': 18500.0,
            },
          ],
        },
      },
    };
  }

  void _showTileDetails(BuildContext context, InvestmentInputData data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(data.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${data.id}'),
            Text('Value: \$${data.value.toStringAsFixed(2)}'),
            Text('Performance: ${data.performance.toStringAsFixed(2)}%'),
            Text('Weightage: ${data.weightage.toStringAsFixed(2)}%'),
            if (data.sector != null) Text('Sector: ${data.sector}'),
            if (data.marketCap != null) Text('Market Cap: ${data.marketCap}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFiltersChanged(BuildContext context, Map<String, dynamic> filters) {
    final message = filters.entries
        .where((e) => e.value != null)
        .map((e) => '${e.key}: ${e.value}')
        .join('\n');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Filters Changed:\n$message'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  IconData _getFilterTypeIcon(InvestmentFilterType type) {
    switch (type) {
      case InvestmentFilterType.portfolio:
        return Icons.account_balance_wallet;
      case InvestmentFilterType.index:
        return Icons.trending_up;
      case InvestmentFilterType.mutualFunds:
        return Icons.business_center;
      case InvestmentFilterType.etf:
        return Icons.show_chart;
    }
  }

  String _getFilterTypeLabel(InvestmentFilterType type) {
    switch (type) {
      case InvestmentFilterType.portfolio:
        return 'Portfolio';
      case InvestmentFilterType.index:
        return 'Index';
      case InvestmentFilterType.mutualFunds:
        return 'Mutual Funds';
      case InvestmentFilterType.etf:
        return 'ETF';
    }
  }
}

/// Helper constant for debug mode check
const bool kDebugMode = true;
