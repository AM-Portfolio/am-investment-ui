import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/portfolio_providers.dart';

/// Web-specific portfolio analysis page with comprehensive analytics
class PortfolioAnalysisWebPage extends ConsumerStatefulWidget {
  final String userId;
  final String portfolioId;
  final String? portfolioName;

  const PortfolioAnalysisWebPage({
    super.key,
    required this.userId,
    required this.portfolioId,
    this.portfolioName,
  });

  @override
  ConsumerState<PortfolioAnalysisWebPage> createState() =>
      _PortfolioAnalysisWebPageState();
}

class _PortfolioAnalysisWebPageState
    extends ConsumerState<PortfolioAnalysisWebPage> {
  String _selectedTimeframe = '1M';
  String _selectedAnalysisType = 'Performance';

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(
      portfolioSummaryProvider(widget.portfolioId),
    );
    final holdingsAsync = ref.watch(
      portfolioHoldingsProvider(widget.portfolioId),
    );

    return Scaffold(
      body: Column(
        children: [
          // Analysis Controls
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: _buildAnalysisControls(context),
          ),

          // Main Analysis Content
          Expanded(
            child: Row(
              children: [
                // Left Panel - Charts and Analytics
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      // Performance Chart Section
                      Expanded(
                        flex: 2,
                        child: _buildPerformanceSection(context, summaryAsync),
                      ),

                      // Analytics Grid
                      Expanded(
                        flex: 3,
                        child: _buildAnalyticsGrid(context, holdingsAsync),
                      ),
                    ],
                  ),
                ),

                // Right Panel - Insights and Actions
                Container(
                  width: 350,
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: _buildInsightsPanel(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisControls(BuildContext context) {
    return Row(
      children: [
        // Analysis Type Selector
        Text(
          'Analysis Type:',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 12),

        ToggleButtons(
          isSelected: [
            _selectedAnalysisType == 'Performance',
            _selectedAnalysisType == 'Risk',
            _selectedAnalysisType == 'Allocation',
            _selectedAnalysisType == 'Comparison',
          ],
          onPressed: (index) {
            final types = ['Performance', 'Risk', 'Allocation', 'Comparison'];
            setState(() {
              _selectedAnalysisType = types[index];
            });
          },
          borderRadius: BorderRadius.circular(8),
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Performance'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Risk'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Allocation'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Comparison'),
            ),
          ],
        ),

        const Spacer(),

        // Timeframe Selector
        Text(
          'Timeframe:',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 12),

        DropdownButton<String>(
          value: _selectedTimeframe,
          underline: Container(),
          items: const [
            DropdownMenuItem(value: '1W', child: Text('1 Week')),
            DropdownMenuItem(value: '1M', child: Text('1 Month')),
            DropdownMenuItem(value: '3M', child: Text('3 Months')),
            DropdownMenuItem(value: '6M', child: Text('6 Months')),
            DropdownMenuItem(value: '1Y', child: Text('1 Year')),
            DropdownMenuItem(value: 'YTD', child: Text('Year to Date')),
            DropdownMenuItem(value: 'ALL', child: Text('All Time')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedTimeframe = value;
              });
            }
          },
        ),

        const SizedBox(width: 16),

        // Export Button
        ElevatedButton.icon(
          onPressed: () {
            // Handle export
            _showExportDialog(context);
          },
          icon: const Icon(Icons.download),
          label: const Text('Export'),
        ),
      ],
    );
  }

  Widget _buildPerformanceSection(
    BuildContext context,
    AsyncValue<dynamic> summaryAsync,
  ) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Portfolio Performance - $_selectedTimeframe',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Expanded(
              child: summaryAsync.when(
                data: (summary) => _buildPerformanceChart(context, summary),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildErrorPlaceholder(
                  context,
                  'Performance Chart',
                  error.toString(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceChart(BuildContext context, dynamic summary) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Interactive Performance Chart',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Total Return: \$${summary.totalReturn?.toStringAsFixed(2) ?? '0.00'}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Time Period: $_selectedTimeframe',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsGrid(
    BuildContext context,
    AsyncValue<dynamic> holdingsAsync,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detailed Analytics',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildAnalyticsCard(
                  context,
                  'Sector Allocation',
                  Icons.pie_chart,
                  Colors.blue,
                  holdingsAsync,
                ),
                _buildAnalyticsCard(
                  context,
                  'Risk Metrics',
                  Icons.security,
                  Colors.orange,
                  holdingsAsync,
                ),
                _buildAnalyticsCard(
                  context,
                  'Top Holdings',
                  Icons.trending_up,
                  Colors.green,
                  holdingsAsync,
                ),
                _buildAnalyticsCard(
                  context,
                  'Market Cap Distribution',
                  Icons.account_balance,
                  Colors.purple,
                  holdingsAsync,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    AsyncValue<dynamic> dataAsync,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Expanded(
              child: dataAsync.when(
                data: (data) => _buildCardContent(context, title, color),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'Error loading data',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context, String title, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getIconForTitle(title), size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              _getPlaceholderData(title),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForTitle(String title) {
    switch (title) {
      case 'Sector Allocation':
        return Icons.donut_small;
      case 'Risk Metrics':
        return Icons.warning;
      case 'Top Holdings':
        return Icons.star;
      case 'Market Cap Distribution':
        return Icons.show_chart;
      default:
        return Icons.analytics;
    }
  }

  String _getPlaceholderData(String title) {
    switch (title) {
      case 'Sector Allocation':
        return 'Tech: 35%\nFinance: 25%\nHealthcare: 20%\nOther: 20%';
      case 'Risk Metrics':
        return 'Beta: 1.2\nSharpe: 0.85\nVolatility: 15%';
      case 'Top Holdings':
        return 'AAPL: 12%\nMSFT: 10%\nAMZN: 8%';
      case 'Market Cap Distribution':
        return 'Large: 70%\nMid: 20%\nSmall: 10%';
      default:
        return 'Data Available';
    }
  }

  Widget _buildInsightsPanel(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Panel Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'AI Insights',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Insights Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInsightCard(
                    context,
                    'Portfolio Health',
                    'Your portfolio shows strong diversification across sectors.',
                    Icons.health_and_safety,
                    Colors.green,
                  ),
                  const SizedBox(height: 16),

                  _buildInsightCard(
                    context,
                    'Risk Alert',
                    'Consider rebalancing - Tech allocation is above target.',
                    Icons.warning,
                    Colors.orange,
                  ),
                  const SizedBox(height: 16),

                  _buildInsightCard(
                    context,
                    'Opportunity',
                    'Healthcare sector showing strong momentum this quarter.',
                    Icons.trending_up,
                    Colors.blue,
                  ),
                  const SizedBox(height: 24),

                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildActionButton(
                    context,
                    'Rebalance Portfolio',
                    Icons.balance,
                  ),
                  const SizedBox(height: 8),
                  _buildActionButton(
                    context,
                    'Generate Report',
                    Icons.description,
                  ),
                  const SizedBox(height: 8),
                  _buildActionButton(
                    context,
                    'Schedule Review',
                    Icons.calendar_today,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String text, IconData icon) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          // Handle action
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('$text - Coming soon!')));
        },
        icon: Icon(icon, size: 16),
        label: Text(text),
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder(
    BuildContext context,
    String title,
    String error,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              'Failed to load $title',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.red.shade700),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Analysis'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Export as PDF'),
              onTap: () {
                Navigator.of(context).pop();
                // Handle PDF export
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Export as Excel'),
              onTap: () {
                Navigator.of(context).pop();
                // Handle Excel export
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Export as Image'),
              onTap: () {
                Navigator.of(context).pop();
                // Handle image export
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
