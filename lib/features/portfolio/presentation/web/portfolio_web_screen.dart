import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/portfolio_heatmap_web_card.dart';
import '../widgets/portfolio_sidebar.dart';
import '../cubit/portfolio_state.dart';
import '../../providers/portfolio_providers.dart';
import '../../internal/domain/entities/portfolio_list.dart';
import 'pages/portfolio_overview_web_page.dart';
import 'pages/portfolio_holdings_web_page.dart';
import 'pages/portfolio_analysis_web_page.dart';

/// Web-specific portfolio screen implementation
class PortfolioWebScreen extends ConsumerStatefulWidget {
  final String userId;
  final String? selectedPortfolioId;
  final String? selectedPortfolioName;
  final List<PortfolioItem>? portfolios;
  final Function(String portfolioId, String portfolioName)? onPortfolioChanged;

  const PortfolioWebScreen({
    super.key,
    required this.userId,
    this.selectedPortfolioId,
    this.selectedPortfolioName,
    this.portfolios,
    this.onPortfolioChanged,
  });

  @override
  ConsumerState<PortfolioWebScreen> createState() => _PortfolioWebScreenState();
}

class _PortfolioWebScreenState extends ConsumerState<PortfolioWebScreen> {
  PortfolioViewType _selectedView = PortfolioViewType.overview;
  String? _currentPortfolioId;

  @override
  void initState() {
    super.initState();
    _currentPortfolioId = widget.selectedPortfolioId ?? widget.userId;
  }

  void _onPortfolioChanged(String portfolioId, String portfolioName) {
    setState(() {
      _currentPortfolioId = portfolioId;
    });

    // Invalidate providers to refresh data for new portfolio
    ref.invalidate(portfolioSummaryProvider(_currentPortfolioId!));
    ref.invalidate(portfolioHoldingsProvider(_currentPortfolioId!));

    // Notify parent if callback is provided
    widget.onPortfolioChanged?.call(portfolioId, portfolioName);
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(
      portfolioSummaryProvider(_currentPortfolioId!),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedPortfolioName ?? 'Portfolio'),
        actions: [
          // Portfolio selector dropdown
          if (widget.portfolios != null && widget.portfolios!.length > 1)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: DropdownButton<String>(
                value: _currentPortfolioId,
                icon: const Icon(Icons.arrow_drop_down),
                underline: Container(),
                items: widget.portfolios!.map<DropdownMenuItem<String>>((
                  portfolio,
                ) {
                  return DropdownMenuItem<String>(
                    value: portfolio.portfolioId,
                    child: Text(
                      portfolio.portfolioName,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    final selectedPortfolio = widget.portfolios!.firstWhere(
                      (p) => p.portfolioId == newValue,
                    );
                    _onPortfolioChanged(
                      newValue,
                      selectedPortfolio.portfolioName,
                    );
                  }
                },
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(portfolioSummaryProvider(_currentPortfolioId!));
              ref.invalidate(portfolioHoldingsProvider(_currentPortfolioId!));
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Left sidebar for navigation
          Container(
            width: 250,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
            ),
            child: PortfolioSidebar(
              selectedView: _selectedView,
              onViewChanged: (viewType) {
                setState(() {
                  _selectedView = viewType;
                });
              },
            ),
          ),
          // Summary sidebar
          Container(
            width: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
            ),
            child: _buildSummarySection(context, summaryAsync),
          ),
          // Main content area
          Expanded(child: _buildMainContent(context)),
        ],
      ),
    );
  }

  /// Build main content based on selected view
  Widget _buildMainContent(BuildContext context) {
    switch (_selectedView) {
      case PortfolioViewType.overview:
        return _buildOverviewContent(context);
      case PortfolioViewType.holdings:
        return _buildHoldingsContent(context);
      case PortfolioViewType.analysis:
        return _buildAnalysisContent(context);
      case PortfolioViewType.heatmap:
        return _buildHeatmapContent(context);
    }
  }

  /// Build overview content using dedicated overview page
  Widget _buildOverviewContent(BuildContext context) {
    return PortfolioOverviewWebPage(
      userId: widget.userId,
      portfolioId: _currentPortfolioId!,
      portfolioName: widget.selectedPortfolioName,
    );
  }

  /// Build holdings content using dedicated holdings page
  Widget _buildHoldingsContent(BuildContext context) {
    return PortfolioHoldingsWebPage(
      userId: widget.userId,
      portfolioId: _currentPortfolioId!,
      portfolioName: widget.selectedPortfolioName,
    );
  }

  /// Build analysis content using dedicated analysis page
  Widget _buildAnalysisContent(BuildContext context) {
    return PortfolioAnalysisWebPage(
      userId: widget.userId,
      portfolioId: _currentPortfolioId!,
      portfolioName: widget.selectedPortfolioName,
    );
  }

  /// Build heatmap content
  Widget _buildHeatmapContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Portfolio Heatmap',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: PortfolioHeatmapWebCard(
              portfolioId: _currentPortfolioId!,
              title: 'Sector Performance Heatmap',
              icon: Icons.grid_view,
              onTilePressed: () {
                // Handle tile press - could show sector details
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection(BuildContext context, AsyncValue summaryAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Portfolio Summary',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        summaryAsync.when(
          data: (summary) => _buildSummaryCards(context, summary),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) =>
              _buildSummaryError(context, error.toString()),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(BuildContext context, dynamic summary) {
    return Column(
      children: [
        _buildSummaryCard(
          context,
          'Total Value',
          '\$${summary.totalValue.toStringAsFixed(2)}',
          Icons.account_balance_wallet,
          Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildSummaryCard(
          context,
          'Today\'s Change',
          '\$${summary.todayChange.toStringAsFixed(2)}',
          summary.todayChange >= 0 ? Icons.trending_up : Icons.trending_down,
          summary.todayChange >= 0 ? Colors.green : Colors.red,
        ),
        const SizedBox(height: 12),
        _buildSummaryCard(
          context,
          'Total Return',
          '\$${summary.totalValue.toStringAsFixed(2)}',
          summary.totalValue >= 0 ? Icons.trending_up : Icons.trending_down,
          summary.totalValue >= 0 ? Colors.green : Colors.red,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodySmall),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryError(BuildContext context, String error) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 32),
            const SizedBox(height: 8),
            Text(
              'Failed to load summary',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              error,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
