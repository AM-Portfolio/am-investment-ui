import 'package:flutter/material.dart';

import '../../../../../../shared/widgets/navigation/sidebar_nav_item.dart';
import '../../../../../../shared/widgets/selectors/shared_portfolio_selector.dart';
import '../../../models/trade_portfolio_view_model.dart';
import '../../trade_web_screen.dart';

class PortfolioSidebarContent extends StatelessWidget {
  const PortfolioSidebarContent({
    required this.selectedView,
    required this.onViewChanged,
    required this.isCompact,
    required this.isCondensed,
    required this.isFull,
    super.key,
    this.currentPortfolioId,
    this.currentPortfolioName,
    this.portfolios = const [],
    this.onPortfolioSelected,
  });

  final TradeViewType selectedView;
  final Function(TradeViewType) onViewChanged;
  final String? currentPortfolioId;
  final String? currentPortfolioName;
  final List<TradePortfolioViewModel> portfolios;
  final Function(String portfolioId, String portfolioName)? onPortfolioSelected;
  final bool isCompact;
  final bool isCondensed;
  final bool isFull;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.symmetric(vertical: 8),
    children: [
      // Add Trade Button - Always visible in full mode
      if (isFull)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C5DD3), Color(0xFF8B80F8)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C5DD3).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/trade/add',
                    arguments: {
                      'portfolioId': currentPortfolioId,
                      'portfolioName': currentPortfolioName
                    },
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Add Trade',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

      // Current Portfolio Selector
      if (portfolios.isNotEmpty && onPortfolioSelected != null)
        SharedPortfolioSelector<TradePortfolioViewModel>(
          currentPortfolioId: currentPortfolioId,
          currentPortfolioName: currentPortfolioName,
          portfolios: portfolios,
          onPortfolioSelected: onPortfolioSelected!,
          idExtractor: (p) => p.id,
          nameExtractor: (p) => p.name,
          isCompact: !isFull, // Use compact mode if not full (i.e. if compact or condensed)
        ),

      if (isFull) const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Divider()),

      // Main Navigation - Always enabled
      SidebarNavItem<TradeViewType>(
        icon: Icons.list_alt,
        title: 'Portfolio List',
        subtitle: 'View all portfolios',
        value: TradeViewType.portfolios,
        groupValue: selectedView,
        onChanged: onViewChanged,
        isEnabled: true,
        isCompact: isCompact,
        isCondensed: isCondensed,
      ),
      SidebarNavItem<TradeViewType>(
        icon: Icons.account_balance_wallet,
        title: 'Holdings',
        subtitle: 'Detailed trade positions',
        value: TradeViewType.holdings,
        groupValue: selectedView,
        onChanged: onViewChanged,
        isEnabled: true,
        isCompact: isCompact,
        isCondensed: isCondensed,
      ),
      SidebarNavItem<TradeViewType>(
        icon: Icons.calendar_today,
        title: 'Calendar',
        subtitle: 'Trade timeline & events',
        value: TradeViewType.calendar,
        groupValue: selectedView,
        onChanged: onViewChanged,
        isEnabled: true,
        isCompact: isCompact,
        isCondensed: isCondensed,
      ),

      if (isFull) const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Divider()),

      // Trade Management Section
      SidebarNavItem<TradeViewType>(
        icon: Icons.receipt_long,
        title: 'Trades',
        subtitle: 'All trade transactions',
        value: TradeViewType.trades,
        groupValue: selectedView,
        onChanged: onViewChanged,
        isEnabled: true,
        isCompact: isCompact,
        isCondensed: isCondensed,
      ),

      SidebarNavItem<TradeViewType>(
        icon: Icons.analytics_outlined,
        title: 'Analysis',
        subtitle: 'Performance metrics',
        value: TradeViewType.analysis,
        groupValue: selectedView,
        onChanged: onViewChanged,
        isEnabled: true,
        isCompact: isCompact,
        isCondensed: isCondensed,
      ),

      SidebarNavItem<TradeViewType>(
        icon: Icons.show_chart,
        title: 'Market Analysis',
        subtitle: 'TradingView Charts',
        value: TradeViewType.marketAnalysis,
        groupValue: selectedView,
        onChanged: onViewChanged,
        isEnabled: true,
        isCompact: isCompact,
        isCondensed: isCondensed,
      ),

      SidebarNavItem<TradeViewType>(
        icon: Icons.dashboard_customize,
        title: 'Dashboard',
        subtitle: 'Unified trade view',
        value: TradeViewType.unified,
        groupValue: selectedView,
        onChanged: onViewChanged,
        isEnabled: true,
        isCompact: isCompact,
        isCondensed: isCondensed,
      ),

      // Quick Actions - Always visible in full mode
      if (isFull) ...[
        // Other quick actions can go here
      ],

      // Trade Journal - Always enabled
      SidebarNavItem<TradeViewType>(
        icon: Icons.book,
        title: 'Journal',
        subtitle: 'Personal trading notes',
        value: TradeViewType.journal,
        groupValue: selectedView,
        onChanged: onViewChanged,
        isEnabled: true,
        isCompact: isCompact,
        isCondensed: isCondensed,
      ),
    ],
  );

  Widget _buildQuickActionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 12, color: theme.colorScheme.onSurface.withOpacity(0.4)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
