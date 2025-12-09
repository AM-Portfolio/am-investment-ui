import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/market_analysis_providers.dart';
import '../widgets/trading_view_chart_widget.dart';

import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';

class MarketAnalysisPage extends ConsumerStatefulWidget {
  const MarketAnalysisPage({super.key});

  @override
  ConsumerState<MarketAnalysisPage> createState() => _MarketAnalysisPageState();
}

class _MarketAnalysisPageState extends ConsumerState<MarketAnalysisPage> {
  bool _isLoading = true;
  late TextEditingController _symbolController;

  @override
  void initState() {
    super.initState();
    final config = ref.read(marketAnalysisChartConfigProvider);
    _symbolController = TextEditingController(text: config.symbol);
  }

  @override
  void dispose() {
    _symbolController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(marketAnalysisChartConfigProvider);
    // Update controller text if provider changes externally
    if (_symbolController.text != config.symbol) {
      _symbolController.text = config.symbol;
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Fullscreen Chart
        Positioned.fill(
          child: TradingViewChartWidget(
            config: config,
            onChartLoaded: () {
              if (mounted) {
                setState(() => _isLoading = false);
              }
            },
          ),
        ),

        // 2. Glossy Search Bar (Floating)
        Positioned(
          top: 24,
          left: 0,
          right: 0,
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: 400,
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.2), // Glassy effect
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _symbolController,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search Symbol (e.g. NASDAQ:AAPL)',
                            hintStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              setState(() => _isLoading = true);
                              ref.read(marketAnalysisSymbolProvider.notifier).updateSymbol(value);
                            }
                          },
                        ),
                      ),
                      Container(
                        height: 24,
                        width: 1,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 20),
                        tooltip: 'Update Chart',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        color: Theme.of(context).colorScheme.primary,
                        onPressed: () {
                          setState(() => _isLoading = true);
                          ref.read(marketAnalysisSymbolProvider.notifier).updateSymbol(_symbolController.text);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ).animate().slideY(begin: -1, end: 0, duration: 600.ms, curve: Curves.easeOutBack).fadeIn(),
        ),

        // 3. Loading Indicator
        if (_isLoading)
          Positioned.fill(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor, // Opaque background to hide loading webview
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading Chart data for ${config.symbol}...',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(duration: 500.ms).then().fadeOut(duration: 500.ms),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
