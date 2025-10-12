import 'package:flutter/material.dart';
import '../../../internal/domain/entities/trade_portfolio.dart';

class TradePortfolioDiscoveryTemplate extends StatelessWidget {
  final List<TradePortfolio> portfolios;
  final bool isLoading;
  final String? errorMessage;
  final Function(TradePortfolio) onPortfolioSelected;
  final VoidCallback? onRefresh;
  final bool isWebView;

  const TradePortfolioDiscoveryTemplate({
    super.key,
    required this.portfolios,
    required this.isLoading,
    this.errorMessage,
    required this.onPortfolioSelected,
    this.onRefresh,
    this.isWebView = true,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            if (onRefresh != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRefresh,
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      );
    }

    if (portfolios.isEmpty) {
      return const Center(child: Text('No portfolios found'));
    }

    return isWebView
        ? _buildGridView()
        : _buildListView();
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: portfolios.length,
      itemBuilder: (context, index) {
        final portfolio = portfolios[index];
        return _buildPortfolioCard(portfolio);
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: portfolios.length,
      itemBuilder: (context, index) {
        final portfolio = portfolios[index];
        return _buildPortfolioCard(portfolio);
      },
    );
  }

  Widget _buildPortfolioCard(TradePortfolio portfolio) {
    final isPositive = portfolio.totalGainLoss >= 0;
    
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => onPortfolioSelected(portfolio),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                portfolio.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (portfolio.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  portfolio.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
              const Spacer(),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\$${portfolio.totalValue.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${portfolio.holdingsCount} Holdings',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isPositive ? '+' : ''}\$${portfolio.totalGainLoss.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isPositive ? Colors.green : Colors.red,
                        ),
                      ),
                      Text(
                        '${isPositive ? '+' : ''}${portfolio.totalGainLossPercentage.toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: isPositive ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
