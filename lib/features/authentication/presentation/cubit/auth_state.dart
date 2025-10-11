import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

/// Authentication state
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Authenticated state
class Authenticated extends AuthState {
  const Authenticated(this.user);
  final UserEntity user;

  @override
  List<Object?> get props => [user];
}

/// Unauthenticated state
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Authentication error state
class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

/// Password reset email sent state
class PasswordResetEmailSent extends AuthState {
  const PasswordResetEmailSent();
}

/// Password reset success state
class PasswordResetSuccess extends AuthState {
  const PasswordResetSuccess();
}
