import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/portfolio_providers.dart';
import '../../widgets/portfolio_analysis_widget.dart';
import '../../widgets/sectorial_allocation_widget.dart';
import '../../widgets/market_cap_allocation_widget.dart';
import '../../widgets/movers_widget.dart';
import '../../widgets/heatmap_widget.dart';
import '../../../../../core/utils/logger.dart';

/// Web-specific portfolio analysis page with comprehensive analytics and insights
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
    extends ConsumerState<PortfolioAnalysisWebPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimeframe = '1M';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.info(
      'Building PortfolioAnalysisWebPage for portfolioId: ${widget.portfolioId}',
      tag: 'PortfolioAnalysisWebPage',
    );

    final holdingsAsync = ref.watch(
      portfolioHoldingsProvider(widget.portfolioId),
    );
    final summaryAsync = ref.watch(
      portfolioSummaryProvider(widget.portfolioId),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.portfolioName ?? 'Portfolio'} - Analysis'),
        actions: [
          // Timeframe Selector
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: DropdownButton<String>(
              value: _selectedTimeframe,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              underline: Container(),
              items: const [
                DropdownMenuItem(value: '1D', child: Text('1D')),
                DropdownMenuItem(value: '1W', child: Text('1W')),
                DropdownMenuItem(value: '1M', child: Text('1M')),
                DropdownMenuItem(value: '3M', child: Text('3M')),
                DropdownMenuItem(value: '6M', child: Text('6M')),
                DropdownMenuItem(value: '1Y', child: Text('1Y')),
              ],
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedTimeframe = newValue;
                  });
                  AppLogger.userAction(
                    'Timeframe changed',
                    tag: 'PortfolioAnalysisWebPage',
                    context: {'timeframe': newValue},
                  );
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(portfolioHoldingsProvider(widget.portfolioId));
              ref.invalidate(portfolioSummaryProvider(widget.portfolioId));
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Allocations', icon: Icon(Icons.pie_chart)),
            Tab(text: 'Performance', icon: Icon(Icons.trending_up)),
            Tab(text: 'Risk Analysis', icon: Icon(Icons.shield)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(context, holdingsAsync, summaryAsync),
          _buildAllocationsTab(context, holdingsAsync),
          _buildPerformanceTab(context, holdingsAsync, summaryAsync),
          _buildRiskAnalysisTab(context, holdingsAsync, summaryAsync),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(
    BuildContext context,
    AsyncValue holdingsAsync,
    AsyncValue summaryAsync,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Title
          Text(
            'Portfolio Analysis Overview',
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Key Metrics Row
          summaryAsync.when(
            data: (summary) => _buildKeyMetricsRow(context, summary),
            loading: () => _buildLoadingRow(),
            error: (error, stack) => _buildErrorCard(
              context,
              'Failed to load metrics',
              error.toString(),
              () =>
                  ref.invalidate(portfolioSummaryProvider(widget.portfolioId)),
            ),
          ),

          const SizedBox(height: 24),

          // Charts Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column - Heatmap
              Expanded(
                flex: 2,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Performance Heatmap',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        holdingsAsync.when(
                          data: (holdings) => Container(
                            height: 300,
                            child: HeatmapWidget(holdings: holdings.holdings),
                          ),
                          loading: () => _buildLoadingWidget(300),
                          error: (error, stack) => _buildErrorWidget(
                            context,
                            'Failed to load heatmap',
                            150,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Right Column - Top Movers
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    // Top Gainers
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Top Gainers',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            holdingsAsync.when(
                              data: (holdings) => MoversWidget(
                                holdings: holdings.holdings,
                                showGainers: true,
                                maxItems: 5,
                              ),
                              loading: () => _buildLoadingWidget(150),
                              error: (error, stack) => _buildErrorWidget(
                                context,
                                'Failed to load gainers',
                                100,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Top Losers
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Top Losers',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            holdingsAsync.when(
                              data: (holdings) => MoversWidget(
                                holdings: holdings.holdings,
                                showGainers: false,
                                maxItems: 5,
                              ),
                              loading: () => _buildLoadingWidget(150),
                              error: (error, stack) => _buildErrorWidget(
                                context,
                                'Failed to load losers',
                                100,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAllocationsTab(BuildContext context, AsyncValue holdingsAsync) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Portfolio Allocations',
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sectorial Allocation
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sector Allocation',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        holdingsAsync.when(
                          data: (holdings) => SectorialAllocationWidget(
                            holdings: holdings.holdings,
                          ),
                          loading: () => _buildLoadingWidget(300),
                          error: (error, stack) => _buildErrorWidget(
                            context,
                            'Failed to load sector allocation',
                            200,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Market Cap Allocation
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Market Cap Allocation',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        holdingsAsync.when(
                          data: (holdings) => MarketCapAllocationWidget(
                            holdings: holdings.holdings,
                          ),
                          loading: () => _buildLoadingWidget(300),
                          error: (error, stack) => _buildErrorWidget(
                            context,
                            'Failed to load market cap allocation',
                            200,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab(
    BuildContext context,
    AsyncValue holdingsAsync,
    AsyncValue summaryAsync,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Analysis',
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Performance Summary Cards
          summaryAsync.when(
            data: (summary) => _buildPerformanceCards(context, summary),
            loading: () => _buildLoadingRow(),
            error: (error, stack) => _buildErrorCard(
              context,
              'Failed to load performance data',
              error.toString(),
              () =>
                  ref.invalidate(portfolioSummaryProvider(widget.portfolioId)),
            ),
          ),

          const SizedBox(height: 24),

          // Performance Chart Placeholder
          Card(
            child: Container(
              height: 400,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Performance Chart ($_selectedTimeframe)',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.show_chart,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Performance chart for $_selectedTimeframe coming soon...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskAnalysisTab(
    BuildContext context,
    AsyncValue holdingsAsync,
    AsyncValue summaryAsync,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Risk Analysis',
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Risk Metrics
          Row(
            children: [
              Expanded(
                child: _buildRiskCard(
                  context,
                  'Portfolio Beta',
                  '1.2',
                  'Medium Risk',
                  Colors.orange,
                  Icons.trending_up,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildRiskCard(
                  context,
                  'Volatility',
                  '18.5%',
                  'Moderate',
                  Colors.blue,
                  Icons.show_chart,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildRiskCard(
                  context,
                  'Sharpe Ratio',
                  '1.8',
                  'Good',
                  Colors.green,
                  Icons.assessment,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Risk Distribution Chart
          Card(
            child: Container(
              height: 300,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Risk Distribution',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shield,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Risk distribution analysis coming soon...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetricsRow(BuildContext context, dynamic summary) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            context,
            'Total Return',
            '\$${summary.totalValue.toStringAsFixed(2)}',
            summary.totalValue >= 0 ? Colors.green : Colors.red,
            summary.totalValue >= 0 ? Icons.trending_up : Icons.trending_down,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            context,
            'Today\'s Change',
            '\$${summary.todayChange.toStringAsFixed(2)}',
            summary.todayChange >= 0 ? Colors.green : Colors.red,
            summary.todayChange >= 0 ? Icons.trending_up : Icons.trending_down,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            context,
            'Portfolio Value',
            '\$${summary.totalValue.toStringAsFixed(2)}',
            Colors.blue,
            Icons.account_balance_wallet,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceCards(BuildContext context, dynamic summary) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            context,
            'YTD Return',
            '${(summary.totalValue * 0.15).toStringAsFixed(1)}%',
            Colors.green,
            Icons.calendar_today,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            context,
            'Best Performer',
            'AAPL (+12.5%)',
            Colors.green,
            Icons.star,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            context,
            'Worst Performer',
            'TSLA (-8.2%)',
            Colors.red,
            Icons.trending_down,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskCard(
    BuildContext context,
    String title,
    String value,
    String description,
    Color color,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingRow() {
    return Row(
      children: List.generate(
        3,
        (index) => Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < 2 ? 16 : 0),
            child: Card(
              child: Container(
                height: 80,
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget(double height) {
    return Container(
      height: height,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorWidget(
    BuildContext context,
    String message,
    double height,
  ) {
    return Container(
      height: height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 32,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(
    BuildContext context,
    String title,
    String error,
    VoidCallback onRetry,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 32,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              error,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
