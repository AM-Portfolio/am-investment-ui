import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../cubit/portfolio_cubit.dart';
import '../cubit/portfolio_state.dart';
import '../../providers/portfolio_providers.dart';
import 'widgets/portfolio_holdings_mobile_widget.dart';
import '../../../../core/utils/logger.dart';

/// Mobile-optimized portfolio screen with bottom navigation
class PortfolioMobileScreen extends ConsumerWidget {
  final String userId;

  const PortfolioMobileScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppLogger.info('Building PortfolioMobileScreen for userId: $userId', tag: 'PortfolioMobileScreen');
    AppLogger.userAction('Navigate to Mobile Portfolio', tag: 'PortfolioMobileScreen', context: {'userId': userId});
    
    // Watch the portfolio service provider
    final portfolioServiceAsync = ref.watch(portfolioServiceProvider);
    
    return portfolioServiceAsync.when(
      data: (portfolioService) {
        AppLogger.debug('Portfolio service loaded, creating mobile cubit', tag: 'PortfolioMobileScreen');
        return BlocProvider(
          create: (context) => PortfolioCubit(portfolioService)..loadPortfolio(userId),
          child: PortfolioMobileView(userId: userId),
        );
      },
      loading: () {
        AppLogger.debug('Portfolio service loading', tag: 'PortfolioMobileScreen');
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      error: (error, stack) {
        AppLogger.error('Failed to load portfolio service', tag: 'PortfolioMobileScreen', error: error);
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

  const PortfolioMobileView({
    super.key,
    required this.userId,
  });

  @override
  State<PortfolioMobileView> createState() => _PortfolioMobileViewState();
}

class _PortfolioMobileViewState extends State<PortfolioMobileView> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.debug('Building PortfolioMobileView - userId: ${widget.userId}', tag: 'PortfolioMobileView');
    
    return BlocListener<PortfolioCubit, PortfolioState>(
      listener: (context, state) {
        AppLogger.stateChange('Previous', state.runtimeType.toString(), tag: 'PortfolioMobileView');
        
        if (state is PortfolioError) {
          AppLogger.error('Portfolio error occurred: ${state.message}', tag: 'PortfolioMobileView');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is PortfolioLoaded) {
          AppLogger.info('Portfolio loaded successfully - ${state.holdings.length} holdings', tag: 'PortfolioMobileView');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Portfolio'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                AppLogger.userAction('Refresh Portfolio', tag: 'PortfolioMobileView', 
                    context: {'userId': widget.userId});
                context.read<PortfolioCubit>().refreshPortfolio(widget.userId);
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: const [
              Tab(
                icon: Icon(Icons.dashboard_outlined),
                text: 'Overview',
              ),
              Tab(
                icon: Icon(Icons.account_balance_wallet_outlined),
                text: 'Holdings',
              ),
              Tab(
                icon: Icon(Icons.analytics_outlined),
                text: 'Analysis',
              ),
            ],
          ),
        ),
        body: BlocBuilder<PortfolioCubit, PortfolioState>(
          builder: (context, state) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(state),
                _buildHoldingsTab(state),
                _buildAnalysisTab(state),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOverviewTab(PortfolioState state) {
    if (state is PortfolioLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (state is PortfolioError) {
      return _buildErrorWidget(state.message);
    }
    
    if (state is PortfolioLoaded) {
      return _buildOverviewContent(state);
    }
    
    return const Center(child: Text('Loading portfolio...'));
  }

  Widget _buildHoldingsTab(PortfolioState state) {
    if (state is PortfolioLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (state is PortfolioError) {
      return _buildErrorWidget(state.message);
    }
    
    return PortfolioHoldingsMobileWidget(userId: widget.userId);
  }

  Widget _buildAnalysisTab(PortfolioState state) {
    if (state is PortfolioLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (state is PortfolioError) {
      return _buildErrorWidget(state.message);
    }
    
    return _buildAnalysisContent(state);
  }

  Widget _buildOverviewContent(PortfolioLoaded state) {
    final summary = state.summary;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Portfolio Summary Cards
          _buildSummaryCard(
            'Total Value',
            '₹${summary.totalValue.toStringAsFixed(2)}',
            Icons.account_balance_wallet,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildSummaryCard(
            'Today\'s Change',
            '₹${summary.todayChange.toStringAsFixed(2)}',
            summary.todayChange >= 0 ? Icons.trending_up : Icons.trending_down,
            summary.todayChange >= 0 ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 12),
          _buildSummaryCard(
            'Total Return',
            '₹${summary.totalGainLoss.toStringAsFixed(2)}',
            summary.totalGainLoss >= 0 ? Icons.trending_up : Icons.trending_down,
            summary.totalGainLoss >= 0 ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 24),
          
          // Quick Actions
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  'View Holdings',
                  Icons.list_alt,
                  () => _tabController.animateTo(1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  'Analysis',
                  Icons.analytics,
                  () => _tabController.animateTo(2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisContent(PortfolioState state) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Portfolio Analysis',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Coming soon...',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
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
            onPressed: () => context.read<PortfolioCubit>().refreshPortfolio(widget.userId),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}