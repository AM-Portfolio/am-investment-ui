import 'package:flutter/material.dart';
import '../../../core/models/portfolio/portfolio_models.dart';
import '../../../core/services/api/api_client.dart';
import '../../../widgets/shared/finance/portfolio_summary_card.dart';
import '../../../widgets/shared/layouts/web_layout.dart';
import '../../../core/services/auth_service.dart';

/// Web-specific implementation of the dashboard screen
class DashboardWebScreen extends StatelessWidget {
  /// Future for portfolio summary data
  final Future<ApiResponse<PortfolioSummary>> portfolioSummaryFuture;

  /// Callback to refresh portfolio data
  final Future<void> Function() refreshPortfolio;

  /// Callback when logout is requested
  final VoidCallback? onLogout;

  /// Constructor
  const DashboardWebScreen({
    super.key,
    required this.portfolioSummaryFuture,
    required this.refreshPortfolio,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return WebLayout(
      title: 'Dashboard',
      activeNavItem: 'Dashboard',
      onLogout: onLogout,
      child: _buildDashboardContent(context),
    );
  }

  /// Build the dashboard content
  Widget _buildDashboardContent(BuildContext context) {
    return FutureBuilder<ApiResponse<PortfolioSummary>>(
      future: portfolioSummaryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildErrorState(context, snapshot.error.toString());
        }

        final response = snapshot.data!;

        if (!response.isSuccess) {
          return _buildErrorState(context, response.error ?? 'Unknown error');
        }

        final summary = response.data!;
        final user = AuthService().currentState.user;

        // Dashboard layout with multiple sections
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome section
                _buildWelcomeSection(context, user?.name ?? 'Investor'),

                const SizedBox(height: 24),

                // Dashboard content in a grid layout
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left column - 2/3 width
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Portfolio summary
                              _buildSectionHeader(
                                context,
                                'Portfolio Overview',
                              ),
                              const SizedBox(height: 16),
                              PortfolioSummaryCard(
                                summary: summary,
                                showDetails: false,
                              ),

                              const SizedBox(height: 24),

                              // Market overview
                              _buildSectionHeader(context, 'Market Overview'),
                              const SizedBox(height: 16),
                              _buildMarketOverview(context),

                              const SizedBox(height: 24),

                              // Recent transactions
                              _buildSectionHeader(
                                context,
                                'Recent Transactions',
                              ),
                              const SizedBox(height: 16),
                              _buildRecentTransactions(context),
                            ],
                          ),
                        ),

                        const SizedBox(width: 24),

                        // Right column - 1/3 width
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Account summary
                              _buildSectionHeader(context, 'Account Summary'),
                              const SizedBox(height: 16),
                              _buildAccountSummary(context),

                              const SizedBox(height: 24),

                              // Watchlist
                              _buildSectionHeader(context, 'Watchlist'),
                              const SizedBox(height: 16),
                              _buildWatchlist(context),

                              const SizedBox(height: 24),

                              // News and insights
                              _buildSectionHeader(context, 'News & Insights'),
                              const SizedBox(height: 16),
                              _buildNewsInsights(context),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build welcome section
  Widget _buildWelcomeSection(BuildContext context, String userName) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    String greeting;

    if (now.hour < 12) {
      greeting = 'Good Morning';
    } else if (now.hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting, $userName',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Welcome to your investment dashboard',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  /// Build section header
  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Build market overview section
  Widget _buildMarketOverview(BuildContext context) {
    final theme = Theme.of(context);

    // Dummy market data
    final marketData = [
      {
        'name': 'NIFTY 50',
        'value': '22,456.30',
        'change': '+1.2%',
        'isPositive': true,
      },
      {
        'name': 'SENSEX',
        'value': '73,890.45',
        'change': '+0.9%',
        'isPositive': true,
      },
      {
        'name': 'NIFTY BANK',
        'value': '48,123.75',
        'change': '-0.3%',
        'isPositive': false,
      },
      {
        'name': 'NIFTY IT',
        'value': '35,678.20',
        'change': '+2.1%',
        'isPositive': true,
      },
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            for (final item in marketData)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['name']! as String,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      item['value']! as String,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (item['isPositive'] as bool)
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item['change']! as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: (item['isPositive'] as bool)
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Navigate to market page
                },
                child: const Text('View All Markets'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build recent transactions section
  Widget _buildRecentTransactions(BuildContext context) {
    final theme = Theme.of(context);

    // Dummy transaction data
    final transactions = [
      {
        'type': 'Buy',
        'symbol': 'INFY',
        'name': 'Infosys Ltd',
        'date': '14 Sep 2025',
        'price': '₹1,850.75',
        'quantity': '10',
      },
      {
        'type': 'Sell',
        'symbol': 'HDFCBANK',
        'name': 'HDFC Bank Ltd',
        'date': '12 Sep 2025',
        'price': '₹1,675.30',
        'quantity': '5',
      },
      {
        'type': 'Buy',
        'symbol': 'TCS',
        'name': 'Tata Consultancy Services',
        'date': '10 Sep 2025',
        'price': '₹3,950.00',
        'quantity': '2',
      },
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            for (final transaction in transactions)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    // Transaction type indicator
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: transaction['type'] == 'Buy'
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        transaction['type'] == 'Buy'
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: transaction['type'] == 'Buy'
                            ? Colors.green
                            : Colors.red,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Stock info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                transaction['symbol']!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                transaction['name']!,
                                style: theme.textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          Text(
                            transaction['date']!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Price and quantity
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          transaction['price']!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${transaction['quantity']} shares',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Navigate to transactions page
                },
                child: const Text('View All Transactions'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build account summary section
  Widget _buildAccountSummary(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildAccountSummaryItem(
              context,
              'Available Balance',
              '₹45,678.90',
              Icons.account_balance_wallet,
            ),
            const Divider(height: 24),
            _buildAccountSummaryItem(
              context,
              'Margin Used',
              '₹12,500.00',
              Icons.trending_up,
            ),
            const Divider(height: 24),
            _buildAccountSummaryItem(
              context,
              'Funds Deposited',
              '₹1,00,000.00',
              Icons.arrow_downward,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Add funds
                    },
                    child: const Text('Add Funds'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Withdraw funds
                    },
                    child: const Text('Withdraw'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build account summary item
  Widget _buildAccountSummaryItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Build watchlist section
  Widget _buildWatchlist(BuildContext context) {
    final theme = Theme.of(context);

    // Dummy watchlist data
    final watchlist = [
      {
        'symbol': 'RELIANCE',
        'price': '₹2,890.45',
        'change': '+1.8%',
        'isPositive': true,
      },
      {
        'symbol': 'TATASTEEL',
        'price': '₹145.75',
        'change': '-0.5%',
        'isPositive': false,
      },
      {
        'symbol': 'ICICIBANK',
        'price': '₹978.30',
        'change': '+0.7%',
        'isPositive': true,
      },
      {
        'symbol': 'WIPRO',
        'price': '₹456.20',
        'change': '-1.2%',
        'isPositive': false,
      },
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            for (final item in watchlist)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['symbol']! as String,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          item['price']! as String,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: (item['isPositive'] as bool)
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item['change']! as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: (item['isPositive'] as bool)
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Navigate to watchlist page
                },
                child: const Text('Manage Watchlist'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build news and insights section
  Widget _buildNewsInsights(BuildContext context) {
    final theme = Theme.of(context);

    // Dummy news data
    final news = [
      {
        'title': 'RBI Monetary Policy: Key Highlights',
        'source': 'Financial Express',
        'time': '2 hours ago',
      },
      {
        'title': 'IT Sector Q2 Results Preview',
        'source': 'Economic Times',
        'time': '5 hours ago',
      },
      {
        'title': 'New IPOs to Watch This Month',
        'source': 'Mint',
        'time': '1 day ago',
      },
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            for (final item in news)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.article,
                        color: theme.colorScheme.onPrimaryContainer,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title']!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                item['source']!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                item['time']!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Navigate to news page
                },
                child: const Text('View All News'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build error state widget
  Widget _buildErrorState(BuildContext context, String errorMessage) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 24),
                Text(
                  'Error loading dashboard data',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Text(
                  errorMessage,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: refreshPortfolio,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
