import 'package:flutter/material.dart';
import '../../../core/domain/entities/portfolio/portfolio_summary.dart';
import '../../../core/services/auth_service.dart';
import '../../../widgets/shared/layouts/web_layout.dart';
import '../../../widgets/shared/finance/portfolio_summary_card.dart';
import '../../../widgets/shared/finance/market_summary.dart';
import '../../../widgets/shared/finance/watchlist.dart';

/// Web-specific implementation of the home screen
class HomeWebScreen extends StatelessWidget {
  /// Future for portfolio summary data
  final Future<PortfolioSummary> portfolioSummaryFuture;

  /// Callback to refresh portfolio data
  final Future<void> Function() onRefresh;

  /// Callback when logout is requested
  final VoidCallback onLogout;

  /// Constructor
  const HomeWebScreen({
    super.key,
    required this.portfolioSummaryFuture,
    required this.onRefresh,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return WebLayout(
      title: 'Home',
      activeNavItem: 'Dashboard',
      onLogout: onLogout,
      child: _buildHomeContent(context),
    );
  }

  /// Build the home content
  Widget _buildHomeContent(BuildContext context) {
    return FutureBuilder<PortfolioSummary>(
      future: portfolioSummaryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildErrorState(context, snapshot.error.toString());
        }

        final summary = snapshot.data!;
        final user = AuthService().currentState.user;

        // Modern home layout with multiple sections
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                                onTap: () {
                                  Navigator.of(context).pushNamed('/portfolio');
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 24),

                        // Right column - 1/3 width
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Quick actions
                              _buildSectionHeader(context, 'Quick Actions'),
                              const SizedBox(height: 16),
                              _buildQuickActions(context),

                              const SizedBox(height: 24),

                              // Market summary
                              _buildSectionHeader(context, 'Market Summary'),
                              const SizedBox(height: 16),
                              MarketSummary(
                                onViewFullSummary: () =>
                                    _showFullMarketSummary(context),
                              ),

                              const SizedBox(height: 24),

                              // Watchlist
                              _buildSectionHeader(context, 'Watchlist'),
                              const SizedBox(height: 16),
                              const Watchlist(),
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

  // Welcome section removed as requested

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

  /// Build quick actions section
  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);

    final actions = [
      {
        'icon': Icons.add_chart,
        'label': 'New Investment',
        'color': Colors.blue,
      },
      {
        'icon': Icons.history,
        'label': 'Transaction History',
        'color': Colors.orange,
      },
      {
        'icon': Icons.analytics,
        'label': 'Portfolio Analysis',
        'color': Colors.purple,
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Use Wrap for smaller screens
            if (constraints.maxWidth < 400) {
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.spaceAround,
                children: actions
                    .map((action) => _buildActionItem(context, action))
                    .toList(),
              );
            }
            // Use Row for larger screens
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: actions
                  .map(
                    (action) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: _buildActionItem(context, action),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ),
    );
  }

  /// Build an individual action item
  Widget _buildActionItem(BuildContext context, Map<String, dynamic> action) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${action['label']} coming soon')),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (action['color'] as Color).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                action['icon'] as IconData,
                color: action['color'] as Color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              action['label'] as String,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Market summary component has been moved to a separate file: widgets/shared/finance/market_summary.dart

  // Watchlist component has been moved to a separate file: widgets/shared/finance/watchlist.dart

  /// Show full market summary dialog
  void _showFullMarketSummary(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Market Summary',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: Container(
                    constraints: const BoxConstraints(
                      maxWidth: 800,
                      maxHeight: 500,
                    ),
                    child: const MarketSummary(showFull: true),
                  ),
                ),
              ],
            ),
          ),
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
                  onPressed: onRefresh,
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
