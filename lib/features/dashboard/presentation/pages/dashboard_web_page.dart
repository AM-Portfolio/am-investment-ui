import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../trade/providers/trade_internal_providers.dart';
import '../../../../shared/widgets/calendar/universal_calendar/universal_calendar_widget.dart';
import '../../../../shared/widgets/calendar/universal_calendar/calendar_types.dart';
import '../../../../shared/widgets/calendar/universal_calendar/data_provider.dart';
import '../../../trade/presentation/models/trade_calendar_view_model.dart';
import '../widgets/dashboard_sidebar.dart';
import '../widgets/dashboard_widgets.dart';

class DashboardWebPage extends ConsumerStatefulWidget {
  const DashboardWebPage({super.key, required this.userId});

  final String userId;

  @override
  ConsumerState<DashboardWebPage> createState() => _DashboardWebPageState();
}

class _DashboardWebPageState extends ConsumerState<DashboardWebPage> {
  String _currentView = 'Dashboard';
  bool _isSidebarVisible = true;
  String? _selectedPortfolioId;
  String? _selectedPortfolioName;

  @override
  Widget build(BuildContext context) {
    final portfoliosAsync = ref.watch(tradePortfoliosStreamProvider(widget.userId));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isSidebarVisible ? 280 : 0,
            curve: Curves.easeInOut,
            child: OverflowBox(
              minWidth: 280,
              maxWidth: 280,
              alignment: Alignment.centerLeft,
              child: DashboardSidebar(
                currentView: _currentView,
                onViewChanged: (view) {
                  setState(() {
                    _currentView = view;
                  });
                },
              ),
            ),
          ),

          // Main Content
          Expanded(
            child: Column(
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
                    return _buildTopBar(portfolios.map((p) => p.name).toList());
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
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(List<String> portfolioNames) {
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
          IconButton(
            icon: Icon(_isSidebarVisible ? Icons.menu_open : Icons.menu),
            color: Colors.grey[600],
            onPressed: () {
              setState(() {
                _isSidebarVisible = !_isSidebarVisible;
              });
            },
          ),
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
          Container(
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
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return Column(
      children: [
        // Stats Row
        const Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Net P&L',
                value: '\$135.00',
                valueColor: Color(0xFF00B894),
                icon: Icons.attach_money,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: StatCard(
                title: 'Trade Expectancy',
                value: '\$27.00',
                icon: Icons.analytics_outlined,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: StatCard(
                title: 'Profit Factor',
                value: '1.90',
                progress: 0.7,
                isPositive: true,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: StatCard(
                title: 'Trade Win %',
                value: '60.00%',
                progress: 0.6,
                isPositive: true,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: StatCard(
                title: 'Avg win/loss trade',
                value: '1.27',
                subtitle: '\$95 / -\$75',
                progress: 0.6,
                isPositive: true,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: StatCard(
                title: 'Improvement Rate',
                value: '15%',
                icon: Icons.trending_up,
                valueColor: Color(0xFF00B894),
                subtitle: '+2.5% vs last week',
                isPositive: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Charts Row
        const SizedBox(
          height: 350,
          child: Row(
            children: [
              Expanded(flex: 2, child: ZellaScoreChart()),
              SizedBox(width: 16),
              Expanded(flex: 3, child: NetCumulativePnLChart()),
              SizedBox(width: 16),
              Expanded(flex: 2, child: NetDailyPnLChart()),
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
