import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/portfolio_providers.dart';
import '../widgets/portfolio_holdings_web_card.dart';
import '../../widgets/portfolio_summary_widget.dart';
import '../../widgets/movers_widget.dart';
import '../../../../../core/utils/logger.dart';

/// Web-specific portfolio holdings page with advanced filtering and sorting
class PortfolioHoldingsWebPage extends ConsumerStatefulWidget {
  final String userId;
  final String portfolioId;
  final String? portfolioName;

  const PortfolioHoldingsWebPage({
    super.key,
    required this.userId,
    required this.portfolioId,
    this.portfolioName,
  });

  @override
  ConsumerState<PortfolioHoldingsWebPage> createState() =>
      _PortfolioHoldingsWebPageState();
}

class _PortfolioHoldingsWebPageState
    extends ConsumerState<PortfolioHoldingsWebPage> {
  String _searchQuery = '';
  String _sortBy = 'marketValue';
  bool _sortAscending = false;
  String _filterSector = 'All';

  @override
  Widget build(BuildContext context) {
    AppLogger.info(
      'Building PortfolioHoldingsWebPage for portfolioId: ${widget.portfolioId}',
      tag: 'PortfolioHoldingsWebPage',
    );

    final holdingsAsync = ref.watch(
      portfolioHoldingsProvider(widget.portfolioId),
    );
    final summaryAsync = ref.watch(
      portfolioSummaryProvider(widget.portfolioId),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.portfolioName ?? 'Portfolio'} - Holdings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(portfolioHoldingsProvider(widget.portfolioId));
              ref.invalidate(portfolioSummaryProvider(widget.portfolioId));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Summary Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: summaryAsync.when(
              data: (summary) => _buildTopSummary(context, summary),
              loading: () => _buildLoadingSummary(),
              error: (error, stack) =>
                  _buildErrorSummary(context, error.toString()),
            ),
          ),

          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: _buildSearchAndFilterBar(context),
          ),

          // Holdings Content
          Expanded(
            child: Row(
              children: [
                // Main Holdings Table
                Expanded(
                  flex: 3,
                  child: holdingsAsync.when(
                    data: (holdings) => _buildHoldingsTable(context, holdings),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => _buildErrorContent(
                      context,
                      'Failed to load holdings',
                      error.toString(),
                      () => ref.invalidate(
                        portfolioHoldingsProvider(widget.portfolioId),
                      ),
                    ),
                  ),
                ),

                // Side Panel for Details
                Container(
                  width: 300,
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: _buildSidePanel(context, holdingsAsync),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSummary(BuildContext context, dynamic summary) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryTile(
            context,
            'Total Value',
            '\$${summary.totalValue.toStringAsFixed(2)}',
            Icons.account_balance_wallet,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryTile(
            context,
            'Today\'s Change',
            '\$${summary.todayChange.toStringAsFixed(2)}',
            summary.todayChange >= 0 ? Icons.trending_up : Icons.trending_down,
            summary.todayChange >= 0 ? Colors.green : Colors.red,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryTile(
            context,
            'Total Holdings',
            '${summary.totalHoldings ?? 0}',
            Icons.list_alt,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryTile(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar(BuildContext context) {
    return Row(
      children: [
        // Search Field
        Expanded(
          flex: 2,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search holdings...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        const SizedBox(width: 16),

        // Sort Dropdown
        SizedBox(
          width: 150,
          child: DropdownButtonFormField<String>(
            value: _sortBy,
            decoration: InputDecoration(
              labelText: 'Sort by',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items: const [
              DropdownMenuItem(
                value: 'marketValue',
                child: Text('Market Value'),
              ),
              DropdownMenuItem(value: 'symbol', child: Text('Symbol')),
              DropdownMenuItem(value: 'changePercent', child: Text('Change %')),
              DropdownMenuItem(value: 'quantity', child: Text('Quantity')),
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
        const SizedBox(width: 8),

        // Sort Direction Button
        IconButton(
          icon: Icon(
            _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
          ),
          onPressed: () {
            setState(() {
              _sortAscending = !_sortAscending;
            });
          },
          tooltip: _sortAscending ? 'Ascending' : 'Descending',
        ),
        const SizedBox(width: 16),

        // Filter Dropdown
        SizedBox(
          width: 120,
          child: DropdownButtonFormField<String>(
            value: _filterSector,
            decoration: InputDecoration(
              labelText: 'Sector',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All')),
              DropdownMenuItem(value: 'Technology', child: Text('Technology')),
              DropdownMenuItem(value: 'Healthcare', child: Text('Healthcare')),
              DropdownMenuItem(value: 'Finance', child: Text('Finance')),
              DropdownMenuItem(value: 'Energy', child: Text('Energy')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _filterSector = value;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHoldingsTable(BuildContext context, dynamic holdings) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Holdings Details',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: PortfolioHoldingsWebCard(
                holdings: holdings,
                showDetails: true,
                maxHoldings: 100,
                onHoldingTap: (holding) {
                  AppLogger.userAction(
                    'Holding selected',
                    tag: 'PortfolioHoldingsWebPage',
                    context: {'symbol': holding.symbol},
                  );
                  // Show holding details in side panel or modal
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidePanel(BuildContext context, AsyncValue holdingsAsync) {
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
                Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Holdings Info',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Top Movers Section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Top Movers',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  holdingsAsync.when(
                    data: (holdings) => MoversWidget(
                      holdings: holdings.holdings,
                      showGainers: true,
                      maxItems: 5,
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Text(
                      'Failed to load movers',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Top Losers',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  holdingsAsync.when(
                    data: (holdings) => MoversWidget(
                      holdings: holdings.holdings,
                      showGainers: false,
                      maxItems: 5,
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Text(
                      'Failed to load losers',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
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

  Widget _buildLoadingSummary() {
    return Row(
      children: List.generate(
        3,
        (index) => Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < 2 ? 16 : 0),
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorSummary(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Failed to load summary: $error',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContent(
    BuildContext context,
    String title,
    String error,
    VoidCallback onRetry,
  ) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
      ),
    );
  }
}
