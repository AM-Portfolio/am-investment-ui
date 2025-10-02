import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/portfolio_cubit.dart';
import '../../cubit/portfolio_state.dart';
import '../../cubit/portfolio_analytics_cubit.dart';
import '../../cubit/portfolio_analytics_state.dart';
import 'portfolio_holdings_widget.dart';
import '../../../../../core/utils/logger.dart';
import '../../widgets/portfolio_summary_widget.dart';
import '../../widgets/heatmap_widget.dart';
import '../portfolio_analysis_widget.dart';

/// Widget that handles portfolio tab content based on state
class PortfolioTabContentWidget extends StatelessWidget {
  final TabController tabController;
  final String currentPortfolioId;
  final String userId;

  const PortfolioTabContentWidget({
    super.key,
    required this.tabController,
    required this.currentPortfolioId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PortfolioCubit, PortfolioState>(
      builder: (context, state) {
        return TabBarView(
          controller: tabController,
          children: [
            _OverviewTab(
              currentPortfolioId: currentPortfolioId,
              userId: userId,
            ),
            _HoldingsTab(
              currentPortfolioId: currentPortfolioId,
              userId: userId,
            ),
            _AnalysisTab(
              currentPortfolioId: currentPortfolioId,
              userId: userId,
            ),
            _HeatmapTab(currentPortfolioId: currentPortfolioId, userId: userId),
          ],
        );
      },
    );
  }
}

/// Overview tab widget
class _OverviewTab extends StatelessWidget {
  final String currentPortfolioId;
  final String userId;

  const _OverviewTab({required this.currentPortfolioId, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PortfolioCubit, PortfolioState>(
      builder: (context, state) {
        if (state is PortfolioLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PortfolioError) {
          return _buildErrorWithRefresh(
            context,
            state.message,
            'Pull to Refresh Portfolio',
          );
        }

        if (state is PortfolioLoaded) {
          return _buildOverviewContent(context, state);
        }

        return _buildLoadingWithRefresh(context, 'Pull to Refresh Portfolio');
      },
    );
  }

  Widget _buildOverviewContent(BuildContext context, PortfolioLoaded state) {
    final summary = state.summary;

    AppLogger.debug(
      'Building overview with summary - totalValue: ${summary.totalValue}, todayChange: ${summary.todayChange}, totalGainLoss: ${summary.totalGainLoss}',
      tag: 'PortfolioOverviewTab',
    );

    return RefreshIndicator(
      onRefresh: () => _refreshPortfolio(context, 'Pull to Refresh Overview'),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: PortfolioSummaryWidget(
          summary: summary,
          onViewHoldings: () => _navigateToTab(1, context),
          onViewAnalysis: () => _navigateToTab(2, context),
        ),
      ),
    );
  }

  Widget _buildErrorWithRefresh(
    BuildContext context,
    String message,
    String logAction,
  ) {
    return RefreshIndicator(
      onRefresh: () => _refreshPortfolio(context, logAction),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: PortfolioErrorWidget(
            message: message,
            onRetry: () => _refreshPortfolio(context, logAction),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWithRefresh(BuildContext context, String logAction) {
    return RefreshIndicator(
      onRefresh: () => _refreshPortfolio(context, logAction),
      child: const SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: 400,
          child: Center(child: Text('Loading portfolio...')),
        ),
      ),
    );
  }

  Future<void> _refreshPortfolio(BuildContext context, String action) async {
    AppLogger.userAction(
      action,
      tag: 'PortfolioOverviewTab',
      context: {'portfolioId': currentPortfolioId, 'userId': userId},
    );
    context.read<PortfolioCubit>().refreshPortfolioById(
      userId,
      currentPortfolioId,
    );
  }

  void _navigateToTab(int index, BuildContext context) {
    // Find the tab controller from the widget tree
    final tabController = DefaultTabController.of(context);
    tabController.animateTo(index);
  }
}

/// Holdings tab widget
class _HoldingsTab extends StatelessWidget {
  final String currentPortfolioId;
  final String userId;

  const _HoldingsTab({required this.currentPortfolioId, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PortfolioCubit, PortfolioState>(
      builder: (context, state) {
        if (state is PortfolioLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PortfolioError) {
          return _buildErrorWithRefresh(context, state.message);
        }

        return PortfolioHoldingsWidget(
          userId: userId,
          portfolioId: currentPortfolioId,
        );
      },
    );
  }

  Widget _buildErrorWithRefresh(BuildContext context, String message) {
    return RefreshIndicator(
      onRefresh: () => _refreshPortfolio(context),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: PortfolioErrorWidget(
            message: message,
            onRetry: () => _refreshPortfolio(context),
          ),
        ),
      ),
    );
  }

  Future<void> _refreshPortfolio(BuildContext context) async {
    AppLogger.userAction(
      'Pull to Refresh Holdings',
      tag: 'PortfolioHoldingsTab',
      context: {'portfolioId': currentPortfolioId, 'userId': userId},
    );
    context.read<PortfolioCubit>().refreshPortfolioById(
      userId,
      currentPortfolioId,
    );
  }
}

/// Analysis tab widget
class _AnalysisTab extends StatelessWidget {
  final String currentPortfolioId;
  final String userId;

  const _AnalysisTab({required this.currentPortfolioId, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PortfolioCubit, PortfolioState>(
      builder: (context, state) {
        if (state is PortfolioLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PortfolioError) {
          return _buildErrorWithRefresh(context, state.message);
        }

        return RefreshIndicator(
          onRefresh: () => _refreshPortfolio(context),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: PortfolioAnalysisWidget(portfolioId: currentPortfolioId),
          ),
        );
      },
    );
  }

  Widget _buildErrorWithRefresh(BuildContext context, String message) {
    return RefreshIndicator(
      onRefresh: () => _refreshPortfolio(context),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: PortfolioErrorWidget(
            message: message,
            onRetry: () => _refreshPortfolio(context),
          ),
        ),
      ),
    );
  }

  Future<void> _refreshPortfolio(BuildContext context) async {
    AppLogger.userAction(
      'Pull to Refresh Analysis',
      tag: 'PortfolioAnalysisTab',
      context: {'portfolioId': currentPortfolioId, 'userId': userId},
    );
    context.read<PortfolioCubit>().refreshPortfolioById(
      userId,
      currentPortfolioId,
    );
  }
}

/// Heatmap tab widget
class _HeatmapTab extends StatelessWidget {
  final String currentPortfolioId;
  final String userId;

  const _HeatmapTab({required this.currentPortfolioId, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PortfolioCubit, PortfolioState>(
      builder: (context, state) {
        if (state is PortfolioLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PortfolioError) {
          return _buildErrorWithRefresh(context, state.message);
        }

        return RefreshIndicator(
          onRefresh: () => _refreshPortfolio(context),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: _buildHeatmapContent(context),
          ),
        );
      },
    );
  }

  Widget _buildHeatmapContent(BuildContext context) {
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
            tag: 'PortfolioHeatmapTab',
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

  Widget _buildErrorWithRefresh(BuildContext context, String message) {
    return RefreshIndicator(
      onRefresh: () => _refreshPortfolio(context),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: PortfolioErrorWidget(
            message: message,
            onRetry: () => _refreshPortfolio(context),
          ),
        ),
      ),
    );
  }

  Future<void> _refreshPortfolio(BuildContext context) async {
    AppLogger.userAction(
      'Pull to Refresh Heatmap',
      tag: 'PortfolioHeatmapTab',
      context: {'portfolioId': currentPortfolioId, 'userId': userId},
    );
    context.read<PortfolioCubit>().refreshPortfolioById(
      userId,
      currentPortfolioId,
    );
  }
}

/// Reusable error widget for portfolio tabs
class PortfolioErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const PortfolioErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
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
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
