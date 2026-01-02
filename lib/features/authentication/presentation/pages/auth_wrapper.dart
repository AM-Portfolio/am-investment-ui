import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/logger.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../../core/services/app_preload_service.dart';
import '../../../../shared/widgets/layouts/mobile_layout.dart';
import '../../../../shared/widgets/layouts/web_layout.dart';
import '../../../portfolio/presentation/pages/portfolio_screen.dart';
import '../../../trade/presentation/mobile/trade_mobile_screen.dart';
import '../../../trade/presentation/web/trade_web_screen.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../../../dashboard/presentation/pages/dashboard_web_page.dart';
import 'login_screen.dart';

/// Authentication-aware wrapper that manages authentication state
class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  String _currentPage = 'Dashboard';
  bool _isSidebarExpanded = true;
  bool _dataPreloaded = false;  // Track if data has been preloaded

  @override
  void initState() {
    super.initState();
    // Check authentication status on app startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthCubit>().checkAuthStatus();
    });
  }

  Future<void> _handleLogin(String userId) async {
    // Login is already handled by AuthCubit
    setState(() {
      _currentPage = 'Dashboard';
      _isSidebarExpanded = true;
    });
  }

  Future<void> _handleLogout() async {
    AppLogger.info('AuthWrapper: User initiated logout', tag: 'AuthWrapper');

    try {
      await context.read<AuthCubit>().logout();
      AppLogger.info(
        'AuthWrapper: Logout completed successfully',
        tag: 'AuthWrapper',
      );
    } catch (error) {
      AppLogger.error(
        'AuthWrapper: Logout failed',
        tag: 'AuthWrapper',
        error: error,
      );
    }

    setState(() {
      _currentPage = 'Dashboard';
      _isSidebarExpanded = true;
      _dataPreloaded = false;  // Reset preload flag for next login
    });
  }

  void _handleNavigation(String navItem) {
    setState(() {
      if (_currentPage == navItem) {
        _isSidebarExpanded = !_isSidebarExpanded;
      } else {
        _currentPage = navItem;
        _isSidebarExpanded = true;
      }
    });
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarExpanded = !_isSidebarExpanded;
    });
  }

  Widget _getCurrentScreen(String userId) {
    AppLogger.debug(
      '🎯 _getCurrentScreen called - page: "$_currentPage", userId: "$userId" (length: ${userId.length})',
      tag: 'AuthWrapper',
    );

    switch (_currentPage) {
      case 'Portfolio':
        AppLogger.debug(
          '📊 Creating PortfolioScreen with userId: "$userId"',
          tag: 'AuthWrapper',
        );
        return PortfolioScreen(
          userId: userId,
          isSidebarVisible: _isSidebarExpanded,
          onToggleSidebar: _toggleSidebar,
        );
      case 'Dashboard':
        return DashboardWebPage(
          userId: userId,
          isSidebarVisible: _isSidebarExpanded,
          onToggleSidebar: _toggleSidebar,
        );
      case 'Trade':
        AppLogger.debug(
          '📈 Creating TradeWebScreen/TradeMobileScreen with userId: "$userId"',
          tag: 'AuthWrapper',
        );
        return PlatformUtils.isWeb
            ? TradeWebScreen(
                userId: userId,
                isSidebarVisible: _isSidebarExpanded,
                onToggleSidebar: _toggleSidebar,
              )
            : TradeMobileScreen(
                userId: userId,
                onBack: () => _handleNavigation('Portfolio'),
              );
      case 'Market':
        return _buildPlaceholderScreen('Market');
      case 'News':
        return _buildPlaceholderScreen('News');
      case 'Reports':
        return _buildPlaceholderScreen('Reports');
      default:
        AppLogger.debug(
          '📊 Default: Creating PortfolioScreen with userId: "$userId"',
          tag: 'AuthWrapper',
        );
        return PortfolioScreen(
          userId: userId,
          isSidebarVisible: _isSidebarExpanded,
          onToggleSidebar: _toggleSidebar,
        );
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
  Widget build(BuildContext context) => BlocBuilder<AuthCubit, AuthState>(
    builder: (context, state) {
      AppLogger.debug(
        '🔄 AuthWrapper build - state: ${state.runtimeType}',
        tag: 'AuthWrapper',
      );

      // Show loading while authentication is in progress
      if (state is AuthLoading || state is AuthInitial) {
        AppLogger.debug('⏳ Showing loading screen', tag: 'AuthWrapper');
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      // Show error if authentication failed
      if (state is AuthError) {
        AppLogger.error(
          '❌ AuthWrapper: Authentication error - ${state.message}',
          tag: 'AuthWrapper',
        );
      }

      // Show login screen if not authenticated
      if (state is! Authenticated) {
        AppLogger.info(
          '🔓 Not authenticated - showing login screen',
          tag: 'AuthWrapper',
        );
        return LoginScreen(onLogin: _handleLogin);
      }

      // Show main app if authenticated
      final userId = state.user.id;
      final email = state.user.email;

      AppLogger.debug(
        '🔐 Authenticated state received - userId: "$userId" (length: ${userId.length}), email: "$email"',
        tag: 'AuthWrapper',
      );

      // CRITICAL: Validate userId is not empty before proceeding
      if (userId.isEmpty) {
        AppLogger.error(
          '🚨 CRITICAL: Authenticated state but userId is EMPTY! Email: "$email", authMethod: ${state.user.authMethod}',
          tag: 'AuthWrapper',
        );
        AppLogger.debug(
          '🔄 Forcing logout due to empty userId...',
          tag: 'AuthWrapper',
        );
        // Force logout and show login screen
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<AuthCubit>().logout();
        });
        return LoginScreen(onLogin: _handleLogin);
      }

      AppLogger.info(
        '✅ AuthWrapper: User authenticated successfully - userId: "$userId", email: "$email"',
        tag: 'AuthWrapper',
      );

      // Preload essential data (once per authentication)
      if (!_dataPreloaded) {
        AppLogger.debug(
          '📦 Preloading essential data for user...',
          tag: 'AuthWrapper',
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppPreloadService.preloadEssentialData(ref, userId);
          setState(() {
            _dataPreloaded = true;
          });
        });
      }

      AppLogger.debug(
        '🏗️ Building main app screen with userId: "$userId"',
        tag: 'AuthWrapper',
      );

      return PlatformUtils.isWeb
          ? WebLayout(
              title: _currentPage,
              activeNavItem: _currentPage,
              userName: state.user.displayName ?? state.user.email,
              userEmail: state.user.email,
              userAvatarUrl: state.user.photoUrl,
              onLogout: _handleLogout,
              onNavigate: _handleNavigation,
              child: _getCurrentScreen(userId),
            )
          : MobileLayout(
              title: 'AM Investment',
              activeNavItem: _currentPage,
              onLogout: _handleLogout,
              onNavigate: _handleNavigation,
              hideBottomNav:
                  _currentPage == 'Trade', // Hide bottom nav in Trade section
              child: _getCurrentScreen(userId),
            );
    },
  );
}
