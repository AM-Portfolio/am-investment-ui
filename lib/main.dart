import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/environment.dart';
import 'core/services/auth_service.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/home/home_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/portfolio/portfolio_screen.dart';
import 'core/config/config_service.dart';
import 'core/di/service_locator.dart';
import 'core/providers/app_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup dependency injection
  await setupServiceLocator();
  
  try {
    // Initialize configuration service
    await ConfigService.initialize(environment: 'dev');
    print('Configuration initialized successfully');
  } catch (e) {
    print('Failed to initialize configuration: $e');
    // The app will continue with default configuration
  }
  
  // Set environment based on compile-time constants
  // This will be overridden by build arguments in CI/CD
  EnvironmentConfig.setEnvironment(const String.fromEnvironment('ENV', defaultValue: 'production'));
  
  runApp(
    ProviderScope(
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Pre-load essential providers at runtime
    ref.watch(appConfigProvider);
    ref.watch(portfolioClientProvider);
    ref.watch(portfolioRepositoryProvider);
    
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
    final authService = AuthService();
    final authState = authService.authStateChanges.first;
    
    if (!authState.isAuthenticated) {
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
