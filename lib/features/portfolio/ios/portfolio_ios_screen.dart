import 'package:flutter/material.dart';
import '../../../core/domain/entities/portfolio/portfolio_summary.dart';

class PortfolioIOSScreen extends StatelessWidget {
  final Future<PortfolioSummary> portfolioSummaryFuture;
  final Future<void> Function() refreshPortfolio;
  final String userId;

  const PortfolioIOSScreen({
    super.key,
    required this.portfolioSummaryFuture,
    required this.refreshPortfolio,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio - iOS'),
      ),
      body: FutureBuilder<PortfolioSummary>(
        future: portfolioSummaryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          final summary = snapshot.data;
          if (summary == null) {
            return const Center(child: Text('No data available'));
          }
          
          return const Center(
            child: Text('iOS Portfolio View - Implementation needed'),
          );
        },
      ),
    );
  }
}