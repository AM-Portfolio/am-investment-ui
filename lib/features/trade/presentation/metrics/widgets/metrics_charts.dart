import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TradesByDayBarChart extends StatelessWidget {
  final Map<String, int> tradesByDay;

  const TradesByDayBarChart({super.key, required this.tradesByDay});

  @override
  Widget build(BuildContext context) {
    // Sort days chronologically if needed, or just map them
    // Assuming keys are like MONDAY, TUESDAY, etc.
    final days = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'];
    
    // Find max value for Y-axis
    int maxY = 0;
    if (tradesByDay.isNotEmpty) {
      maxY = tradesByDay.values.reduce((curr, next) => curr > next ? curr : next);
    }
    // Add some buffer
    maxY = (maxY * 1.2).ceil();
    if (maxY == 0) maxY = 5;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceBetween, // Use spaceBetween for better spread
        maxY: maxY.toDouble(),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${days[group.x.toInt()].substring(0, 3)}: ${rod.toY.toInt()}',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final index = value.toInt();
                if (index < 0 || index >= days.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    days[index].substring(0, 1), // M, T, W...
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.white.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(days.length, (index) {
          final count = tradesByDay[days[index]] ?? 0;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: count.toDouble(),
                color: Colors.blueAccent,
                width: 32, // Increased width for density
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY.toDouble(),
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class DistributionPieChart extends StatelessWidget {
  final Map<String, int> data;
  final bool animate;

  const DistributionPieChart({super.key, required this.data, this.animate = true});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text("No Data"));
    }

    final List<Color> colors = [
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.green,
      Colors.red,
      Colors.teal,
      Colors.pink,
    ];

    int colorIndex = 0;
    final sections = data.entries.map((e) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      
      return PieChartSectionData(
        color: color,
        value: e.value.toDouble(),
        title: '${e.key}\n${e.value}',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: sections,
        pieTouchData: PieTouchData(enabled: true),
      ),
      swapAnimationDuration: const Duration(milliseconds: 800),
      swapAnimationCurve: Curves.easeInOutQuad,
    );
  }
}

class ConsistencyGauge extends StatelessWidget {
  final double score; // 0 to 100

  const ConsistencyGauge({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PieChart(
          PieChartData(
            startDegreeOffset: 180,
            sectionsSpace: 0,
            centerSpaceRadius: 60,
            sections: [
              PieChartSectionData(
                color: _getColorForScore(score),
                value: score,
                title: '',
                radius: 15,
              ),
              PieChartSectionData(
                color: Colors.grey.withOpacity(0.2),
                value: 100 - score,
                title: '',
                radius: 15,
              ),
              PieChartSectionData(
                color: Colors.transparent,
                value: 100, // Bottom half hidden
                title: '',
                radius: 15,
              ),
            ],
          ),
        ),
        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${score.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getColorForScore(score),
                ),
              ),
              Text(
                'Score',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 10), // Adjust for the gauge being top-half
            ],
          ),
        ),
      ],
    );
  }

  Color _getColorForScore(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }
}
