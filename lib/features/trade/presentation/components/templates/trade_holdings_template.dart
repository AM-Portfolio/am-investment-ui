import 'package:flutter/material.dart';
import '../../../data/models/trade_holding.dart';
import '../../../data/models/paginated_response.dart';

class TradeHoldingsTemplate extends StatelessWidget {
  final PaginatedResponse<TradeHolding>? holdings;
  final bool isLoading;
  final String? errorMessage;
  final Function(TradeHolding) onTradeSelected;
  final Function(int page)? onPageChanged;
  final bool isWebView;

  const TradeHoldingsTemplate({
    super.key,
    required this.holdings,
    required this.isLoading,
    this.errorMessage,
    required this.onTradeSelected,
    this.onPageChanged,
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
          ],
        ),
      );
    }

    if (holdings == null || holdings!.content.isEmpty) {
      return const Center(child: Text('No holdings found'));
    }

    return Column(
      children: [
        Expanded(
          child: isWebView
              ? _buildTableView()
              : _buildCardView(),
        ),
        if (onPageChanged != null) _buildPagination(),
      ],
    );
  }

  Widget _buildTableView() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Symbol')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Entry Price')),
          DataColumn(label: Text('Exit Price')),
          DataColumn(label: Text('Quantity')),
          DataColumn(label: Text('P&L')),
          DataColumn(label: Text('P&L %')),
        ],
        rows: holdings!.content.map((holding) {
          return DataRow(
            cells: [
              DataCell(Text(holding.instrumentInfo.symbol)),
              DataCell(_buildStatusChip(holding.status)),
              DataCell(Text(holding.entryInfo.price.toStringAsFixed(2))),
              DataCell(Text(holding.exitInfo.price.toStringAsFixed(2))),
              DataCell(Text(holding.entryInfo.quantity.toString())),
              DataCell(
                Text(
                  holding.metrics.profitLoss.toStringAsFixed(2),
                  style: TextStyle(
                    color: holding.metrics.profitLoss >= 0
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ),
              DataCell(
                Text(
                  '${holding.metrics.profitLossPercentage.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: holding.metrics.profitLossPercentage >= 0
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ),
            ],
            onSelectChanged: (_) => onTradeSelected(holding),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCardView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: holdings!.content.length,
      itemBuilder: (context, index) {
        final holding = holdings!.content[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(holding.instrumentInfo.symbol),
            subtitle: Text('${holding.status} • ${holding.tradePositionType}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  holding.metrics.profitLoss.toStringAsFixed(2),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: holding.metrics.profitLoss >= 0
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                Text(
                  '${holding.metrics.profitLossPercentage.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: holding.metrics.profitLossPercentage >= 0
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ],
            ),
            onTap: () => onTradeSelected(holding),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toUpperCase()) {
      case 'WIN':
      case 'WINNING':
        color = Colors.green;
        break;
      case 'LOSS':
      case 'LOSING':
        color = Colors.red;
        break;
      case 'BREAK_EVEN':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        status,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildPagination() {
    if (holdings == null) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: holdings!.first ? null : () => onPageChanged!(holdings!.page - 1),
          ),
          Text('Page ${holdings!.page + 1} of ${holdings!.totalPages}'),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: holdings!.last ? null : () => onPageChanged!(holdings!.page + 1),
          ),
        ],
      ),
    );
  }
}
