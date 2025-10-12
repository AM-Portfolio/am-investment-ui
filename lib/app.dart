import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/login/presentation/pages/auth_wrapper.dart';
import 'features/portfolio/presentation/pages/portfolio_screen.dart';
import 'features/authentication/presentation/pages/register_page.dart';
import 'features/authentication/presentation/pages/forgot_password_page.dart';
import 'features/authentication/presentation/pages/reset_password_page.dart';
import 'features/trade/presentation/web/pages/trade_portfolio_list_web_page.dart';
import 'features/trade/presentation/web/pages/trade_holdings_dashboard_web_page.dart';
import 'features/trade/presentation/web/pages/trade_calendar_analytics_web_page.dart';
import 'features/trade/presentation/mobile/pages/trade_holdings_dashboard_mobile_page.dart';
import 'features/trade/presentation/mobile/pages/trade_calendar_analytics_mobile_page.dart';
import 'features/trade/providers/trade_providers.dart';
import 'features/trade/data/models/trade_portfolio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/trade/presentation/cubit/unified_trade_cubit.dart';

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
    onGenerateRoute: (settings) {
      switch (settings.name) {
        case '/portfolio':
          return MaterialPageRoute(
            builder: (context) => const PortfolioScreen(userId: ''),
          );
        case '/register':
          return MaterialPageRoute(
            builder: (context) => const RegisterPage(),
          );
        case '/forgot-password':
          return MaterialPageRoute(
            builder: (context) => const ForgotPasswordPage(),
          );
        case '/reset-password':
          return MaterialPageRoute(
            builder: (context) => const ResetPasswordPage(),
          );
        case '/trade/portfolios':
          return MaterialPageRoute(
            builder: (context) => Consumer(
              builder: (context, ref, _) => BlocProvider(
                create: (_) => ref.read(unifiedTradeCubitProvider),
                child: const TradePortfolioListWebPage(
                  ownerId: '64d5f6c9-9516-4eca-ac45-c73cfff7a8ec',
                ),
              ),
            ),
          );
        case '/trade/holdings':
          final portfolio = settings.arguments as TradePortfolio;
          return MaterialPageRoute(
            builder: (context) => Consumer(
              builder: (context, ref, _) => BlocProvider(
                create: (_) => ref.read(unifiedTradeCubitProvider),
                child: TradeHoldingsDashboardWebPage(portfolio: portfolio),
              ),
            ),
          );
        case '/trade/calendar':
          final portfolio = settings.arguments as TradePortfolio;
          return MaterialPageRoute(
            builder: (context) => Consumer(
              builder: (context, ref, _) => BlocProvider(
                create: (_) => ref.read(unifiedTradeCubitProvider),
                child: TradeCalendarAnalyticsWebPage(portfolio: portfolio),
              ),
            ),
          );
        default:
          // Handle dynamic routes for mobile trade pages
          if (settings.name?.startsWith('/trade/holdings/') == true) {
            final portfolioId =
                settings.name!.substring('/trade/holdings/'.length);
            final args = settings.arguments as Map<String, dynamic>?;
            final portfolioName = args?['portfolioName'] as String?;

            return MaterialPageRoute(
              builder: (context) => Consumer(
                builder: (context, ref, _) {
                  final apiService = ref.read(tradeApiServiceProvider);
                  final mockService = ref.read(tradeMockServiceProvider);

                  return BlocProvider<UnifiedTradeCubit>(
                    create: (_) => UnifiedTradeCubit(
                      apiService: apiService,
                      mockService: mockService,
                      useMockData: false,
                    ),
                    child: TradeHoldingsDashboardMobilePage(
                      portfolioId: portfolioId,
                      portfolioName: portfolioName,
                    ),
                  );
                },
              ),
            );
          } else if (settings.name?.startsWith('/trade/calendar/') == true) {
            final portfolioId =
                settings.name!.substring('/trade/calendar/'.length);
            final args = settings.arguments as Map<String, dynamic>?;
            final portfolioName = args?['portfolioName'] as String?;

            return MaterialPageRoute(
              builder: (context) => Consumer(
                builder: (context, ref, _) {
                  final apiService = ref.read(tradeApiServiceProvider);
                  final mockService = ref.read(tradeMockServiceProvider);

                  return BlocProvider<UnifiedTradeCubit>(
                    create: (_) => UnifiedTradeCubit(
                      apiService: apiService,
                      mockService: mockService,
                      useMockData: false,
                    ),
                    child: TradeCalendarAnalyticsMobilePage(
                      portfolioId: portfolioId,
                      portfolioName: portfolioName,
                    ),
                  );
                },
              ),
            );
          }
          return null;
      }
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
