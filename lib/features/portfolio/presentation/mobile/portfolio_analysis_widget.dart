import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/sectorial_allocation_widget.dart';
import '../widgets/market_cap_allocation_widget.dart';
import '../widgets/heatmap_widget.dart';
import '../widgets/movers_widget.dart';
import '../cubit/portfolio_analytics_cubit.dart';
import '../cubit/portfolio_analytics_state.dart';
import '../../../../core/utils/logger.dart';

/// Main portfolio analysis widget that orchestrates all analytics components
/// This widget provides comprehensive portfolio analysis including:
/// - Sector allocation visualization
/// - Market cap allocation breakdown
/// - Portfolio heatmap
/// - Top movers (gainers and losers)
class PortfolioAnalysisWidget extends StatefulWidget {
  final String portfolioId;

  const PortfolioAnalysisWidget({super.key, required this.portfolioId});

  @override
  State<PortfolioAnalysisWidget> createState() =>
      _PortfolioAnalysisWidgetState();
}

class _PortfolioAnalysisWidgetState extends State<PortfolioAnalysisWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Hardcoded portfolio ID for testing
  String get effectivePortfolioId => "163d0143-4fcb-480c-ac20-622f14e0e293";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    AppLogger.info(
      'Portfolio analysis widget initialized for portfolio: $effectivePortfolioId',
      tag: 'PortfolioAnalysisWidget',
    );

    // Load analytics data when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppLogger.debug(
        '🔍 PortfolioAnalysisWidget: About to call loadAnalytics with portfolioId: $effectivePortfolioId',
        tag: 'PortfolioAnalysisWidget',
      );
      context.read<PortfolioAnalyticsCubit>().loadAnalytics(
        effectivePortfolioId,
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          _buildHeader(context),
          _buildTabBar(context),
          SizedBox(height: 400, child: _buildTabBarView(context)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Icon(
            Icons.analytics,
            color: Theme.of(context).primaryColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Portfolio Analysis',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'Comprehensive portfolio insights',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const Spacer(),
          _buildRefreshButton(context),
        ],
      ),
    );
  }

  Widget _buildRefreshButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        AppLogger.info(
          'Refreshing portfolio analytics for portfolio: $effectivePortfolioId',
          tag: 'PortfolioAnalysisWidget',
        );
        context.read<PortfolioAnalyticsCubit>().refreshAnalytics(
          effectivePortfolioId,
        );
      },
      icon: Icon(Icons.refresh, color: Theme.of(context).primaryColor),
      tooltip: 'Refresh analytics data',
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      tabs: const [
        Tab(icon: Icon(Icons.donut_small, size: 20), text: 'Sectors'),
        Tab(icon: Icon(Icons.insights, size: 20), text: 'Market Cap'),
        Tab(icon: Icon(Icons.grid_view, size: 20), text: 'Heatmap'),
        Tab(icon: Icon(Icons.trending_up, size: 20), text: 'Movers'),
      ],
      labelColor: Theme.of(context).primaryColor,
      unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
      indicatorColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildTabBarView(BuildContext context) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildSectorAllocationTab(),
        _buildMarketCapAllocationTab(),
        _buildHeatmapTab(),
        _buildMoversTab(),
      ],
    );
  }

  Widget _buildSectorAllocationTab() {
    return BlocBuilder<PortfolioAnalyticsCubit, PortfolioAnalyticsState>(
      builder: (context, state) {
        AppLogger.debug(
          '🔍 SectorAllocationTab: Current state is ${state.runtimeType}',
          tag: 'PortfolioAnalysisWidget',
        );

        if (state is PortfolioAnalyticsLoading) {
          return const SectorialAllocationWidget(isLoading: true);
        } else if (state is PortfolioAnalyticsLoaded) {
          AppLogger.debug(
            '🔍 SectorAllocationTab: sectorAllocation data = ${state.sectorAllocation != null ? 'available' : 'null'}',
            tag: 'PortfolioAnalysisWidget',
          );
          final isLoading = state.isLoadingType(
            AnalyticsDataType.sectorAllocation,
          );
          final error = state.getErrorForType(
            AnalyticsDataType.sectorAllocation,
          );

          return SectorialAllocationWidget(
            sectorAllocation: state.sectorAllocation,
            isLoading: isLoading,
            error: error,
          );
        } else if (state is PortfolioAnalyticsError) {
          AppLogger.error(
            'Failed to load sector allocation',
            tag: 'PortfolioAnalysisWidget',
            error: state.message,
          );
          return SectorialAllocationWidget(error: state.message);
        }

        return const SectorialAllocationWidget(isLoading: true);
      },
    );
  }

  Widget _buildMarketCapAllocationTab() {
    return BlocBuilder<PortfolioAnalyticsCubit, PortfolioAnalyticsState>(
      builder: (context, state) {
        if (state is PortfolioAnalyticsLoading) {
          return const MarketCapAllocationWidget(isLoading: true);
        } else if (state is PortfolioAnalyticsLoaded) {
          final isLoading = state.isLoadingType(
            AnalyticsDataType.marketCapAllocation,
          );
          final error = state.getErrorForType(
            AnalyticsDataType.marketCapAllocation,
          );

          return MarketCapAllocationWidget(
            marketCapAllocation: state.marketCapAllocation,
            isLoading: isLoading,
            error: error,
          );
        } else if (state is PortfolioAnalyticsError) {
          AppLogger.error(
            'Failed to load market cap allocation',
            tag: 'PortfolioAnalysisWidget',
            error: state.message,
          );
          return MarketCapAllocationWidget(error: state.message);
        }

        return const MarketCapAllocationWidget(isLoading: true);
      },
    );
  }

  Widget _buildHeatmapTab() {
    return BlocBuilder<PortfolioAnalyticsCubit, PortfolioAnalyticsState>(
      builder: (context, state) {
        if (state is PortfolioAnalyticsLoading) {
          return const HeatmapWidget(isLoading: true);
        } else if (state is PortfolioAnalyticsLoaded) {
          final isLoading = state.isLoadingType(AnalyticsDataType.heatmap);
          final error = state.getErrorForType(AnalyticsDataType.heatmap);

          return HeatmapWidget(
            heatmap: state.heatmap,
            isLoading: isLoading,
            error: error,
          );
        } else if (state is PortfolioAnalyticsError) {
          AppLogger.error(
            'Failed to load heatmap',
            tag: 'PortfolioAnalysisWidget',
            error: state.message,
          );
          return HeatmapWidget(error: state.message);
        }

        return const HeatmapWidget(isLoading: true);
      },
    );
  }

  Widget _buildMoversTab() {
    return BlocBuilder<PortfolioAnalyticsCubit, PortfolioAnalyticsState>(
      builder: (context, state) {
        if (state is PortfolioAnalyticsLoading) {
          return const MoversWidget(isLoading: true);
        } else if (state is PortfolioAnalyticsLoaded) {
          final isLoading = state.isLoadingType(AnalyticsDataType.movers);
          final error = state.getErrorForType(AnalyticsDataType.movers);

          return MoversWidget(
            movers: state.movers,
            isLoading: isLoading,
            error: error,
          );
        } else if (state is PortfolioAnalyticsError) {
          AppLogger.error(
            'Failed to load movers',
            tag: 'PortfolioAnalysisWidget',
            error: state.message,
          );
          return MoversWidget(error: state.message);
        }

        return const MoversWidget(isLoading: true);
      },
    );
  }
}
