import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/trade_holding_view_model.dart';

class TradeHoldingsTemplate extends StatefulWidget {
  const TradeHoldingsTemplate({
    required this.holdings,
    required this.isLoading,
    super.key,
    this.errorMessage,
    this.onHoldingSelected,
    this.onRefresh,
    this.isWebView = true,
  });
  final List<TradeHoldingViewModel> holdings;
  final bool isLoading;
  final String? errorMessage;
  final Function(TradeHoldingViewModel)? onHoldingSelected;
  final VoidCallback? onRefresh;
  final bool isWebView;

  @override
  State<TradeHoldingsTemplate> createState() => _TradeHoldingsTemplateState();
}

class _TradeHoldingsTemplateState extends State<TradeHoldingsTemplate> {
  final Set<String> _expandedItems = {};

  void _toggleExpanded(String tradeId) {
    setState(() {
      if (_expandedItems.contains(tradeId)) {
        _expandedItems.remove(tradeId);
      } else {
        _expandedItems.add(tradeId);
      }
    });
  }

  bool _isExpanded(String tradeId) => _expandedItems.contains(tradeId);

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(widget.errorMessage!, style: const TextStyle(color: Colors.red)),
            if (widget.onRefresh != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(onPressed: widget.onRefresh, child: const Text('Retry')),
            ],
          ],
        ),
      );
    }

    if (widget.holdings.isEmpty) {
      return const Center(child: Text('No holdings found'));
    }

    return widget.isWebView ? _buildTableView() : _buildCardView();
  }

  Widget _buildTableView() => SingleChildScrollView(
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
        rows: widget.holdings.map((holding) {
          final isPositive = holding.isProfit;

          return DataRow(
            cells: [
              DataCell(Text(holding.displaySymbol, style: const TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Text(holding.displayCompanyName)),
              DataCell(Text(holding.displayStatus)),
              DataCell(Text(holding.displayQuantity)),
              DataCell(Text(holding.displayEntryPrice)),
              DataCell(Text(holding.displayCurrentPrice)),
              DataCell(Text(holding.displayCurrentValue)),
              DataCell(
                Text(
                  holding.displayProfitLoss,
                  style: TextStyle(color: isPositive ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(
                Text(
                  holding.displayProfitLossPercentage,
                  style: TextStyle(color: isPositive ? Colors.green : Colors.red),
                ),
              ),
              DataCell(Text(holding.displayRiskRewardRatio)),
            ],
            onSelectChanged: widget.onHoldingSelected != null ? (_) => widget.onHoldingSelected!(holding) : null,
          );
        }).toList(),
      ),
    ),
  );

  Widget _buildCardView() => ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: widget.holdings.length,
    itemBuilder: (context, index) {
      final holding = widget.holdings[index];
      final isPositive = holding.isProfit;
      final pnlColor = isPositive ? Colors.green : Colors.red;
      final isExpanded = _isExpanded(holding.tradeId);

      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: () => _toggleExpanded(holding.tradeId),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Top Row - Matches Portfolio Holdings Pattern
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left Section - Icon + Symbol/Name
                    Row(
                      children: [
                        // Symbol Icon (similar to portfolio)
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: pnlColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Center(
                            child: Text(
                              holding.displaySymbol.length >= 2
                                  ? holding.displaySymbol.substring(0, 2).toUpperCase()
                                  : holding.displaySymbol.toUpperCase(),
                              style: TextStyle(
                                color: pnlColor.withOpacity(0.8),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Symbol and Company Name
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              holding.displaySymbol,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              holding.displayCompanyName,
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Right Section - Current Value
                    Text(
                      holding.displayCurrentValue,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Bottom Row - Investment Details & Performance (matches portfolio pattern)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left - Investment Details
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Entry Price (like "Inv." in portfolio)
                        Row(
                          children: [
                            Text('Entry ', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                            Text(
                              holding.displayEntryPrice,
                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        // Current Price & Quantity (like Avg price and quantity in portfolio)
                        Row(
                          children: [
                            Icon(isPositive ? Icons.trending_up : Icons.trending_down, color: pnlColor, size: 12),
                            const SizedBox(width: 2),
                            Text(
                              'Current ${holding.displayCurrentPrice}',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.inventory_2_outlined, color: Colors.grey.shade600, size: 12),
                            const SizedBox(width: 2),
                            Text(holding.displayQuantity, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    // Right - Performance (matches portfolio pattern)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // P&L Amount
                        Text(
                          holding.displayProfitLoss,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: pnlColor),
                        ),
                        const SizedBox(height: 2),
                        // P&L Percentage
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: pnlColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            holding.displayProfitLossPercentage,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: pnlColor),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Expanded Details - Trade-specific information
                if (isExpanded) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  // Entry & Exit Details
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailRow(
                          icon: Icons.login,
                          label: 'Entry',
                          value: holding.displayEntryPrice,
                          subValue: holding.entryTimestamp != null
                              ? DateFormat('MMM dd, yyyy').format(holding.entryTimestamp!)
                              : null,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildDetailRow(
                          icon: Icons.logout,
                          label: 'Exit',
                          value: holding.displayExitPrice,
                          subValue: holding.exitTimestamp != null
                              ? DateFormat('MMM dd, yyyy').format(holding.exitTimestamp!)
                              : holding.displayStatus == 'ACTIVE'
                              ? 'Active'
                              : null,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Period & R:R
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailRow(
                          icon: Icons.access_time,
                          label: 'Period',
                          value: holding.displayHoldingPeriod,
                          color: Colors.purple,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildDetailRow(
                          icon: Icons.balance,
                          label: 'R:R',
                          value: holding.displayRiskRewardRatio,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                  // Info Chips
                  if (holding.sector != null || holding.broker != null) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (holding.sector != null) _buildChip(holding.displaySector, Icons.category, Colors.blue),
                        if (holding.broker != null) _buildChip(holding.broker!, Icons.account_balance, Colors.green),
                        if (holding.displayStatus != 'Unknown')
                          _buildChip(
                            holding.displayStatus,
                            Icons.flag,
                            holding.displayStatus == 'ACTIVE' ? Colors.green : Colors.grey,
                          ),
                      ],
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      );
    },
  );

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    String? subValue,
  }) => Container(
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.05),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 9, color: Colors.grey[700], fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        if (subValue != null) ...[
          const SizedBox(height: 1),
          Text(subValue, style: TextStyle(fontSize: 8, color: Colors.grey[600])),
        ],
      ],
    ),
  );

  Widget _buildChip(String label, IconData icon, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 9, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: color),
        ),
      ],
    ),
  );
}
