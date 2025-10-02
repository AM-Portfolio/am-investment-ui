import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_result.freezed.dart';
part 'auth_result.g.dart';

/// Domain entity representing the result of authentication operations
@freezed
class AuthResult with _$AuthResult {
  const AuthResult._();
  
  const factory AuthResult.success({
    String? message,
  }) = AuthSuccess;
  
  const factory AuthResult.failure({
    required String error,
    String? errorCode,
  }) = AuthFailure;

  factory AuthResult.fromJson(Map<String, dynamic> json) => _$AuthResultFromJson(json);

  /// Check if operation was successful
  bool get isSuccess => this is AuthSuccess;
  
  /// Check if operation failed
  bool get isFailure => this is AuthFailure;
  
  /// Get error message if available
  String? get errorMessage => when(
    success: (_) => null,
    failure: (error, _) => error,
  );
}