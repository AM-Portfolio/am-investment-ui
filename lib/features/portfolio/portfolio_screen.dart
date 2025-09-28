import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/platform_utils.dart';
import '../../di/app_providers.dart';
import '../../config/environment_config.dart';
import '../../shared/widgets/navigation/portfolio_sidebar.dart';
import '../../shared/widgets/portfolio/right_floating_quick_actions.dart';
import '../../shared/widgets/portfolio/enhanced_portfolio_quick_actions.dart';
import 'presentation/web/portfolio_holdings_widget.dart';
import '../../shared/widgets/cards/portfolio_holdings_card.dart';
import '../../shared/widgets/filters/portfolio_filter_widget.dart';
import '../../core/app_logic/domain/entities/portfolio/portfolio_holdings.dart';

/// Screen to display portfolio information with sidebar navigation and quick actions
class PortfolioScreen extends ConsumerStatefulWidget {
  /// User ID for portfolio data
  final String userId;

  /// Constructor
  const PortfolioScreen({super.key, required this.userId});

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen> {
  String _currentPage = 'Holdings'; // Default to Holdings page
  String? _currentPortfolioId;
  bool _showQuickActions = true;
  List<dynamic> _filteredHoldings = [];
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    // Listen for environment changes
    EnvironmentConfig.addListener(_onEnvironmentChanged);
  }

  /// Handle environment changes
  void _onEnvironmentChanged(Environment env) {
    // Invalidate providers to reload with new settings
    ref.invalidate(portfolioRepositoryProvider);
    ref.invalidate(portfolioSummaryProvider);
  }

  /// Refresh portfolio data
  Future<void> _refreshPortfolio() async {
    // Invalidate providers to force refresh
    ref.invalidate(portfolioSummaryProvider);
    ref.invalidate(portfolioHoldingsProvider);
  }

  @override
  void dispose() {
    // Remove environment change listener
    EnvironmentConfig.removeListener(_onEnvironmentChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if it's mobile for responsive design
    final isMobile = MediaQuery.of(context).size.width < 800;
    
    return Scaffold(
      appBar: AppBar(
        //title: const Text('Portfolio Management'),
        actions: [
          IconButton(
            icon: Icon(_showQuickActions ? Icons.expand_less : Icons.expand_more),
            onPressed: () {
              setState(() {
                _showQuickActions = !_showQuickActions;
              });
            },
            tooltip: _showQuickActions ? 'Hide Quick Actions' : 'Show Quick Actions',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshPortfolio,
          ),
        ],
      ),
      body: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
    );
  }
  
  /// Build desktop layout with sidebar
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left Sidebar
        Container(
          width: 220,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              right: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: PortfolioSidebar(
            currentPage: _currentPage,
            onPageSelected: _onPageSelected,
          ),
        ),
        // Main Content Area
        Expanded(
          child: Stack(
            children: [
              _buildMainContent(),
              // Right Floating Quick Actions
              if (_showQuickActions)
                RightFloatingQuickActions(
                  userId: widget.userId,
                  portfolioId: _currentPortfolioId,
                  onPortfolioCreated: (portfolioId) {
                    setState(() {
                      _currentPortfolioId = portfolioId;
                    });
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Portfolio created successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    
                    _refreshPortfolio();
                  },
                  onTradeDetailsAdded: (message) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _refreshPortfolio();
                  },
                  onError: _handleError,
                ),
            ],
          ),
        ),
      ],
    );
  }
  
  /// Build mobile layout with drawer
  Widget _buildMobileLayout() {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Row(
                children: [
                  Icon(Icons.account_balance_wallet, color: Colors.white, size: 32),
                  SizedBox(width: 12),
                  Text(
                    'Portfolio',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            PortfolioSidebar(
              currentPage: _currentPage,
              onPageSelected: (page) {
                _onPageSelected(page);
                Navigator.of(context).pop(); // Close drawer
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Main Content
          _buildMainContent(),
          // Right Floating Quick Actions for mobile
          if (_showQuickActions)
            RightFloatingQuickActions(
              userId: widget.userId,
              portfolioId: _currentPortfolioId,
              onPortfolioCreated: (portfolioId) {
                setState(() {
                  _currentPortfolioId = portfolioId;
                });
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Portfolio created successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
                
                _refreshPortfolio();
              },
              onTradeDetailsAdded: (message) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: Colors.green,
                  ),
                );
                _refreshPortfolio();
              },
              onError: _handleError,
            ),
        ],
      ),
    );
  }

  /// Build main content based on selected page
  Widget _buildMainContent() {
    switch (_currentPage) {
      case 'Overview':
        return _buildOverviewContent();
      case 'Holdings':
        return _buildHoldingsContent();
      case 'Analysis':
        return _buildAnalysisContent();
      default:
        return _buildHoldingsContent();
    }
  }

  /// Build overview content
  Widget _buildOverviewContent() {
    final summaryAsync = ref.watch(portfolioSummaryProvider(widget.userId));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Portfolio Overview',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: summaryAsync.when(
              data: (summary) => _buildSummaryCards(summary),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading summary: $error'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build holdings content
  Widget _buildHoldingsContent() {
    final holdingsAsync = ref.watch(portfolioHoldingsProvider(widget.userId));
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                    icon: Icon(_showFilters ? Icons.filter_list : Icons.filter_list_outlined),
                    onPressed: () {
                      setState(() {
                        _showFilters = !_showFilters;
                      });
                    },
                    tooltip: _showFilters ? 'Hide Filters' : 'Show Filters',
                  ),
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Export coming soon')),
                      );
                    },
                    tooltip: 'Export Holdings',
                  ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Holdings content with constraints
          Expanded(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 1400, // Increased width for better table display
              ),
              child: holdingsAsync.when(
                data: (portfolioHoldings) {
                  final holdings = portfolioHoldings.holdings ?? [];
                  
                  return Column(
                    children: [
                      // Holdings card - Use the existing PortfolioHoldingsWidget for now
                      Expanded(
                        child: PortfolioHoldingsWidget(
                          userId: widget.userId,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading portfolio holdings...'),
                    ],
                  ),
                ),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading holdings',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$error',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.refresh(portfolioHoldingsProvider(widget.userId)),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build analysis content
  Widget _buildAnalysisContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Portfolio Analysis',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 64,
                  color: Theme.of(context).primaryColor.withOpacity(0.6),
                ),
                const SizedBox(height: 16),
                Text(
                  'Analysis Coming Soon',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Advanced portfolio analysis features will be available soon.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build summary cards for overview
  Widget _buildSummaryCards(dynamic summary) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildSummaryCard(
          'Total Value',
          '\$${summary.totalValue.toStringAsFixed(2)}',
          Icons.account_balance_wallet,
          Colors.blue,
        ),
        _buildSummaryCard(
          'Total Gain/Loss',
          '\$${summary.totalGainLoss.toStringAsFixed(2)}',
          Icons.trending_up,
          summary.totalGainLoss >= 0 ? Colors.green : Colors.red,
        ),
        _buildSummaryCard(
          'Total Holdings',
          '${summary.totalHoldings}',
          Icons.pie_chart,
          Colors.orange,
        ),
        _buildSummaryCard(
          'Performance',
          '${summary.totalGainLossPercentage.toStringAsFixed(2)}%',
          Icons.assessment,
          summary.totalGainLossPercentage >= 0 ? Colors.green : Colors.red,
        ),
      ],
    );
  }

  /// Build individual summary card
  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Handle page selection from sidebar
  void _onPageSelected(String page) {
    setState(() {
      _currentPage = page;
    });
  }

  /// Handle portfolio creation
  void _handlePortfolioCreated(PortfolioCreationResult result) {
    if (result.isSuccess) {
      setState(() {
        _currentPortfolioId = result.portfolioId;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Portfolio "${result.portfolioName}" created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      _refreshPortfolio();
    }
  }

  /// Handle trade details addition
  void _handleTradeDetailsAdded(TradeDetailsResult result) {
    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${result.tradesAdded} trades successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      _refreshPortfolio();
    }
  }

  /// Handle errors
  void _handleError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $error'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Show detailed information about a specific holding
  void _showHoldingDetails(dynamic holding) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        holding.symbol ?? 'Unknown',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        holding.sector ?? 'Unknown Sector',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Holding summary
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildDetailRow('Quantity', '${holding.quantity ?? 0}'),
                      _buildDetailRow('Average Price', '₹${((holding.investmentCost ?? 0) / (holding.quantity ?? 1)).toStringAsFixed(2)}'),
                      _buildDetailRow('Current Price', '₹${(holding.currentPrice ?? 0).toStringAsFixed(2)}'),
                      _buildDetailRow('Investment Cost', '₹${(holding.investmentCost ?? 0).toStringAsFixed(2)}'),
                      _buildDetailRow('Current Value', '₹${(holding.currentValue ?? 0).toStringAsFixed(2)}'),
                      _buildDetailRow('Gain/Loss', '₹${(holding.gainLoss ?? 0).toStringAsFixed(2)} (${(holding.gainLossPercentage ?? 0).toStringAsFixed(2)}%)', 
                        valueColor: (holding.gainLoss ?? 0) >= 0 ? Colors.green : Colors.red),
                      _buildDetailRow('Portfolio Weight', '${(holding.weightInPortfolio ?? 0).toStringAsFixed(2)}%'),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Additional details section
              Text(
                'Additional Details',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Details list
              Expanded(
                child: SingleChildScrollView(
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Market Information',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow('Market Cap', holding.marketCap ?? 'Unknown'),
                          _buildDetailRow('Industry', holding.industry ?? 'Unknown'),
                          _buildDetailRow('Exchange', holding.exchange ?? 'Unknown'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build a detail row for the holding details dialog
  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
