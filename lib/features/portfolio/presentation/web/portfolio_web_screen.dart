import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/portfolio_sidebar.dart';
import '../cubit/portfolio_state.dart';
import '../../providers/portfolio_providers.dart';
import '../../internal/domain/entities/portfolio_list.dart';
import 'pages/portfolio_overview_web_page.dart';
import 'pages/portfolio_holdings_web_page.dart';
import 'pages/portfolio_analysis_web_page.dart';
import 'pages/portfolio_heatmap_web_page.dart';

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

  /// Build heatmap content using dedicated heatmap page
  Widget _buildHeatmapContent(BuildContext context) {
    return PortfolioHeatmapWebPage(
      userId: widget.userId,
      portfolioId: _currentPortfolioId!,
      portfolioName: widget.selectedPortfolioName,
    );
  }
}
