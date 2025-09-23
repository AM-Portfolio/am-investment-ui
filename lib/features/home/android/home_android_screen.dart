import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/domain/entities/portfolio/portfolio_summary.dart';
import '../../../core/widgets/platform_widget.dart';
import '../../../widgets/shared/finance/portfolio_summary_card.dart';
import '../../../widgets/shared/finance/holdings_breakdown.dart';

/// Android-specific implementation of the home screen
class HomeAndroidScreen extends StatelessWidget {
  /// Current navigation index
  final int currentIndex;

  /// Callback when navigation index changes
  final ValueChanged<int> onIndexChanged;

  /// Future for portfolio summary data
  final Future<PortfolioSummary> portfolioSummaryFuture;

  /// Callback to refresh portfolio data
  final Future<void> Function() onRefresh;

  /// Callback when logout is requested
  final VoidCallback onLogout;

  /// Constructor
  const HomeAndroidScreen({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.portfolioSummaryFuture,
    required this.onRefresh,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return _HomeScreenContent(
      currentIndex: currentIndex,
      onIndexChanged: onIndexChanged,
      portfolioSummaryFuture: portfolioSummaryFuture,
      onRefresh: onRefresh,
      onLogout: onLogout,
    );
  }
}

/// Platform-adaptive home screen content
class _HomeScreenContent
    extends PlatformWidget<CupertinoPageScaffold, Scaffold> {
  /// Current navigation index
  final int currentIndex;

  /// Callback when navigation index changes
  final ValueChanged<int> onIndexChanged;

  /// Future for portfolio summary data
  final Future<PortfolioSummary> portfolioSummaryFuture;

  /// Callback to refresh portfolio data
  final Future<void> Function() onRefresh;

  /// Callback when logout is requested
  final VoidCallback onLogout;

  /// Constructor
  const _HomeScreenContent({
    required this.currentIndex,
    required this.onIndexChanged,
    required this.portfolioSummaryFuture,
    required this.onRefresh,
    required this.onLogout,
  });

  @override
  CupertinoPageScaffold buildIosWidget(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('AM Investment'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.profile_circled),
          onPressed: () => _showProfileOptions(context),
        ),
      ),
      child: SafeArea(child: _buildBody(context)),
    );
  }

  @override
  Scaffold buildMaterialWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AM Investment'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => _showProfileOptions(context),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: _buildBody(context),
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  /// Build the main body content
  Widget _buildBody(BuildContext context) {
    // Currently we only have the portfolio view
    // In the future, we can switch based on currentIndex
    return CustomScrollView(
      slivers: [
        CupertinoSliverRefreshControl(onRefresh: onRefresh),
        SliverToBoxAdapter(child: _buildPortfolioContent(context)),
      ],
    );
  }

  /// Build the portfolio content
  Widget _buildPortfolioContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder<PortfolioSummary>(
        future: portfolioSummaryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorView(
              context,
              'Error loading portfolio data',
              snapshot.error.toString(),
            );
          }

          final summary = snapshot.data!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Welcome back!',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),

              // Portfolio summary card
              PortfolioSummaryCard(
                summary: summary,
                showDetails: false,
                onTap: () {
                  // Navigate to detailed portfolio view
                  Navigator.pushNamed(context, '/portfolio');
                },
              ),

              const SizedBox(height: 16),

              // Holdings breakdown
              HoldingsBreakdown(summary: summary),

              // Space for additional panels in the future
              const SizedBox(height: 32),

              // Placeholder for future panels
              _buildPlaceholderPanel(
                context,
                'Recent Transactions',
                'View your recent investment activities',
                Icons.history,
              ),

              const SizedBox(height: 16),

              _buildPlaceholderPanel(
                context,
                'Market News',
                'Stay updated with the latest market trends',
                Icons.newspaper,
              ),
            ],
          );
        },
      ),
    );
  }

  /// Build a placeholder panel for future features
  Widget _buildPlaceholderPanel(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Will be implemented in future
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('$title coming soon!')));
        },
      ),
    );
  }

  /// Build error view
  Widget _buildErrorView(BuildContext context, String title, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRefresh, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  /// Build bottom navigation
  Widget _buildBottomNavigation(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onIndexChanged,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Portfolio'),
        NavigationDestination(
          icon: Icon(Icons.swap_horiz),
          label: 'Transactions',
        ),
        NavigationDestination(icon: Icon(Icons.newspaper), label: 'News'),
        NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }

  /// Build drawer for material design
  Widget _buildDrawer(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: theme.colorScheme.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 30, color: Colors.blueGrey),
                ),
                const SizedBox(height: 10),
                Text(
                  'AM Investment',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Manage your investments',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            selected: currentIndex == 0,
            onTap: () {
              onIndexChanged(0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Portfolio'),
            selected: currentIndex == 0,
            onTap: () {
              onIndexChanged(0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.swap_horiz),
            title: const Text('Transactions'),
            selected: currentIndex == 1,
            onTap: () {
              onIndexChanged(1);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.newspaper),
            title: const Text('Market News'),
            selected: currentIndex == 2,
            onTap: () {
              onIndexChanged(2);
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            selected: currentIndex == 3,
            onTap: () {
              onIndexChanged(3);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.pop(context);
              // Will be implemented in future
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help & Support coming soon!')),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              onLogout();
            },
          ),
        ],
      ),
    );
  }

  /// Show profile options
  void _showProfileOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Account Settings'),
            onTap: () {
              Navigator.pop(context);
              // Will be implemented in future
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.pop(context);
              // Will be implemented in future
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              onLogout();
            },
          ),
        ],
      ),
    );
  }
}
