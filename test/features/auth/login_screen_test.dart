import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/cupertino.dart';
import '../../../lib/features/auth/presentation/screens/login_screen.dart';
import '../../../lib/core/services/auth_service.dart';
import '../../../lib/core/widgets/app_button.dart';
import '../../../lib/core/widgets/app_text_field.dart';

void main() {
  late Widget testWidget;

  setUp(() {
    testWidget = const MaterialApp(
      home: LoginScreen(),
    );
  });

  group('LoginScreen UI Tests', () {
    testWidgets('Renders login form with all elements', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      // Verify the app title is displayed
      expect(find.text('AM Investment'), findsOneWidget);

      // Verify form fields are present
      expect(find.byType(AppTextField), findsNWidgets(2)); // Email and password fields
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);

      // Verify buttons are present
      expect(find.byType(AppButton), findsOneWidget); // Login button
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text("Don't have an account?"), findsOneWidget);
      expect(find.text('Register'), findsOneWidget);
    });

    testWidgets('Shows validation errors when form is submitted empty', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      // Find and tap the login button
      final loginButton = find.text('Login');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Verify validation error messages are shown
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('Shows validation error for invalid email format', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      // Enter invalid email
      await tester.enterText(find.byType(TextField).first, 'invalid-email');
      
      // Enter valid password
      await tester.enterText(find.byType(TextField).last, 'password123');

      // Find and tap the login button
      final loginButton = find.text('Login');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Verify validation error message is shown for email
      expect(find.text('Enter a valid email address'), findsOneWidget);
      expect(find.text('Password is required'), findsNothing);
    });

    testWidgets('Shows validation error for short password', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      // Enter valid email
      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      
      // Enter short password
      await tester.enterText(find.byType(TextField).last, '123');

      // Find and tap the login button
      final loginButton = find.text('Login');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Verify validation error message is shown for password
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
      expect(find.text('Email is required'), findsNothing);
    });

    testWidgets('Shows loading state when login button is pressed with valid inputs', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      // Enter valid email
      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      
      // Enter valid password
      await tester.enterText(find.byType(TextField).last, 'password123');

      // Find and tap the login button
      final loginButton = find.text('Login');
      await tester.tap(loginButton);
      
      // Pump once to start the loading state
      await tester.pump();

      // Verify loading indicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Navigates to register screen when register button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      // Find and tap the register button
      final registerButton = find.text('Register');
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      // Verify navigation to register screen
      expect(find.text('Create your account'), findsOneWidget);
    });
  });

  group('Platform-specific UI Tests', () {
    testWidgets('Uses correct text field style based on platform', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      // Check if the correct text field widget is used based on platform
      if (kIsWeb || Theme.of(tester.element(find.byType(MaterialApp))).platform == TargetPlatform.android) {
        expect(find.byType(TextField), findsWidgets);
        expect(find.byType(CupertinoTextField), findsNothing);
      } else {
        expect(find.byType(CupertinoTextField), findsWidgets);
        expect(find.byType(TextField), findsNothing);
      }
    });

    testWidgets('Uses correct button style based on platform', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      // Check if the correct button widget is used based on platform
      if (kIsWeb || Theme.of(tester.element(find.byType(MaterialApp))).platform == TargetPlatform.android) {
        expect(find.byType(ElevatedButton), findsWidgets);
        expect(find.byType(CupertinoButton), findsNothing);
      } else {
        expect(find.byType(CupertinoButton), findsWidgets);
        expect(find.byType(ElevatedButton), findsNothing);
      }
    });
  });
}
