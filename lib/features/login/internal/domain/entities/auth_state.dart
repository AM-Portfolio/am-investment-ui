import 'package:freezed_annotation/freezed_annotation.dart';
import 'user.dart';

part 'auth_state.freezed.dart';
part 'auth_state.g.dart';

/// Domain entity representing authentication state
@freezed
class AuthState with _$AuthState {
  const AuthState._();
  
  const factory AuthState({
    @Default(false) bool isAuthenticated,
    @Default(false) bool isLoading,
    User? currentUser,
    String? accessToken,
    String? refreshToken,
    DateTime? tokenExpiresAt,
    String? errorMessage,
  }) = _AuthState;

  factory AuthState.fromJson(Map<String, dynamic> json) => _$AuthStateFromJson(json);

  /// Check if user is logged in
  bool get isLoggedIn => isAuthenticated && currentUser != null;

  /// Check if token is expired
  bool get isTokenExpired => tokenExpiresAt != null && DateTime.now().isAfter(tokenExpiresAt!);

  /// Check if token needs refresh (expires in less than 5 minutes)
  bool get needsTokenRefresh {
    if (tokenExpiresAt == null) return false;
    return DateTime.now().add(const Duration(minutes: 5)).isAfter(tokenExpiresAt!);
  }
}

