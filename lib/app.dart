import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/login/presentation/pages/auth_wrapper.dart';
import 'features/portfolio/presentation/pages/portfolio_screen.dart';
import 'features/authentication/presentation/pages/register_page.dart';
import 'features/authentication/presentation/pages/forgot_password_page.dart';
import 'features/authentication/presentation/pages/reset_password_page.dart';

/// Root app widget that sets up DI, router, and theme.
/// Uses adaptive navigation if needed (e.g., sidebar on web).
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp(
    title: 'AM Investment',
    theme: ThemeData(
      primarySwatch: Colors.blue,
      useMaterial3: true,
      // Configure theme based on platform/screen size
      visualDensity: _getVisualDensity(),
    ),
    darkTheme: ThemeData.dark(useMaterial3: true),
    home: const AuthWrapper(),
    // Add routes
    routes: {
      '/portfolio': (context) => const PortfolioScreen(userId: ''),
      '/register': (context) => const RegisterPage(),
      '/forgot-password': (context) => const ForgotPasswordPage(),
      '/reset-password': (context) => const ResetPasswordPage(),
    },
    // Add error handling
    builder: (context, child) =>
        _AppErrorBoundary(child: child ?? const SizedBox.shrink()),
  );

  /// Get visual density based on platform
  VisualDensity _getVisualDensity() {
    // Use adaptive density - compact on mobile, standard on desktop
    return VisualDensity.adaptivePlatformDensity;
  }
}

/// Error boundary widget to handle app-level errors
class _AppErrorBoundary extends StatelessWidget {
  const _AppErrorBoundary({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
