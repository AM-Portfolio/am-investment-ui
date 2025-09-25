import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';

/// Widget for displaying portfolio holdings
class PortfolioHoldingsWidget extends ConsumerWidget {
  final String userId;
  final EdgeInsets? padding;
  final Widget Function(BuildContext context, dynamic holding)? itemBuilder;

  const PortfolioHoldingsWidget({
    super.key,
    required this.userId,
    this.padding,
    this.itemBuilder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holdingsAsync = ref.watch(portfolioHoldingsProvider(userId));

    return holdingsAsync.when(
      data: (holdings) => _buildHoldingsList(context, ref, holdings.holdings ?? []),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorWidget(context, error.toString(), () {
        ref.refresh(portfolioHoldingsProvider(userId));
      }),
    );
  }

  Widget _buildHoldingsList(BuildContext context, WidgetRef ref, List<dynamic> holdings) {
    if (holdings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No holdings found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: padding ?? const EdgeInsets.all(16),
      itemCount: holdings.length,
      itemBuilder: (context, index) {
        final holding = holdings[index];
        if (itemBuilder != null) {
          return itemBuilder!(context, holding);
        }
        return _buildDefaultHoldingItem(context, holding);
      },
    );
  }

  Widget _buildDefaultHoldingItem(BuildContext context, dynamic holding) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(holding?.symbol ?? 'Unknown'),
        subtitle: Text(holding?.companyName ?? ''),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${holding?.currentPrice.toStringAsFixed(2) ?? '0.00'}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${holding?.shares.toString() ?? '0'} shares',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Failed to load holdings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
