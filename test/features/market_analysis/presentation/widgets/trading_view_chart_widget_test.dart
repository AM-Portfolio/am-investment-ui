
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/features/market_analysis/presentation/widgets/trading_view_chart_widget.dart';
import 'package:todo_app/features/market_analysis/internal/domain/models/chart_config.dart';

void main() {
  testWidgets('TradingViewChartWidget loads without error on platform', (WidgetTester tester) async {
    // Basic config
    const config = ChartConfig(symbol: 'NASDAQ:AAPL');

    // Pump the widget
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TradingViewChartWidget(config: config),
        ),
      ),
    );

    // Initial pump
    await tester.pump();

    // Verify it exists
    expect(find.byType(TradingViewChartWidget), findsOneWidget);
    
    // We expect no exceptions to be thrown during build/init.
  });
}
