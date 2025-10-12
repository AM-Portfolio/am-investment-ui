import 'package:flutter/material.dart';
import '../../../internal/domain/entities/trade_summary.dart';

class TradeSummaryTemplate extends StatelessWidget {
  final TradeSummary summary;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRefresh;
  final bool isWebView;

  const TradeSummaryTemplate({
    super.key,
    required this.summary,
    required this.isLoading,
    this.errorMessage,
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewCards(),
          const SizedBox(height: 24),
          _buildSectorAllocation(),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildTopGainers()),
              const SizedBox(width: 16),
              Expanded(child: _buildTopLosers()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCards() {
    final isPositive = summary.totalGainLoss >= 0;
    final isTodayPositive = summary.todayChange >= 0;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: 'Total Value',
            value: '\$${summary.totalValue.toStringAsFixed(2)}',
            subtitle: '${summary.holdingsCount} holdings',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            title: 'Total P&L',
            value: '${isPositive ? '+' : ''}\$${summary.totalGainLoss.toStringAsFixed(2)}',
            subtitle: '${isPositive ? '+' : ''}${summary.totalGainLossPercentage.toStringAsFixed(2)}%',
            color: isPositive ? Colors.green : Colors.red,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            title: 'Today',
            value: '${isTodayPositive ? '+' : ''}\$${summary.todayChange.toStringAsFixed(2)}',
            subtitle: '${isTodayPositive ? '+' : ''}${summary.todayChangePercentage.toStringAsFixed(2)}%',
            color: isTodayPositive ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectorAllocation() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sector Allocation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...summary.sectorAllocation.map((sector) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          sector.sector,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '${sector.percentage.toStringAsFixed(1)}%',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: sector.percentage / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getSectorColor(sector.sector),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${sector.value.toStringAsFixed(2)} • ${sector.holdingsCount} holdings',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopGainers() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Gainers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (summary.topGainers.isEmpty)
              const Text('No gainers')
            else
              ...summary.topGainers.map((mover) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(mover.symbol),
                  subtitle: Text(mover.name),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '+\$${mover.change.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '+${mover.changePercentage.toStringAsFixed(2)}%',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopLosers() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Losers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (summary.topLosers.isEmpty)
              const Text('No losers')
            else
              ...summary.topLosers.map((mover) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(mover.symbol),
                  subtitle: Text(mover.name),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${mover.change.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${mover.changePercentage.toStringAsFixed(2)}%',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Color _getSectorColor(String sector) {
    final colors = {
      'Healthcare': Colors.blue,
      'Automotive': Colors.orange,
      'Financial Services': Colors.purple,
      'FMCG': Colors.green,
      'Energy': Colors.amber,
      'Technology': Colors.cyan,
      'Materials': Colors.brown,
    };
    return colors[sector] ?? Colors.grey;
  }
}
