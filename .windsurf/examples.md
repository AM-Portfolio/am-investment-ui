# AM Investment UI - Code Examples

This document provides examples of preferred code patterns and implementations for common tasks in this project.

## Widget Examples

### Platform-Adaptive Button

```dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final AppButtonType type;
  final bool isFullWidth;
  
  const AppButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.type = AppButtonType.primary,
    this.isFullWidth = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return _buildCupertinoButton(context);
    } else {
      return _buildMaterialButton(context);
    }
  }
  
  Widget _buildMaterialButton(BuildContext context) {
    final theme = Theme.of(context);
    
    switch (type) {
      case AppButtonType.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: isFullWidth 
                ? Size(double.infinity, 48) 
                : const Size(120, 48),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(text),
        );
      case AppButtonType.secondary:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: isFullWidth 
                ? Size(double.infinity, 48) 
                : const Size(120, 48),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(text),
        );
      case AppButtonType.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(text),
        );
    }
  }
  
  Widget _buildCupertinoButton(BuildContext context) {
    switch (type) {
      case AppButtonType.primary:
        return CupertinoButton.filled(
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? const CupertinoActivityIndicator()
              : Text(text),
        );
      case AppButtonType.secondary:
      case AppButtonType.text:
        return CupertinoButton(
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? const CupertinoActivityIndicator()
              : Text(text),
        );
    }
  }
}

enum AppButtonType {
  primary,
  secondary,
  text,
}
```

### Responsive Layout

```dart
import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  
  const ResponsiveLayout({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
  }) : super(key: key);
  
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;
      
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 650 &&
      MediaQuery.of(context).size.width < 1100;
      
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;
  
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    
    if (size.width >= 1100 && desktop != null) {
      return desktop!;
    } else if (size.width >= 650 && tablet != null) {
      return tablet!;
    } else {
      return mobile;
    }
  }
}
```

## State Management Examples

### Provider Example

```dart
// 1. Define the model
class ThemeModel extends ChangeNotifier {
  bool _isDarkMode = false;
  
  bool get isDarkMode => _isDarkMode;
  
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

// 2. Provide the model
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeModel(),
      child: MyApp(),
    ),
  );
}

// 3. Consume the model
class ThemeToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, themeModel, child) {
        return Switch(
          value: themeModel.isDarkMode,
          onChanged: (_) => themeModel.toggleTheme(),
        );
      },
    );
  }
}
```

### BLoC Example

```dart
// 1. Define events
abstract class AuthEvent {}

class LoginEvent extends AuthEvent {
  final String identifier;
  final String password;
  
  LoginEvent({required this.identifier, required this.password});
}

class LogoutEvent extends AuthEvent {}

// 2. Define states
abstract class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final User user;
  
  AuthAuthenticated(this.user);
}
class AuthError extends AuthState {
  final String message;
  
  AuthError(this.message);
}

// 3. Implement BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  
  AuthBloc(this._authService) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
  }
  
  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      final result = await _authService.login(
        event.identifier,
        event.password,
      );
      
      if (result.success) {
        emit(AuthAuthenticated(_authService.currentState.user!));
      } else {
        emit(AuthError(result.error ?? 'Unknown error'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  
  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      await _authService.logout();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
```

## Service Implementation Example

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl;
  final http.Client _client;
  
  ApiService({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();
  
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      final response = await _client.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token != null ? 'Bearer $token' : '',
          ...?headers,
        },
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: ${e.toString()}');
    }
  }
  
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      final response = await _client.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token != null ? 'Bearer $token' : '',
          ...?headers,
        },
        body: body != null ? jsonEncode(body) : null,
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: ${e.toString()}');
    }
  }
  
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      try {
        final errorData = jsonDecode(response.body);
        throw ApiException(
          errorData['message'] ?? 'Unknown error',
          code: response.statusCode,
        );
      } catch (_) {
        throw ApiException(
          'Error ${response.statusCode}: ${response.reasonPhrase}',
          code: response.statusCode,
        );
      }
    }
  }
  
  void dispose() {
    _client.close();
  }
}

class ApiException implements Exception {
  final String message;
  final int? code;
  
  ApiException(this.message, {this.code});
  
  @override
  String toString() => 'ApiException: $message (code: $code)';
}
```

## Testing Examples

### Widget Test

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  group('LoginScreen', () {
    late MockAuthService mockAuthService;
    
    setUp(() {
      mockAuthService = MockAuthService();
    });
    
    testWidgets('shows error message on failed login', (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.login(any, any))
          .thenAnswer((_) async => AuthResult.failure('Invalid credentials'));
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>.value(
            value: mockAuthService,
            child: LoginScreen(),
          ),
        ),
      );
      
      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.enterText(find.byType(TextField).last, 'password');
      await tester.tap(find.text('Login'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      
      // Assert
      expect(find.text('Invalid credentials'), findsOneWidget);
    });
    
    testWidgets('navigates to home on successful login', (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.login(any, any))
          .thenAnswer((_) async => AuthResult.success());
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>.value(
            value: mockAuthService,
            child: LoginScreen(),
          ),
        ),
      );
      
      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.enterText(find.byType(TextField).last, 'password');
      await tester.tap(find.text('Login'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      
      // Assert
      verify(mockAuthService.login('test@example.com', 'password')).called(1);
      // Verify navigation would happen here
    });
  });
}
```

### Unit Test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

class MockHttpClient extends Mock implements http.Client {}
class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('AuthService', () {
    late AuthService authService;
    late MockHttpClient mockHttpClient;
    late MockSharedPreferences mockPrefs;
    
    setUp(() {
      mockHttpClient = MockHttpClient();
      mockPrefs = MockSharedPreferences();
      authService = AuthService(
        client: mockHttpClient,
        prefs: mockPrefs,
      );
    });
    
    test('login with valid credentials returns success', () async {
      // Arrange
      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
        '{"user": {"id": "123", "email": "test@example.com", "name": "Test User"}, "token": "test_token"}',
        200,
      ));
      
      // Act
      final result = await authService.login('test@example.com', 'password');
      
      // Assert
      expect(result.success, true);
      expect(authService.currentState.isAuthenticated, true);
      expect(authService.currentState.user?.email, 'test@example.com');
    });
    
    test('login with invalid credentials returns failure', () async {
      // Arrange
      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
        '{"message": "Invalid credentials"}',
        401,
      ));
      
      // Act
      final result = await authService.login('test@example.com', 'wrong');
      
      // Assert
      expect(result.success, false);
      expect(result.error, 'Invalid credentials');
      expect(authService.currentState.isAuthenticated, false);
    });
  });
}
```
