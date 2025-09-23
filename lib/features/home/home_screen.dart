import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../core/services/auth_service.dart';
import '../../core/domain/entities/portfolio/portfolio_summary.dart';
import '../../core/domain/repositories/portfolio_repository.dart';
import '../../config/environment.dart';
import 'web/home_web_screen.dart';
import 'android/home_android_screen.dart';

/// Home screen displayed after login
class HomeScreen extends StatefulWidget {
  /// Constructor
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Current navigation index
  int _currentIndex = 0;

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

    // Show a notification
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Environment changed to ${env.toString().split('.').last}. Reloading data...',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Load portfolio summary data
  void _loadPortfolioSummary() {
    // Get user ID from auth service
    final userId = _authService.currentState.user?.id ?? 'ssd2658';
    debugPrint('Loading portfolio data for user: $userId');

    _portfolioSummaryFuture = _portfolioRepository.getPortfolioSummary(userId).then(
      (summary) {
        debugPrint('Successfully loaded portfolio data');
        return summary;
      },
    ).catchError((error) {
      debugPrint('Failed to load portfolio data: $error');
      throw Exception('Failed to load portfolio data: $error');
    });
  }

  /// Refresh portfolio data
  Future<void> _refreshPortfolio() async {
    // Show a loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Refreshing portfolio data...')),
    );

    setState(() {
      _loadPortfolioSummary();
    });
  }

  @override
  void dispose() {
    // Remove environment change listener
    EnvironmentConfig.removeListener(_onEnvironmentChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Platform-specific implementations
    if (kIsWeb) {
      return HomeWebScreen(
        portfolioSummaryFuture: _portfolioSummaryFuture,
        onRefresh: _refreshPortfolio,
        onLogout: () async {
          await _authService.logout();
          // Navigation will be handled by auth state listener in main.dart
        },
      );
    } else {
      // For mobile platforms
      return HomeAndroidScreen(
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
}

// The _HomeScreenContent class has been moved to the Android implementation
