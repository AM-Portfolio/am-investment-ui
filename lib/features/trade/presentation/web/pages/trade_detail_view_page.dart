import 'package:flutter/material.dart';

import '../../models/trade_holding_view_model.dart';

/// Dedicated page for displaying detailed trade information in a compact single-view layout
class TradeDetailViewPage extends StatelessWidget {
  const TradeDetailViewPage({required this.trade, this.onClose, super.key});

  final TradeHoldingViewModel trade;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final isProfit = trade.isProfit;
    final statusColor = _getStatusColor(trade.status);

    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Column(
        children: [
          // Comprehensive Header with Company Info and Trade Details
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
                  Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
                ],
              ),
              border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
            ),
            child: Column(
              children: [
                // Top Row - Back button, Symbol, Status, P&L
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                  child: Row(
                    children: [
                      // Back button
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onClose,
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.arrow_back_rounded,
                                    size: 18,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Back',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Symbol Badge
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [statusColor.withOpacity(0.15), statusColor.withOpacity(0.05)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: statusColor.withOpacity(0.3), width: 1.5),
                        ),
                        child: Icon(_getStatusIcon(trade.status), color: statusColor, size: 26),
                      ),
                      const SizedBox(width: 16),

                      // Symbol and Company with info icon
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Text(
                                  trade.displaySymbol,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: statusColor.withOpacity(0.4)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(_getStatusIcon(trade.status), size: 12, color: statusColor),
                                      const SizedBox(width: 5),
                                      Text(
                                        trade.displayStatus.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: statusColor,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Company Name
                            Text(
                              trade.displayCompanyName,
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            // Company info badges
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                _buildInfoBadge(
                                  context,
                                  icon: Icons.category_rounded,
                                  label: 'Sector',
                                  value: trade.sector ?? 'N/A',
                                  color: Colors.blue.shade600,
                                ),
                                _buildInfoBadge(
                                  context,
                                  icon: Icons.factory_rounded,
                                  label: 'Industry',
                                  value: trade.industry ?? 'N/A',
                                  color: Colors.purple.shade600,
                                ),
                                _buildInfoBadge(
                                  context,
                                  icon: Icons.currency_exchange_rounded,
                                  label: 'Exchange',
                                  value: trade.exchange ?? 'N/A',
                                  color: Colors.teal.shade600,
                                ),
                                _buildInfoBadge(
                                  context,
                                  icon: Icons.tag_rounded,
                                  label: 'ISIN',
                                  value: trade.isin ?? 'N/A',
                                  color: Colors.orange.shade600,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // P&L Card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isProfit
                                ? [Colors.green.shade400, Colors.green.shade600]
                                : [Colors.red.shade400, Colors.red.shade600],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: (isProfit ? Colors.green : Colors.red).withOpacity(0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isProfit ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  trade.displayProfitLossPercentage,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                Text(
                                  trade.displayProfitLoss,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withOpacity(0.95),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Content - Trade Details + Price, Fees, Performance
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Trade Details Card
                  _buildModernCard(
                    context,
                    icon: Icons.receipt_long_rounded,
                    iconColor: Colors.purple.shade600,
                    title: 'Trade Details',
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                _buildModernInfoRow(context, 'Position', trade.tradePositionType ?? 'N/A'),
                                _buildModernInfoRow(context, 'Quantity', trade.displayQuantity),
                                _buildModernInfoRow(context, 'Executions', '${trade.executionCount}'),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              children: [
                                _buildModernInfoRow(context, 'Average Price', trade.displayAvgPrice),
                                _buildModernInfoRow(context, 'Holding Period', trade.displayHoldingPeriod),
                                _buildModernInfoRow(context, 'Currency', trade.displayCurrency),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Price, Fees, Performance Row
                  // Price, Fees, Performance Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildModernCard(
                          context,
                          icon: Icons.price_change_rounded,
                          iconColor: Colors.indigo.shade600,
                          title: 'Price & Value',
                          children: [
                            _buildModernInfoRow(context, 'Entry Price', trade.displayEntryPrice),
                            _buildModernInfoRow(context, 'Exit Price', trade.displayExitPrice),
                            _buildModernInfoRow(context, 'Average Price', trade.displayAvgPrice),
                            _buildModernInfoRow(context, 'Current Price', trade.displayCurrentPrice),
                            _buildModernInfoRow(context, 'Current Value', trade.displayCurrentValue),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildModernCard(
                          context,
                          icon: Icons.receipt_rounded,
                          iconColor: Colors.orange.shade600,
                          title: 'Fees & Charges',
                          children: [
                            _buildModernInfoRow(context, 'Entry Fees', trade.displayEntryFees),
                            _buildModernInfoRow(context, 'Exit Fees', trade.displayExitFees),
                            const SizedBox(height: 8),
                            Divider(color: Theme.of(context).dividerColor.withOpacity(0.3)),
                            const SizedBox(height: 8),
                            _buildModernInfoRow(context, 'Total Fees', trade.displayTotalFees, isBold: true),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildModernCard(
                          context,
                          icon: Icons.analytics_rounded,
                          iconColor: isProfit ? Colors.green.shade600 : Colors.red.shade600,
                          title: 'Performance Metrics',
                          children: [
                            _buildModernInfoRow(
                              context,
                              'Profit/Loss',
                              trade.displayProfitLoss,
                              valueColor: isProfit ? Colors.green.shade700 : Colors.red.shade700,
                              isBold: true,
                            ),
                            _buildModernInfoRow(context, 'Return on Equity', trade.displayReturnOnEquity),
                            const SizedBox(height: 8),
                            Divider(color: Theme.of(context).dividerColor.withOpacity(0.3)),
                            const SizedBox(height: 8),
                            _buildModernInfoRow(context, 'Risk Amount', trade.displayRiskAmount),
                            _buildModernInfoRow(context, 'Reward Amount', trade.displayRewardAmount),
                            _buildModernInfoRow(context, 'Risk/Reward Ratio', trade.displayRiskRewardRatio),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
        ),
      ],
    ),
  );

  Widget _buildModernCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<Widget> children,
  }) => Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.15)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Modern Card Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [iconColor.withOpacity(0.08), iconColor.withOpacity(0.03)],
            ),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: iconColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),

        // Card Content
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: children),
        ),
      ],
    ),
  );

  Widget _buildModernInfoRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 5,
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontSize: isBold ? 14 : 13,
              color: valueColor ?? Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    ),
  );

  IconData _getStatusIcon(String? status) {
    switch (status?.toUpperCase()) {
      case 'WIN':
        return Icons.check_circle;
      case 'LOSS':
        return Icons.cancel;
      case 'BREAK_EVEN':
        return Icons.remove_circle;
      case 'OPEN':
        return Icons.pending;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'WIN':
        return Colors.green;
      case 'LOSS':
        return Colors.red;
      case 'BREAK_EVEN':
        return Colors.orange;
      case 'OPEN':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
