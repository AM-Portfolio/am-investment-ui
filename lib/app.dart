import 'package:flutter/material.dart';
import 'core/utils/logger.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'di/auth_providers.dart';
import 'features/authentication/presentation/pages/auth_wrapper.dart';
import 'package:am_common_ui/features/authentication/presentation/pages/login_page.dart';
import 'package:am_common_ui/features/authentication/presentation/pages/register_page.dart';
import 'package:am_common_ui/features/authentication/presentation/pages/forgot_password_page.dart';
import 'package:am_common_ui/features/authentication/presentation/pages/reset_password_page.dart';
import 'package:am_common_ui/core/theme/cubit/theme_cubit.dart';
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
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: AuthProviders.providers,
      child: const _MaterialApp(),
    );
  }
}

class _MaterialApp extends StatelessWidget {
  const _MaterialApp();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return MaterialApp(
          title: 'AM Investment',
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            FlutterQuillLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', '')],
          theme: state.lightTheme,
          darkTheme: state.darkTheme,
          themeMode: state.themeMode,
          home: const AuthWrapper(),
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/portfolio':
                return MaterialPageRoute(builder: (context) => const PortfolioScreen(userId: ''));
              case '/register':
                return MaterialPageRoute(builder: (context) => const RegisterPage());
              case '/forgot-password':
                return MaterialPageRoute(builder: (context) => const ForgotPasswordPage());
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
                if (settings.name?.startsWith('/trade/holdings/') == true) {
                  final portfolioId = settings.name!.substring('/trade/holdings/'.length);
                  final args = settings.arguments as Map<String, dynamic>?;
                  final userId = args?['userId'] as String? ?? '64d5f6c9-9516-4eca-ac45-c73cfff7a8ec';
                  return MaterialPageRoute(
                    builder: (context) => TradeHoldingsDashboardMobilePage(
                      userId: userId,
                      portfolioId: portfolioId,
                      portfolioName: args?['portfolioName'] as String?,
                    ),
                  );
                }
                return null;
            }
          },
          builder: (context, child) => _AppErrorBoundary(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}

class _AppErrorBoundary extends StatefulWidget {
  const _AppErrorBoundary({required this.child});
  final Widget child;

  @override
  State<_AppErrorBoundary> createState() => _AppErrorBoundaryState();
}

class _AppErrorBoundaryState extends State<_AppErrorBoundary> {
  @override
  void initState() {
    super.initState();
    FlutterError.onError = (details) {
      AppLogger.error(
        'Flutter Framework Error: ${details.exception}',
        tag: 'Framework',
        error: details.exception,
        stackTrace: details.stack,
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      AppLogger.error(
        'UI Rendering Error: ${details.exception}',
        tag: 'Renderer',
        error: details.exception,
        stackTrace: details.stack,
      );

      return Material(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                const Text('Something went wrong', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  details.exception.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      );
    };
    return widget.child;
  }
}


