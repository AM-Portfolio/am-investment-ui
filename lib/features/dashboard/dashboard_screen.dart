import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../../core/domain/entities/portfolio/portfolio_summary.dart';
import '../../core/domain/repositories/portfolio_repository.dart';
import '../../config/environment.dart';
import '../../core/services/auth_service.dart';
import 'web/dashboard_web_screen.dart';

/// Main dashboard screen that serves as the entry point after login
/// Delegates to platform-specific implementations
class DashboardScreen extends StatefulWidget {
  /// Constructor
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  /// Portfolio repository for data operations
  late final PortfolioRepository _portfolioRepository;

  /// Future for portfolio summary data
  late Future<PortfolioSummary> _portfolioSummaryFuture;

  /// Auth service instance
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _initializeRepository();
    _loadPortfolioSummary();

    // Listen for environment changes
    EnvironmentConfig.addListener(_onEnvironmentChanged);
  }

  /// Initialize portfolio repository
  void _initializeRepository() {
    _portfolioRepository = PortfolioRepositoryImpl();
  }

  /// Handle environment changes
  void _onEnvironmentChanged(Environment env) {
    // Reload data with updated environment
    setState(() {
      _loadPortfolioSummary();
    });
  }

  /// Load portfolio summary data
  void _loadPortfolioSummary() {
    // Get user ID from auth service
    final userId = _authService.currentState.user?.id ?? 'ssd2658';

    _portfolioSummaryFuture = _portfolioRepository.getPortfolioSummary(userId);
  }

  /// Refresh portfolio data
  Future<void> _refreshPortfolio() async {
    setState(() {
      _loadPortfolioSummary();
    });
  }

  /// Handle logout
  Future<void> _handleLogout() async {
    await _authService.logout();
    // Navigation will be handled by auth state listener in main.dart
  }

  @override
  void dispose() {
    // Remove environment change listener
    EnvironmentConfig.removeListener(_onEnvironmentChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // For web, use the web-specific dashboard
    if (kIsWeb) {
      return DashboardWebScreen(
        portfolioSummaryFuture: _portfolioSummaryFuture,
        refreshPortfolio: _refreshPortfolio,
        onLogout: _handleLogout,
      );
    }

    // For mobile platforms, we'll implement platform-specific screens later
    // For now, just show a placeholder
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _handleLogout),
        ],
      ),
      body: Center(
        child: Text(
          'Mobile dashboard coming soon',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
