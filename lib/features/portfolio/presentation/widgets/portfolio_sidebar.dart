import 'package:flutter/material.dart';

import '../../../../shared/widgets/navigation/sidebar_nav_item.dart';
import '../../internal/domain/entities/portfolio_list.dart';
import '../cubit/portfolio_state.dart';

/// Portfolio sidebar widget with view selection
class PortfolioSidebar extends StatelessWidget {
  const PortfolioSidebar({
    required this.selectedView,
    required this.onViewChanged,
    super.key,
    this.currentPortfolioId,
    this.currentPortfolioName,
    this.portfolios = const [],
    this.onPortfolioSelected,
  });

  final PortfolioViewType selectedView;
  final Function(PortfolioViewType) onViewChanged;
  final String? currentPortfolioId;
  final String? currentPortfolioName;
  final List<PortfolioItem> portfolios;
  final Function(String portfolioId, String portfolioName)? onPortfolioSelected;

  @override
  Widget build(BuildContext context) {
    // Define dark theme for sidebar (consistent with TradeSidebar)
    final darkTheme = Theme.of(context).copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF1E1E2E),
      cardColor: const Color(0xFF1E1E2E),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF6C5DD3),
        surface: Color(0xFF1E1E2E),
        onSurface: Colors.white,
        primaryContainer: Color(0xFF2C2C3E),
        onPrimaryContainer: Colors.white,
        outline: Colors.white24,
      ),
      textTheme: Theme.of(context).textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      dividerColor: Colors.white.withValues(alpha: 0.1),
    );

    return Theme(
      data: darkTheme,
      child: Container(
        color: const Color(0xFF1E1E2E),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  // Portfolio Selector
                  _buildPortfolioSelector(context),

                  const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Divider()),

                  // Navigation Items
                  _buildNavItem(
                    context,
                    icon: Icons.dashboard,
                    title: 'Overview',
                    subtitle: 'Portfolio summary',
                    viewType: PortfolioViewType.overview,
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.account_balance_wallet,
                    title: 'Holdings',
                    subtitle: 'Detailed positions',
                    viewType: PortfolioViewType.holdings,
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.analytics,
                    title: 'Analytics',
                    subtitle: 'Performance metrics',
                    viewType: PortfolioViewType.analysis,
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.grid_view,
                    title: 'Heatmap',
                    subtitle: 'Visual distribution',
                    viewType: PortfolioViewType.heatmap,
                  ),
                ],
              ),
            ),

            // Footer
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF6C5DD3).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.pie_chart, color: Color(0xFF6C5DD3), size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Portfolio Manager',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                ),
                Text(
                  'Asset Allocation',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioSelector(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet, size: 16, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Current Portfolio',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currentPortfolioName ?? 'No Portfolio Selected',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (currentPortfolioId != null) ...[
            const SizedBox(height: 2),
            Text(
              'ID: ${currentPortfolioId!.substring(0, 8)}...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                fontSize: 10,
                fontFamily: 'monospace',
              ),
            ),
          ],
          const SizedBox(height: 8),
          // Portfolio Dropdown Selector
          if (portfolios.isNotEmpty && onPortfolioSelected != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
              ),
              child: DropdownButton<String>(
                value: currentPortfolioId,
                isExpanded: true,
                underline: const SizedBox(),
                hint: const Text('Select Portfolio'),
                icon: const Icon(Icons.arrow_drop_down, size: 20),
                items: portfolios
                    .map(
                      (portfolio) => DropdownMenuItem<String>(
                        value: portfolio.portfolioId,
                        child: Text(
                          portfolio.portfolioName,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (portfolioId) {
                  if (portfolioId != null) {
                    final portfolio = portfolios.firstWhere((p) => p.portfolioId == portfolioId);
                    onPortfolioSelected!(portfolioId, portfolio.portfolioName);
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required PortfolioViewType viewType,
  }) {
    return SidebarNavItem<PortfolioViewType>(
      icon: icon,
      title: title,
      subtitle: subtitle,
      value: viewType,
      groupValue: selectedView,
      onChanged: onViewChanged,
      isEnabled: true,
      isCompact: false,
      isCondensed: false,
    );
  }

  Widget _buildFooter(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trade System v1.0',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Professional trading analysis',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
        ),
      ],
    ),
  );
}
