import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../core/config/config_service.dart';
import '../../core/domain/entities/portfolio/portfolio_summary.dart';
import '../../core/domain/repositories/portfolio_repository.dart';
import '../../config/environment.dart';
import '../../core/utils/platform_utils.dart';
import 'web/portfolio_web_screen.dart';
//import 'ios/portfolio_ios_screen.dart';
//import 'android/portfolio_android_screen.dart';

/// Screen to display portfolio information
/// This is the base class that handles shared logic and delegates UI to platform-specific implementations
class PortfolioScreen extends StatefulWidget {
  /// User ID for portfolio data
  final String userId;

  /// Constructor
  const PortfolioScreen({super.key, required this.userId});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  /// Portfolio repository for data access
  late final PortfolioRepository _portfolioRepository;

  /// Future for portfolio summary data
  late Future<PortfolioSummary> _portfolioSummaryFuture;

  @override
  void initState() {
    super.initState();
    _initializeRepository();
    _loadPortfolioSummary();

    // Listen for environment changes
    EnvironmentConfig.addListener(_onEnvironmentChanged);
  }

  /// Initialize repository
  void _initializeRepository() {
    _portfolioRepository = PortfolioRepositoryImpl();
  }

  /// Handle environment changes
  void _onEnvironmentChanged(Environment env) {
    // Reinitialize repository with new settings
    _initializeRepository();

    // Reload data
    setState(() {
      _loadPortfolioSummary();
    });
  }

  /// Load portfolio summary data
  void _loadPortfolioSummary() {
    _portfolioSummaryFuture = _portfolioRepository.getSummary();
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
