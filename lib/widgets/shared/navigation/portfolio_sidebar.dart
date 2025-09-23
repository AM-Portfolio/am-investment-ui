import 'package:flutter/material.dart';

/// A sidebar component for portfolio navigation
class PortfolioSidebar extends StatelessWidget {
  /// Current selected page
  final String currentPage;

  /// Callback when a page is selected
  final Function(String) onPageSelected;

  /// Constructor
  const PortfolioSidebar({
    super.key,
    required this.currentPage,
    required this.onPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(
                'Portfolio',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildSidebarItem(
              context,
              'Overview',
              Icons.dashboard_outlined,
              currentPage == 'Overview',
            ),
            _buildSidebarItem(
              context,
              'Holdings',
              Icons.account_balance_outlined,
              currentPage == 'Holdings',
            ),
            _buildSidebarItem(
              context,
              'Analysis',
              Icons.analytics_outlined,
              currentPage == 'Analysis',
            ),
          ],
        ),
      ),
    );
  }

  /// Build a sidebar navigation item
  Widget _buildSidebarItem(
    BuildContext context,
    String title,
    IconData icon,
    bool isActive,
  ) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => onPageSelected(title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: isActive
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isActive ? theme.colorScheme.primary : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
