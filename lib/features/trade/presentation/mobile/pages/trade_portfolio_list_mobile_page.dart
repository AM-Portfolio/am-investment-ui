import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/utils/logger.dart';
import '../../../providers/trade_internal_providers.dart';

/// Mobile page for trade portfolio list using Riverpod streams
class TradePortfolioListMobilePage extends ConsumerWidget {
  const TradePortfolioListMobilePage({
    required this.userId,
    super.key,
  });

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfoliosStream = ref.watch(
      tradePortfoliosStreamProvider(userId),
    );

    return portfoliosStream.when(
      data: (portfolios) {
        if (portfolios.isEmpty) {
          return const Center(
            child: Text('No trade portfolios available'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            AppLogger.userAction(
              'Pull to Refresh Trade Portfolios',
              tag: 'TradePortfolioListMobile',
              context: {'userId': userId},
            );
            ref.invalidate(
              tradePortfoliosStreamProvider(userId),
            );
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: portfolios.length,
            itemBuilder: (context, index) {
              final portfolio = portfolios[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      portfolio.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    portfolio.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('ID: ${portfolio.id}'),
                      if (portfolio.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          portfolio.description!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    AppLogger.userAction(
                      'Navigate to Trade Holdings',
                      tag: 'TradePortfolioListMobile',
                      context: {
                        'portfolioId': portfolio.id,
                        'portfolioName': portfolio.name,
                      },
                    );
                    Navigator.pushNamed(
                      context,
                      '/trade/holdings/${portfolio.id}',
                      arguments: {
                        'userId': userId,
                        'portfolioName': portfolio.name,
                      },
                    );
                  },
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(
                  tradePortfoliosStreamProvider(userId),
                );
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
