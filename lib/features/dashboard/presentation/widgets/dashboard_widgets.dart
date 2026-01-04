import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../trade/providers/trade_internal_providers.dart';

// --- Stat Card ---
// --- Stat Card ---
// DEPRECATED: Use AmStatCard from am_common_ui directly.
// This wrapper exists for migration compatibility.
import 'package:am_common_ui/am_common_ui.dart';

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
    // Map legacy props to new StatType
    StatType type = StatType.neutral;
    if (isPositive == true) type = StatType.positive;
    if (isPositive == false) type = StatType.negative;
    // valueColor typically implies an accent if it's not red/green
    if (valueColor != null && isPositive == null) type = StatType.accent;

    return AmStatCard(
      title: title,
      value: value,
      subtitle: subtitle,
      icon: icon,
      progress: progress,
      type: type,
    );
  }
}

// --- Zella Score Chart (Radar) ---
class ZellaScoreChart extends StatelessWidget {
  const ZellaScoreChart({
    super.key,
    required this.score,
    required this.winRate,
    required this.profitFactor,
    required this.avgWinLoss,
  });

  final double score;
  final double winRate;
  final double profitFactor;
  final double avgWinLoss;

  @override
  Widget build(BuildContext context) {
    // Normalize values for radar chart (0-100 scale)
    // specific normalization logic can be adjusted
    final winRateNormalized = (winRate * 100).clamp(0.0, 100.0);
    final profitFactorNormalized = (profitFactor * 20).clamp(0.0, 100.0); // Assuming PF 5.0 is 100
    final avgWinLossNormalized = (avgWinLoss * 30).clamp(0.0, 100.0); // Assuming Ratio 3.33 is 100

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      color: Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor,
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
                        RadarEntry(value: winRateNormalized), // Win %
                        RadarEntry(value: profitFactorNormalized), // Profit Factor
                        RadarEntry(value: avgWinLossNormalized), // Avg win/loss
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
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Your Zella Score: ',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    TextSpan(
                      text: score.toStringAsFixed(2),
                      style: const TextStyle(
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
    ).animate().fadeIn(duration: 800.ms).scale(curve: Curves.easeOutBack);
  }
}

// --- Net Cumulative P&L Chart (Area) ---
class NetCumulativePnLChart extends StatelessWidget {
  const NetCumulativePnLChart({
    super.key,
    required this.spots,
    required this.dates,
  });

  final List<FlSpot> spots;
  final List<String> dates;

  @override
  Widget build(BuildContext context) {
    if (spots.isEmpty) {
      return const Center(child: Text("No Data"));
    }
    
    // Determine min and max Y for scaling
    final minY = spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    final buffer = (maxY - minY).abs() * 0.1;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      color: Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor,
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
                    horizontalInterval: (maxY - minY) / 5 == 0 ? 1 : (maxY - minY) / 5,
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
                          final index = value.toInt();
                          if (index >= 0 && index < dates.length) {
                             // Only show labels for some points to avoid crowding if needed
                             if (dates.length > 5 && index % (dates.length ~/ 3) != 0) return const SizedBox();
                             return Padding(
                               padding: const EdgeInsets.only(top: 8.0),
                               child: Text(dates[index], style: const TextStyle(color: Colors.grey, fontSize: 10)),
                             );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: (maxY - minY) / 4 == 0 ? 1 : (maxY - minY) / 4,
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
                  maxX: (spots.length - 1).toDouble(),
                  minY: minY - buffer,
                  maxY: maxY + buffer,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
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
    ).animate().fadeIn(duration: 800.ms, delay: 200.ms).scale(curve: Curves.easeOutBack);
  }
}

// --- Net Daily P&L Chart (Bar) ---
class NetDailyPnLChart extends StatelessWidget {
  const NetDailyPnLChart({
    super.key,
    required this.dailyData,
  });

  final List<({String date, double pnl})> dailyData;

  @override
  Widget build(BuildContext context) {
    if (dailyData.isEmpty) {
      return const Center(child: Text("No Data"));
    }

    // Determine Y range
    final minY = dailyData.map((e) => e.pnl).reduce((a, b) => a < b ? a : b);
    final maxY = dailyData.map((e) => e.pnl).reduce((a, b) => a > b ? a : b);
    final absMax = (maxY.abs() > minY.abs() ? maxY.abs() : minY.abs()) * 1.2;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      color: Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor,
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
                  maxY: absMax,
                  minY: -absMax, // To support negative bars if needed, but here we center 0 usually or just use positive/negative
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
                          TextStyle(
                            color: rod.toY >= 0 ? const Color(0xFF00B894) : const Color(0xFFFF7675),
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
                           final index = value.toInt();
                           if (index >= 0 && index < dailyData.length) {
                             if (dailyData.length > 5 && index % (dailyData.length ~/ 3) != 0) return const SizedBox();
                             return Text(dailyData[index].date, style: const TextStyle(color: Colors.grey, fontSize: 10));
                           }
                           return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: absMax / 2 == 0 ? 10 : absMax / 2,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const Text('0', style: TextStyle(color: Colors.grey, fontSize: 10));
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
                    horizontalInterval: absMax / 2 == 0 ? 10 : absMax / 2,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withValues(alpha: 0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: dailyData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: data.pnl,
                          color: data.pnl >= 0 ? const Color(0xFF00B894) : const Color(0xFFFF7675),
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 800.ms, delay: 400.ms).scale(curve: Curves.easeOutBack);
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
      return _buildEmptyState(context, 'Select a portfolio');
    }

    final params = (userId: userId, portfolioId: portfolioId!);
    final holdingsAsync = ref.watch(tradeHoldingsStreamProvider(params));

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      color: Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                _buildTab(context, 'RECENT TRADES', true),
                const SizedBox(width: 20),
                _buildTab(context, 'OPEN POSITIONS', false),
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
                children: recentTrades.asMap().entries.map((entry) {
                  final index = entry.key;
                  final holding = entry.value;
                  // Use formatted date if available, else mock or parse
                  // TradeHoldingViewModel might not have close date directly exposed in a nice format
                  // We'll use displaySymbol and displayProfitLoss
                  return _buildRow(
                    context,
                    '08/15/2023', // Placeholder date as it's not in view model easily
                    holding.displaySymbol,
                    holding.profitLoss ?? 0.0,
                  ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.2, end: 0);
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
    ).animate().fadeIn(duration: 800.ms, delay: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Card(
      elevation: 0,
            shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      color: Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(child: Text(message, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color))),
      ),
    );
  }

  Widget _buildTab(BuildContext context, String title, bool isSelected) {
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

  Widget _buildRow(BuildContext context, String date, String symbol, double pnl) {
    final isPositive = pnl >= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.05))),
      ),
      child: Row(
        children: [
          Expanded(child: Text(date, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13))),
          Expanded(child: Text(symbol, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontWeight: FontWeight.w600, fontSize: 13))),
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
        side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      color: Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor,
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
                    Text(
                      'August 2023',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
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
                _buildDayCell(context, '', null, null),
                _buildDayCell(context, '', null, null),
                _buildDayCell(context, '1', 105, 4),
                _buildDayCell(context, '2', 101, 5),
                _buildDayCell(context, '3', -248, 6),
                _buildDayCell(context, '4', -241, 4),
                _buildDayCell(context, '5', null, null),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCell(BuildContext context, String day, double? pnl, int? trades) {
    Color? bgColor;
    Color textColor = Theme.of(context).textTheme.bodyMedium?.color ?? const Color(0xFF2D3436);
    
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
          color: bgColor ?? Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor,
          border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
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
