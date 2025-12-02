import 'package:flutter/material.dart';

import '../../../../../../shared/widgets/navigation/sidebar_nav_item.dart';
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
      // Current Portfolio Selector - Always visible in full mode
      if (isFull)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C3E), // Dark card background
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
                // Subtle purple glow
                BoxShadow(
                  color: const Color(0xFF6C5DD3).withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF2C2C3E),
                  const Color(0xFF2C2C3E).withValues(alpha: 0.8),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C5DD3).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.account_balance_wallet, size: 16, color: Color(0xFF6C5DD3)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Current Portfolio',
                        style: TextStyle(
                          color: const Color(0xFF6C5DD3),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  currentPortfolioName ?? 'No Portfolio Selected',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (currentPortfolioId != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${currentPortfolioId!.substring(0, 8)}...',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                // Portfolio Dropdown Selector
                if (portfolios.isNotEmpty && onPortfolioSelected != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: currentPortfolioId,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF2C2C3E),
                        icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.white70),
                        hint: const Text('Select Portfolio', style: TextStyle(color: Colors.white54)),
                        items: portfolios
                            .map(
                              (portfolio) => DropdownMenuItem<String>(
                                value: portfolio.id,
                                child: Text(
                                  portfolio.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white),
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
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
              ],
            ),
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
        title: 'View Trades',
        subtitle: 'All trade transactions',
        value: TradeViewType.trades,
        groupValue: selectedView,
        onChanged: onViewChanged,
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
      SidebarNavItem<TradeViewType>(
        icon: Icons.book,
        title: 'Trade Journal',
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
