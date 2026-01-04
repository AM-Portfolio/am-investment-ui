import 'package:flutter/material.dart';
import 'package:market_data_web/modules/widgets/market_sidebar_content.dart';
import 'package:market_data_web/modules/widgets/market_main_content.dart';
import 'package:market_data_web/providers/market_provider.dart';
import 'package:provider/provider.dart';
import 'package:am_common_ui/am_common_ui.dart';

import 'package:todo_app/core/utils/logger.dart';



/// Market feature page - embeds Market Data widgets
class MarketPage extends StatelessWidget {
  const MarketPage({
    super.key,
    required this.userId,
    this.onBack,
  });

  final String userId;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    AppLogger.methodEntry('build', tag: 'MarketPage');
    
    return ChangeNotifierProvider(
      create: (_) {
        AppLogger.info('Initializing MarketProvider for MarketPage', tag: 'MarketPage');
        final provider = MarketProvider();
        // Trigger initial load
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (provider.availableIndices == null) {
            provider.loadIndices();
          }
        });
        return provider;
      },

      child: Consumer<MarketProvider>(
        builder: (context, provider, _) {
          final selectedIndex = provider.selectedIndex ?? 'All Indices';
          const accentColor = ModuleColors.market;

          // Define Main Navigation Items
          final mainItems = [
            SecondarySidebarItem(
              title: 'All Indices',
              icon: Icons.dashboard_rounded,
              subtitle: 'Market Overview',
              isSelected: selectedIndex == 'All Indices',
              accentColor: accentColor,
              onTap: () => provider.selectIndex('All Indices'),
            ),
            SecondarySidebarItem(
              title: 'Streamer',
              icon: Icons.waves_rounded,
              subtitle: 'Real-time data',
              isSelected: selectedIndex == 'Streamer',
              accentColor: accentColor,
              onTap: () => provider.selectIndex('Streamer'),
            ),
            SecondarySidebarItem(
              title: 'Instrument Explorer',
              icon: Icons.manage_search_rounded,
              subtitle: 'Search instruments',
              isSelected: selectedIndex == 'Instrument Explorer',
              accentColor: accentColor,
              onTap: () => provider.selectIndex('Instrument Explorer'),
            ),
            SecondarySidebarItem(
              title: 'Security Explorer',
              icon: Icons.security_rounded,
              subtitle: 'Security details',
              isSelected: selectedIndex == 'Security Explorer',
              accentColor: accentColor,
              onTap: () => provider.selectIndex('Security Explorer'),
            ),
            SecondarySidebarItem(
              title: 'ETF Explorer',
              icon: Icons.dashboard_customize_rounded,
              subtitle: 'ETF insights',
              isSelected: selectedIndex == 'ETF Explorer',
              accentColor: accentColor,
              onTap: () => provider.selectIndex('ETF Explorer'),
            ),
            SecondarySidebarItem(
              title: 'Price Test',
              icon: Icons.price_check_rounded,
              subtitle: 'Price validation',
              isSelected: selectedIndex == 'Price Test',
              accentColor: accentColor,
              onTap: () => provider.selectIndex('Price Test'),
            ),
            SecondarySidebarItem(
              title: 'Market Analysis',
              icon: Icons.analytics_rounded,
              subtitle: 'Detailed charts',
              isSelected: selectedIndex == 'Market Analysis',
              accentColor: accentColor,
              onTap: () => provider.selectIndex('Market Analysis'),
            ),
          ];

          // Define Dynamic Index Items
          final indexItems = provider.availableIndices?.broad.take(5).map((index) => 
            SecondarySidebarItem(
              title: index,
              icon: Icons.trending_up_rounded,
              subtitle: 'Live Index Data',
              isSelected: selectedIndex == index,
              accentColor: accentColor,
              onTap: () => provider.selectIndex(index),
            )
          ).toList() ?? [];

          // Admin Item
          final adminItem = SecondarySidebarItem(
            title: 'Admin Dashboard',
            icon: Icons.admin_panel_settings_rounded,
            isSelected: selectedIndex == 'Admin Dashboard',
            accentColor: const Color(0xFFFF6B6B), // Red/Pink for admin
            onTap: () => provider.selectIndex('Admin Dashboard'),
          );

          return UnifiedSidebarScaffold(
            module: ModuleType.market,
            // accentColor etc handled by module type
            onBackToGlobal: onBack,
            sections: [
              SecondarySidebarSection(
                title: 'Data',
                items: mainItems,
              ),
              if (indexItems.isNotEmpty)
                SecondarySidebarSection(
                  title: 'Major Indices',
                  items: indexItems,
                ),
              SecondarySidebarSection(
                title: 'System Tools',
                items: [adminItem],
              ),
            ],
            body: MarketMainContent(provider: provider),
          );
        },
      ),
    );
  }
}
