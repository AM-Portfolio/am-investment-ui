import 'package:flutter/material.dart';
import '../../../core/models/portfolio/portfolio_holdings.dart';
import '../../../core/services/api/portfolio_client.dart';
import '../../../widgets/shared/finance/portfolio_holdings_view.dart';
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
  String _currentPage = 'Holdings';
  
  // Portfolio client for API calls
  late final PortfolioClient _portfolioClient;

  // Future for portfolio holdings data
  late Future<PortfolioHoldings> _holdingsFuture;
  
  /// Handle page selection from sidebar
  void _handlePageSelected(String page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeApiClient();
    _loadHoldings();
  }

  /// Initialize API client
  void _initializeApiClient() {
    _portfolioClient = PortfolioClient(
      baseUrl: 'http://localhost:8082',
      useMockData: false, // Using real API data
    );
    debugPrint(
      'Portfolio client initialized with baseUrl: http://localhost:8082',
    );
  }

  /// Load portfolio holdings data
  void _loadHoldings() {
    debugPrint('Loading portfolio holdings for user: ${widget.userId}');
    _holdingsFuture = _portfolioClient.getPortfolioHoldings(widget.userId);
  }

  /// Refresh holdings data
  void _refreshHoldings() {
    debugPrint('Refreshing portfolio holdings for user: ${widget.userId}');
    setState(() {
      _loadHoldings();
    });
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
                        // Portfolio holdings view - with dynamic height
                        PortfolioHoldingsView(
                          holdingsFuture: _holdingsFuture,
                          onRefresh: _refreshHoldings,
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
    _portfolioClient.dispose();
    super.dispose();
  }
}
