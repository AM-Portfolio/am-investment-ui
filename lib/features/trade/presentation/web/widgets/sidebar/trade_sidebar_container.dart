import 'package:flutter/material.dart';

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
            _buildHeader(context, isFull, isCondensed),

            // Navigation Items
            Expanded(child: _buildContent(context, isCompact, isCondensed, isFull)),

            // Footer
            if (isFull) _buildFooter(context),
          ],
        ),
      );
    },
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

  Widget _buildHeader(BuildContext context, bool isFull, bool isCondensed) {
    if (isFull) {
      return Container(
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
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
      );
    } else if (isCondensed) {
      return Container(
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
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.02),
          border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
        ),
        child: Center(child: Icon(Icons.swap_horiz, color: Theme.of(context).colorScheme.primary, size: 20)),
      );
    }
  }

  Widget _buildFooter(BuildContext context) => Container(
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
  );
}
