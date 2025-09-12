import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/platform_widget.dart';
import '../../portfolio/widgets/portfolio_summary_card.dart';
import '../../portfolio/widgets/holdings_breakdown.dart';
import '../../../core/models/portfolio/portfolio_models.dart';
import '../../../core/services/api/portfolio_client.dart';
import '../../../core/services/api/api_client.dart';
import '../../../config/environment.dart';

/// Home screen displayed after login
class HomeScreen extends StatefulWidget {
  /// Constructor
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Current navigation index
  int _currentIndex = 0;
  
  /// Portfolio client for API calls
  late final PortfolioClient _portfolioClient;
  
  /// Future for portfolio summary data
  late Future<PortfolioSummary> _portfolioSummaryFuture;
  
  /// Auth service instance
  final _authService = AuthService();
  
  @override
  void initState() {
    super.initState();
    _portfolioClient = PortfolioClient(
      baseUrl: EnvironmentConfig.apiBaseUrl,
      useMockData: EnvironmentConfig.settings['useMockData'] ?? true,
    );
    _loadPortfolioSummary();
  }
  
  /// Load portfolio summary data
  void _loadPortfolioSummary() {
    // Get user ID from auth service
    final userId = _authService.currentState.user?.id ?? 'ssd2658';
    debugPrint('Loading portfolio data for user: $userId');
    
    // Ensure we're using the live API first
    _portfolioClient.useMockData = false;
    
    _portfolioSummaryFuture = _portfolioClient.getPortfolioSummary(userId).then((response) {
      if (response.isSuccess) {
        debugPrint('Successfully loaded portfolio data');
        return response.data!;
      } else {
        debugPrint('Failed to load portfolio data: ${response.error}');
        throw Exception(response.error ?? 'Failed to load portfolio data');
      }
    });
  }
  
  /// Refresh portfolio data
  Future<void> _refreshPortfolio() async {
    // Show a loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Refreshing portfolio data...')),
    );
    
    // Always try to fetch from the API when manually refreshing
    _portfolioClient.useMockData = false;
    
    setState(() {
      _loadPortfolioSummary();
    });
  }
  
  @override
  void dispose() {
    _portfolioClient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _HomeScreenContent(
      currentIndex: _currentIndex,
      onIndexChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      portfolioSummaryFuture: _portfolioSummaryFuture,
      onRefresh: _refreshPortfolio,
      onLogout: () async {
        await _authService.logout();
        // Navigation will be handled by auth state listener in main.dart
      },
    );
  }
}

/// Platform-adaptive home screen content
class _HomeScreenContent extends PlatformWidget<CupertinoPageScaffold, Scaffold> {
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
    Key? key,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.portfolioSummaryFuture,
    required this.onRefresh,
    required this.onLogout,
  }) : super(key: key);

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
      child: SafeArea(
        child: _buildBody(context),
      ),
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
        CupertinoSliverRefreshControl(
          onRefresh: onRefresh,
        ),
        SliverToBoxAdapter(
          child: _buildPortfolioContent(context),
        ),
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
                  // This will be implemented later
                },
              ),
              
              const SizedBox(height: 16),
              
              // Holdings breakdown
              HoldingsBreakdown(
                summary: summary,
              ),
              
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title coming soon!')),
          );
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
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRefresh,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build bottom navigation
  Widget _buildBottomNavigation(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS && !kIsWeb) {
      return CupertinoTabBar(
        currentIndex: currentIndex,
        onTap: onIndexChanged,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chart_bar_fill),
            label: 'Portfolio',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.arrow_right_arrow_left),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.news),
            label: 'News',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: 'Settings',
          ),
        ],
      );
    } else {
      return NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onIndexChanged,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: 'Portfolio',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.newspaper),
            label: 'News',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      );
    }
  }
  
  /// Build drawer for material design
  Widget _buildDrawer(BuildContext context) {
    final theme = Theme.of(context);
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.blueGrey,
                  ),
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
    if (defaultTargetPlatform == TargetPlatform.iOS && !kIsWeb) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoActionSheet(
          title: const Text('Profile Options'),
          actions: [
            CupertinoActionSheetAction(
              child: const Text('Account Settings'),
              onPressed: () {
                Navigator.pop(context);
                // Will be implemented in future
              },
            ),
            CupertinoActionSheetAction(
              child: const Text('Help & Support'),
              onPressed: () {
                Navigator.pop(context);
                // Will be implemented in future
              },
            ),
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context);
                onLogout();
              },
              child: const Text('Logout'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      );
    } else {
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
}
