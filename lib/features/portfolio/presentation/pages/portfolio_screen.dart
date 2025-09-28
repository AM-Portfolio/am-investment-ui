import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/portfolio_overview_widget.dart';
import '../widgets/portfolio_holdings_widget.dart';
import '../widgets/portfolio_analysis_widget.dart';
import '../widgets/portfolio_sidebar.dart';
import '../cubit/portfolio_cubit.dart';
import '../cubit/portfolio_state.dart';

/// Main portfolio screen with clean architecture using BLoC
class PortfolioScreen extends StatelessWidget {
  final String userId;

  const PortfolioScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PortfolioCubit(
        // TODO: Get dependencies from DI container
        null!, // GetPortfolioSummary
        null!, // GetPortfolioHoldings  
        null!, // SearchPortfolioHoldings
      )..loadPortfolio(userId),
      child: PortfolioView(userId: userId),
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
    
    return BlocListener<PortfolioCubit, PortfolioState>(
      listener: (context, state) {
        // Handle any state changes like showing errors, etc.
        if (state is PortfolioError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Portfolio'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
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