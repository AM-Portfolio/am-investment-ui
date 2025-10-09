import 'package:equatable/equatable.dart';

/// Base class for all failures in the app
abstract class Failure extends Equatable {
  const Failure(this.message, {this.code});
  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code, this.fieldErrors});
  final Map<String, String>? fieldErrors;

  @override
  List<Object?> get props => [message, code, fieldErrors];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.code});
}
