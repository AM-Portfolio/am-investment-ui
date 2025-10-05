import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../portfolio/presentation/pages/portfolio_screen.dart';
import '../../../../shared/widgets/layouts/web_layout.dart';
import '../../../../shared/widgets/layouts/mobile_layout.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../../di/login_providers.dart';
import 'login_screen.dart';

/// Authentication-aware wrapper that manages authentication state
/// and persists login status across page reloads using SharedPreferences
class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  String _currentPage = 'Portfolio';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    // Initialize authentication state and check for existing session
    await ref.read(authStateNotifierProvider.notifier).validateSession();
    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _handleLogin(String userId) async {
    // The login is already handled by the Riverpod providers
    // This callback is just for compatibility with LoginScreen
    setState(() {
      _currentPage = 'Portfolio';
    });
  }

  Future<void> _handleLogout() async {
    await ref.read(authStateNotifierProvider.notifier).logout();
    setState(() {
      _currentPage = 'Portfolio';
    });
  }

  void _handleNavigation(String navItem) {
    setState(() {
      _currentPage = navItem;
    });
  }

  Widget _getCurrentScreen() {
    final user = ref.watch(currentUserProvider);
    final userId = user?.id ?? '';

    switch (_currentPage) {
      case 'Portfolio':
        return PortfolioScreen(userId: userId);
      case 'Dashboard':
        return _buildPlaceholderScreen('Dashboard');
      case 'Trade':
        return _buildPlaceholderScreen('Trade');
      case 'Market':
        return _buildPlaceholderScreen('Market');
      case 'News':
        return _buildPlaceholderScreen('News');
      case 'Reports':
        return _buildPlaceholderScreen('Reports');
      default:
        return PortfolioScreen(userId: userId);
    }
  }

  Widget _buildPlaceholderScreen(String title) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.construction,
          size: 64,
          color: Theme.of(context).primaryColor.withOpacity(0.6),
        ),
        const SizedBox(height: 16),
        Text(
          '$title Coming Soon',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'This feature is under development.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    // Show loading while initializing authentication
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final authState = ref.watch(authStateNotifierProvider);

    // Show loading while authentication is in progress
    if (authState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Show login screen if not authenticated
    if (!isAuthenticated) {
      return LoginScreen(onLogin: _handleLogin);
    }

    // Show main app if authenticated
    return PlatformUtils.isWeb
        ? WebLayout(
            title: _currentPage,
            activeNavItem: _currentPage,
            onLogout: _handleLogout,
            onNavigate: _handleNavigation,
            child: _getCurrentScreen(),
          )
        : MobileLayout(
            title: 'AM Investment',
            activeNavItem: _currentPage,
            onLogout: _handleLogout,
            onNavigate: _handleNavigation,
            child: _getCurrentScreen(),
          );
  }
}
