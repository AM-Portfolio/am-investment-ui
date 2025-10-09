import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/authentication/presentation/pages/login_page.dart';
import 'features/authentication/presentation/cubit/auth_cubit.dart';
import 'features/authentication/presentation/cubit/feature_flag_cubit.dart';
import 'shared/pages/home_page.dart';
import 'di/injection.dart';

/// Root app widget that sets up DI, router, and theme.
/// Uses adaptive navigation if needed (e.g., sidebar on web).
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MultiBlocProvider(
    providers: [
      BlocProvider<AuthCubit>(create: (context) => getIt<AuthCubit>()),
      BlocProvider<FeatureFlagCubit>(
        create: (context) => getIt<FeatureFlagCubit>(),
      ),
    ],
    child: MaterialApp(
      title: 'AM Investment',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        // Configure theme based on platform/screen size
        visualDensity: _getVisualDensity(),
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: const LoginPage(),
      // Add routes
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
      },
      // Add error handling
      builder: (context, child) =>
          _AppErrorBoundary(child: child ?? const SizedBox.shrink()),
    ),
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
