import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/logger.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../../shared/widgets/layouts/mobile_layout.dart';
import '../../../../shared/widgets/layouts/web_layout.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../../../portfolio/presentation/pages/portfolio_screen.dart';
import 'login_screen.dart';

/// Authentication-aware wrapper that manages authentication state
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  String _currentPage = 'Portfolio';

  Future<void> _handleLogin(String userId) async {
    // Login is already handled by AuthCubit
    setState(() {
      _currentPage = 'Portfolio';
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
      _currentPage = 'Portfolio';
    });
  }

  void _handleNavigation(String navItem) {
    setState(() {
      _currentPage = navItem;
    });
  }

  Widget _getCurrentScreen(String userId) {
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
  Widget build(BuildContext context) =>
      BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          // Show loading while authentication is in progress
          if (state is AuthLoading || state is AuthInitial) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Show error if authentication failed
          if (state is AuthError) {
            AppLogger.error(
              'AuthWrapper: Authentication error - ${state.message}',
              tag: 'AuthWrapper',
            );
          }

          // Show login screen if not authenticated
          if (state is! Authenticated) {
            return LoginScreen(onLogin: _handleLogin);
          }

          // Show main app if authenticated
          final userId = state.user.id;
          AppLogger.info(
            'AuthWrapper: User authenticated - ${state.user.email}',
            tag: 'AuthWrapper',
          );

          return PlatformUtils.isWeb
              ? WebLayout(
                  title: _currentPage,
                  activeNavItem: _currentPage,
                  userName: state.user.displayName ?? state.user.email,
                  userEmail: state.user.email,
                  onLogout: _handleLogout,
                  onNavigate: _handleNavigation,
                  child: _getCurrentScreen(userId),
                )
              : MobileLayout(
                  title: 'AM Investment',
                  activeNavItem: _currentPage,
                  onLogout: _handleLogout,
                  onNavigate: _handleNavigation,
                  child: _getCurrentScreen(userId),
                );
        },
      );
}
