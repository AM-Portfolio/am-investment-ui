import 'package:flutter/material.dart';

import '../../../models/trade_holding_view_model.dart';
import '../widgets/info_card.dart';
import '../widgets/info_row.dart';

/// Displays basic trade information in a clean, organized layout.
///
/// This is a reusable component that can be used in dialogs, detail pages,
/// or any other context where trade information needs to be displayed.
class TradeInfoSection extends StatelessWidget {
  const TradeInfoSection({required this.holding, super.key});

  final TradeHoldingViewModel holding;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildCompanyInfoCard(context),
        const SizedBox(height: 16),
        _buildTradeDetailsCard(context),
        const SizedBox(height: 16),
        _buildPricingCard(context),
        const SizedBox(height: 16),
        _buildBrokerInfoCard(context),
      ],
    ),
  );

  Widget _buildCompanyInfoCard(BuildContext context) => InfoCard(
    title: 'Company Information',
    icon: Icons.business,
    iconColor: Colors.blue,
    children: [
      InfoRow(label: 'Symbol', value: holding.displaySymbol),
      InfoRow(label: 'Company', value: holding.displayCompanyName),
      InfoRow(label: 'Sector', value: holding.displaySector),
      InfoRow(label: 'Industry', value: holding.displayIndustry),
      InfoRow(label: 'Exchange', value: holding.displayExchange),
    ],
  );

  Widget _buildTradeDetailsCard(BuildContext context) => InfoCard(
    title: 'Trade Details',
    icon: Icons.receipt_long,
    iconColor: Colors.purple,
    children: [
      InfoRow(
        label: 'Status',
        value: holding.displayStatus.toUpperCase(),
        valueColor: _getStatusColor(holding.status),
        isBold: true,
      ),
      InfoRow(label: 'Quantity', value: holding.displayQuantity),
      InfoRow(label: 'Executions', value: '${holding.executionCount}'),
      InfoRow(label: 'Holding Period', value: holding.displayHoldingPeriod),
    ],
  );

  Widget _buildPricingCard(BuildContext context) => InfoCard(
    title: 'Pricing Information',
    icon: Icons.attach_money,
    iconColor: Colors.green,
    children: [
      InfoRow(label: 'Entry Price', value: holding.displayEntryPrice),
      if (holding.exitPrice != null) InfoRow(label: 'Exit Price', value: holding.displayExitPrice),
      InfoRow(label: 'Current Price', value: holding.displayCurrentPrice),
      const Divider(height: 20),
      InfoRow(
        label: 'Profit/Loss',
        value: '${holding.displayProfitLoss} (${holding.displayProfitLossPercentage})',
        valueColor: holding.isProfit ? Colors.green : Colors.red,
        isBold: true,
      ),
    ],
  );

  Widget _buildBrokerInfoCard(BuildContext context) {
    if (holding.broker == null) {
      return const SizedBox.shrink();
    }

    return InfoCard(
      title: 'Additional Information',
      icon: Icons.info_outline,
      iconColor: Colors.orange,
      children: [InfoRow(label: 'Broker', value: holding.broker!)],
    );
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
