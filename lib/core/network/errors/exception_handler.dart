import 'dart:io';
import 'package:dio/dio.dart';
import 'failures.dart';

/// Global exception handler that maps exceptions to failures
class ExceptionHandler {
  /// Map various exceptions to appropriate failure types
  static Failure mapExceptionToFailure(dynamic exception) {
    if (exception is DioException) {
      return _handleDioException(exception);
    } else if (exception is SocketException) {
      return NetworkFailure(
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
        return TimeoutFailure(
          'Connection timeout. Please try again.',
          code: 'TIMEOUT_ERROR',
        );
      
      case DioExceptionType.badResponse:
        return _handleHttpStatusCode(exception.response?.statusCode, exception.message);
      
      case DioExceptionType.cancel:
        return NetworkFailure(
          'Request was cancelled',
          code: 'REQUEST_CANCELLED',
        );
      
      case DioExceptionType.connectionError:
        return NetworkFailure(
          'Connection error. Please check your internet connection.',
          code: 'CONNECTION_ERROR',
        );
      
      case DioExceptionType.badCertificate:
        return NetworkFailure(
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
        return AuthFailure(
          'Unauthorized: Please login again',
          code: 'UNAUTHORIZED',
        );
      case 403:
        return PermissionFailure(
          'Forbidden: You don\'t have permission to access this resource',
          code: 'FORBIDDEN',
        );
      case 404:
        return ServerFailure(
          'Resource not found',
          code: 'NOT_FOUND',
        );
      case 422:
        return ValidationFailure(
          'Validation failed: ${message ?? 'Invalid input data'}',
          code: 'VALIDATION_ERROR',
        );
      case 429:
        return ServerFailure(
          'Too many requests. Please try again later.',
          code: 'RATE_LIMIT',
        );
      case 500:
      case 502:
      case 503:
      case 504:
        return ServerFailure(
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