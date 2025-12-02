import 'package:flutter/material.dart';

import '../cubit/portfolio_state.dart';

/// Portfolio sidebar widget with view selection
class PortfolioSidebar extends StatelessWidget {
  const PortfolioSidebar({
    required this.selectedView,
    required this.onViewChanged,
    super.key,
  });
  final PortfolioViewType selectedView;
  final Function(PortfolioViewType) onViewChanged;

  @override
  Widget build(BuildContext context) => Container(
    color: const Color(0xFF1E1E2E), // Dark background
    child: Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Portfolio Navigation',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        _buildNavItem(
          context,
          icon: Icons.dashboard,
          title: 'Overview',
          viewType: PortfolioViewType.overview,
        ),
        _buildNavItem(
          context,
          icon: Icons.account_balance_wallet,
          title: 'Holdings',
          viewType: PortfolioViewType.holdings,
        ),
        _buildNavItem(
          context,
          icon: Icons.analytics,
          title: 'Analytics',
          viewType: PortfolioViewType.analysis,
        ),
        _buildNavItem(
          context,
          icon: Icons.grid_view,
          title: 'Heatmap',
          viewType: PortfolioViewType.heatmap,
        ),
      ],
    ),
  );

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required PortfolioViewType viewType,
  }) {
    final isSelected = selectedView == viewType;
    const activeColor = Color(0xFF6C5DD3);
    final inactiveColor = Colors.white.withValues(alpha: 0.7);

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? activeColor : inactiveColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? activeColor : inactiveColor,
        ),
      ),
      selected: isSelected,
      selectedTileColor: activeColor.withValues(alpha: 0.1),
      onTap: () => onViewChanged(viewType),
    );
  }
}
