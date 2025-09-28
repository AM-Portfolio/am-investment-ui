import 'package:flutter/material.dart';

/// Document types for import
enum DocumentType {
  brokerPortfolio('Broker Portfolio', Icons.account_balance, 'Import your complete portfolio from broker statements'),
  mutualFund('Mutual Fund', Icons.trending_up, 'Import mutual fund holdings and transactions'),
  npsStatement('NPS Statement', Icons.savings, 'Import National Pension System statements'),
  companyFinancialReport('Company Financial Report', Icons.business, 'Import company financial reports and analysis'),
  stockPortfolio('Stock Portfolio', Icons.show_chart, 'Import individual stock holdings and transactions'),
  nseIndices('NSE Indices', Icons.bar_chart, 'Import NSE index data and performance'),
  tradeFno('F&O Trades', Icons.swap_horiz, 'Import Futures & Options trading data'),
  tradeEq('Equity Trades', Icons.monetization_on, 'Import equity trading transactions');

  const DocumentType(this.label, this.icon, this.description);
  final String label;
  final IconData icon;
  final String description;
}