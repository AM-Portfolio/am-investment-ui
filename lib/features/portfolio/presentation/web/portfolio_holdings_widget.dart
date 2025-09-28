import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../di/app_providers.dart';

/// Widget for displaying portfolio holdings
class PortfolioHoldingsWidget extends ConsumerWidget {
  final String userId;
  final EdgeInsets padding;

  const PortfolioHoldingsWidget({
    super.key,
    required this.userId,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holdingsAsync = ref.watch(portfolioHoldingsProvider(userId));
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 1200;

    return Padding(
      padding: padding,
      child: holdingsAsync.when(
        data: (portfolioHoldings) => _buildHoldingsTable(context, portfolioHoldings.holdings ?? [], isWideScreen),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading holdings',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                '$error',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(portfolioHoldingsProvider(userId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHoldingsTable(BuildContext context, List<dynamic> holdings, bool isWideScreen) {
    if (holdings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: Theme.of(context).primaryColor.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'No Holdings Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Start investing to see your portfolio holdings here.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: isWideScreen ? 1000 : double.infinity,
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width - 32,
            ),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              columns: _buildColumns(context),
              rows: holdings.map((holding) => _buildDataRow(context, holding)).toList(),
            ),
          ),
        ),
      ),
    );
  }

  List<DataColumn> _buildColumns(BuildContext context) {
    return [
      const DataColumn(
        label: Text('Symbol', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      const DataColumn(
        label: Text('Company', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      const DataColumn(
        label: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold)),
        numeric: true,
      ),
      const DataColumn(
        label: Text('Avg Price', style: TextStyle(fontWeight: FontWeight.bold)),
        numeric: true,
      ),
      const DataColumn(
        label: Text('Current Price', style: TextStyle(fontWeight: FontWeight.bold)),
        numeric: true,
      ),
      const DataColumn(
        label: Text('Market Value', style: TextStyle(fontWeight: FontWeight.bold)),
        numeric: true,
      ),
      const DataColumn(
        label: Text('P&L', style: TextStyle(fontWeight: FontWeight.bold)),
        numeric: true,
      ),
      const DataColumn(
        label: Text('P&L %', style: TextStyle(fontWeight: FontWeight.bold)),
        numeric: true,
      ),
    ];
  }

  DataRow _buildDataRow(BuildContext context, dynamic holding) {
    final pnl = holding.performance.totalGainLoss;
    final pnlPercentage = holding.performance.totalGainLossPercentage;
    final pnlColor = pnl >= 0 ? Colors.green : Colors.red;

    return DataRow(
      cells: [
        DataCell(
          Text(
            holding.symbol ?? '',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        DataCell(
          Text(
            holding.companyName ?? '',
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DataCell(
          Text('${holding.shares.toStringAsFixed(0)}'),
        ),
        DataCell(
          Text('₹${(holding.investedAmount / holding.shares).toStringAsFixed(2)}'),
        ),
        DataCell(
          Text('₹${holding.currentPrice.toStringAsFixed(2)}'),
        ),
        DataCell(
          Text('₹${holding.currentValue.toStringAsFixed(2)}'),
        ),
        DataCell(
          Text(
            '₹${pnl.toStringAsFixed(2)}',
            style: TextStyle(
              color: pnlColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: pnlColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${pnlPercentage.toStringAsFixed(2)}%',
              style: TextStyle(
                color: pnlColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
