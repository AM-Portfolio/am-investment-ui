import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/portfolio_cubit.dart';
import '../widgets/portfolio_overview_widget.dart';
import '../widgets/portfolio_holdings_widget.dart';
import '../widgets/portfolio_analysis_widget.dart';
import '../widgets/portfolio_sidebar.dart';

/// Main portfolio screen with clean architecture
class PortfolioScreen extends StatelessWidget {
  final String userId;

  const PortfolioScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => context.read<PortfolioCubit>()..loadPortfolio(userId),
      child: PortfolioView(userId: userId),
    );
  }
}

/// Internal portfolio view widget
class PortfolioView extends StatelessWidget {
  final String userId;

  const PortfolioView({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio'),
        actions: [
          BlocBuilder<PortfolioCubit, PortfolioState>(
            builder: (context, state) {
              return IconButton(
                icon: state.isRefreshing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                onPressed: state.isRefreshing
                    ? null
                    : () => context.read<PortfolioCubit>().refreshPortfolio(userId),
              );
            },
          ),
        ],
      ),
      body: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Sidebar
        Container(
          width: 250,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border(
              right: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: const PortfolioSidebar(),
        ),
        // Main content
        Expanded(
          child: _buildMainContent(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      drawer: const Drawer(
        child: PortfolioSidebar(),
      ),
      body: _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    return BlocBuilder<PortfolioCubit, PortfolioState>(
      builder: (context, state) {
        return state.when(
          initial: () => const Center(child: Text('Welcome to Portfolio')),
          loading: () => const Center(child: CircularProgressIndicator()),
          loaded: (holdings, summary, selectedView, isRefreshing, searchQuery, 
                  searchResults, sectorAllocation, topPerformers) {
            return _buildLoadedContent(selectedView);
          },
          error: (message) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error Loading Portfolio',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<PortfolioCubit>().loadPortfolio(userId),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadedContent(PortfolioView selectedView) {
    switch (selectedView) {
      case PortfolioView.overview:
        return PortfolioOverviewWidget(userId: userId);
      case PortfolioView.holdings:
        return PortfolioHoldingsWidget(userId: userId);
      case PortfolioView.analysis:
        return PortfolioAnalysisWidget(userId: userId);
    }
  }
}