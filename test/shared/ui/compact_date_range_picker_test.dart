import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/shared/core/ui/components/trade/compact_date_range_picker.dart';

void main() {
  testWidgets('CompactDateRangePickerDialog renders without overflow', (WidgetTester tester) async {
    // Set a large enough surface size to mimic desktop/tablet
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (c) => const CompactDateRangePickerDialog(),
                );
              },
              child: const Text('Open Picker'),
            ),
          ),
        ),
      ),
    );

    // Open the dialog
    await tester.tap(find.text('Open Picker'));
    await tester.pumpAndSettle();

    // Verify dialog is present
    expect(find.byType(CompactDateRangePickerDialog), findsOneWidget);

    // Verify Calendar View is default (check for day '1' or similar)
    // Note: Depends on current month. We might need to mock DateTime.now() if we want strict determinism,
    // but detecting '1' is usually safe in a calendar view.
    expect(find.text('1'), findsAtLeastNWidgets(1));

    // Check for overflow errors (tester.takeException() would reveal them, or just pump success)
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });

  testWidgets('CompactDateRangePickerDialog disables future dates', (WidgetTester tester) async {
     tester.view.physicalSize = const Size(1200, 800);
     tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: const CompactDateRangePickerDialog(),
        ),
      ),
    );
    
    // We are in the view directly now (Dialog content).
    // Find a date in the future.
    // Since we can't easily jump to next month without tapping, let's just check visual state or tap behavior 
    // of a known future date if displayed (e.g. if today is 15th, 16th is future? No, we likely disabled > today).
    
    // Actually our logic disables date > DateTime.now().
    // Getting a specific future date widget is tricky without knowing Today.
    // Let's rely on the Month Grid test for clearer disability.
    
    // Switch to Month View
    final now = DateTime.now();
    final headerDateText = DateFormat('MMMM yyyy').format(now); 
    // Wait, displayed month defaults to end date or now. End date is null. displayedMonth is now.
    // Header shows "Select start" and "Select end", but also the Month Navigation title: e.g. "December 2025"
    
    // Find the dropdown icon to indicate interactivity?
    // The code uses InkWell on the month title.
    
    // Let's find the text that says the current month/year
    await tester.tap(find.text(headerDateText));
    await tester.pumpAndSettle(); // Should switch to Year view (logic: default toggle Year -> Month -> Calendar)
    // Note: The code actually toggles: if calendar -> year.
    
    // Now in Year view.
    // Future years should be disabled.
    final futureYear = (now.year + 1).toString();
    
    // Verify future year exists in tree (as text) but is disabled?
    // Our code: onTap is null if isFuture.
    // And text color is disabledColor.
    
    // Note: GridBuilder generates years. Our logic: startYear = currentYear - 19.
    // Wait, generated years: index 0 to 19. startYear + index.
    // If startYear = 2025 - 19 = 2006. Max year = 2006 + 19 = 2025.
    // So future years are NOT even generated in the lists!
    // Ah, logic: `final startYear = currentYear - 19; final years = List.generate(20...`
    // So max year is currentYear.
    // So distinct future years (2026) won't even be visible.
    
    expect(find.text(futureYear), findsNothing);
    
    final currentYearStr = now.year.toString();
    expect(find.text(currentYearStr), findsOneWidget);
    
    // Tap current year to go to Month view
    await tester.tap(find.text(currentYearStr));
    await tester.pumpAndSettle();
    
    // Now in Month View.
    // Future months of current year should be disabled.
    if (now.month < 12) {
       final nextMonthIndex = now.month + 1;
       final nextMonthName = DateFormat().dateSymbols.SHORTMONTHS[nextMonthIndex - 1]; // 0-indexed
       
       // It should be visible
       expect(find.text(nextMonthName), findsOneWidget);
       
       // Try tapping it. Should NOT switch to Calendar.
       await tester.tap(find.text(nextMonthName));
       await tester.pumpAndSettle();
       
       // Verify we are still in Month view (checking presence of other months)
       // e.g. Jan should be there.
       expect(find.text('Jan'), findsOneWidget);
       
       // If we switched to calendar, we'd see '1', '2' etc. (though months might show for current day? No).
       // Actually simpler: if we switched, viewMode changed.
       // But we can't inspect private state.
       // We can assert we still find 12 months (Jan-Dec).
       expect(find.text('Dec'), findsOneWidget); 
    }
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
