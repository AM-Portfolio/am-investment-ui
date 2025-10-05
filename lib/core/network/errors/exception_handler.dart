import 'dart:io';
import 'package:dio/dio.dart';
import 'failures.dart';

/// Global exception handler that maps exceptions to failures
class ExceptionHandler {
  /// Map various exceptions to appropriate failure types
  static Failure mapExceptionToFailure(exception) {
    if (exception is DioException) {
      return _handleDioException(exception);
    } else if (exception is SocketException) {
      return const NetworkFailure(
        'No internet connection. Please check your network.',
        code: 'NETWORK_ERROR',
      );
    } else if (exception is HttpException) {
      return NetworkFailure(
        'HTTP error occurred: ${exception.message}',
        code: 'HTTP_ERROR',
      );
    } else if (exception is FormatException) {
      return ParsingFailure(
        'Data format error: ${exception.message}',
        code: 'FORMAT_ERROR',
      );
    } else if (exception is FileSystemException) {
      return FileFailure(
        'File operation failed: ${exception.message}',
        code: 'FILE_ERROR',
      );
    } else {
      return UnknownFailure(
        exception?.toString() ?? 'An unknown error occurred',
        code: 'UNKNOWN_ERROR',
      );
    }
  }

  /// Handle Dio-specific exceptions
  static Failure _handleDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure(
          'Connection timeout. Please try again.',
          code: 'TIMEOUT_ERROR',
        );

      case DioExceptionType.badResponse:
        return _handleHttpStatusCode(
          exception.response?.statusCode,
          exception.message,
        );

      case DioExceptionType.cancel:
        return const NetworkFailure(
          'Request was cancelled',
          code: 'REQUEST_CANCELLED',
        );

      case DioExceptionType.connectionError:
        return const NetworkFailure(
          'Connection error. Please check your internet connection.',
          code: 'CONNECTION_ERROR',
        );

      case DioExceptionType.badCertificate:
        return const NetworkFailure(
          'Certificate verification failed',
          code: 'CERTIFICATE_ERROR',
        );

      default:
        return NetworkFailure(
          exception.message ?? 'Network error occurred',
          code: 'NETWORK_ERROR',
        );
    }
  }

  /// Handle HTTP status codes
  static Failure _handleHttpStatusCode(int? statusCode, String? message) {
    switch (statusCode) {
      case 400:
        return ValidationFailure(
          'Bad request: ${message ?? 'Invalid request data'}',
          code: 'BAD_REQUEST',
        );
      case 401:
        return const AuthFailure(
          'Unauthorized: Please login again',
          code: 'UNAUTHORIZED',
        );
      case 403:
        return const PermissionFailure(
          "Forbidden: You don't have permission to access this resource",
          code: 'FORBIDDEN',
        );
      case 404:
        return const ServerFailure('Resource not found', code: 'NOT_FOUND');
      case 422:
        return ValidationFailure(
          'Validation failed: ${message ?? 'Invalid input data'}',
          code: 'VALIDATION_ERROR',
        );
      case 429:
        return const ServerFailure(
          'Too many requests. Please try again later.',
          code: 'RATE_LIMIT',
        );
      case 500:
      case 502:
      case 503:
      case 504:
        return const ServerFailure(
          'Server error. Please try again later.',
          code: 'SERVER_ERROR',
        );
      default:
        return ServerFailure(
          message ?? 'Server error occurred',
          code: 'UNKNOWN_SERVER_ERROR',
        );
    }
  }
}
