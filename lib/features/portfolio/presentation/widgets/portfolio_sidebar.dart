import 'package:flutter/material.dart';
import '../cubit/portfolio_state.dart';

/// Portfolio sidebar widget with view selection
class PortfolioSidebar extends StatelessWidget {
  final PortfolioViewType selectedView;
  final Function(PortfolioViewType) onViewChanged;

  const PortfolioSidebar({
    super.key,
    required this.selectedView,
    required this.onViewChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Portfolio Navigation',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        // Temporarily disabled navigation items
        // _buildNavItem(
        //   context,
        //   icon: Icons.dashboard,
        //   title: 'Overview',
        //   viewType: PortfolioViewType.overview,
        // ),
        // _buildNavItem(
        //   context,
        //   icon: Icons.account_balance_wallet,
        //   title: 'Holdings',
        //   viewType: PortfolioViewType.holdings,
        // ),
        // _buildNavItem(
        //   context,
        //   icon: Icons.analytics,
        //   title: 'Analysis',
        //   viewType: PortfolioViewType.analysis,
        // ),
        _buildNavItem(
          context,
          icon: Icons.grid_view,
          title: 'Heatmap',
          viewType: PortfolioViewType.heatmap,
        ),
      ],
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required PortfolioViewType viewType,
  }) {
    final isSelected = selectedView == viewType;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).primaryColor : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Theme.of(context).primaryColor : null,
        ),
      ),
      selected: isSelected,
      onTap: () => onViewChanged(viewType),
    );
  }
}
