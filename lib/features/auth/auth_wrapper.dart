import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../portfolio/portfolio_screen.dart';
import '../../widgets/shared/layouts/web_layout.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isAuthenticated = false;
  String _userId = '';
  String _currentPage = 'Portfolio';

  void _handleLogin(String userId) {
    setState(() {
      _isAuthenticated = true;
      _userId = userId;
    });
  }

  void _handleLogout() {
    setState(() {
      _isAuthenticated = false;
      _userId = '';
      _currentPage = 'Portfolio';
    });
  }

  void _handleNavigation(String navItem) {
    setState(() {
      _currentPage = navItem;
    });
  }

  Widget _getCurrentScreen() {
    switch (_currentPage) {
      case 'Portfolio':
        return PortfolioScreen(userId: _userId);
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
        return PortfolioScreen(userId: _userId);
    }
  }

  Widget _buildPlaceholderScreen(String title) {
    return Center(
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
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticated) {
      return WebLayout(
        title: 'AM Investment',
        activeNavItem: _currentPage,
        onLogout: _handleLogout,
        onNavigate: _handleNavigation,
        child: _getCurrentScreen(),
      );
    } else {
      return LoginScreen(onLogin: _handleLogin);
    }
  }
}
