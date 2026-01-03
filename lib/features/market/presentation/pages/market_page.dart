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
  });

  final String userId;

  @override
  Widget build(BuildContext context) {
    AppLogger.methodEntry('build', tag: 'MarketPage');
    // Use market widgets directly without ModuleContainer
    return ChangeNotifierProvider(
      create: (_) {
        AppLogger.info('Initializing MarketProvider for MarketPage', tag: 'MarketPage');
        return MarketProvider();
      },

      child: Consumer<MarketProvider>(
        builder: (context, provider, _) {
          AppLogger.debug('MarketPage consumer building with provider: ${provider.runtimeType}', tag: 'MarketPage');
          return Row(
            children: [
              // Market Secondary Sidebar
              SecondarySidebar(
                title: 'Market Data',
                subtitle: 'Real-time market insights',
                icon: Icons.trending_up_rounded,
                accentColor: const Color(0xFF06b6d4), // Cyan
                child: MarketSidebarContent(provider: provider),
              ),
              
              // Market Main Content
              Expanded(
                child: MarketMainContent(provider: provider),
              ),
            ],
          );
        },
      ),
    );
  }
}

