import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../mobile/portfolio_mobile_screen.dart';
import '../web/portfolio_web_screen.dart';
import '../../../../core/utils/logger.dart';

/// Platform-aware portfolio screen router
/// Routes to mobile or web specific portfolio screens based on platform
class PortfolioScreen extends StatelessWidget {
  final String userId;

  const PortfolioScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    AppLogger.info('Routing to platform-specific portfolio screen for userId: $userId', tag: 'PortfolioScreen');
    
    // Determine platform and route to appropriate screen
    if (kIsWeb) {
      // Web platform - use web-optimized portfolio screen
      AppLogger.debug('Routing to web portfolio screen', tag: 'PortfolioScreen');
      return PortfolioWebScreen(userId: userId);
    } else {
      // Mobile platforms (Android/iOS) - use mobile-optimized screen
      AppLogger.debug('Routing to mobile portfolio screen', tag: 'PortfolioScreen');
      return PortfolioMobileScreen(userId: userId);
    }
  }
}