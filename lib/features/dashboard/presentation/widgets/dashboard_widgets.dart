import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../trade/providers/trade_internal_providers.dart';

// --- Stat Card ---
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.valueColor,
    this.icon,
    this.progress,
    this.isPositive,
  });

  final String title;
  final String value;
  final String? subtitle;
  final Color? valueColor;
  final IconData? icon;
  final double? progress; // 0.0 to 1.0
  final bool? isPositive;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.info_outline, size: 14, color: Colors.grey[300]),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: valueColor ?? const Color(0xFF1A1B25),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                if (icon != null)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (valueColor ?? const Color(0xFF6C5DD3)).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: valueColor ?? const Color(0xFF6C5DD3),
                    ),
                  ),
              ],
            ),
            if (subtitle != null || progress != null) ...[
              const SizedBox(height: 16),
              if (progress != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[100],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        (isPositive ?? true) ? const Color(0xFF00B894) : const Color(0xFFFF7675),
                      ),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ),
              if (subtitle != null)
                Padding(
                  padding: EdgeInsets.only(top: progress != null ? 8 : 0),
                  child: Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: (isPositive == true)
                          ? const Color(0xFF00B894)
                          : (isPositive == false)
                              ? const Color(0xFFFF7675)
                              : Colors.grey[500],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

// --- Zella Score Chart (Radar) ---
class ZellaScoreChart extends StatelessWidget {
  const ZellaScoreChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Zella Score',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.info_outline, size: 16, color: Colors.grey[400]),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEAA7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'BETA',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD35400),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: RadarChart(
                RadarChartData(
                  dataSets: [
                    RadarDataSet(
                      fillColor: const Color(0xFF6C5DD3).withValues(alpha: 0.2),
                      borderColor: const Color(0xFF6C5DD3),
                      entryRadius: 2,
                      dataEntries: [
                        const RadarEntry(value: 80), // Win %
                        const RadarEntry(value: 60), // Profit Factor
                        const RadarEntry(value: 70), // Avg win/loss
                      ],
                    ),
                  ],
                  radarBackgroundColor: Colors.transparent,
                  borderData: FlBorderData(show: false),
                  radarBorderData: const BorderSide(color: Colors.transparent),
                  titlePositionPercentageOffset: 0.2,
                  titleTextStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                  gridBorderData: BorderSide(color: Colors.grey.withValues(alpha: 0.1), width: 1),
                  getTitle: (index, angle) {
                    switch (index) {
                      case 0:
                        return const RadarChartTitle(text: 'Win %');
                      case 1:
                        return const RadarChartTitle(text: 'Profit factor');
                      case 2:
                        return const RadarChartTitle(text: 'Avg win/loss');
                      default:
                        return const RadarChartTitle(text: '');
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Your Zella Score: ',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    TextSpan(
                      text: '60.95',
                      style: TextStyle(
                        color: Color(0xFF00B894),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Net Cumulative P&L Chart (Area) ---
class NetCumulativePnLChart extends StatelessWidget {
  const NetCumulativePnLChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Daily Net Cumulative P&L',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.info_outline, size: 16, color: Colors.grey[400]),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withValues(alpha: 0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text('08/13/23', style: TextStyle(color: Colors.grey, fontSize: 10));
                            case 1:
                              return const Text('08/14/23', style: TextStyle(color: Colors.grey, fontSize: 10));
                            case 2:
                              return const Text('08/15/23', style: TextStyle(color: Colors.grey, fontSize: 10));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${value.toInt()}',
                            style: const TextStyle(color: Colors.grey, fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 2,
                  minY: 0,
                  maxY: 140,
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 0),
                        FlSpot(1, 130),
                        FlSpot(2, 135),
                      ],
                      isCurved: true,
                      color: const Color(0xFF6C5DD3),
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6C5DD3).withValues(alpha: 0.3),
                            const Color(0xFF6C5DD3).withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Net Daily P&L Chart (Bar) ---
class NetDailyPnLChart extends StatelessWidget {
  const NetDailyPnLChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Net Daily P&L',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.info_outline, size: 16, color: Colors.grey[400]),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 140,
                  barTouchData: BarTouchData(
                    enabled: false,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => Colors.transparent,
                      tooltipPadding: EdgeInsets.zero,
                      tooltipMargin: 8,
                      getTooltipItem: (
                        BarChartGroupData group,
                        int groupIndex,
                        BarChartRodData rod,
                        int rodIndex,
                      ) {
                        return BarTooltipItem(
                          rod.toY.round().toString(),
                          const TextStyle(
                            color: Colors.cyan,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text('08/14/23', style: TextStyle(color: Colors.grey, fontSize: 10));
                            case 1:
                              return const Text('08/15/23', style: TextStyle(color: Colors.grey, fontSize: 10));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 20,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${value.toInt()}',
                            style: const TextStyle(color: Colors.grey, fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withValues(alpha: 0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: 130,
                          color: const Color(0xFF00B894),
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: 5,
                          color: const Color(0xFF00B894),
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Recent Trades Widget ---
class RecentTradesWidget extends ConsumerWidget {
  const RecentTradesWidget({
    super.key,
    required this.userId,
    this.portfolioId,
  });

  final String userId;
  final String? portfolioId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (portfolioId == null) {
      return _buildEmptyState('Select a portfolio');
    }

    final params = (userId: userId, portfolioId: portfolioId!);
    final holdingsAsync = ref.watch(tradeHoldingsStreamProvider(params));

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                _buildTab('RECENT TRADES', true),
                const SizedBox(width: 20),
                _buildTab('OPEN POSITIONS', false),
              ],
            ),
          ),
          const Divider(height: 1),
          // Table Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Expanded(child: Text('Close Date', style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w600))),
                Expanded(child: Text('Symbol', style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w600))),
                Expanded(child: Text('Net P&L', style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
              ],
            ),
          ),
          const Divider(height: 1),
          // Table Rows
          holdingsAsync.when(
            data: (tradeHoldings) {
              final holdings = tradeHoldings.holdings;
              if (holdings.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(child: Text('No trades found')),
                );
              }
              // Show last 5 trades
              final recentTrades = holdings.take(5).toList();
              return Column(
                children: recentTrades.map((holding) {
                  // Use formatted date if available, else mock or parse
                  // TradeHoldingViewModel might not have close date directly exposed in a nice format
                  // We'll use displaySymbol and displayProfitLoss
                  return _buildRow(
                    '08/15/2023', // Placeholder date as it's not in view model easily
                    holding.displaySymbol,
                    holding.profitLoss ?? 0.0,
                  );
                }).toList(),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(child: Text(message)),
      ),
    );
  }

  Widget _buildTab(String title, bool isSelected) {
    return Container(
      padding: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isSelected ? const Color(0xFF6C5DD3) : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? const Color(0xFF6C5DD3) : Colors.grey[500],
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildRow(String date, String symbol, double pnl) {
    final isPositive = pnl >= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.05))),
      ),
      child: Row(
        children: [
          Expanded(child: Text(date, style: const TextStyle(color: Color(0xFF2D3436), fontSize: 13))),
          Expanded(child: Text(symbol, style: const TextStyle(color: Color(0xFF2D3436), fontWeight: FontWeight.w600, fontSize: 13))),
          Expanded(
            child: Text(
              '\$${pnl.toStringAsFixed(2)}',
              style: TextStyle(
                color: isPositive ? const Color(0xFF00B894) : const Color(0xFFFF7675),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Calendar Widget ---
class CalendarWidget extends StatelessWidget {
  const CalendarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.chevron_left, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'TODAY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                    const SizedBox(width: 16),
                    const Text(
                      'August 2023',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                  ],
                ),
                Icon(Icons.info_outline, size: 16, color: Colors.grey[400]),
              ],
            ),
            const SizedBox(height: 20),
            // Calendar Grid Header
            Row(
              children: const [
                Expanded(child: Center(child: Text('Sun', style: TextStyle(color: Colors.grey, fontSize: 12)))),
                Expanded(child: Center(child: Text('Mon', style: TextStyle(color: Colors.grey, fontSize: 12)))),
                Expanded(child: Center(child: Text('Tue', style: TextStyle(color: Colors.grey, fontSize: 12)))),
                Expanded(child: Center(child: Text('Wed', style: TextStyle(color: Colors.grey, fontSize: 12)))),
                Expanded(child: Center(child: Text('Thu', style: TextStyle(color: Colors.grey, fontSize: 12)))),
                Expanded(child: Center(child: Text('Fri', style: TextStyle(color: Colors.grey, fontSize: 12)))),
                Expanded(child: Center(child: Text('Sat', style: TextStyle(color: Colors.grey, fontSize: 12)))),
              ],
            ),
            const SizedBox(height: 12),
            // Calendar Grid Row (Sample)
            Row(
              children: [
                _buildDayCell('', null, null),
                _buildDayCell('', null, null),
                _buildDayCell('1', 105, 4),
                _buildDayCell('2', 101, 5),
                _buildDayCell('3', -248, 6),
                _buildDayCell('4', -241, 4),
                _buildDayCell('5', null, null),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCell(String day, double? pnl, int? trades) {
    Color? bgColor;
    Color textColor = const Color(0xFF2D3436);
    
    if (pnl != null) {
      if (pnl > 0) {
        bgColor = const Color(0xFF00B894).withValues(alpha: 0.15);
        textColor = const Color(0xFF00B894);
      } else {
        bgColor = const Color(0xFFFF7675).withValues(alpha: 0.15);
        textColor = const Color(0xFFFF7675);
      }
    }

    return Expanded(
      child: Container(
        height: 80,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: bgColor ?? Colors.white,
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
            if (pnl != null) ...[
              const Spacer(),
              Center(
                child: Text(
                  '\$${pnl.abs().toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontSize: 13,
                  ),
                ),
              ),
              Center(
                child: Text(
                  '$trades trades',
                  style: TextStyle(
                    fontSize: 10,
                    color: textColor.withValues(alpha: 0.8),
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],
          ],
        ),
      ),
    );
  }
}
