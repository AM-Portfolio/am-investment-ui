import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../trade/providers/trade_internal_providers.dart';
import '../../../../shared/widgets/calendar/universal_calendar/universal_calendar_widget.dart';
import '../../../../shared/widgets/calendar/universal_calendar/calendar_types.dart';
import '../../../../shared/widgets/calendar/universal_calendar/data_provider.dart';
import '../../../trade/presentation/models/trade_calendar_view_model.dart';
import '../widgets/dashboard_widgets.dart';

class DashboardWebPage extends ConsumerStatefulWidget {
  const DashboardWebPage({
    super.key,
    required this.userId,
    this.isSidebarVisible = true,
    this.onToggleSidebar,
  });

  final String userId;
  final bool isSidebarVisible;
  final VoidCallback? onToggleSidebar;

  @override
  ConsumerState<DashboardWebPage> createState() => _DashboardWebPageState();
}

class _DashboardWebPageState extends ConsumerState<DashboardWebPage> {
  String _currentView = 'Dashboard';
  String? _selectedPortfolioId;
  String? _selectedPortfolioName;

  @override
  Widget build(BuildContext context) {
    final portfoliosAsync = ref.watch(tradePortfoliosStreamProvider(widget.userId));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
                // Top Bar
                portfoliosAsync.when(
                  data: (portfolios) {
                    if (portfolios.isNotEmpty && _selectedPortfolioId == null) {
                      // Auto-select first portfolio if none selected
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() {
                            _selectedPortfolioId = portfolios.first.id;
                            _selectedPortfolioName = portfolios.first.name;
                          });
                        }
                      });
                    }
                    return _buildTopBar(portfolios);
                  },
                  loading: () => _buildTopBar([]),
                  error: (_, __) => _buildTopBar([]),
                ),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome Message
                        const Text(
                          'Good morning!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3436),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Placeholder for Widgets
                        if (_currentView == 'Dashboard')
                          _buildDashboardContent()
                        else
                          Center(child: Text('$_currentView Content Coming Soon')),
                      ],
                    ),
                  ),
                ),
              ],
            ),

    );
  }

  Widget _buildTopBar(List<dynamic> portfolios) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
      ),
      child: Row(
        children: [
          // Toggle Sidebar Button

          const SizedBox(width: 8),
          // Breadcrumb / Title
          const Icon(Icons.chevron_left, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            _currentView,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3436),
            ),
          ),
          
          const Spacer(),

          // Right Side Actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.monetization_on_outlined, size: 16, color: Color(0xFF6C5DD3)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          
          // Date Range Picker
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Color(0xFF6C5DD3)),
                const SizedBox(width: 8),
                Text(
                  'Aug 13, 2023 - Aug 15, 2023', // Mocked for now, could be dynamic
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2D3436),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.close, size: 14, color: Colors.grey),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Account Selector
          // Account Selector
          PopupMenuButton<String>(
            offset: const Offset(0, 40),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (String id) {
              final selected = portfolios.firstWhere((p) => p.id == id);
              setState(() {
                _selectedPortfolioId = selected.id;
                _selectedPortfolioName = selected.name;
              });
            },
            itemBuilder: (context) => portfolios.map((portfolio) {
              return PopupMenuItem<String>(
                value: portfolio.id,
                child: Text(
                  portfolio.name,
                  style: TextStyle(
                    fontWeight: portfolio.id == _selectedPortfolioId ? FontWeight.bold : FontWeight.normal,
                    color: portfolio.id == _selectedPortfolioId ? const Color(0xFF6C5DD3) : Colors.black87,
                  ),
                ),
              );
            }).toList(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    _selectedPortfolioName ?? 'Select Portfolio',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_drop_down, size: 18, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    if (_selectedPortfolioId == null) {
      return const Center(child: Text('Select a portfolio to view dashboard'));
    }

    final userId = widget.userId;
    final portfolioId = _selectedPortfolioId!;

    // Watch Trade Summary
    final tradeSummaryAsync = ref.watch(tradeSummaryStreamProvider((userId: userId, portfolioId: portfolioId)));
    // Watch Trade Holdings for Charts
    final tradeHoldingsAsync = ref.watch(tradeHoldingsStreamProvider((userId: userId, portfolioId: portfolioId)));

    return Column(
      children: [
        // Stats Row
        tradeSummaryAsync.when(
          data: (summary) {
            final metrics = summary.metrics;
            // Calculate Avg Win/Loss
            final avgWin = metrics.winningTrades > 0 
                ? (metrics.totalProfit ?? 0) / metrics.winningTrades 
                : 0.0;
            final avgLoss = metrics.losingTrades > 0 
                ? (metrics.totalLoss ?? 0) / metrics.losingTrades 
                : 0.0;
            final avgWinLossRatio = avgLoss != 0 ? (avgWin / avgLoss.abs()) : 0.0;

            final winRate = (metrics.winRate ?? 0) * 100;
            
            return Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Net P&L',
                    value: '\$${(metrics.netProfitLoss ?? 0).toStringAsFixed(2)}',
                    valueColor: (metrics.netProfitLoss ?? 0) >= 0 ? const Color(0xFF00B894) : const Color(0xFFFF7675),
                    icon: Icons.attach_money,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    title: 'Trade Expectancy',
                     // Expectancy usually is $ per trade
                    value: '\$${(metrics.expectancy ?? 0).toStringAsFixed(2)}',
                    icon: Icons.analytics_outlined,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    title: 'Profit Factor',
                    value: (metrics.profitFactor ?? 0).toStringAsFixed(2),
                    progress: (metrics.profitFactor ?? 0) / 3.0, // simplified max
                    isPositive: (metrics.profitFactor ?? 0) >= 1,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    title: 'Trade Win %',
                    value: '${winRate.toStringAsFixed(2)}%',
                    progress: metrics.winRate ?? 0,
                    isPositive: winRate >= 50,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    title: 'Avg win/loss trade',
                    value: avgWinLossRatio.toStringAsFixed(2),
                    subtitle: '\$${avgWin.toStringAsFixed(0)} / \$${avgLoss.toStringAsFixed(0)}',
                    progress: avgWinLossRatio / 3.0, // simplified
                    isPositive: avgWinLossRatio >= 1,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: StatCard(
                    title: 'Improvement Rate',
                    value: '15%', // Mocked: Implementation requires historical comparison
                    icon: Icons.trending_up,
                    valueColor: Color(0xFF00B894),
                    subtitle: '+2.5% vs last week',
                    isPositive: true,
                  ),
                ),
              ],
            );
          },
          loading: () => const SizedBox(height: 140, child: Center(child: CircularProgressIndicator())),
          error: (e, _) => SizedBox(height: 140, child: Center(child: Text('Error: $e'))),
        ),
        
        const SizedBox(height: 24),
        
        // Charts Row
        SizedBox(
          height: 350,
          child: Row(
            children: [
              Expanded(
                flex: 2, 
                child: tradeSummaryAsync.when(
                  data: (summary) {
                     final metrics = summary.metrics;
                     // Simple Score Calculation Mock
                     final score = ((metrics.winRate ?? 0) * 0.4 + 
                                    ((metrics.profitFactor ?? 0) / 5) * 0.3 + 
                                    ((metrics.netProfitLoss ?? 0) > 0 ? 0.3 : 0)) * 100;
                     
                     // Helper for avg win/loss
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
                  error: (_,__) => const Center(child: Text('Error')),
                )
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3, 
                child: tradeHoldingsAsync.when(
                  data: (data) {
                    final trades = data.holdings;
                    if (trades.isEmpty) return NetCumulativePnLChart(spots: const [], dates: const []);

                    // Calculate Daily P&L Map
                    final dailyPnl = <String, double>{};
                    // Sort trades by date
                    final sortedTrades = [...trades]..sort((a, b) {
                      final timeA = a.entryTimestamp ?? DateTime.now();
                      final timeB = b.entryTimestamp ?? DateTime.now();
                      return timeA.compareTo(timeB);
                    });

                    for (var trade in sortedTrades) {
                      final date = trade.entryTimestamp; // Should use exit/close date for PnL technically
                      if (date != null && trade.profitLoss != null) {
                        final key = DateFormat('MM/dd/yy').format(date);
                        dailyPnl[key] = (dailyPnl[key] ?? 0.0) + (trade.profitLoss!);
                      }
                    }
                    
                    // Ensure keys are sorted chronologically
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
                  error: (_,__) => const Center(child: Text('Error')),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2, 
                child: tradeHoldingsAsync.when(
                  data: (data) {
                    // Similar logic for bar chart, simpler
                     final trades = data.holdings;
                     if (trades.isEmpty) return NetDailyPnLChart(dailyData: const []);

                    final dailyPnl = <String, double>{};
                    for (var trade in trades) {
                      final date = trade.entryTimestamp; 
                      if (date != null && trade.profitLoss != null) {
                         // Sort check needed? Map isn't sorted
                        final key = DateFormat('MM/dd/yy').format(date);
                        dailyPnl[key] = (dailyPnl[key] ?? 0.0) + (trade.profitLoss!);
                      }
                    }
                    // Sort by Date
                    // Need parsing back to sort correctly
                    final entries = dailyPnl.entries.toList();
                    entries.sort((a, b) {
                       try {
                         final dA = DateFormat('MM/dd/yy').parse(a.key);
                         final dB = DateFormat('MM/dd/yy').parse(b.key);
                         return dA.compareTo(dB);
                       } catch(e) { return 0; }
                    });

                    final chartData = entries.map((e) => (date: e.key, pnl: e.value)).toList();
                    // Limit to last 7 days? Or take all? Let's take last 7 for visual clarity
                    final limitedData = chartData.length > 7 ? chartData.sublist(chartData.length - 7) : chartData;

                    return NetDailyPnLChart(dailyData: limitedData);
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_,__) => const Center(child: Text('Error')),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Bottom Row: Recent Trades & Calendar
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2, 
              child: RecentTradesWidget(
                userId: widget.userId,
                portfolioId: _selectedPortfolioId,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3, 
              child: SizedBox(
                height: 400, // Fixed height for calendar
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _selectedPortfolioId != null
                        ? UniversalCalendarWidget(
                            context: 'dashboard',
                            templateType: CalendarTemplateType.compact,
                            title: 'Trade Calendar',
                            onDateSelectionChanged: (selection) {
                              // Handle date selection if needed, or just log
                              print('Dashboard calendar selection: ${selection.description}');
                            },
                            dataProvider: TradeCalendarDataProvider(
                              portfolioId: _selectedPortfolioId!,
                            ),
                            currentYear: DateTime.now().year,
                            showYearCalendar: false,
                          )
                        : const Center(child: Text('Select a portfolio to view calendar')),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
