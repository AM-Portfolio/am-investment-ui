import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../cubit/portfolio_cubit.dart';
import '../cubit/portfolio_state.dart';
import '../cubit/portfolio_analytics_cubit.dart';
import '../../providers/portfolio_providers.dart';
import '../../internal/domain/entities/portfolio_list.dart';
import 'widgets/portfolio_header_widget.dart';
import 'widgets/portfolio_tab_content_widget.dart';
import 'widgets/portfolio_logout_handler.dart';
import '../../../../core/utils/logger.dart';

/// Mobile-optimized portfolio screen with bottom navigation and portfolio selection
class PortfolioMobileScreen extends ConsumerWidget {
  final String userId;
  final String? selectedPortfolioId;
  final String? selectedPortfolioName;
  final List<PortfolioItem>? portfolios;
  final Function(String portfolioId, String portfolioName)? onPortfolioChanged;

  const PortfolioMobileScreen({
    super.key,
    required this.userId,
    this.selectedPortfolioId,
    this.selectedPortfolioName,
    this.portfolios,
    this.onPortfolioChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppLogger.info(
      'Building PortfolioMobileScreen for userId: $userId',
      tag: 'PortfolioMobileScreen',
    );
    AppLogger.userAction(
      'Navigate to Mobile Portfolio',
      tag: 'PortfolioMobileScreen',
      context: {'userId': userId},
    );

    // Watch the portfolio service provider
    final portfolioServiceAsync = ref.watch(portfolioServiceProvider);

    return portfolioServiceAsync.when(
      data: (portfolioService) {
        AppLogger.debug(
          'Portfolio service loaded, creating mobile cubit',
          tag: 'PortfolioMobileScreen',
        );
        // Watch analytics service as well
        final analyticsServiceAsync = ref.watch(
          portfolioAnalyticsServiceProvider,
        );

        return analyticsServiceAsync.when(
          data: (analyticsService) {
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => PortfolioCubit(portfolioService),
                ),
                BlocProvider(
                  create: (context) =>
                      PortfolioAnalyticsCubit(analyticsService),
                ),
              ],
              child: PortfolioMobileView(
                userId: userId,
                selectedPortfolioId: selectedPortfolioId,
                selectedPortfolioName: selectedPortfolioName,
                portfolios: portfolios,
                onPortfolioChanged: onPortfolioChanged,
              ),
            );
          },
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, stack) {
            AppLogger.error(
              'Failed to load analytics service',
              tag: 'PortfolioMobileScreen',
              error: error,
            );
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Failed to load analytics: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          ref.invalidate(portfolioAnalyticsServiceProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () {
        AppLogger.debug(
          'Portfolio service loading',
          tag: 'PortfolioMobileScreen',
        );
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
      error: (error, stack) {
        AppLogger.error(
          'Failed to load portfolio service',
          tag: 'PortfolioMobileScreen',
          error: error,
        );
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Failed to load portfolio: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(portfolioServiceProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Internal mobile portfolio view with tab-based navigation and portfolio selection
class PortfolioMobileView extends StatefulWidget {
  final String userId;
  final String? selectedPortfolioId;
  final String? selectedPortfolioName;
  final List<PortfolioItem>? portfolios;
  final Function(String portfolioId, String portfolioName)? onPortfolioChanged;

  const PortfolioMobileView({
    super.key,
    required this.userId,
    this.selectedPortfolioId,
    this.selectedPortfolioName,
    this.portfolios,
    this.onPortfolioChanged,
  });

  @override
  State<PortfolioMobileView> createState() => _PortfolioMobileViewState();
}

class _PortfolioMobileViewState extends State<PortfolioMobileView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String? _currentPortfolioId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _currentPortfolioId = widget.selectedPortfolioId ?? widget.userId;

    // Load portfolio data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_currentPortfolioId != null) {
        context.read<PortfolioCubit>().loadPortfolioById(
          widget.userId,
          _currentPortfolioId!,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Handles portfolio selection change
  void _onPortfolioChanged(String portfolioId, String portfolioName) {
    setState(() {
      _currentPortfolioId = portfolioId;
    });

    // Load new portfolio data
    context.read<PortfolioCubit>().loadPortfolioById(
      widget.userId,
      portfolioId,
    );

    // Notify parent if callback is provided
    widget.onPortfolioChanged?.call(portfolioId, portfolioName);
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.debug(
      'Building PortfolioMobileView - userId: ${widget.userId}',
      tag: 'PortfolioMobileView',
    );

    return BlocListener<PortfolioCubit, PortfolioState>(
      listener: (context, state) {
        AppLogger.stateChange(
          'Previous',
          state.runtimeType.toString(),
          tag: 'PortfolioMobileView',
        );

        if (state is PortfolioError) {
          AppLogger.error(
            'Portfolio error occurred: ${state.message}',
            tag: 'PortfolioMobileView',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is PortfolioLoaded) {
          AppLogger.info(
            'Portfolio loaded successfully - ${state.holdings.length} holdings',
            tag: 'PortfolioMobileView',
          );
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            // Portfolio header with selector and tabs
            PortfolioHeaderWidget(
              tabController: _tabController,
              currentPortfolioId: _currentPortfolioId,
              portfolios: widget.portfolios,
              onPortfolioChanged: _onPortfolioChanged,
              onLogout: () => PortfolioLogoutHandler.showLogoutDialog(context),
            ),
            // Tab content
            Expanded(
              child: PortfolioTabContentWidget(
                tabController: _tabController,
                currentPortfolioId: _currentPortfolioId!,
                userId: widget.userId,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
