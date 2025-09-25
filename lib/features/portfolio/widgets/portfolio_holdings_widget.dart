import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/domain/entities/portfolio/portfolio_holding.dart';
import '../../../core/providers/app_providers.dart';

/// Shared widget for displaying portfolio holdings
/// Uses Riverpod providers for data management
class PortfolioHoldingsWidget extends ConsumerWidget {
  /// User ID for portfolio data
  final String userId;
  
  /// Optional custom styling
  final EdgeInsetsGeometry? padding;
  
  /// Custom item builder for holdings
  final Widget Function(BuildContext context, PortfolioHolding holding)? itemBuilder;

  const PortfolioHoldingsWidget({
    super.key,
    required this.userId,
    this.padding,
    this.itemBuilder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holdingsAsync = ref.watch(portfolioHoldingsProvider(userId));

    return Container(
      padding: padding ?? const EdgeInsets.all(16.0),
      child: holdingsAsync.when(
        data: (portfolioHoldings) {
          final holdings = portfolioHoldings.holdings;
          
          if (holdings.isEmpty) {
            return _buildEmptyWidget(context);
          }

          return _buildHoldingsList(context, ref, holdings);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => _buildErrorWidget(context, ref, error.toString()),
      ),
    );
  }

  /// Build error widget
  Widget _buildErrorWidget(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load holdings',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.refresh(portfolioHoldingsProvider(userId)),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  /// Build empty state widget
  Widget _buildEmptyWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.portfolio_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No Holdings Found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Your portfolio is currently empty',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  /// Build holdings list
  Widget _buildHoldingsList(BuildContext context, WidgetRef ref, List<PortfolioHolding> holdings) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.refresh(portfolioHoldingsProvider(userId));
      },
      child: ListView.builder(
        itemCount: holdings.length,
        itemBuilder: (context, index) {
          final holding = holdings[index];
          
          // Use custom item builder if provided
          if (itemBuilder != null) {
            return itemBuilder!(context, holding);
          }
          
          // Default item builder
          return _buildDefaultHoldingItem(context, holding);
        },
      ),
    );
  }

  /// Build default holding item
  Widget _buildDefaultHoldingItem(BuildContext context, PortfolioHolding holding) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            holding.symbol.substring(0, 2).toUpperCase(),
            style: const TextStyle(fontSize: 12),
          ),
        ),
        title: Text(
          holding.symbol,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(holding.name ?? 'Unknown'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${holding.currentValue.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${holding.quantity} shares',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
          // Default item builder
          return _buildDefaultHoldingItem(holding);
        },
      ),
    );
  }

  /// Build default holding item
  Widget _buildDefaultHoldingItem(PortfolioHolding holding) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            holding.symbol.substring(0, 2).toUpperCase(),
            style: const TextStyle(fontSize: 12),
          ),
        ),
        title: Text(
          holding.symbol,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(holding.name ?? 'Unknown'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${holding.currentValue.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${holding.quantity} shares',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
