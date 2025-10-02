import 'package:flutter/material.dart';

/// Broker options
enum BrokerType {
  zerodha('Zerodha', 'images/brokers/zerodha.svg', Color(0xFF387ADF)),
  angelBroking('Angel Broking', 'images/brokers/angel.svg', Color(0xFFE31E24)),
  upstox('Upstox', 'images/brokers/upstox.svg', Color(0xFF6C63FF)),
  iciciDirect('ICICI Direct', 'images/brokers/icici.svg', Color(0xFFFF6900)),
  hdfcSecurities('HDFC Securities', 'images/brokers/hdfc.svg', Color(0xFF004C8F)),
  kotakSecurities('Kotak Securities', 'images/brokers/kotak.svg', Color(0xFFED1C24)),
  sbicap('SBI Cap Securities', 'images/brokers/sbi.svg', Color(0xFF1C4B9C)),
  sharekhan('Sharekhan', 'images/brokers/sharekhan.svg', Color(0xFF0066CC)),
  motilalOswal('Motilal Oswal', 'images/brokers/motilal.svg', Color(0xFFE31E24)),
  edelweiss('Edelweiss', 'images/brokers/edelweiss.svg', Color(0xFF1B5E20)),
  fyers('Fyers', 'images/brokers/fyers.svg', Color(0xFF2196F3)),
  aliceBlue('Alice Blue', 'images/brokers/alice.svg', Color(0xFF4CAF50)),
  other('Other', null, Color(0xFF9E9E9E));

  const BrokerType(this.label, this.logoPath, this.color);
  final String label;
  final String? logoPath;
  final Color color;

  /// Get appropriate icon for broker when logo is not available
  IconData get fallbackIcon {
    switch (label.toLowerCase()) {
      case 'zerodha':
        return Icons.trending_up;
      case 'angel one':
      case 'angel':
        return Icons.star;
      case 'upstox':
        return Icons.show_chart;
      case 'icici direct':
      case 'icici':
        return Icons.account_balance;
      case 'hdfc securities':
      case 'hdfc':
        return Icons.business;
      case 'kotak securities':
      case 'kotak':
        return Icons.monetization_on;
      case 'sbi securities':
      case 'sbi':
        return Icons.corporate_fare;
      case 'sharekhan':
        return Icons.pie_chart;
      case 'motilal oswal':
      case 'motilal':
        return Icons.analytics;
      case 'edelweiss':
        return Icons.diamond;
      case 'fyers':
        return Icons.rocket_launch;
      case 'alice blue':
      case 'alice':
        return Icons.insights;
      default:
        return Icons.business;
    }
  }
}