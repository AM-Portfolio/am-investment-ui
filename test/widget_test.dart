// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:todo_app/main.dart';

void main() {
  testWidgets('Todo app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app title is displayed
    expect(find.text('My To-Do List'), findsOneWidget);
    
    // Verify that the empty state message is shown
    expect(find.text('No tasks yet. Add one!'), findsOneWidget);
    
    // Enter text in the text field
    await tester.enterText(find.byType(TextField), 'Test Task');
    
    // Tap the add button and trigger a frame
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    
    // Verify that the task was added
    expect(find.text('Test Task'), findsOneWidget);
    
    // Verify that the empty state message is gone
    expect(find.text('No tasks yet. Add one!'), findsNothing);
  });
}
