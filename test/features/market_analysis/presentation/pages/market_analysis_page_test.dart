
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/features/market_analysis/presentation/pages/market_analysis_page.dart';
import 'package:todo_app/features/market_analysis/presentation/widgets/trading_view_chart_widget.dart';
import 'package:todo_app/features/market_analysis/providers/market_analysis_providers.dart';
import 'package:todo_app/features/market_analysis/internal/domain/models/chart_config.dart';

void main() {
  testWidgets('MarketAnalysisPage shows loading then chart', (WidgetTester tester) async {
    // Override the provider if needed, or rely on default
    // We mainly want to test the UI state logic.
    
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: MarketAnalysisPage(),
          ),
        ),
      ),
    );

    // Initial state: Should show loading indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.textContaining('Loading Chart'), findsOneWidget);

    // The component has a delay of 1500ms on Web (and test environment simulates via pump)
    // We pump for a duration satisfying the delay + animation time
    await tester.pump(const Duration(milliseconds: 2000));
    
    // After delay, loading should be gone (or fading out) and chart visible
    // The fadeOut takes 500ms, so let's pump a bit more to be sure
    await tester.pump(const Duration(milliseconds: 600));

    // Animations might still be running or completed. 
    // Ideally, loading indicator text is gone or transparent.
    // We check if TradingViewChartWidget is present
    expect(find.byType(TradingViewChartWidget), findsOneWidget);
    
    // Search bar should be present
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });
}
