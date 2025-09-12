import 'package:flutter/material.dart';
import '../../../core/models/portfolio/portfolio_models.dart';
import '../../../core/services/api/portfolio_client.dart';
import '../widgets/portfolio_summary_card.dart';
import '../widgets/holdings_breakdown.dart';
import '../../../config/environment.dart';

/// Screen to display portfolio summary information
class PortfolioSummaryScreen extends StatefulWidget {
  /// User ID for portfolio data
  final String userId;
  
  /// Constructor
  const PortfolioSummaryScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<PortfolioSummaryScreen> createState() => _PortfolioSummaryScreenState();
}

class _PortfolioSummaryScreenState extends State<PortfolioSummaryScreen> {
  /// Portfolio client for API calls
  late final PortfolioClient _portfolioClient;
  
  /// Future for portfolio summary data
  late Future<ApiResponse<PortfolioSummary>> _portfolioSummaryFuture;
  
  @override
  void initState() {
    super.initState();
    _portfolioClient = PortfolioClient(
      baseUrl: EnvironmentConfig.apiBaseUrl,
      useMockData: EnvironmentConfig.settings['useMockData'] ?? true,
    );
    _loadPortfolioSummary();
  }
  
  /// Load portfolio summary data
  void _loadPortfolioSummary() {
    _portfolioSummaryFuture = _portfolioClient.getPortfolioSummary(widget.userId);
  }
  
  /// Refresh portfolio data
  Future<void> _refreshPortfolio() async {
    setState(() {
      _loadPortfolioSummary();
    });
  }
  
  @override
  void dispose() {
    _portfolioClient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio Summary'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPortfolio,
        child: FutureBuilder<ApiResponse<PortfolioSummary>>(
          future: _portfolioSummaryFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading portfolio data',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshPortfolio,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            
            final response = snapshot.data!;
            
            if (!response.isSuccess) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 48,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load portfolio data',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      response.error ?? 'Unknown error',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshPortfolio,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            
            final summary = response.data!;
            
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                PortfolioSummaryCard(
                  summary: summary,
                  showDetails: true,
                ),
                const SizedBox(height: 16),
                HoldingsBreakdown(
                  summary: summary,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
