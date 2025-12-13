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
  final List<ChartMetric> initialMetrics;
  final ChartTimeFrame initialTimeFrame;
  final ChartType initialChartType;

  const DynamicChartCard({
    required this.title,
    required this.timingAnalysis,
    required this.dailyPerformance,
    this.initialMetrics = const [ChartMetric.winRate],
    this.initialTimeFrame = ChartTimeFrame.dailyLinear,
    this.initialChartType = ChartType.line,
    super.key,
  });

  @override
  State<DynamicChartCard> createState() => _DynamicChartCardState();
}

class _DynamicChartCardState extends State<DynamicChartCard> {
  late Set<ChartMetric> _selectedMetrics;
  late ChartTimeFrame _selectedTimeFrame;
  late ChartType _selectedChartType;
  
  // Define colors for metrics
  final Map<ChartMetric, Color> _metricColors = {
      ChartMetric.winRate: const Color(0xFF6C5DD3), // Purple
      ChartMetric.tradeCount: const Color(0xFFFFA500), // Orange
      ChartMetric.avgWin: const Color(0xFF00FF00), // Green
      ChartMetric.avgLoss: const Color(0xFFFF0000), // Red
      ChartMetric.grossPnL: const Color(0xFF00BFFF), // Blue
      ChartMetric.holdTime: const Color(0xFFFF69B4), // Pink
      ChartMetric.profitFactor: const Color(0xFF8B4513), // Brown
  };

  @override
  void initState() {
    super.initState();
    _selectedMetrics = widget.initialMetrics.toSet();
    if (_selectedMetrics.isEmpty) _selectedMetrics = {ChartMetric.winRate};
    _selectedTimeFrame = widget.initialTimeFrame;
    _selectedChartType = widget.initialChartType;
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

  Map<ChartMetric, List<ChartDataPoint>> _getAllData() {
      final Map<ChartMetric, List<ChartDataPoint>> data = {};
      for (var metric in _selectedMetrics) {
          data[metric] = _getDataForMetric(metric);
      }
      return data;
  }

  List<ChartDataPoint> _getDataForMetric(ChartMetric metric) {
    List<ChartDataPoint> points = [];
    
    switch (_selectedTimeFrame) {
      // Linear Time Series
      case ChartTimeFrame.dailyLinear:
        points = ChartAggregator.accumulateDaily(widget.dailyPerformance, metric);
        break;
      case ChartTimeFrame.weeklyLinear:
        points = ChartAggregator.accumulateWeekly(widget.dailyPerformance, metric);
        break;
      case ChartTimeFrame.monthlyLinear:
        points = ChartAggregator.accumulateMonthly(widget.dailyPerformance, metric);
        break;

      // Seasonality
      case ChartTimeFrame.hourSeason:
        final Map<int, List<HourlyPerformance>> grouped = {};
        for (var item in widget.timingAnalysis.hourlyPerformance) {
            grouped.putIfAbsent(item.hour, () => []).add(item);
        }
        final sortedKeys = grouped.keys.toList()..sort();
        for (var hour in sortedKeys) {
            final items = grouped[hour]!;
            final aggValue = _aggregateSeasonality(items.map((e) => e.metrics).toList(), items.map((e) => e.tradeCount).toList(), metric);
            String label = '$hour';
            points.add(ChartDataPoint(xLabel: label, yValue: aggValue, xIndex: hour));
        }
        break;

      case ChartTimeFrame.daySeason:
        final Map<int, List<DayOfWeekPerformance>> grouped = {};
        for(var item in widget.timingAnalysis.dayOfWeekPerformance) {
            grouped.putIfAbsent(item.dayOrder, () => []).add(item);
        }
        final sortedKeys = grouped.keys.toList()..sort();
        for(var dayOrder in sortedKeys) {
            final items = grouped[dayOrder]!;
            final aggValue = _aggregateSeasonality(items.map((e) => e.metrics).toList(), items.map((e) => e.tradeCount).toList(), metric);
            final label = items.first.dayOfWeek.substring(0, 3);
            points.add(ChartDataPoint(xLabel: label, yValue: aggValue, xIndex: dayOrder));
        }
        break;
        
      case ChartTimeFrame.monthSeason:
         final Map<int, List<MonthlyPerformance>> grouped = {};
         for (var item in widget.timingAnalysis.monthlyPerformance) {
             grouped.putIfAbsent(item.monthOrder, () => []).add(item);
         }
         final sortedKeys = grouped.keys.toList()..sort();
         for(var monthOrder in sortedKeys) {
             final items = grouped[monthOrder]!;
             final aggValue = _aggregateSeasonality(items.map((e) => e.metrics).toList(), items.map((e) => e.tradeCount).toList(), metric);
             final label = items.first.month.substring(0, 3);
             points.add(ChartDataPoint(xLabel: label, yValue: aggValue, xIndex: monthOrder));
         }
         break;
         
      case ChartTimeFrame.yearSeason:
        final data = List.of(widget.timingAnalysis.yearlyPerformance);
        data.sort((a,b) => a.year.compareTo(b.year));
        for(var i=0; i<data.length; i++) {
            final item = data[i];
            final val = metric.getValue(item.metrics, tradeCount: item.tradeCount);
            points.add(ChartDataPoint(xLabel: '${item.year}', yValue: val, xIndex: i));
        }
        break;
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allData = _getAllData();
    final firstMetricData = allData.values.isNotEmpty ? allData.values.first : <ChartDataPoint>[];
    
    // Determine labels from the first available dataset (assuming shared X access)
    // If multiple timeframes alignment is an issue, we assume standardized X-axis by aggregator.
    
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
                       // Chart Type Selector
                       Container(
                           height: 32,
                           padding: const EdgeInsets.symmetric(horizontal: 8),
                           decoration: BoxDecoration(
                               color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                               borderRadius: BorderRadius.circular(8),
                           ),
                           child: Row(
                               children: [
                                   _buildChartTypeIcon(ChartType.line, Icons.show_chart),
                                   const SizedBox(width: 4),
                                   _buildChartTypeIcon(ChartType.area, Icons.area_chart),
                                   const SizedBox(width: 4),
                                   _buildChartTypeIcon(ChartType.bar, Icons.bar_chart),
                               ]
                           )
                       ),
                       const SizedBox(width: 12),
                       // Metric Multi-Select
                       // Metric Multi-Select Button
                       InkWell(
                         onTap: () => _showMetricsSelectionDialog(context),
                         borderRadius: BorderRadius.circular(8),
                         child: Container(
                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                           decoration: BoxDecoration(
                               border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
                               borderRadius: BorderRadius.circular(8),
                           ),
                           child: Row(
                               children: [
                                   Text('${_selectedMetrics.length} Metrics', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
                                   const SizedBox(width: 8),
                                   Icon(Icons.arrow_drop_down, color: theme.colorScheme.onSurface),
                               ]
                           ),
                         ),
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
            const SizedBox(height: 10),
            
            // Legend
            const SizedBox(height: 20),
            const SizedBox(height: 20),
            
            // Chart
            Expanded(
              child: allData.isEmpty || allData.values.every((l) => l.isEmpty)
               ? const Center(child: Text("No data available"))
               : _buildChart(allData, firstMetricData, theme),
            ),
            const SizedBox(height: 16),
            
            // Legend
             Wrap(
                spacing: 24,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: _selectedMetrics.map((m) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        Container(
                          width: 12, 
                          height: 12, 
                          decoration: BoxDecoration(color: _metricColors[m], shape: BoxShape.circle),
                          margin: const EdgeInsets.only(right: 8)
                        ),
                        Text(m.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    ]
                )).toList(),
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


  void _showMetricsSelectionDialog(BuildContext context) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
              title: const Text('Select Metrics'),
              content: SingleChildScrollView(
                  child: StatefulBuilder(
                      builder: (context, setState) { 
                          return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: ChartMetric.values
                                  .where((m) => m != ChartMetric.profitFactor) // Remove Profit Factor
                                  .map((metric) {
                                  final isSelected = _selectedMetrics.contains(metric);
                                  return CheckboxListTile(
                                      title: Text(metric.label),
                                      value: isSelected,
                                      activeColor: _metricColors[metric],
                                      onChanged: (bool? value) {
                                          setState(() {
                                              if (value == true) {
                                                  _selectedMetrics.add(metric);
                                              } else {
                                                  if (_selectedMetrics.length > 1) { 
                                                      _selectedMetrics.remove(metric);
                                                  }
                                              }
                                          });
                                          // Update main widget state
                                          this.setState(() {}); 
                                      },
                                  );
                              }).toList(),
                          );
                      }
                  ),
              ),
              actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Done'),
                  )
              ],
          )
      );
  }

  Widget _buildChartTypeIcon(ChartType type, IconData icon) {
      final isSelected = _selectedChartType == type;
      return InkWell(
          onTap: () => setState(() => _selectedChartType = type),
          child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(icon, size: 16, color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
          ),
      );
  }

  Widget _buildChart(Map<ChartMetric, List<ChartDataPoint>> allData, List<ChartDataPoint> firstMetricData, ThemeData theme) {
      if (_selectedChartType == ChartType.bar) {
          return BarChart(
              BarChartData(
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  titlesData: _buildTitlesData(firstMetricData),
                  borderData: FlBorderData(show: false),
                  barGroups: _buildBarGroups(allData),
              )
          );
      }
      
      return LineChart(
          LineChartData(
              gridData: const FlGridData(show: true, drawVerticalLine: false),
              titlesData: _buildTitlesData(firstMetricData),
              borderData: FlBorderData(show: false),
              lineBarsData: _selectedMetrics.map((metric) {
                  final points = allData[metric] ?? [];
                  return LineChartBarData(
                      spots: points.map((p) => FlSpot(p.xIndex.toDouble(), p.yValue)).toList(),
                      isCurved: true,
                      color: _metricColors[metric] ?? theme.colorScheme.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: false), // Hide dots for cleaner look
                      belowBarData: BarAreaData(
                          show: _selectedChartType == ChartType.area,
                          color: (_metricColors[metric] ?? theme.colorScheme.primary).withOpacity(0.15)
                      ),
                  );
              }).toList(),
          )
      );
  }

  FlTitlesData _buildTitlesData(List<ChartDataPoint> firstMetricData) {
      return FlTitlesData(
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (val, meta) => Text(val.toInt().toString(), style: const TextStyle(fontSize: 10)))),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
             sideTitles: SideTitles(
                 showTitles: true,
                 getTitlesWidget: (val, meta) {
                     final index = val.toInt();
                     if (index >= 0 && index < firstMetricData.length) {
                         return Padding(
                           padding: const EdgeInsets.only(top: 8),
                           child: Text(
                             firstMetricData[index].xLabel, 
                             style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500), 
                             textAlign: TextAlign.center
                           ),
                         );
                     }
                     return const SizedBox.shrink();
                 },
                 reservedSize: 60,
             )
         )
      );
  }

  List<BarChartGroupData> _buildBarGroups(Map<ChartMetric, List<ChartDataPoint>> allData) {
      // Assuming all metrics have same x-indices.
      // We need to group by index.
      final Map<int, List<BarChartRodData>> groups = {};
      
      int metricIndex = 0;
      for (var metric in _selectedMetrics) {
          final points = allData[metric] ?? [];
          for (var p in points) {
             groups.putIfAbsent(p.xIndex, () => []);
             groups[p.xIndex]!.add(
                 BarChartRodData(
                     toY: p.yValue,
                     color: _metricColors[metric],
                     width: 8, // Thinner bars for groups
                     borderRadius: BorderRadius.circular(2)
                 )
             );
          }
          metricIndex++;
      }
      
      final sortedIndices = groups.keys.toList()..sort();
      return sortedIndices.map((index) {
          return BarChartGroupData(
              x: index,
              barRods: groups[index]!,
              barsSpace: 4, // Space between bars in a group
          );
      }).toList();
  }
}

