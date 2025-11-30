import 'package:flutter/material.dart';

import '../../models/trade_portfolio_view_model.dart';
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
      // Current Portfolio Selector - Always visible in full mode
      if (isFull)
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
                            value: portfolio.id,
                            child: Text(
                              portfolio.name,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (portfolioId) {
                      if (portfolioId != null) {
                        final portfolio = portfolios.firstWhere((p) => p.id == portfolioId);
                        onPortfolioSelected!(portfolioId, portfolio.name);
                      }
                    },
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => onViewChanged(TradeViewType.portfolios),
                    icon: const Icon(Icons.swap_horiz, size: 16),
                    label: const Text('Change Portfolio'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
            ],
          ),
        ),

      if (isFull) const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Divider()),

      // Main Navigation - Always enabled
      SidebarNavItem(
        icon: Icons.list_alt,
        title: 'Portfolio List',
        subtitle: 'View all portfolios',
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
        isEnabled: true,
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
        isEnabled: true,
        isCompact: isCompact,
        isCondensed: isCondensed,
      ),

      if (isFull) const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Divider()),

      // Trade Management Section
      SidebarNavItem(
        icon: Icons.receipt_long,
        title: 'View Trades',
        subtitle: 'All trade transactions',
        viewType: TradeViewType.trades,
        selectedView: selectedView,
        onViewChanged: onViewChanged,
        isEnabled: true,
        isCompact: isCompact,
        isCondensed: isCondensed,
      ),

      // Quick Actions - Always visible in full mode
      if (isFull) ...[
        // Add Trade action - always enabled
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
      ],

      // Trade Journal - Always enabled
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
