import 'package:flutter/material.dart';
import 'config/environment.dart';
import 'core/services/auth_service.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/home/screens/home_screen.dart';

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
        primarySwatch: Colors.blue,
        brightness: EnvironmentConfig.environment == Environment.preprod ? Brightness.light : Brightness.light,
      ),
      initialRoute: _authState.isAuthenticated ? '/home' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
      debugShowCheckedModeBanner: EnvironmentConfig.environment == Environment.preprod,
    );
  }
}

// HomeScreen is now imported from features/home/screens/home_screen.dart
