import 'package:flutter/material.dart';

import '../web/trade_web_screen.dart';
import 'sidebar/trade_sidebar_container.dart';

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
  Widget build(BuildContext context) {
    return TradeSidebarContainer(
      selectedView: selectedView,
      onViewChanged: onViewChanged,
      currentPortfolioId: currentPortfolioId,
      currentPortfolioName: currentPortfolioName,
    );
  }
}
