import 'package:flutter/material.dart';

import '../../../../../shared/widgets/portfolio_overview/configs/portfolio_overview_config.dart';
import '../../../../../shared/widgets/portfolio_overview/portfolio_overview_widget.dart';
import '../../widgets/gmail_sync/gmail_connect_button.dart';

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
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  portfolioName ?? 'My Portfolio',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const GmailConnectButton(),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: PortfolioOverviewWidget(
                userId: userId,
                config: PortfolioOverviewConfig.web(),
                onRefresh: () {
                  // Refresh handled by widget
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
