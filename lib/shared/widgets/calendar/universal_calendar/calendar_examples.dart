/// Example usage of Universal Calendar Widget with predefined models
library;

import 'package:flutter/material.dart';

import 'card_types.dart' as card_types;
import 'data_provider.dart';
import 'types.dart';
import 'universal_calendar_widget.dart';

class CalendarExampleScreen extends StatefulWidget {
  const CalendarExampleScreen({super.key});

  @override
  State<CalendarExampleScreen> createState() => _CalendarExampleScreenState();
}

class _CalendarExampleScreenState extends State<CalendarExampleScreen> {
  DateSelection? _currentSelection;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Universal Calendar Examples')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExampleSection(
            'Trading Calendar with Cards',
            _buildTradingCalendarWithCards(),
          ),
          const SizedBox(height: 32),
          _buildExampleSection('Portfolio Calendar', _buildPortfolioCalendar()),
          const SizedBox(height: 32),
          _buildExampleSection('Quick Date Filter', _buildQuickDateFilter()),
          const SizedBox(height: 32),
          _buildExampleSection('Web Date Filter', _buildWebDateFilter()),
          const SizedBox(height: 32),
          _buildExampleSection('Trade Date Filter', _buildTradeDateFilter()),
        ],
      ),
    ),
  );

  Widget _buildExampleSection(String title, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 16),
      Container(
        height: 400,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: child,
      ),
    ],
  );

  Widget _buildTradingCalendarWithCards() => UniversalCalendarWidget(
    onDateSelectionChanged: (selection) {
      setState(() {
        _currentSelection = selection;
      });
      print('Trading Calendar Selection: $selection');
    },
    context: 'trade',
    title: 'Trading Analysis',
    enableCardView: true,
    cardConfigs: [
      const CalendarCardConfig(
        type: CalendarCardType.pnlSummary,
        title: 'P&L Summary',
        theme: CalendarCardTheme.neutral,
      ),
      const CalendarCardConfig(
        type: CalendarCardType.tradeMetrics,
        title: 'Trade Metrics',
        size: CardSizeType.large,
        layout: CardLayoutStyle.grid,
        theme: CalendarCardTheme.info,
      ),
      const CalendarCardConfig(
        type: CalendarCardType.winLossRatio,
        title: 'Win/Loss Ratio',
        size: CardSizeType.small,
        layout: CardLayoutStyle.chart,
        theme: CalendarCardTheme.success,
      ),
    ],
    dataProvider: TradeCalendarDataProvider(
      portfolioId: '8a57024c-05c2-475b-a2c4-0545865efa4a',
      mockData: _getMockTradeData(),
    ),
  );

  Widget _buildPortfolioCalendar() => UniversalCalendarWidget(
    onDateSelectionChanged: (selection) {
      print('Portfolio Calendar Selection: $selection');
    },
    context: 'portfolio',
    templateType: CalendarTemplateType.full,
    title: 'Portfolio Analysis',
    enableCardView: true,
    cardConfigs: [
      const CalendarCardConfig(
        type: CalendarCardType.portfolioValue,
        title: 'Portfolio Value',
        theme: CalendarCardTheme.info,
      ),
      const CalendarCardConfig(
        type: CalendarCardType.assetAllocation,
        title: 'Asset Allocation',
        size: CardSizeType.large,
        layout: CardLayoutStyle.chart,
        theme: CalendarCardTheme.neutral,
      ),
    ],
    dataProvider: PortfolioCalendarDataProvider(
      portfolioId: 'sample-portfolio-id',
    ),
  );

  Widget _buildQuickDateFilter() => QuickDateFilter(
    onDateSelectionChanged: (selection) {
      print('Quick Filter Selection: $selection');
    },
    initialSelection: DateSelection(
      startDate: DateTime.now().subtract(const Duration(days: 7)),
      endDate: DateTime.now(),
      description: 'Last 7 Days',
      filterType: DateFilterMode.quick,
    ),
  );

  Widget _buildWebDateFilter() => WebDateFilter(
    onDateSelectionChanged: (selection) {
      print('Web Filter Selection: $selection');
    },
    title: 'Web Analytics Period',
  );

  Widget _buildTradeDateFilter() => TradeDateFilter(
    onDateSelectionChanged: (selection) {
      print('Trade Filter Selection: $selection');
    },
    title: 'Trading Period',
  );

  Map<String, dynamic> _getMockTradeData() => {
    '8a57024c-05c2-475b-a2c4-0545865efa4a': [
      {
        'tradeId': 'sample-trade-1',
        'portfolioId': '8a57024c-05c2-475b-a2c4-0545865efa4a',
        'status': 'WIN',
        'tradePositionType': 'LONG',
        'entryInfo': {'quantity': 100, 'price': 50.0, 'fees': 2.0},
        'exitInfo': {'quantity': 100, 'price': 55.0, 'fees': 2.0},
        'metrics': {'totalPnL': 496.0, 'returnPercent': 10.0},
        'tradeDate': '2024-01-15',
        'tradeEndDate': '2024-01-20',
      },
      {
        'tradeId': 'sample-trade-2',
        'portfolioId': '8a57024c-05c2-475b-a2c4-0545865efa4a',
        'status': 'LOSS',
        'tradePositionType': 'SHORT',
        'entryInfo': {'quantity': 50, 'price': 100.0, 'fees': 2.0},
        'exitInfo': {'quantity': 50, 'price': 105.0, 'fees': 2.0},
        'metrics': {'totalPnL': -254.0, 'returnPercent': -5.0},
        'tradeDate': '2024-01-16',
        'tradeEndDate': '2024-01-18',
      },
    ],
  };
}

/// Predefined card configurations for different contexts
class CalendarPresets {
  /// Trading focused card configurations
  static List<card_types.CalendarCardConfig> get tradingCards => [
    const card_types.CalendarCardConfig(
      type: card_types.CalendarCardType.pnlSummary,
      title: 'Daily P&L',
    ),
    const card_types.CalendarCardConfig(
      type: card_types.CalendarCardType.tradeMetrics,
      title: 'Trade Count & Win Rate',
      size: card_types.CardSizeType.large,
      layout: card_types.CardLayoutStyle.grid,
      theme: card_types.CardTheme.info,
    ),
    const card_types.CalendarCardConfig(
      type: card_types.CalendarCardType.winLossRatio,
      title: 'Win/Loss',
      size: card_types.CardSizeType.small,
      layout: card_types.CardLayoutStyle.chart,
      theme: card_types.CardTheme.success,
    ),
    const CalendarCardConfig(
      type: CalendarCardType.riskReward,
      title: 'Risk/Reward',
      size: CardSizeType.small,
      theme: CalendarCardTheme.warning,
    ),
  ];

  /// Portfolio focused card configurations
  static List<CalendarCardConfig> get portfolioCards => [
    const CalendarCardConfig(
      type: CalendarCardType.portfolioValue,
      title: 'Portfolio Value',
      theme: CalendarCardTheme.info,
    ),
    const CalendarCardConfig(
      type: CalendarCardType.assetAllocation,
      title: 'Asset Allocation',
      size: CardSizeType.large,
      layout: CardLayoutStyle.chart,
      theme: CalendarCardTheme.neutral,
    ),
    const CalendarCardConfig(
      type: CalendarCardType.portfolioPerformance,
      title: 'Performance',
      layout: CardLayoutStyle.comparison,
      theme: CalendarCardTheme.success,
    ),
  ];

  /// Analytics focused card configurations
  static List<CalendarCardConfig> get analyticsCards => [
    const CalendarCardConfig(
      type: CalendarCardType.volumeAnalysis,
      title: 'Volume Analysis',
      size: CardSizeType.large,
      layout: CardLayoutStyle.chart,
      theme: CalendarCardTheme.info,
    ),
    const CalendarCardConfig(
      type: CalendarCardType.sectorPerformance,
      title: 'Sector Performance',
      size: CardSizeType.full,
      layout: CardLayoutStyle.heatmap,
      theme: CalendarCardTheme.neutral,
    ),
    const CalendarCardConfig(
      type: CalendarCardType.timeAnalysis,
      title: 'Time Analysis',
      layout: CardLayoutStyle.timeline,
      theme: CalendarCardTheme.warning,
    ),
  ];

  /// Minimal card configurations for dashboard use
  static List<CalendarCardConfig> get dashboardCards => [
    const CalendarCardConfig(
      type: CalendarCardType.summary,
      title: 'Summary',
      size: CardSizeType.small,
      theme: CalendarCardTheme.neutral,
    ),
  ];
}
