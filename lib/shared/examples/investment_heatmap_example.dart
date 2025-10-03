import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../widgets/investment/investment_heatmap_widget.dart';
import '../models/investment/investment_types.dart';
import '../converters/portfolio_analytics_converter.dart';

/// Example usage of the investment heatmap pattern
/// This demonstrates how to load data and display different investment types
class InvestmentHeatmapExample extends StatefulWidget {
  const InvestmentHeatmapExample({super.key});

  @override
  State<InvestmentHeatmapExample> createState() =>
      _InvestmentHeatmapExampleState();
}

class _InvestmentHeatmapExampleState extends State<InvestmentHeatmapExample> {
  InvestmentFilterType _selectedFilterType = InvestmentFilterType.portfolio;
  Map<InvestmentFilterType, List<InvestmentInputData>> _allData = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPortfolioData();
  }

  Future<void> _loadPortfolioData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Load the portfolio analytics JSON from assets
      final String jsonString = await rootBundle.loadString(
        'lib/assets/mock_data/portfolio_analytics.json',
      );

      // Parse the JSON
      final analyticsJson = PortfolioAnalyticsConverter.parsePortfolioAnalytics(
        jsonString,
      );

      // Convert to all data types
      final allData = PortfolioAnalyticsConverter.getAllDataTypes(
        analyticsJson,
      );

      setState(() {
        _allData = allData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load portfolio data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investment Heatmap Pattern'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _loadPortfolioData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: Column(
        children: [
          // Data overview card
          _buildDataOverviewCard(),

          // Main heatmap display
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildHeatmapWidget(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataOverviewCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Data Overview',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Loading portfolio data...'),
                ],
              )
            else if (_error != null)
              Row(
                children: [
                  Icon(Icons.error, color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              )
            else
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: InvestmentFilterType.values.map((type) {
                  final count = _allData[type]?.length ?? 0;
                  final config = InvestmentTypeConfig.getConfig(type);

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: config.accentColor?.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            config.accentColor?.withOpacity(0.3) ?? Colors.grey,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(config.icon, size: 16, color: config.accentColor),
                        const SizedBox(width: 4),
                        Text(
                          '${type.displayName}: $count',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: config.accentColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmapWidget() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading investment data...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Data',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadPortfolioData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final currentData = _allData[_selectedFilterType] ?? [];

    return InvestmentHeatmapWidget(
      filterType: _selectedFilterType,
      inputData: currentData,
      onTilePressed: _handleTilePressed,
      onFiltersChanged: _handleFiltersChanged,
      compact: MediaQuery.of(context).size.width < 600,
    );
  }

  void _handleTilePressed(InvestmentInputData data) {
    // Show details dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(data.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
              'Value',
              '\$${data.currentValue.toStringAsFixed(2)}',
            ),
            _buildDetailRow(
              'Change',
              '${data.changePercent >= 0 ? '+' : ''}${data.changePercent.toStringAsFixed(2)}%',
            ),
            _buildDetailRow(
              'Change Amount',
              '\$${data.changeAmount.toStringAsFixed(2)}',
            ),
            _buildDetailRow(
              'Last Updated',
              data.lastUpdated.toString().split('.')[0],
            ),
            if (data.additionalData.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Additional Info:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...data.additionalData.entries
                  .take(3)
                  .map(
                    (entry) =>
                        _buildDetailRow(entry.key, entry.value.toString()),
                  ),
            ],
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _handleFiltersChanged({
    InvestmentFilterType? filterType,
    TimeFrame? timeFrame,
    MetricType? metric,
    SectorType? sector,
    MarketCapType? marketCap,
  }) {
    if (filterType != null && filterType != _selectedFilterType) {
      setState(() {
        _selectedFilterType = filterType;
      });
    }

    // Here you could implement additional filtering logic based on
    // timeFrame, metric, sector, marketCap parameters
    print(
      'Filters changed: filterType=$filterType, timeFrame=$timeFrame, metric=$metric, sector=$sector, marketCap=$marketCap',
    );
  }
}

/// Example of how to use specific investment types directly
class SpecificInvestmentExamples {
  /// Portfolio heatmap example
  static Widget portfolioExample(List<PortfolioInputData> portfolioData) {
    return InvestmentHeatmapWidget.portfolio(
      portfolioData: portfolioData,
      onTilePressed: (data) => print('Portfolio tile pressed: ${data.name}'),
      compact: false,
      accentColor: Colors.blue,
    );
  }

  /// Mutual funds heatmap example
  static Widget mutualFundsExample(List<MutualFundInputData> fundData) {
    return InvestmentHeatmapWidget.mutualFunds(
      fundData: fundData,
      onTilePressed: (data) => print('Fund tile pressed: ${data.name}'),
      compact: true,
      accentColor: Colors.orange,
    );
  }

  /// ETF heatmap example
  static Widget etfExample(List<EtfInputData> etfData) {
    return InvestmentHeatmapWidget.etf(
      etfData: etfData,
      onTilePressed: (data) => print('ETF tile pressed: ${data.name}'),
      compact: false,
      accentColor: Colors.purple,
    );
  }
}
