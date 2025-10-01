import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/sectorial_allocation_widget.dart';
import '../widgets/market_cap_allocation_widget.dart';
import '../widgets/heatmap_widget.dart';
import '../widgets/movers_widget.dart';
import '../../providers/portfolio_providers.dart';
import '../../../../core/utils/logger.dart';

/// Main portfolio analysis widget that orchestrates all analytics components
/// This widget provides comprehensive portfolio analysis including:
/// - Sector allocation visualization
/// - Market cap allocation breakdown
/// - Portfolio heatmap
/// - Top movers (gainers and losers)
class PortfolioAnalysisWidget extends ConsumerStatefulWidget {
  final String portfolioId;

  const PortfolioAnalysisWidget({super.key, required this.portfolioId});

  @override
  ConsumerState<PortfolioAnalysisWidget> createState() =>
      _PortfolioAnalysisWidgetState();
}

class _PortfolioAnalysisWidgetState
    extends ConsumerState<PortfolioAnalysisWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    AppLogger.info(
      'Portfolio analysis widget initialized for portfolio: ${widget.portfolioId}',
      tag: 'PortfolioAnalysisWidget',
    );
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
          'Refreshing portfolio analytics for portfolio: ${widget.portfolioId}',
          tag: 'PortfolioAnalysisWidget',
        );
        ref.invalidate(portfolioAnalyticsWithDefaultsProvider);
        ref.invalidate(portfolioHeatmapProvider);
        ref.invalidate(portfolioMoversProvider);
        ref.invalidate(portfolioAllocationsProvider);
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
    final allocationsAsync = ref.watch(
      portfolioAllocationsProvider(widget.portfolioId),
    );

    return allocationsAsync.when(
      data: (allocations) => SectorialAllocationWidget(
        sectorAllocation: allocations.sectorAllocation,
        isLoading: false,
      ),
      loading: () => const SectorialAllocationWidget(isLoading: true),
      error: (error, stack) {
        AppLogger.error(
          'Failed to load sector allocation',
          tag: 'PortfolioAnalysisWidget',
          error: error,
          stackTrace: stack,
        );
        return SectorialAllocationWidget(error: error.toString());
      },
    );
  }

  Widget _buildMarketCapAllocationTab() {
    final allocationsAsync = ref.watch(
      portfolioAllocationsProvider(widget.portfolioId),
    );

    return allocationsAsync.when(
      data: (allocations) => MarketCapAllocationWidget(
        marketCapAllocation: allocations.marketCapAllocation,
        isLoading: false,
      ),
      loading: () => const MarketCapAllocationWidget(isLoading: true),
      error: (error, stack) {
        AppLogger.error(
          'Failed to load market cap allocation',
          tag: 'PortfolioAnalysisWidget',
          error: error,
          stackTrace: stack,
        );
        return MarketCapAllocationWidget(error: error.toString());
      },
    );
  }

  Widget _buildHeatmapTab() {
    final heatmapAsync = ref.watch(
      portfolioHeatmapProvider(widget.portfolioId),
    );

    return heatmapAsync.when(
      data: (heatmap) => HeatmapWidget(heatmap: heatmap, isLoading: false),
      loading: () => const HeatmapWidget(isLoading: true),
      error: (error, stack) {
        AppLogger.error(
          'Failed to load heatmap',
          tag: 'PortfolioAnalysisWidget',
          error: error,
          stackTrace: stack,
        );
        return HeatmapWidget(error: error.toString());
      },
    );
  }

  Widget _buildMoversTab() {
    final moversAsync = ref.watch(
      portfolioMoversProvider(widget.portfolioId, limit: 10),
    );

    return moversAsync.when(
      data: (movers) => MoversWidget(movers: movers, isLoading: false),
      loading: () => const MoversWidget(isLoading: true),
      error: (error, stack) {
        AppLogger.error(
          'Failed to load movers',
          tag: 'PortfolioAnalysisWidget',
          error: error,
          stackTrace: stack,
        );
        return MoversWidget(error: error.toString());
      },
    );
  }
}
