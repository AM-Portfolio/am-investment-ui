import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import '../../../portfolio/presentation/pages/portfolio_screen.dart';
import '../../../../shared/widgets/layouts/web_layout.dart';
import '../../../../shared/widgets/layouts/mobile_layout.dart';
import '../../../../core/utils/platform_utils.dart';

class LoginWrapper extends StatefulWidget {
  const LoginWrapper({super.key});

  @override
  State<LoginWrapper> createState() => _LoginWrapperState();
}

class _LoginWrapperState extends State<LoginWrapper> {
  bool _isAuthenticated = false;
  String _userId = '';
  String _currentPage = 'Portfolio';
  bool _isInitialized = false;
  
  // SharedPreferences keys
  static const String _authKey = 'is_authenticated';
  static const String _userIdKey = 'user_id';
  
  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }
  
  Future<void> _initializeAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isAuth = prefs.getBool(_authKey) ?? false;
      final userId = prefs.getString(_userIdKey) ?? '';
      
      setState(() {
        _isAuthenticated = isAuth;
        _userId = userId;
        _isInitialized = true;
      });
    } catch (error) {
      setState(() {
        _isInitialized = true;
      });  
    }
  }

  void _handleLogin(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_authKey, true);
      await prefs.setString(_userIdKey, userId);
      
      setState(() {
        _isAuthenticated = true;
        _userId = userId;
      });
    } catch (error) {
      // Fallback to local state if SharedPreferences fails
      setState(() {
        _isAuthenticated = true;
        _userId = userId;
      });
    }
  }

  void _handleLogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_authKey);
      await prefs.remove(_userIdKey);
    } catch (error) {
      // Continue with logout even if SharedPreferences fails
    }
    
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
    // Show loading screen while initializing authentication state
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (_isAuthenticated) {
      // For mobile platforms, use mobile layout, for web/desktop use web layout
      if (PlatformUtils.isMobile) {
        return MobileLayout(
          title: 'AM Investment',
          activeNavItem: _currentPage,
          onLogout: _handleLogout,
          onNavigate: _handleNavigation,
          child: _getCurrentScreen(),
        );
      } else {
        return WebLayout(
          title: 'AM Investment',
          activeNavItem: _currentPage,
          onLogout: _handleLogout,
          onNavigate: _handleNavigation,
          child: _getCurrentScreen(),
        );
      }
    } else {
      // Always show login screen regardless of platform when not authenticated
      return LoginScreen(onLogin: _handleLogin);
    }
  }
}
