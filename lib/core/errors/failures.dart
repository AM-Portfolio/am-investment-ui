/// Base failure class
abstract class Failure {
  final String message;
  final String? code;
  
  const Failure(this.message, {this.code});
  
  @override
  String toString() => 'Failure: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}

/// Server failures
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});
}

/// Cache failures
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}

/// File operation failures
class FileFailure extends Failure {
  const FileFailure(super.message, {super.code});
}

/// Parsing failures
class ParsingFailure extends Failure {
  const ParsingFailure(super.message, {super.code});
}

/// Permission failures
class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {super.code});
}

/// Timeout failures
class TimeoutFailure extends Failure {
  const TimeoutFailure(super.message, {super.code});
}

/// Unknown failures
class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.code});
}