import 'package:flutter/material.dart';

import '../web/trade_web_screen.dart';

/// Trade sidebar widget with view selection
class TradeSidebar extends StatelessWidget {
  const TradeSidebar({
    required this.selectedView,
    required this.onViewChanged,
    super.key,
    this.currentPortfolioId,
    this.currentPortfolioName,
  });

  final TradeViewType selectedView;
  final Function(TradeViewType) onViewChanged;
  final String? currentPortfolioId;
  final String? currentPortfolioName;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      // Determine sidebar mode based on available width
      final isCompact = constraints.maxWidth < 100; // Icon-only mode
      final isCondensed = constraints.maxWidth >= 100 && constraints.maxWidth < 200; // Minimal text mode
      final isFull = constraints.maxWidth >= 200; // Full mode

      return Container(
        color: Theme.of(context).cardColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sidebar Header
            if (isFull)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.02),
                  border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.swap_horiz, color: Theme.of(context).colorScheme.primary, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Trade Analysis',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          Text(
                            'Portfolio Management',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else if (isCondensed)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.02),
                  border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.swap_horiz, color: Theme.of(context).colorScheme.primary, size: 18),
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.02),
                  border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
                ),
                child: Center(child: Icon(Icons.swap_horiz, color: Theme.of(context).colorScheme.primary, size: 20)),
              ),

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

            // Navigation Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildNavItem(
                    context,
                    icon: Icons.list_alt,
                    title: 'Portfolio List',
                    subtitle: 'Browse available portfolios',
                    viewType: TradeViewType.portfolios,
                    isEnabled: true,
                    isCompact: isCompact,
                    isCondensed: isCondensed,
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.account_balance_wallet,
                    title: 'Holdings',
                    subtitle: 'Detailed trade positions',
                    viewType: TradeViewType.holdings,
                    isEnabled: currentPortfolioId != null,
                    isCompact: isCompact,
                    isCondensed: isCondensed,
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.calendar_today,
                    title: 'Calendar',
                    subtitle: 'Trade timeline & events',
                    viewType: TradeViewType.calendar,
                    isEnabled: currentPortfolioId != null,
                    isCompact: isCompact,
                    isCondensed: isCondensed,
                  ),

                  if (isFull)
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Divider()),

                  // Quick Actions - only show in full mode
                  if (isFull) ...[
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
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(const SnackBar(content: Text('Export functionality coming soon')));
                      },
                    ),
                  ],
                ],
              ),
            ),

            // Footer - only show in full mode
            if (isFull)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
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
              ),
          ],
        ),
      );
    },
  );

  /// Build a navigation item
  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required TradeViewType viewType,
    required bool isEnabled,
    required bool isCompact,
    required bool isCondensed,
  }) {
    final isSelected = selectedView == viewType;
    final theme = Theme.of(context);

    // Compact mode: Icon only with enhanced styling
    if (isCompact) {
      return Tooltip(
        message: title,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: isEnabled ? () => onViewChanged(viewType) : null,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                  border: isSelected ? Border.all(color: theme.colorScheme.primary, width: 2) : null,
                  boxShadow: isSelected
                      ? [BoxShadow(color: theme.colorScheme.primary.withOpacity(0.4), blurRadius: 8, spreadRadius: 1)]
                      : null,
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: isEnabled
                      ? (isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.primary)
                      : theme.colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Condensed mode: Icon + abbreviated text
    if (isCondensed) {
      return Tooltip(
        message: subtitle,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: isEnabled ? () => onViewChanged(viewType) : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isSelected ? theme.colorScheme.primaryContainer : Colors.transparent,
                  border: isSelected ? Border.all(color: theme.colorScheme.primary.withOpacity(0.5)) : null,
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isEnabled
                            ? (isSelected ? theme.colorScheme.primary : theme.colorScheme.primary.withOpacity(0.1))
                            : theme.colorScheme.onSurface.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: isEnabled
                            ? (isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.primary)
                            : theme.colorScheme.onSurface.withOpacity(0.4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title.split(' ').first, // First word only
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isEnabled
                            ? (isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface)
                            : theme.colorScheme.onSurface.withOpacity(0.4),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Full mode: Original design
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: isEnabled ? () => onViewChanged(viewType) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isSelected ? theme.colorScheme.primaryContainer : Colors.transparent,
              border: isSelected ? Border.all(color: theme.colorScheme.primary.withOpacity(0.3)) : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isEnabled
                        ? (isSelected ? theme.colorScheme.primary : theme.colorScheme.primary.withOpacity(0.1))
                        : theme.colorScheme.onSurface.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: isEnabled
                        ? (isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.primary)
                        : theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isEnabled
                              ? (isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface)
                              : theme.colorScheme.onSurface.withOpacity(0.4),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isEnabled
                              ? theme.colorScheme.onSurface.withOpacity(0.6)
                              : theme.colorScheme.onSurface.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isEnabled) Icon(Icons.lock_outline, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.3)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build a quick action item
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
