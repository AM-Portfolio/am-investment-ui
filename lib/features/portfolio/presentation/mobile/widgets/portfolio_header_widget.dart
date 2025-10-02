import 'package:flutter/material.dart';
import '../../../internal/domain/entities/portfolio_list.dart';
import '../../../../../core/utils/logger.dart';

/// Widget that displays the portfolio selector and tab bar
class PortfolioHeaderWidget extends StatelessWidget {
  final TabController tabController;
  final String? currentPortfolioId;
  final List<PortfolioItem>? portfolios;
  final Function(String portfolioId, String portfolioName)? onPortfolioChanged;
  final VoidCallback onLogout;

  const PortfolioHeaderWidget({
    super.key,
    required this.tabController,
    required this.currentPortfolioId,
    required this.onLogout,
    this.portfolios,
    this.onPortfolioChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Portfolio selector dropdown (only show if portfolios are provided)
            if (portfolios != null && portfolios!.isNotEmpty)
              _buildPortfolioSelector(context),
            // Tab bar
            _buildTabBar(context),
          ],
        ),
      ),
    );
  }

  /// Builds the portfolio selector dropdown
  Widget _buildPortfolioSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.account_balance_wallet,
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: currentPortfolioId,
                isExpanded: true,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                items: portfolios!.map((portfolio) {
                  return DropdownMenuItem<String>(
                    value: portfolio.portfolioId,
                    child: Text(
                      portfolio.portfolioName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  );
                }).toList(),
                onChanged: _handlePortfolioChange,
              ),
            ),
          ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: onLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
    );
  }

  /// Builds the tab bar
  Widget _buildTabBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TabBar(
            controller: tabController,
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
              Tab(icon: Icon(Icons.wallet, size: 20), text: 'Holdings'),
              Tab(
                icon: Icon(Icons.analytics_outlined, size: 20),
                text: 'Analysis',
              ),
              Tab(icon: Icon(Icons.grid_view, size: 20), text: 'Heatmap'),
            ],
          ),
        ),
        // Logout icon (only show if no portfolio selector)
        if (portfolios == null || portfolios!.isEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8.0),
            child: IconButton(
              onPressed: onLogout,
              icon: Icon(
                Icons.logout_outlined,
                color: Colors.grey[600],
                size: 22,
              ),
              tooltip: 'Logout',
            ),
          ),
      ],
    );
  }

  /// Handles portfolio selection change
  void _handlePortfolioChange(String? newPortfolioId) {
    if (newPortfolioId != null &&
        newPortfolioId != currentPortfolioId &&
        portfolios != null &&
        onPortfolioChanged != null) {
      final selectedPortfolio = portfolios!.firstWhere(
        (p) => p.portfolioId == newPortfolioId,
      );

      onPortfolioChanged!(newPortfolioId, selectedPortfolio.portfolioName);

      AppLogger.info(
        'Portfolio selection changed to: ${selectedPortfolio.portfolioName} ($newPortfolioId)',
        tag: 'PortfolioHeaderWidget',
      );
    }
  }
}
