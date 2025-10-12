import 'package:flutter/material.dart';
import '../../models/trade_holding_view_model.dart';

class TradeHoldingsTemplate extends StatelessWidget {
  final List<TradeHoldingViewModel> holdings;
  final bool isLoading;
  final String? errorMessage;
  final Function(TradeHoldingViewModel)? onHoldingSelected;
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
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Quantity')),
            DataColumn(label: Text('Entry Price')),
            DataColumn(label: Text('Current Price')),
            DataColumn(label: Text('Current Value')),
            DataColumn(label: Text('P&L')),
            DataColumn(label: Text('P&L %')),
            DataColumn(label: Text('R:R Ratio')),
          ],
          rows: holdings.map((holding) {
            final isPositive = holding.isProfit;
            
            return DataRow(
              cells: [
                DataCell(Text(
                  holding.displaySymbol,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )),
                DataCell(Text(holding.displayCompanyName)),
                DataCell(Text(holding.displayStatus)),
                DataCell(Text(holding.displayQuantity)),
                DataCell(Text(holding.displayEntryPrice)),
                DataCell(Text(holding.displayCurrentPrice)),
                DataCell(Text(holding.displayCurrentValue)),
                DataCell(
                  Text(
                    holding.displayProfitLoss,
                    style: TextStyle(
                      color: isPositive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    holding.displayProfitLossPercentage,
                    style: TextStyle(
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                  ),
                ),
                DataCell(Text(holding.displayRiskRewardRatio)),
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
        final isPositive = holding.isProfit;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              holding.displaySymbol,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(holding.displayCompanyName),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('${holding.displayQuantity} @ ${holding.displayCurrentPrice}'),
                    const SizedBox(width: 16),
                    Chip(
                      label: Text(
                        holding.displaySector,
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
                  holding.displayProfitLoss,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                ),
                Text(
                  holding.displayProfitLossPercentage,
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
