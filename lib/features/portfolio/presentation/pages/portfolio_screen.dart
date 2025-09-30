import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/portfolio_overview_widget.dart';
import '../widgets/portfolio_holdings_widget.dart';
import '../widgets/portfolio_analysis_widget.dart';
import '../widgets/portfolio_sidebar.dart';
import '../cubit/portfolio_cubit.dart';
import '../cubit/portfolio_state.dart';
import '../../providers/portfolio_providers.dart';
import '../../../../core/utils/logger.dart';

/// Main portfolio screen with clean architecture using BLoC
class PortfolioScreen extends ConsumerWidget {
  final String userId;

  const PortfolioScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppLogger.info('Building PortfolioScreen for userId: $userId', tag: 'PortfolioScreen');
    AppLogger.userAction('Navigate to Portfolio', tag: 'PortfolioScreen', context: {'userId': userId});
    
    // Watch the portfolio service provider
    final portfolioServiceAsync = ref.watch(portfolioServiceProvider);
    
    return portfolioServiceAsync.when(
      data: (portfolioService) {
        AppLogger.debug('Portfolio service loaded, creating cubit', tag: 'PortfolioScreen');
        return BlocProvider(
          create: (context) => PortfolioCubit(portfolioService)..loadPortfolio(userId),
          child: PortfolioView(userId: userId),
        );
      },
      loading: () {
        AppLogger.debug('Portfolio service loading', tag: 'PortfolioScreen');
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      error: (error, stack) {
        AppLogger.error('Failed to load portfolio service', tag: 'PortfolioScreen', error: error);
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

/// Internal portfolio view widget
class PortfolioView extends StatefulWidget {
  final String userId;

  const PortfolioView({
    super.key,
    required this.userId,
  });

  @override
  State<PortfolioView> createState() => _PortfolioViewState();
}

class _PortfolioViewState extends State<PortfolioView> {

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    AppLogger.debug('Building PortfolioView - isMobile: $isMobile, userId: ${widget.userId}', tag: 'PortfolioView');
    
    return BlocListener<PortfolioCubit, PortfolioState>(
      listener: (context, state) {
        // Handle any state changes like showing errors, etc.
        AppLogger.stateChange('Previous', state.runtimeType.toString(), tag: 'PortfolioView');
        
        if (state is PortfolioError) {
          AppLogger.error('Portfolio error occurred: ${state.message}', tag: 'PortfolioView');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is PortfolioLoaded) {
          AppLogger.info('Portfolio loaded successfully - ${state.holdings.length} holdings', tag: 'PortfolioView');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Portfolio'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                AppLogger.userAction('Refresh Portfolio', tag: 'PortfolioView', 
                    context: {'userId': widget.userId});
                // Refresh portfolio data using cubit
                context.read<PortfolioCubit>().refreshPortfolio(widget.userId);
              },
            ),
          ],
        ),
        body: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return BlocBuilder<PortfolioCubit, PortfolioState>(
      builder: (context, state) {
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
              child: PortfolioSidebar(
                selectedView: state is PortfolioLoaded ? state.currentView : PortfolioViewType.overview,
                onViewChanged: (view) {
                  context.read<PortfolioCubit>().changeView(view);
                },
              ),
            ),
            // Main content
            Expanded(
              child: _buildMainContent(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMobileLayout() {
    return BlocBuilder<PortfolioCubit, PortfolioState>(
      builder: (context, state) {
        return Scaffold(
          drawer: Drawer(
            child: PortfolioSidebar(
              selectedView: state is PortfolioLoaded ? state.currentView : PortfolioViewType.overview,
              onViewChanged: (view) {
                context.read<PortfolioCubit>().changeView(view);
                Navigator.of(context).pop(); // Close drawer
              },
            ),
          ),
          body: _buildMainContent(),
        );
      },
    );
  }

  Widget _buildMainContent() {
    return BlocBuilder<PortfolioCubit, PortfolioState>(
      builder: (context, state) {
        final currentView = state is PortfolioLoaded ? state.currentView : PortfolioViewType.overview;
        return _buildLoadedContent(currentView);
      },
    );
  }

  Widget _buildLoadedContent(PortfolioViewType selectedView) {
    switch (selectedView) {
      case PortfolioViewType.overview:
        return PortfolioOverviewWidget(userId: widget.userId);
      case PortfolioViewType.holdings:
        return PortfolioHoldingsWidget(userId: widget.userId);
      case PortfolioViewType.analysis:
        return PortfolioAnalysisWidget(userId: widget.userId);
    }
  }
}