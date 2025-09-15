import 'package:flutter/material.dart';
import '../../../core/models/portfolio/portfolio_holdings.dart';
import '../../../core/services/api/portfolio_client.dart';
import '../../../widgets/shared/finance/portfolio_holdings_view.dart';
import '../../../widgets/shared/layouts/web_layout.dart';

/// Web-specific implementation of the portfolio screen
/// Simplified version that only shows portfolio holdings
class PortfolioWebScreen extends StatefulWidget {
  /// User ID for portfolio data
  final String userId;
  
  /// Callback to refresh portfolio data
  final Future<void> Function() refreshPortfolio;
  
  /// Constructor
  const PortfolioWebScreen({
    Key? key,
    required this.refreshPortfolio,
    required this.userId,
  }) : super(key: key);
  
  @override
  State<PortfolioWebScreen> createState() => _PortfolioWebScreenState();
}

class _PortfolioWebScreenState extends State<PortfolioWebScreen> {
  // Portfolio client for API calls
  late final PortfolioClient _portfolioClient;
  
  // Future for portfolio holdings data
  late Future<PortfolioHoldings> _holdingsFuture;

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
    debugPrint('Portfolio client initialized with baseUrl: http://localhost:8082');
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
        // Reduce padding to maximize available space for content
        final horizontalPadding = constraints.maxWidth * 0.01; // 1% of width
        final verticalPadding = constraints.maxHeight * 0.01; // 1% of height
        
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page title - make more compact
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Portfolio Holdings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Add refresh button at the top level for easier access
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _refreshHoldings,
                    tooltip: 'Refresh holdings',
                  ),
                ],
              ),
              SizedBox(height: constraints.maxHeight * 0.01), // 1% of height
              
              // Holdings view - give maximum space
              Expanded(
                child: PortfolioHoldingsView(
                  holdingsFuture: _holdingsFuture,
                  onRefresh: _refreshHoldings,
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
