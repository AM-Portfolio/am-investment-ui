
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../trade/providers/trade_internal_providers.dart';
import 'package:am_common_ui/widgets/calendar/universal_calendar/universal_calendar_widget.dart';
import 'package:am_common_ui/widgets/calendar/universal_calendar/calendar_types.dart';
import 'package:am_common_ui/widgets/calendar/universal_calendar/data_provider.dart';
import '../../../trade/presentation/models/trade_calendar_view_model.dart';
import '../widgets/dashboard_widgets.dart';

class DashboardMobilePage extends ConsumerStatefulWidget {
  const DashboardMobilePage({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  ConsumerState<DashboardMobilePage> createState() => _DashboardMobilePageState();
}

class _DashboardMobilePageState extends ConsumerState<DashboardMobilePage> {
  String? _selectedPortfolioId;
  String? _selectedPortfolioName;

  @override
  Widget build(BuildContext context) {
    final portfoliosAsync = ref.watch(tradePortfoliosStreamProvider(widget.userId));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: portfoliosAsync.when(
          data: (portfolios) {
            if (portfolios.isNotEmpty && _selectedPortfolioId == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _selectedPortfolioId = portfolios.first.id;
                    _selectedPortfolioName = portfolios.first.name;
                  });
                }
              });
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildPortfolioSelector(portfolios),
                  const SizedBox(height: 24),
                  if (_selectedPortfolioId != null) ...[
                    _buildStatsGrid(),
                    const SizedBox(height: 24),
                    _buildCharts(),
                    const SizedBox(height: 24),
                    const Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    const SizedBox(height: 12),
                    RecentTradesWidget(
                      userId: widget.userId,
                      portfolioId: _selectedPortfolioId,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Calendar',
                       style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 380,
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: UniversalCalendarWidget(
                            context: 'dashboard_mobile',
                            templateType: CalendarTemplateType.compact,
                            title: '',
                            onDateSelectionChanged: (selection) {},
                            dataProvider: TradeCalendarDataProvider(
                              portfolioId: _selectedPortfolioId!,
                            ),
                            currentYear: DateTime.now().year,
                            showYearCalendar: false,
                          ),
                        ),
                      ),
                    ),
                  ] else
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text("Please select a portfolio"),
                      ),
                    ),
                 // Bottom spacing for nav bar if needed
                 const SizedBox(height: 80), 
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 4),
            Text(
             DateFormat('MMM d, yyyy').format(DateTime.now()),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.notifications_outlined, color: Color(0xFF6C5DD3)),
        ),
      ],
    );
  }

  Widget _buildPortfolioSelector(List<dynamic> portfolios) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
         boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPortfolioId,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6C5DD3)),
          hint: const Text('Select Portfolio'),
          items: portfolios.map((p) {
            return DropdownMenuItem<String>(
              value: p.id,
              child: Text(
                p.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3436),
                ),
              ),
            );
          }).toList(),
          onChanged: (val) {
             final selected = portfolios.firstWhere((p) => p.id == val);
             setState(() {
               _selectedPortfolioId = val;
               _selectedPortfolioName = selected.name;
             });
          },
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    final userId = widget.userId;
    final portfolioId = _selectedPortfolioId!;
    final tradeSummaryAsync = ref.watch(tradeSummaryStreamProvider((userId: userId, portfolioId: portfolioId)));

    return tradeSummaryAsync.when(
      data: (summary) {
        final metrics = summary.metrics;
        final avgWin = metrics.winningTrades > 0 
            ? (metrics.totalProfit ?? 0) / metrics.winningTrades 
            : 0.0;
        final avgLoss = metrics.losingTrades > 0 
            ? (metrics.totalLoss ?? 0) / metrics.losingTrades 
            : 0.0;
        final avgWinLossRatio = avgLoss != 0 ? (avgWin / avgLoss.abs()) : 0.0;
        final winRate = (metrics.winRate ?? 0) * 100;

        return Column(
          children: [
            // Net P&L (Full Width)
            StatCard(
              title: 'Net P&L',
              value: '\$${(metrics.netProfitLoss ?? 0).toStringAsFixed(2)}',
              valueColor: (metrics.netProfitLoss ?? 0) >= 0 ? const Color(0xFF00B894) : const Color(0xFFFF7675),
              icon: Icons.attach_money,
            ),
            const SizedBox(height: 16),
            
            // Grid 2x2
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Win Rate',
                    value: '${winRate.toStringAsFixed(1)}%',
                    progress: metrics.winRate ?? 0,
                    isPositive: winRate >= 50,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    title: 'Profit Factor',
                    value: (metrics.profitFactor ?? 0).toStringAsFixed(2),
                    isPositive: (metrics.profitFactor ?? 0) >= 1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                     title: 'Exp. Value',
                     value: '\$${(metrics.expectancy ?? 0).toStringAsFixed(2)}',
                     icon: Icons.analytics_outlined,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    title: 'Avg W/L',
                    value: avgWinLossRatio.toStringAsFixed(2),
                    isPositive: avgWinLossRatio >= 1.0,
                  ),
                ),
              ],
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _buildCharts() {
     final userId = widget.userId;
    final portfolioId = _selectedPortfolioId!;
    
    // Using same providers as web
    final tradeSummaryAsync = ref.watch(tradeSummaryStreamProvider((userId: userId, portfolioId: portfolioId)));
    final tradeHoldingsAsync = ref.watch(tradeHoldingsStreamProvider((userId: userId, portfolioId: portfolioId)));

    return Column(
      children: [
        // Zella Score
        SizedBox(
          height: 320,
          child: tradeSummaryAsync.when(
            data: (summary) {
               final metrics = summary.metrics;
               final score = ((metrics.winRate ?? 0) * 0.4 + 
                              ((metrics.profitFactor ?? 0) / 5) * 0.3 + 
                              ((metrics.netProfitLoss ?? 0) > 0 ? 0.3 : 0)) * 100;
               final avgWin = metrics.winningTrades > 0 ? (metrics.totalProfit ?? 0) / metrics.winningTrades : 0.0;
               final avgLoss = metrics.losingTrades > 0 ? (metrics.totalLoss ?? 0) / metrics.losingTrades : 0.0;
               final ratio = avgLoss != 0 ? (avgWin / avgLoss.abs()) : 0.0;

               return ZellaScoreChart(
                 score: score.clamp(0, 100),
                 winRate: metrics.winRate ?? 0,
                 profitFactor: metrics.profitFactor ?? 0,
                 avgWinLoss: ratio,
               );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_,__) => const SizedBox(),
          ),
        ),
        const SizedBox(height: 16),
        // Cumulative P&L
        SizedBox(
          height: 300,
          child: tradeHoldingsAsync.when(
            data: (data) {
                final trades = data.holdings;
                if (trades.isEmpty) return const NetCumulativePnLChart(spots: [], dates: []);

                final dailyPnl = <String, double>{};
                final sortedTrades = [...trades]..sort((a, b) {
                  final timeA = a.entryTimestamp ?? DateTime.now();
                  final timeB = b.entryTimestamp ?? DateTime.now();
                  return timeA.compareTo(timeB);
                });

                for (var trade in sortedTrades) {
                  final date = trade.entryTimestamp;
                  if (date != null && trade.profitLoss != null) {
                    final key = DateFormat('MM/dd/yy').format(date);
                    dailyPnl[key] = (dailyPnl[key] ?? 0.0) + (trade.profitLoss!);
                  }
                }
                
                final sortedKeys = dailyPnl.keys.toList()..sort((a, b) {
                    try {
                      final dA = DateFormat('MM/dd/yy').parse(a);
                      final dB = DateFormat('MM/dd/yy').parse(b);
                      return dA.compareTo(dB);
                    } catch(e) { return a.compareTo(b); }
                });

                final spots = <FlSpot>[];
                final dates = <String>[];
                double cumulative = 0;
                
                for (int i = 0; i < sortedKeys.length; i++) {
                  final key = sortedKeys[i];
                  cumulative += dailyPnl[key]!;
                  spots.add(FlSpot(i.toDouble(), cumulative));
                  dates.add(key);
                }

                return NetCumulativePnLChart(spots: spots, dates: dates);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_,__) => const SizedBox(),
          ),
        ),
        const SizedBox(height: 16),
        // Daily P&L
        SizedBox(
          height: 300,
          child: tradeHoldingsAsync.when(
            data: (data) {
                final trades = data.holdings;
                if (trades.isEmpty) return const NetDailyPnLChart(dailyData: []);

                final dailyPnl = <String, double>{};
                for (var trade in trades) {
                  final date = trade.entryTimestamp; 
                  if (date != null && trade.profitLoss != null) {
                    final key = DateFormat('MM/dd/yy').format(date);
                    dailyPnl[key] = (dailyPnl[key] ?? 0.0) + (trade.profitLoss!);
                  }
                }
                final entries = dailyPnl.entries.toList();
                entries.sort((a, b) {
                    try {
                      final dA = DateFormat('MM/dd/yy').parse(a.key);
                      final dB = DateFormat('MM/dd/yy').parse(b.key);
                      return dA.compareTo(dB);
                    } catch(e) { return 0; }
                });

                final chartData = entries.map((e) => (date: e.key, pnl: e.value)).toList();
                final limitedData = chartData.length > 7 ? chartData.sublist(chartData.length - 7) : chartData;

                return NetDailyPnLChart(dailyData: limitedData);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_,__) => const SizedBox(),
          ),
        )
      ],
    );
  }
}
