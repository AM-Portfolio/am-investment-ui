import 'package:flutter/material.dart';
import '../../core/models/portfolio/portfolio_models.dart';
import '../../core/services/api/portfolio_client.dart';
import '../../core/services/api/api_client.dart';
import '../../config/environment.dart';
import '../../core/utils/platform_utils.dart';
import 'web/portfolio_web_screen.dart';
import 'ios/portfolio_ios_screen.dart';
import 'android/portfolio_android_screen.dart';

/// Screen to display portfolio information
/// This is the base class that handles shared logic and delegates UI to platform-specific implementations
class PortfolioScreen extends StatefulWidget {
  /// User ID for portfolio data
  final String userId;
  
  /// Constructor
  const PortfolioScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  /// Portfolio client for API calls
  late final PortfolioClient _portfolioClient;
  
  /// Future for portfolio summary data
  late Future<ApiResponse<PortfolioSummary>> _portfolioSummaryFuture;
  
  @override
  void initState() {
    super.initState();
    _initializeApiClient();
    _loadPortfolioSummary();
    
    // Listen for environment changes
    EnvironmentConfig.addListener(_onEnvironmentChanged);
  }
  
  /// Initialize API client with current environment settings
  void _initializeApiClient() {
    _portfolioClient = PortfolioClient(
      baseUrl: EnvironmentConfig.apiBaseUrl,
      useMockData: EnvironmentConfig.settings['useMockData'] ?? true,
    );
  }
  
  /// Handle environment changes
  void _onEnvironmentChanged(Environment env) {
    // Dispose old client
    _portfolioClient.dispose();
    
    // Create new client with updated environment
    _initializeApiClient();
    
    // Reload data
    setState(() {
      _loadPortfolioSummary();
    });
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
    // Remove environment change listener
    EnvironmentConfig.removeListener(_onEnvironmentChanged);
    _portfolioClient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Delegate to platform-specific implementations
    if (PlatformUtils.isWeb) {
      return PortfolioWebScreen(
        refreshPortfolio: _refreshPortfolio,
        userId: widget.userId,
      );
    } else if (PlatformUtils.isIOS) {
      return PortfolioIOSScreen(
        portfolioSummaryFuture: _portfolioSummaryFuture,
        refreshPortfolio: _refreshPortfolio,
        userId: widget.userId,
      );
    } else {
      return PortfolioAndroidScreen(
        portfolioSummaryFuture: _portfolioSummaryFuture,
        refreshPortfolio: _refreshPortfolio,
        userId: widget.userId,
      );
    }
  }
}
