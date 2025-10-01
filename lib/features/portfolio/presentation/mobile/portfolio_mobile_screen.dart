import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../cubit/portfolio_cubit.dart';
import '../cubit/portfolio_state.dart';
import '../cubit/portfolio_analytics_cubit.dart';
import '../cubit/portfolio_analytics_state.dart';
import '../../providers/portfolio_providers.dart';
import 'widgets/portfolio_holdings_widget.dart';
import '../../../../core/utils/logger.dart';
import '../widgets/portfolio_summary_widget.dart';
import '../widgets/heatmap_widget.dart';
import 'portfolio_analysis_widget.dart';

/// Mobile-optimized portfolio screen with bottom navigation
class PortfolioMobileScreen extends ConsumerWidget {
  final String userId;

  const PortfolioMobileScreen({super.key, required this.userId});

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
                  create: (context) =>
                      PortfolioCubit(portfolioService)..loadPortfolio(userId),
                ),
                BlocProvider(
                  create: (context) =>
                      PortfolioAnalyticsCubit(analyticsService),
                ),
              ],
              child: PortfolioMobileView(userId: userId),
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

/// Internal mobile portfolio view with tab-based navigation
class PortfolioMobileView extends StatefulWidget {
  final String userId;

  const PortfolioMobileView({super.key, required this.userId});

  @override
  State<PortfolioMobileView> createState() => _PortfolioMobileViewState();
}

class _PortfolioMobileViewState extends State<PortfolioMobileView>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            // Tab bar directly under status bar with logout icon
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    Expanded(
                      child: TabBar(
                        controller: _tabController,
                        labelColor: Theme.of(context).primaryColor,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Theme.of(context).primaryColor,
                        labelStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        tabs: const [
                          Tab(
                            icon: Icon(Icons.dashboard_outlined, size: 20),
                            text: 'Overview',
                          ),
                          Tab(
                            icon: Icon(Icons.wallet, size: 20),
                            text: 'Holdings',
                          ),
                          Tab(
                            icon: Icon(Icons.analytics_outlined, size: 20),
                            text: 'Analysis',
                          ),
                          Tab(
                            icon: Icon(Icons.grid_view, size: 20),
                            text: 'Heatmap',
                          ),
                        ],
                      ),
                    ),
                    // Logout icon
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0, top: 8.0),
                      child: IconButton(
                        onPressed: _showLogoutDialog,
                        icon: Icon(
                          Icons.logout_outlined,
                          color: Colors.grey[600],
                          size: 22,
                        ),
                        tooltip: 'Logout',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Tab content with pull-to-refresh
            Expanded(
              child: BlocBuilder<PortfolioCubit, PortfolioState>(
                builder: (context, state) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(state),
                      _buildHoldingsTab(state),
                      _buildAnalysisTab(state),
                      _buildHeatmapTab(state),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(PortfolioState state) {
    if (state is PortfolioLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is PortfolioError) {
      return RefreshIndicator(
        onRefresh: () async {
          AppLogger.userAction(
            'Pull to Refresh Portfolio',
            tag: 'PortfolioMobileView',
            context: {'userId': widget.userId},
          );
          context.read<PortfolioCubit>().refreshPortfolio(widget.userId);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: _buildErrorWidget(state.message),
          ),
        ),
      );
    }

    if (state is PortfolioLoaded) {
      return _buildOverviewContent(state);
    }

    return RefreshIndicator(
      onRefresh: () async {
        AppLogger.userAction(
          'Pull to Refresh Portfolio',
          tag: 'PortfolioMobileView',
          context: {'userId': widget.userId},
        );
        context.read<PortfolioCubit>().refreshPortfolio(widget.userId);
      },
      child: const SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: 400,
          child: Center(child: Text('Loading portfolio...')),
        ),
      ),
    );
  }

  Widget _buildHoldingsTab(PortfolioState state) {
    if (state is PortfolioLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is PortfolioError) {
      return RefreshIndicator(
        onRefresh: () async {
          AppLogger.userAction(
            'Pull to Refresh Holdings',
            tag: 'PortfolioMobileView',
            context: {'userId': widget.userId},
          );
          context.read<PortfolioCubit>().refreshPortfolio(widget.userId);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: _buildErrorWidget(state.message),
          ),
        ),
      );
    }

    return PortfolioHoldingsWidget(userId: widget.userId);
  }

  Widget _buildAnalysisTab(PortfolioState state) {
    if (state is PortfolioLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is PortfolioError) {
      return RefreshIndicator(
        onRefresh: () async {
          AppLogger.userAction(
            'Pull to Refresh Analysis',
            tag: 'PortfolioMobileView',
            context: {'userId': widget.userId},
          );
          context.read<PortfolioCubit>().refreshPortfolio(widget.userId);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: _buildErrorWidget(state.message),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        AppLogger.userAction(
          'Pull to Refresh Analysis',
          tag: 'PortfolioMobileView',
          context: {'userId': widget.userId},
        );
        context.read<PortfolioCubit>().refreshPortfolio(widget.userId);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: _buildAnalysisContent(state),
      ),
    );
  }

  Widget _buildHeatmapTab(PortfolioState state) {
    if (state is PortfolioLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is PortfolioError) {
      return RefreshIndicator(
        onRefresh: () async {
          AppLogger.userAction(
            'Pull to Refresh Heatmap',
            tag: 'PortfolioMobileView',
            context: {'userId': widget.userId},
          );
          context.read<PortfolioCubit>().refreshPortfolio(widget.userId);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: _buildErrorWidget(state.message),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        AppLogger.userAction(
          'Pull to Refresh Heatmap',
          tag: 'PortfolioMobileView',
          context: {'userId': widget.userId},
        );
        context.read<PortfolioCubit>().refreshPortfolio(widget.userId);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: _buildHeatmapContent(state),
      ),
    );
  }

  Widget _buildOverviewContent(PortfolioLoaded state) {
    final summary = state.summary;

    AppLogger.debug(
      'Building overview with summary - totalValue: ${summary.totalValue}, todayChange: ${summary.todayChange}, totalGainLoss: ${summary.totalGainLoss}',
      tag: 'PortfolioMobileView',
    );

    return RefreshIndicator(
      onRefresh: () async {
        AppLogger.userAction(
          'Pull to Refresh Overview',
          tag: 'PortfolioMobileView',
          context: {'userId': widget.userId},
        );
        context.read<PortfolioCubit>().refreshPortfolio(widget.userId);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: PortfolioSummaryWidget(
          summary: summary,
          onViewHoldings: () => _tabController.animateTo(1),
          onViewAnalysis: () => _tabController.animateTo(2),
        ),
      ),
    );
  }

  Widget _buildAnalysisContent(PortfolioState state) {
    // Use userId as portfolioId since that's how the system is structured
    return PortfolioAnalysisWidget(portfolioId: widget.userId);
  }

  Widget _buildHeatmapContent(PortfolioState state) {
    return BlocBuilder<PortfolioAnalyticsCubit, PortfolioAnalyticsState>(
      builder: (context, analyticsState) {
        if (analyticsState is PortfolioAnalyticsLoading) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: HeatmapWidget(isLoading: true),
          );
        } else if (analyticsState is PortfolioAnalyticsLoaded) {
          final isLoading = analyticsState.isLoadingType(
            AnalyticsDataType.heatmap,
          );
          final error = analyticsState.getErrorForType(
            AnalyticsDataType.heatmap,
          );

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: HeatmapWidget(
              heatmap: analyticsState.heatmap,
              isLoading: isLoading,
              error: error,
            ),
          );
        } else if (analyticsState is PortfolioAnalyticsError) {
          AppLogger.error(
            'Failed to load heatmap',
            tag: 'PortfolioMobileView',
            error: analyticsState.message,
          );
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: HeatmapWidget(error: analyticsState.message),
          );
        }

        return const Padding(
          padding: EdgeInsets.all(8.0),
          child: HeatmapWidget(isLoading: true),
        );
      },
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                context.read<PortfolioCubit>().refreshPortfolio(widget.userId),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () async {
                Navigator.of(context).pop();
                // Clear authentication state and navigate to login
                try {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('is_authenticated');
                  await prefs.remove('user_id');
                } catch (e) {
                  // Continue with logout even if SharedPreferences fails
                }
                // Navigate back to root and clear all routes
                if (mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/', (route) => false);
                }
              },
            ),
          ],
        );
      },
    );
  }
}
