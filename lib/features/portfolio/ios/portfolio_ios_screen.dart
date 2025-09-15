import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/models/portfolio/portfolio_models.dart';
import '../../../core/services/api/api_client.dart';
import '../../../widgets/shared/finance/portfolio_summary_card.dart';
import '../../../widgets/shared/finance/holdings_breakdown.dart';

/// iOS-specific implementation of the portfolio summary screen
class PortfolioIOSScreen extends StatelessWidget {
  /// Future for portfolio summary data
  final Future<ApiResponse<PortfolioSummary>> portfolioSummaryFuture;
  
  /// Callback to refresh portfolio data
  final Future<void> Function() refreshPortfolio;
  
  /// User ID for portfolio data
  final String userId;
  
  /// Constructor
  const PortfolioIOSScreen({
    Key? key,
    required this.portfolioSummaryFuture,
    required this.refreshPortfolio,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Portfolio Summary'),
      ),
      child: SafeArea(
        child: FutureBuilder<ApiResponse<PortfolioSummary>>(
          future: portfolioSummaryFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CupertinoActivityIndicator(),
              );
            }
            
            if (snapshot.hasError) {
              return _buildErrorState(context, snapshot.error.toString());
            }
            
            final response = snapshot.data!;
            
            if (!response.isSuccess) {
              return _buildErrorState(context, response.error ?? 'Unknown error');
            }
            
            final summary = response.data!;
            
            // iOS-specific layout with Cupertino styling
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                CupertinoSliverRefreshControl(
                  onRefresh: refreshPortfolio,
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      PortfolioSummaryCard(
                        summary: summary,
                        showDetails: true,
                      ),
                      const SizedBox(height: 16),
                      HoldingsBreakdown(
                        summary: summary,
                      ),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Build error state widget with iOS styling
  Widget _buildErrorState(BuildContext context, String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_triangle,
              size: 64,
              color: CupertinoColors.destructiveRed,
            ),
            const SizedBox(height: 24),
            Text(
              'Error loading portfolio data',
              style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: CupertinoTheme.of(context).textTheme.textStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CupertinoButton.filled(
              onPressed: refreshPortfolio,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
