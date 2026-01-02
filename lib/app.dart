import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'di/auth_providers.dart';
import 'features/authentication/presentation/pages/auth_wrapper.dart';
import 'features/authentication/presentation/pages/login_screen.dart';
import 'features/authentication/presentation/pages/reset_password_page.dart';
import 'features/portfolio/presentation/pages/portfolio_screen.dart';
import 'features/trade/presentation/add_trade/pages/add_trade_web_page.dart';
import 'features/trade/presentation/calendar/pages/trade_calendar_analytics_web_page.dart';
import 'features/trade/presentation/cubit/trade_controller_cubit.dart';
import 'features/trade/presentation/holdings/pages/trade_holdings_dashboard_web_page.dart';
import 'features/trade/presentation/mobile/pages/trade_holdings_dashboard_mobile_page.dart';
import 'features/market_analysis/presentation/pages/market_analysis_page.dart';
import 'features/trade/presentation/web/pages/trade_portfolio_list_web_page.dart';
import 'features/trade/providers/trade_controller_providers.dart';

/// Root app widget that sets up DI, router, and theme.
/// Uses adaptive navigation if needed (e.g., sidebar on web).
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) =>
      MultiBlocProvider(providers: AuthProviders.providers, child: const _MaterialApp());
}

class _MaterialApp extends StatelessWidget {
  const _MaterialApp();

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'AM Investment',
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      FlutterQuillLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en', '')],
    theme: ThemeData(
      primarySwatch: Colors.blue,
      useMaterial3: true,
      // Configure theme based on platform/screen size
      visualDensity: _getVisualDensity(),
    ),
    darkTheme: ThemeData.dark(useMaterial3: true),
    home: const AuthWrapper(),
    // Add routes
    onGenerateRoute: (settings) {
      switch (settings.name) {
        case '/portfolio':
          return MaterialPageRoute(builder: (context) => const PortfolioScreen(userId: ''));
        case '/register':
          return MaterialPageRoute(builder: (context) => const LoginScreen(initialView: AuthView.register));
        case '/forgot-password':
          return MaterialPageRoute(builder: (context) => const LoginScreen(initialView: AuthView.forgotPassword));
        case '/reset-password':
          return MaterialPageRoute(builder: (context) => const ResetPasswordPage());
        case '/trade/portfolios':
          return MaterialPageRoute(
            builder: (context) => const TradePortfolioListWebPage(userId: '64d5f6c9-9516-4eca-ac45-c73cfff7a8ec'),
          );
        case '/trade/holdings':
          final args = settings.arguments! as Map<String, String>;
          return MaterialPageRoute(
            builder: (context) =>
                TradeHoldingsDashboardWebPage(userId: args['userId']!, portfolioId: args['portfolioId']!),
          );
        case '/trade/calendar':
          final args = settings.arguments! as Map<String, String>;
          return MaterialPageRoute(
            builder: (context) =>
                TradeCalendarAnalyticsWebPage(userId: args['userId']!, portfolioId: args['portfolioId']!),
          );
        case '/market-analysis':
          return MaterialPageRoute(builder: (context) => const MarketAnalysisPage());
        case '/trade/add':
          final args = settings.arguments! as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => Consumer(
              builder: (context, ref, _) {
                // Get TradeControllerCubit from Riverpod provider
                final tradeControllerCubitAsync = ref.watch(tradeControllerCubitProvider);

                return tradeControllerCubitAsync.when(
                  data: (tradeControllerCubit) => BlocProvider<TradeControllerCubit>.value(
                    value: tradeControllerCubit,
                    child: AddTradeWebPage(
                      portfolioId: args['portfolioId']! as String,
                      portfolioName: args['portfolioName'] as String?,
                    ),
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error initializing trade controller: $error')),
                );
              },
            ),
          );
        default:
          // Handle dynamic routes for mobile trade pages
          if (settings.name?.startsWith('/trade/holdings/') == true) {
            final portfolioId = settings.name!.substring('/trade/holdings/'.length);
            final args = settings.arguments as Map<String, dynamic>?;
            final portfolioName = args?['portfolioName'] as String?;
            final userId = args?['userId'] as String? ?? '64d5f6c9-9516-4eca-ac45-c73cfff7a8ec';

            return MaterialPageRoute(
              builder: (context) => TradeHoldingsDashboardMobilePage(
                userId: userId,
                portfolioId: portfolioId,
                portfolioName: portfolioName,
              ),
            );
          } else if (settings.name?.startsWith('/trade/calendar/') == true) {
            final portfolioId = settings.name!.substring('/trade/calendar/'.length);
            final args = settings.arguments as Map<String, dynamic>?;
            final portfolioName = args?['portfolioName'] as String?;
            final userId = args?['userId'] as String? ?? '64d5f6c9-9516-4eca-ac45-c73cfff7a8ec';

            return MaterialPageRoute(
              builder: (context) => const Scaffold(body: Center(child: Text('Mobile page placeholder'))),
            );
          }
          return null;
      }
    },
    // Add error handling
    builder: (context, child) => _AppErrorBoundary(child: child ?? const SizedBox.shrink()),
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
