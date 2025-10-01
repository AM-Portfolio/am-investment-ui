import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/portfolio_cubit.dart';
import '../../cubit/portfolio_state.dart';
import '../../../../../core/utils/logger.dart';

/// Portfolio holdings widget showing detailed holdings list
class PortfolioHoldingsAppWidget extends StatelessWidget {
  final String userId;

  const PortfolioHoldingsAppWidget({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    AppLogger.debug('Building PortfolioHoldingsWidget for userId: $userId', tag: 'PortfolioHoldingsWidget');
    
    return BlocBuilder<PortfolioCubit, PortfolioState>(
      builder: (context, state) {
        AppLogger.debug('Portfolio state changed in holdings widget: ${state.runtimeType}', 
            tag: 'PortfolioHoldingsWidget');
        
        if (state is PortfolioLoading) {
          AppLogger.debug('Showing loading indicator for portfolio holdings', tag: 'PortfolioHoldingsWidget');
          return const Center(child: CircularProgressIndicator());
        } else if (state is PortfolioError) {
          AppLogger.warning('Showing error state in portfolio holdings: ${state.message}', 
              tag: 'PortfolioHoldingsWidget');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
                const SizedBox(height: 16),
                Text('Error: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<PortfolioCubit>().loadPortfolio(userId),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else if (state is PortfolioLoaded) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      'Holdings (${state.holdings.length})',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        // TODO: Implement search functionality with cubit
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => context.read<PortfolioCubit>().refreshPortfolio(userId),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _buildHoldingsList(context, state.holdings),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildHoldingsList(BuildContext context, List holdings) {
    return ListView.builder(
      itemCount: holdings.length,
      itemBuilder: (context, index) {
        final holding = holdings[index];
        final isPositive = holding.totalGainLoss >= 0;
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isPositive ? Colors.green.shade100 : Colors.red.shade100,
              child: Text(
                holding.symbol.substring(0, 2),
                style: TextStyle(
                  color: isPositive ? Colors.green.shade800 : Colors.red.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              holding.symbol,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(holding.companyName),
                Text('${holding.quantity.toStringAsFixed(0)} shares @ \$${holding.currentPrice.toStringAsFixed(2)}'),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${holding.currentValue.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${isPositive ? '+' : ''}\$${holding.totalGainLoss.toStringAsFixed(2)} (${holding.totalGainLossPercentage.toStringAsFixed(2)}%)',
                  style: TextStyle(
                    color: isPositive ? Colors.green : Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            onTap: () {
              // TODO: Navigate to holding details
            },
          ),
        );
      },
    );
  }
}