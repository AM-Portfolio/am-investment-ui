import 'package:flutter/material.dart';

import '../../web/trade_web_screen.dart';
import 'sidebar_nav_item.dart';

class JournalSidebarContent extends StatelessWidget {
  const JournalSidebarContent({
    required this.selectedView,
    required this.onViewChanged,
    required this.isCompact,
    required this.isCondensed,
    required this.isFull,
    super.key,
  });

  final TradeViewType selectedView;
  final Function(TradeViewType) onViewChanged;
  final bool isCompact;
  final bool isCondensed;
  final bool isFull;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // Back to Portfolios
        SidebarNavItem(
          icon: Icons.arrow_back,
          title: 'Back to Portfolios',
          subtitle: 'Return to main view',
          viewType: TradeViewType.portfolios,
          selectedView: selectedView,
          onViewChanged: onViewChanged,
          isEnabled: true,
          isCompact: isCompact,
          isCondensed: isCondensed,
        ),
        
        const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Divider()),

        // Journal specific items (can be expanded later)
        SidebarNavItem(
          icon: Icons.book,
          title: 'All Entries',
          subtitle: 'View all journal entries',
          viewType: TradeViewType.journal,
          selectedView: selectedView,
          onViewChanged: onViewChanged,
          isEnabled: true,
          isCompact: isCompact,
          isCondensed: isCondensed,
        ),
      ],
    );
  }
}
