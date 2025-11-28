import 'package:flutter/material.dart';

import '../../web/trade_web_screen.dart';
import 'sidebar_nav_item.dart';

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
  });

  final TradeViewType selectedView;
  final Function(TradeViewType) onViewChanged;
  final String? currentPortfolioId;
  final String? currentPortfolioName;
  final bool isCompact;
  final bool isCondensed;
  final bool isFull;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // Current Portfolio Info (if selected) - only show in full mode
        if (currentPortfolioId != null && isFull)
          Container(
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
                const SizedBox(height: 6),
                Text(
                  currentPortfolioName ?? 'Unknown Portfolio',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
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
            ),
          ),

        SidebarNavItem(
          icon: Icons.list_alt,
          title: 'Portfolio List',
          subtitle: 'Browse available portfolios',
          viewType: TradeViewType.portfolios,
          selectedView: selectedView,
          onViewChanged: onViewChanged,
          isEnabled: true,
          isCompact: isCompact,
          isCondensed: isCondensed,
        ),
        SidebarNavItem(
          icon: Icons.account_balance_wallet,
          title: 'Holdings',
          subtitle: 'Detailed trade positions',
          viewType: TradeViewType.holdings,
          selectedView: selectedView,
          onViewChanged: onViewChanged,
          isEnabled: currentPortfolioId != null,
          isCompact: isCompact,
          isCondensed: isCondensed,
        ),
        SidebarNavItem(
          icon: Icons.calendar_today,
          title: 'Calendar',
          subtitle: 'Trade timeline & events',
          viewType: TradeViewType.calendar,
          selectedView: selectedView,
          onViewChanged: onViewChanged,
          isEnabled: currentPortfolioId != null,
          isCompact: isCompact,
          isCondensed: isCondensed,
        ),
        
        // Link to Journal
        const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Divider()),
        
        SidebarNavItem(
          icon: Icons.book,
          title: 'Trade Journal',
          subtitle: 'Personal trading notes',
          viewType: TradeViewType.journal,
          selectedView: selectedView,
          onViewChanged: onViewChanged,
          isEnabled: true,
          isCompact: isCompact,
          isCondensed: isCondensed,
        ),

        if (isFull)
          const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Divider()),

        // Quick Actions - only show in full mode
        if (isFull) ...[
          // Add Trade action
          if (currentPortfolioId != null)
            _buildQuickActionItem(
              context,
              icon: Icons.add_chart,
              title: 'Add Trade',
              subtitle: 'Record new position',
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/trade/add',
                  arguments: {'portfolioId': currentPortfolioId, 'portfolioName': currentPortfolioName},
                );
              },
            ),
          _buildQuickActionItem(
            context,
            icon: Icons.analytics,
            title: 'Analytics Dashboard',
            subtitle: 'Performance overview',
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Analytics dashboard coming soon')));
            },
          ),
          _buildQuickActionItem(
            context,
            icon: Icons.download,
            title: 'Export Data',
            subtitle: 'Download trade reports',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Export functionality coming soon')));
            },
          ),
        ],
      ],
    );
  }

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
