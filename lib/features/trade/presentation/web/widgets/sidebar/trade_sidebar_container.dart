import 'package:flutter/material.dart';
import 'package:am_common_ui/am_common_ui.dart';

import '../../../models/trade_portfolio_view_model.dart';
import '../../trade_web_screen.dart';
import 'portfolio_sidebar_content.dart';

class TradeSidebarContainer extends StatelessWidget {
  const TradeSidebarContainer({
    required this.selectedView,
    required this.onViewChanged,
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

  @override
  Widget build(BuildContext context) => SecondarySidebar(
    title: 'Trade Analysis',
    subtitle: 'Portfolio Management',
    icon: Icons.show_chart_rounded,
    accentColor: const Color(0xFF8b5cf6), // Purple accent for Trade
    child: LayoutBuilder(
      builder: (context, constraints) {
        // Determine sidebar mode based on available width
        final isCompact = constraints.maxWidth < 100; // Icon-only mode
        final isCondensed = constraints.maxWidth >= 100 && constraints.maxWidth < 200; // Minimal text mode
        final isFull = constraints.maxWidth >= 200; // Full mode

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Navigation Items
            Expanded(child: _buildContent(context, isCompact, isCondensed, isFull)),

            // Footer
            if (isFull) _buildFooter(context),
          ],
        );
      },
    ),
  );

  Widget _buildContent(BuildContext context, bool isCompact, bool isCondensed, bool isFull) {
    // Always show portfolio sidebar content regardless of selected view
    return PortfolioSidebarContent(
      selectedView: selectedView,
      onViewChanged: onViewChanged,
      currentPortfolioId: currentPortfolioId,
      currentPortfolioName: currentPortfolioName,
      portfolios: portfolios,
      onPortfolioSelected: onPortfolioSelected,
      isCompact: isCompact,
      isCondensed: isCondensed,
      isFull: isFull,
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
