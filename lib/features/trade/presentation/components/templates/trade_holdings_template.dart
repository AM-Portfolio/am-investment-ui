import 'package:flutter/material.dart';
import '../../../internal/domain/entities/trade_holding.dart';

class TradeHoldingsTemplate extends StatelessWidget {
  final List<TradeHolding> holdings;
  final bool isLoading;
  final String? errorMessage;
  final Function(TradeHolding)? onHoldingSelected;
  final VoidCallback? onRefresh;
  final bool isWebView;

  const TradeHoldingsTemplate({
    super.key,
    required this.holdings,
    required this.isLoading,
    this.errorMessage,
    this.onHoldingSelected,
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

    if (holdings.isEmpty) {
      return const Center(child: Text('No holdings found'));
    }

    return isWebView
        ? _buildTableView()
        : _buildCardView();
  }

  Widget _buildTableView() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Symbol')),
            DataColumn(label: Text('Company')),
            DataColumn(label: Text('Quantity')),
            DataColumn(label: Text('Avg Price')),
            DataColumn(label: Text('Current Price')),
            DataColumn(label: Text('Current Value')),
            DataColumn(label: Text('P&L')),
            DataColumn(label: Text('P&L %')),
            DataColumn(label: Text('Today')),
          ],
          rows: holdings.map((holding) {
            final isPositive = holding.totalGainLoss >= 0;
            final isTodayPositive = holding.todayChange >= 0;
            
            return DataRow(
              cells: [
                DataCell(Text(
                  holding.symbol,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )),
                DataCell(Text(holding.companyName)),
                DataCell(Text(holding.quantity.toStringAsFixed(0))),
                DataCell(Text('\$${holding.avgPrice.toStringAsFixed(2)}')),
                DataCell(Text('\$${holding.currentPrice.toStringAsFixed(2)}')),
                DataCell(Text('\$${holding.currentValue.toStringAsFixed(2)}')),
                DataCell(
                  Text(
                    '${isPositive ? '+' : ''}\$${holding.totalGainLoss.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: isPositive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    '${isPositive ? '+' : ''}${holding.totalGainLossPercentage.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    '${isTodayPositive ? '+' : ''}${holding.todayChangePercentage.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: isTodayPositive ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
              onSelectChanged: onHoldingSelected != null 
                  ? (_) => onHoldingSelected!(holding)
                  : null,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCardView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: holdings.length,
      itemBuilder: (context, index) {
        final holding = holdings[index];
        final isPositive = holding.totalGainLoss >= 0;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              holding.symbol,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(holding.companyName),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('${holding.quantity.toStringAsFixed(0)} @ \$${holding.currentPrice.toStringAsFixed(2)}'),
                    const SizedBox(width: 16),
                    if (holding.sector != null)
                      Chip(
                        label: Text(
                          holding.sector!,
                          style: const TextStyle(fontSize: 10),
                        ),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                  ],
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isPositive ? '+' : ''}\$${holding.totalGainLoss.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                ),
                Text(
                  '${isPositive ? '+' : ''}${holding.totalGainLossPercentage.toStringAsFixed(2)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            onTap: onHoldingSelected != null 
                ? () => onHoldingSelected!(holding)
                : null,
          ),
        );
      },
    );
  }
}
