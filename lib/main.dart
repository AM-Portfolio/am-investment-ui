import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'config/environment.dart';
import 'core/services/auth_service.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/home/home_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/portfolio/portfolio_screen.dart';

void main() {
  // Set environment based on compile-time constants
  // This will be overridden by build arguments in CI/CD
  EnvironmentConfig.setEnvironment(const String.fromEnvironment('ENV', defaultValue: 'production'));
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService _authService = AuthService();
  AuthState _authState = AuthState.unauthenticated();
  
  @override
  void initState() {
    super.initState();
    _authService.authStateChanges.listen((state) {
      setState(() {
        _authState = state;
      });
    });
    
    // Check if user is already logged in
    _authService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: EnvironmentConfig.settings['appTitle'],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: EnvironmentConfig.environment == Environment.preprod ? Brightness.light : Brightness.light,
        ),
        useMaterial3: true,
      ),
      initialRoute: _getInitialRoute(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/portfolio': (context) => const PortfolioScreen(userId: 'ssd2658'),
      },
      debugShowCheckedModeBanner: EnvironmentConfig.environment == Environment.preprod,
    );
  }
  
  /// Get the initial route based on authentication state and platform
  String _getInitialRoute() {
    if (!_authState.isAuthenticated) {
      return '/login';
    }
    
    // For web, go to dashboard as default
    if (kIsWeb) {
      return '/dashboard';
    }
    
    // For mobile, use the home screen
    return '/home';
  }
}

// HomeScreen is now imported from features/home/home_screen.dart
