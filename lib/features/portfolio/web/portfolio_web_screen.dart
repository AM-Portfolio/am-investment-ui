import 'package:flutter/material.dart';
import '../../../core/config/config_service.dart';
import '../../../core/repositories/portfolio_repository.dart';
import '../../../widgets/shared/finance/portfolio_holdings_view.dart';
import '../../../widgets/shared/finance/portfolio_overview.dart';
import '../../../widgets/shared/layouts/web_layout.dart';
import '../../../widgets/shared/navigation/portfolio_sidebar.dart';

/// Web-specific implementation of the portfolio screen
/// Simplified version that only shows portfolio holdings
class PortfolioWebScreen extends StatefulWidget {
  /// User ID for portfolio data
  final String userId;

  /// Callback to refresh portfolio data
  final Future<void> Function() refreshPortfolio;

  /// Constructor
  const PortfolioWebScreen({
    super.key,
    required this.refreshPortfolio,
    required this.userId,
  });

  @override
  State<PortfolioWebScreen> createState() => _PortfolioWebScreenState();
}

class _PortfolioWebScreenState extends State<PortfolioWebScreen> {
  // Current selected page in sidebar
  String _currentPage = 'Overview';
  
  // Portfolio repository for data operations
  late final PortfolioRepository _portfolioRepository;

  // Future for portfolio holdings data
  late Future<PortfolioHoldings> _holdingsFuture;
  
  // Future for portfolio summary data
  late Future<PortfolioSummary> _summaryFuture;
  
  /// Handle page selection from sidebar
  void _handlePageSelected(String page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeRepository();
    _loadHoldings();
    _loadSummary();
  }

  /// Initialize portfolio repository
  void _initializeRepository() {
    _portfolioRepository = PortfolioRepository();
  }

  /// Load portfolio holdings data
  void _loadHoldings() {
    debugPrint('Loading portfolio holdings for user: ${widget.userId}');
    debugPrint('Using base URL: ${ConfigService.config.api.baseUrl}');
    debugPrint('Holdings endpoint: ${ConfigService.config.api.portfolio.holdingsEndpoint}');
    debugPrint('Full holdings URL: ${ConfigService.getPortfolioHoldingsUrl(userId: widget.userId)}');
    _holdingsFuture = _portfolioRepository.getPortfolioHoldings(widget.userId);
  }
  
  /// Load portfolio summary data
  void _loadSummary() {
    debugPrint('Loading portfolio summary for user: ${widget.userId}');
    debugPrint('Using base URL: ${ConfigService.config.api.baseUrl}');
    debugPrint('Summary endpoint: ${ConfigService.config.api.portfolio.summaryEndpoint}');
    debugPrint('Full summary URL: ${ConfigService.getPortfolioSummaryUrl(userId: widget.userId)}');
    _summaryFuture = _portfolioRepository.getPortfolioSummary(widget.userId);
  }

  /// Refresh holdings data
  void _refreshHoldings() {
    debugPrint('Refreshing portfolio holdings for user: ${widget.userId}');
    setState(() {
      _loadHoldings();
    });
  }
  
  /// Refresh all portfolio data
  Future<void> _refreshAllData() async {
    debugPrint('Refreshing all portfolio data for user: ${widget.userId}');
    setState(() {
      _loadHoldings();
      _loadSummary();
    });
    // Add a small delay to simulate network request
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return WebLayout(
      title: 'Portfolio Holdings',
      activeNavItem: 'Portfolio',
      child: _buildContent(),
    );
  }

  /// Build the main content
  Widget _buildContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive padding based on screen size
        final horizontalPadding = constraints.maxWidth * 0.02; // 2% of width
        final verticalPadding = constraints.maxHeight * 0.02; // 2% of height

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          // Use Row to place sidebar on the left
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left sidebar
              PortfolioSidebar(
                currentPage: _currentPage,
                onPageSelected: _handlePageSelected,
              ),
              
              // Add spacing between sidebar and content
              SizedBox(width: horizontalPadding),
              
              // Main content area - expanded to fill available space
              Expanded(
                child: SingleChildScrollView(
                  // Set a minimum height to ensure proper scrolling behavior
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - (verticalPadding * 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Conditionally display content based on selected sidebar item
                        if (_currentPage == 'Overview')
                          // Portfolio overview with summary and quick actions
                          FutureBuilder<PortfolioSummary>(
                            future: _summaryFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (snapshot.hasError) {
                                return Center(
                                  child: Text(
                                    'Error loading portfolio summary: ${snapshot.error}',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                );
                              } else if (snapshot.hasData) {
                                return PortfolioOverview(
                                  summary: snapshot.data!,
                                  onRefresh: _refreshAllData,
                                );
                              } else {
                                return const Center(
                                  child: Text('No portfolio summary data available'),
                                );
                              }
                            },
                          )
                        else if (_currentPage == 'Holdings')
                          // Portfolio holdings view
                          PortfolioHoldingsView(
                            holdingsFuture: _holdingsFuture,
                            onRefresh: _refreshHoldings,
                          )
                        else if (_currentPage == 'Analysis')
                          // Placeholder for Analysis section
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.analytics_outlined,
                                    size: 64,
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Portfolio Analysis',
                                    style: Theme.of(context).textTheme.headlineMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Advanced portfolio analysis features coming soon.',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
