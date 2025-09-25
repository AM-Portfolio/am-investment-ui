import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/platform_utils.dart';
import '../../core/providers/app_providers.dart';
import '../../core/config/environment_config.dart';
import 'web/portfolio_web_screen.dart';
import 'widgets/portfolio_holdings_widget.dart';

/// Screen to display portfolio information
/// This is the base class that handles shared logic and delegates UI to platform-specific implementations
class PortfolioScreen extends ConsumerStatefulWidget {
  /// User ID for portfolio data
  final String userId;

  /// Constructor
  const PortfolioScreen({super.key, required this.userId});

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen> {
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
    // Delegate to platform-specific implementations
    if (PlatformUtils.isWeb) {
      return PortfolioWebScreen(
        userId: widget.userId,
      );
    } else {
      // For mobile platforms, use a simple implementation for now
      return Scaffold(
        appBar: AppBar(
          title: const Text('Portfolio'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshPortfolio,
            ),
          ],
        ),
        body: PortfolioHoldingsWidget(
          userId: widget.userId,
        ),
      );
    }
  }
}
