import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../metrics/widgets/glossy_card.dart';
import '../models/chart_config.dart';
import '../../../internal/domain/entities/report/timing_analysis.dart';
import '../../../internal/domain/entities/report/daily_performance.dart';
import '../utils/chart_aggregator.dart';
import '../../../internal/domain/entities/report/report_performance_metrics.dart';

class DynamicChartCard extends StatefulWidget {
  final String title;
  final TimingAnalysis timingAnalysis;
  final List<DailyPerformance> dailyPerformance;
  final ChartMetric initialMetric;
  final ChartTimeFrame initialTimeFrame;
  final bool isBarChart;

  const DynamicChartCard({
    required this.title,
    required this.timingAnalysis,
    required this.dailyPerformance,
    this.initialMetric = ChartMetric.winRate,
    this.initialTimeFrame = ChartTimeFrame.dailyLinear,
    this.isBarChart = false,
    super.key,
  });

  @override
  State<DynamicChartCard> createState() => _DynamicChartCardState();
}

class _DynamicChartCardState extends State<DynamicChartCard> {
  late ChartMetric _selectedMetric;
  late ChartTimeFrame _selectedTimeFrame;

  @override
  void initState() {
    super.initState();
    _selectedMetric = widget.initialMetric;
    _selectedTimeFrame = widget.initialTimeFrame;
  }
  
  @override 
  void didUpdateWidget(DynamicChartCard oldWidget) {
      super.didUpdateWidget(oldWidget);
      if(oldWidget.initialTimeFrame != widget.initialTimeFrame) {
          setState(() {
              _selectedTimeFrame = widget.initialTimeFrame;
          });
      }
  }

  List<ChartDataPoint> _getData() {
    List<ChartDataPoint> points = [];
    
    switch (_selectedTimeFrame) {
      // Linear Time Series
      case ChartTimeFrame.dailyLinear:
        points = ChartAggregator.accumulateDaily(widget.dailyPerformance, _selectedMetric);
        break;
      case ChartTimeFrame.weeklyLinear:
        points = ChartAggregator.accumulateWeekly(widget.dailyPerformance, _selectedMetric);
        break;
      case ChartTimeFrame.monthlyLinear:
        points = ChartAggregator.accumulateMonthly(widget.dailyPerformance, _selectedMetric);
        break;

      // Seasonality
      // Seasonality
      case ChartTimeFrame.hourSeason:
        // Aggregate by hour (0-23)
        final Map<int, List<HourlyPerformance>> grouped = {};
        for (var item in widget.timingAnalysis.hourlyPerformance) {
            grouped.putIfAbsent(item.hour, () => []).add(item);
        }
        
        // Sort 0-23
        final sortedKeys = grouped.keys.toList()..sort();
        
        for (var hour in sortedKeys) {
            final items = grouped[hour]!;
            final aggValue = _aggregateSeasonality(items.map((e) => e.metrics).toList(), items.map((e) => e.tradeCount).toList(), _selectedMetric);
            String label = '$hour';
            points.add(ChartDataPoint(xLabel: label, yValue: aggValue, xIndex: hour));
        }
        break;

      case ChartTimeFrame.daySeason:
        // Aggregate by dayOrder (1-7)
        final Map<int, List<DayOfWeekPerformance>> grouped = {};
        for(var item in widget.timingAnalysis.dayOfWeekPerformance) {
            grouped.putIfAbsent(item.dayOrder, () => []).add(item);
        }
        
        final sortedKeys = grouped.keys.toList()..sort();
        
        for(var dayOrder in sortedKeys) {
            final items = grouped[dayOrder]!;
            final aggValue = _aggregateSeasonality(items.map((e) => e.metrics).toList(), items.map((e) => e.tradeCount).toList(), _selectedMetric);
            // Use first item's day name (e.g. "Monday")
            final label = items.first.dayOfWeek.substring(0, 3);
            points.add(ChartDataPoint(xLabel: label, yValue: aggValue, xIndex: dayOrder));
        }
        break;
        
      case ChartTimeFrame.monthSeason:
         // Aggregate by monthOrder(1-12)
         final Map<int, List<MonthlyPerformance>> grouped = {};
         for (var item in widget.timingAnalysis.monthlyPerformance) {
             grouped.putIfAbsent(item.monthOrder, () => []).add(item);
         }
         
         final sortedKeys = grouped.keys.toList()..sort();
         
         for(var monthOrder in sortedKeys) {
             final items = grouped[monthOrder]!;
             final aggValue = _aggregateSeasonality(items.map((e) => e.metrics).toList(), items.map((e) => e.tradeCount).toList(), _selectedMetric);
             final label = items.first.month.substring(0, 3);
             points.add(ChartDataPoint(xLabel: label, yValue: aggValue, xIndex: monthOrder));
         }
         break;
         
      case ChartTimeFrame.yearSeason:
        // Yearly is implicitly linear? Or could be multiple portfolios?
        // Assuming year is unique enough for now, but sorting helps.
        // Actually, if we have duplicate years it's weird.
        final data = List.of(widget.timingAnalysis.yearlyPerformance);
        data.sort((a,b) => a.year.compareTo(b.year));
        for(var i=0; i<data.length; i++) {
            final item = data[i];
            final val = _selectedMetric.getValue(item.metrics, tradeCount: item.tradeCount);
            points.add(ChartDataPoint(xLabel: '${item.year}', yValue: val, xIndex: i));
        }
        break;
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dataPoints = _getData();

    return GlossyCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Controls Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Row(
                   children: [
                       Icon(widget.isBarChart ? Icons.bar_chart : Icons.show_chart, size: 20, color: theme.colorScheme.primary),
                       const SizedBox(width: 8),
                       // Metric Dropdown
                       DropdownButton<ChartMetric>(
                         value: _selectedMetric,
                         underline: const SizedBox(),
                         icon: const Icon(Icons.arrow_drop_down, size: 16),
                         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                         items: ChartMetric.values.map((e) => DropdownMenuItem(
                           value: e,
                           child: Text(e.label, style: TextStyle(color: theme.colorScheme.onSurface)),
                         )).toList(),
                         onChanged: (val) {
                           if(val != null) setState(() => _selectedMetric = val);
                         },
                         dropdownColor: theme.colorScheme.surface,
                       ),
                   ]
                 ),
                 
                 // TimeFrame Dropdown
                 Container(
                     padding: const EdgeInsets.symmetric(horizontal: 8),
                     decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(8),
                         border: Border.all(color: Colors.white24),
                     ),
                     child: DropdownButton<ChartTimeFrame>(
                         value: _selectedTimeFrame,
                         underline: const SizedBox(),
                         isDense: true,
                         icon: const Icon(Icons.arrow_drop_down, size: 16),
                         style: const TextStyle(fontSize: 12),
                         items: ChartTimeFrame.values.map((e) => DropdownMenuItem(
                           value: e,
                           child: Text(e.label, style: TextStyle(color: theme.colorScheme.onSurface)),
                         )).toList(),
                         onChanged: (val) {
                            if(val != null) setState(() => _selectedTimeFrame = val);
                         },
                         dropdownColor: theme.colorScheme.surface,
                     ),
                 ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Chart
            Expanded(
              child: dataPoints.isEmpty 
               ? const Center(child: Text("No data available"))
               : widget.isBarChart 
                  ? BarChart(
                      BarChartData(
                        gridData: const FlGridData(show: true, drawVerticalLine: false),
                        titlesData: FlTitlesData(
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (val, meta) => Text(val.toInt().toString(), style: const TextStyle(fontSize: 10)))),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (val, meta) {
                                        final index = val.toInt();
                                        if (index >= 0 && index < dataPoints.length) {
                                            // Show label if enough space or simply show periodically
                                            // Simple logic: Show all for small datasets, skip for large?
                                            // For now showing all.
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 4),
                                              child: Text(dataPoints[index].xLabel, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center),
                                            );
                                        }
                                        return const SizedBox.shrink();
                                    }
                                )
                            )
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: dataPoints.map((p) => BarChartGroupData(
                            x: p.xIndex,
                            barRods: [
                                BarChartRodData(
                                    toY: p.yValue,
                                    color: p.yValue < 0 ? Colors.red.withOpacity(0.7) : const Color(0xFF6C5DD3),
                                    width: 12, 
                                    borderRadius: BorderRadius.circular(4)
                                )
                            ]
                        )).toList(),
                      ),
                    )
                  : LineChart(
                      LineChartData(
                         gridData: const FlGridData(show: true, drawVerticalLine: false),
                         titlesData: FlTitlesData(
                             rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (val, meta) => Text(val.toInt().toString(), style: const TextStyle(fontSize: 10)))),
                             topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                             bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (val, meta) {
                                        final index = val.toInt();
                                        if (index >= 0 && index < dataPoints.length) {
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 4),
                                              child: Text(dataPoints[index].xLabel, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center),
                                            );
                                        }
                                        return const SizedBox.shrink();
                                    }
                                )
                            )
                         ),
                         borderData: FlBorderData(show: false),
                         lineBarsData: [
                            LineChartBarData(
                                spots: dataPoints.map((p) => FlSpot(p.xIndex.toDouble(), p.yValue)).toList(),
                                isCurved: true,
                                color: const Color(0xFF6C5DD3),
                                barWidth: 3,
                                dotData: const FlDotData(show: true),
                                belowBarData: BarAreaData(show: true, color: const Color(0xFF6C5DD3).withOpacity(0.1)),
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
  double _aggregateSeasonality(List<ReportPerformanceMetrics> metricsList, List<int> tradeCounts, ChartMetric metric) {
        if(metricsList.isEmpty) return 0;
        
        double weightedSum = 0;
        int totalTrades = 0;
        int totalWins = 0;
        
        for(int i=0; i<metricsList.length; i++) {
            final m = metricsList[i];
            final tCount = tradeCounts[i];
            totalTrades += tCount;
            final winPct = m.winPercentage ?? 0;
            totalWins += (winPct * tCount).round().toInt();
        }
        
        switch(metric) {
            case ChartMetric.tradeCount:
               return totalTrades.toDouble();
               
            case ChartMetric.grossPnL:
               double sum = 0;
               for(var m in metricsList) sum += (m.grossPnL ?? 0);
               return sum;
               
            case ChartMetric.winRate:
               if(totalTrades == 0) return 0;
               double estWins = 0;
               for(int i=0; i<metricsList.length; i++) {
                   estWins += (metricsList[i].winPercentage ?? 0) * tradeCounts[i];
               }
               return (estWins / totalTrades) * 100;
            
            case ChartMetric.avgWin:
               double weightedWinSum = 0;
               double winCountSum = 0;
               for(int i=0; i<metricsList.length; i++) {
                   final wCount = (metricsList[i].winPercentage ?? 0) * tradeCounts[i];
                   weightedWinSum += (metricsList[i].avgWin ?? 0) * wCount;
                   winCountSum += wCount;
               }
               if(winCountSum < 1) return 0;
               return weightedWinSum / winCountSum;

            case ChartMetric.avgLoss:
               double weightedLossSum = 0;
               double lossCountSum = 0;
                for(int i=0; i<metricsList.length; i++) {
                   final wCount = (metricsList[i].winPercentage ?? 0) * tradeCounts[i];
                   final lCount = tradeCounts[i] - wCount;
                   weightedLossSum += (metricsList[i].avgLoss ?? 0) * lCount;
                   lossCountSum += lCount;
               }
                if(lossCountSum < 1) return 0;
               return weightedLossSum / lossCountSum;
               
            case ChartMetric.holdTime:
               double weightedHold = 0;
               for(int i=0; i<metricsList.length; i++) {
                   weightedHold += (metricsList[i].avgHoldTime ?? 0) * tradeCounts[i];
               }
               if(totalTrades == 0) return 0;
               return weightedHold / totalTrades;
               
            case ChartMetric.profitFactor:
               if(metricsList.isEmpty) return 0;
               double sumPf = 0;
               for(var m in metricsList) sumPf += (m.profitFactor ?? 0);
               return sumPf / metricsList.length;
        }
  }
}
