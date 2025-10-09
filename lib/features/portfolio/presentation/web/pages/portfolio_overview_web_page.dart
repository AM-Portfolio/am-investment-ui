import 'package:flutter/material.dart';

import '../../../../../shared/widgets/portfolio_overview/configs/portfolio_overview_config.dart';
import '../../../../../shared/widgets/portfolio_overview/portfolio_overview_widget.dart';

/// Web-specific portfolio overview page
class PortfolioOverviewWebPage extends StatelessWidget {
  const PortfolioOverviewWebPage({
    required this.userId,
    super.key,
    this.portfolioName,
  });

  final String userId;
  final String? portfolioName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: PortfolioOverviewWidget(
          userId: userId,
          config: PortfolioOverviewConfig.web(),
          onRefresh: () {
            // Refresh handled by widget
          },
        ),
      ),
    );
  }
}
