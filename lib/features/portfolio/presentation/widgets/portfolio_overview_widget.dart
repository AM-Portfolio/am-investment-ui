import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/portfolio_cubit.dart';
import '../cubit/portfolio_state.dart';

/// Portfolio overview widget showing summary and key metrics
class PortfolioOverviewWidget extends StatelessWidget {
  const PortfolioOverviewWidget({required this.userId, super.key});
  final String userId;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<PortfolioCubit, PortfolioState>(
        builder: (context, state) {
          if (state is PortfolioLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PortfolioError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<PortfolioCubit>().loadPortfolio(userId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is PortfolioLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Portfolio Overview',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  _buildSummaryCards(context, state.summary),
                  const SizedBox(height: 24),
                  _buildPerformanceSection(context, state.summary),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      );

  Widget _buildSummaryCards(BuildContext context, summary) => GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: 2,
    childAspectRatio: 1.5,
    children: [
      _buildSummaryCard(
        'Total Value',
        '\$${summary.totalValue.toStringAsFixed(2)}',
        Icons.account_balance_wallet,
        Colors.blue,
      ),
      _buildSummaryCard(
        'Today Change',
        '\$${summary.todayChange.toStringAsFixed(2)}',
        Icons.trending_up,
        summary.todayChange >= 0 ? Colors.green : Colors.red,
      ),
      _buildSummaryCard(
        'Total P&L',
        '\$${summary.totalGainLoss.toStringAsFixed(2)}',
        Icons.show_chart,
        summary.totalGainLoss >= 0 ? Colors.green : Colors.red,
      ),
      _buildSummaryCard(
        'Holdings',
        '${summary.totalHoldings}',
        Icons.pie_chart,
        Colors.orange,
      ),
    ],
  );

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );

  Widget _buildPerformanceSection(BuildContext context, summary) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Performance', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: _buildPerformanceCard(
              'Today',
              '${summary.todayChangePercentage.toStringAsFixed(2)}%',
              summary.todayChangePercentage >= 0 ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildPerformanceCard(
              'Total',
              '${summary.totalGainLossPercentage.toStringAsFixed(2)}%',
              summary.totalGainLossPercentage >= 0 ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    ],
  );

  Widget _buildPerformanceCard(String title, String percentage, Color color) =>
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                percentage,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      );
}
