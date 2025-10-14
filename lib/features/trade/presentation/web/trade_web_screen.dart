import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/logger.dart';
import '../../providers/trade_internal_providers.dart';
import '../components/templates/trade_portfolio_discovery_template.dart';
import '../models/trade_portfolio_view_model.dart';
import '../widgets/trade_sidebar.dart';
import 'pages/trade_calendar_analytics_web_page.dart';
import 'pages/trade_holdings_dashboard_web_page.dart';

/// Trade view types for navigation
enum TradeViewType { portfolios, holdings, calendar }

/// Web-specific trade screen implementation with sidebar navigation
class TradeWebScreen extends ConsumerStatefulWidget {
  const TradeWebScreen({
    required this.userId,
    super.key,
    this.selectedPortfolioId,
    this.selectedPortfolioName,
    this.initialView = TradeViewType.portfolios,
  });

  final String userId;
  final String? selectedPortfolioId;
  final String? selectedPortfolioName;
  final TradeViewType initialView;

  @override
  ConsumerState<TradeWebScreen> createState() => _TradeWebScreenState();
}

class _TradeWebScreenState extends ConsumerState<TradeWebScreen> {
  late TradeViewType _selectedView;
  String? _currentPortfolioId;
  String? _currentPortfolioName;

  @override
  void initState() {
    super.initState();
    _selectedView = widget.initialView;
    _currentPortfolioId = widget.selectedPortfolioId;
    _currentPortfolioName = widget.selectedPortfolioName;

    AppLogger.info(
      'TradeWebScreen initialized with view: $_selectedView',
      tag: 'TradeWebScreen',
    );
  }

  void _onViewChanged(TradeViewType viewType) {
    setState(() {
      _selectedView = viewType;
    });

    AppLogger.info('Trade view changed to: $viewType', tag: 'TradeWebScreen');
  }

  void _onPortfolioSelected(String portfolioId, String portfolioName) {
    setState(() {
      _currentPortfolioId = portfolioId;
      _currentPortfolioName = portfolioName;
      // Automatically switch to holdings view when portfolio is selected
      if (_selectedView == TradeViewType.portfolios) {
        _selectedView = TradeViewType.holdings;
      }
    });

    AppLogger.info(
      'Portfolio selected: $portfolioName ($portfolioId)',
      tag: 'TradeWebScreen',
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: _buildAppBar(context),
    body: Row(
      children: [
        // Left sidebar for trade navigation
        Container(
          width: 280,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: Theme.of(context).dividerColor),
            ),
            color: Theme.of(context).cardColor,
          ),
          child: TradeSidebar(
            selectedView: _selectedView,
            onViewChanged: _onViewChanged,
            currentPortfolioId: _currentPortfolioId,
            currentPortfolioName: _currentPortfolioName,
          ),
        ),

        // Main content area
        Expanded(child: _buildMainContent(context)),
      ],
    ),
  );

  /// Build app bar with context-aware title and actions
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    var title = 'Trade Analysis';

    switch (_selectedView) {
      case TradeViewType.portfolios:
        title = 'Portfolio Discovery';
        break;
      case TradeViewType.holdings:
        title = _currentPortfolioName != null
            ? 'Holdings Dashboard - $_currentPortfolioName'
            : 'Trade Holdings Dashboard';
        break;
      case TradeViewType.calendar:
        title = _currentPortfolioName != null
            ? 'Calendar Analytics - $_currentPortfolioName'
            : 'Trade Calendar Analytics';
        break;
    }

    return AppBar(
      title: Row(
        children: [
          Icon(Icons.swap_horiz, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
      actions: [
        // Back to portfolios button (when portfolio is selected)
        if (_currentPortfolioId != null &&
            _selectedView != TradeViewType.portfolios)
          TextButton.icon(
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Portfolios'),
            onPressed: () {
              setState(() {
                _selectedView = TradeViewType.portfolios;
                _currentPortfolioId = null;
                _currentPortfolioName = null;
              });
            },
          ),

        // Refresh button
        Consumer(
          builder: (context, ref, child) => IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
            onPressed: () {
              AppLogger.info(
                'Refreshing trade data for view: $_selectedView',
                tag: 'TradeWebScreen',
              );

              // Invalidate relevant providers based on current view
              switch (_selectedView) {
                case TradeViewType.portfolios:
                  ref.invalidate(tradePortfoliosStreamProvider(widget.userId));
                  break;
                case TradeViewType.holdings:
                  if (_currentPortfolioId != null) {
                    final params = (
                      userId: widget.userId,
                      portfolioId: _currentPortfolioId!,
                    );
                    ref.invalidate(tradeHoldingsStreamProvider(params));
                    ref.invalidate(tradeSummaryStreamProvider(params));
                  }
                  break;
                case TradeViewType.calendar:
                  if (_currentPortfolioId != null) {
                    final params = (
                      userId: widget.userId,
                      portfolioId: _currentPortfolioId!,
                    );
                    ref.invalidate(tradeCalendarStreamProvider(params));
                  }
                  break;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Refreshing ${_selectedView.name} data...'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ),

        const SizedBox(width: 8),
      ],
    );
  }

  /// Build main content based on selected view
  Widget _buildMainContent(BuildContext context) {
    switch (_selectedView) {
      case TradeViewType.portfolios:
        return _buildPortfoliosView();

      case TradeViewType.holdings:
        if (_currentPortfolioId == null) {
          return _buildSelectPortfolioPrompt();
        }
        return TradeHoldingsDashboardWebPage(
          userId: widget.userId,
          portfolioId: _currentPortfolioId!,
        );

      case TradeViewType.calendar:
        if (_currentPortfolioId == null) {
          return _buildSelectPortfolioPrompt();
        }
        return TradeCalendarAnalyticsWebPage(
          userId: widget.userId,
          portfolioId: _currentPortfolioId!,
        );
    }
  }

  /// Build portfolios view with integrated navigation
  Widget _buildPortfoliosView() => Consumer(
    builder: (context, ref, child) {
      final portfoliosAsync = ref.watch(
        tradePortfoliosStreamProvider(widget.userId),
      );

      return portfoliosAsync.when(
        data: (portfolios) => TradePortfolioDiscoveryTemplate(
          portfolios: portfolios,
          isLoading: false,
          onPortfolioSelected: (portfolio) {
            _onPortfolioSelected(portfolio.id, portfolio.name);
          },
          onRefresh: () {
            ref.invalidate(tradePortfoliosStreamProvider(widget.userId));
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => TradePortfolioDiscoveryTemplate(
          portfolios: const <TradePortfolioViewModel>[],
          isLoading: false,
          errorMessage: error.toString(),
          onPortfolioSelected: (_) {},
          onRefresh: () {
            ref.invalidate(tradePortfoliosStreamProvider(widget.userId));
          },
        ),
      );
    },
  );

  /// Build prompt to select a portfolio
  Widget _buildSelectPortfolioPrompt() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _selectedView == TradeViewType.holdings
              ? Icons.dashboard_outlined
              : Icons.calendar_today_outlined,
          size: 64,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
        ),
        const SizedBox(height: 16),
        Text(
          'Select a Portfolio',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _selectedView == TradeViewType.holdings
              ? 'Choose a portfolio to access the comprehensive holdings dashboard with detailed analytics and summary views'
              : 'Choose a portfolio to explore the interactive calendar analytics with trade event insights',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          icon: const Icon(Icons.account_balance_wallet),
          label: const Text('Browse Portfolios'),
          onPressed: () {
            setState(() {
              _selectedView = TradeViewType.portfolios;
            });
          },
        ),
      ],
    ),
  );
}
