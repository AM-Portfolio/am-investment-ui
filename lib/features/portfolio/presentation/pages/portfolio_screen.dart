import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../widgets/portfolio_list_wrapper.dart';
import '../../../../core/utils/logger.dart';

/// Platform-aware portfolio screen router
/// Routes to mobile or web specific portfolio screens based on platform
/// Now uses PortfolioListWrapper for portfolio selection functionality
class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({
    required this.userId,
    super.key,
    this.isSidebarVisible = true,
    this.onToggleSidebar,
  });

  final String userId;
  final bool isSidebarVisible;
  final VoidCallback? onToggleSidebar;

  @override
  Widget build(BuildContext context) {
    AppLogger.info(
      'Routing to portfolio screen with selection for userId: $userId',
      tag: 'PortfolioScreen',
    );

    // Determine if we're on mobile platform
    const isMobile = !kIsWeb;

    AppLogger.debug(
      'Using PortfolioListWrapper for ${isMobile ? 'mobile' : 'web'} platform',
      tag: 'PortfolioScreen',
    );

    // Use PortfolioListWrapper to handle portfolio selection
    // The wrapper will automatically select appropriate screens based on platform
    return PortfolioListWrapper(
      userId: userId,
      isMobile: isMobile,
      isSidebarVisible: isSidebarVisible,
      onToggleSidebar: onToggleSidebar,
    );
  }
}
