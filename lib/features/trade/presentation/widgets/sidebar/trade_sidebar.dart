import 'package:flutter/material.dart';

import '../../models/trade_portfolio_view_model.dart';
import '../trade_web_screen.dart';
import 'trade_sidebar_container.dart';

/// Trade sidebar widget with view selection
class TradeSidebar extends StatelessWidget {
  const TradeSidebar({
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
  Widget build(BuildContext context) => TradeSidebarContainer(
    selectedView: selectedView,
    onViewChanged: onViewChanged,
    currentPortfolioId: currentPortfolioId,
    currentPortfolioName: currentPortfolioName,
    portfolios: portfolios,
    onPortfolioSelected: onPortfolioSelected,
  );
}
