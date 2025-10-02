import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../widgets/portfolio_list_wrapper.dart';
import '../../../../core/utils/logger.dart';

/// Platform-aware portfolio screen router
/// Routes to mobile or web specific portfolio screens based on platform
/// Now uses PortfolioListWrapper for portfolio selection functionality
class PortfolioScreen extends StatelessWidget {
  final String userId;

  const PortfolioScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    AppLogger.info(
      'Routing to portfolio screen with selection for userId: $userId',
      tag: 'PortfolioScreen',
    );

    // Determine if we're on mobile platform
    final isMobile = !kIsWeb;

    AppLogger.debug(
      'Using PortfolioListWrapper for ${isMobile ? 'mobile' : 'web'} platform',
      tag: 'PortfolioScreen',
    );

    // Use PortfolioListWrapper to handle portfolio selection
    // The wrapper will automatically select appropriate screens based on platform
    return PortfolioListWrapper(userId: userId, isMobile: isMobile);
  }
}
