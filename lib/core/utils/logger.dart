import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../../config/environment.dart';

/// Log levels in order of severity
enum LogLevel {
  debug(0, 'DEBUG'),
  info(1, 'INFO'),
  warning(2, 'WARNING'),
  error(3, 'ERROR');

  const LogLevel(this.priority, this.label);

  final int priority;
  final String label;
}

/// Centralized logging service that can be controlled by environment
///
/// Usage:
/// ```dart
/// AppLogger.debug('Debug message', tag: 'NetworkClient');
/// AppLogger.info('User logged in', tag: 'AuthService');
/// AppLogger.warning('API response slow', tag: 'ApiClient');
/// AppLogger.error('Failed to load data', error: e, stackTrace: stack, tag: 'Repository');
/// ```
class AppLogger {
  static bool _isInitialized = false;
  static bool _loggingEnabled = false;
  static LogLevel _minimumLogLevel = LogLevel.debug;
  static final Map<String, int> _tagCounts = {};

  /// Initialize the logger with environment-based configuration
  static void initialize() {
    if (_isInitialized) return;

    _updateLoggingConfig(EnvironmentConfig.environment);

    // Listen for environment changes
    EnvironmentConfig.addListener(_updateLoggingConfig);

    _isInitialized = true;

    if (_loggingEnabled) {
      info(
        'AppLogger initialized for environment: ${EnvironmentConfig.environment.name}',
        tag: 'Logger',
      );
    }
  }

  /// Update logging configuration based on environment
  static void _updateLoggingConfig(Environment environment) {
    switch (environment) {
      case Environment.development:
        _loggingEnabled = true;
        _minimumLogLevel = LogLevel.debug;
        break;
      case Environment.preprod:
        _loggingEnabled = true;
        _minimumLogLevel = LogLevel.info; // Hide debug logs in preprod
        break;
      case Environment.production:
        _loggingEnabled = false; // Completely disabled in production
        _minimumLogLevel = LogLevel.error;
        break;
    }
  }

  /// Check if logging is enabled for the given level
  static bool _shouldLog(LogLevel level) {
    if (!_loggingEnabled) return false;
    return level.priority >= _minimumLogLevel.priority;
  }

  /// Format log message with timestamp, level, and tag
  static String _formatMessage(String message, LogLevel level, String? tag) {
    final timestamp = DateTime.now().toIso8601String().substring(
      11,
      23,
    ); // HH:mm:ss.SSS
    final tagInfo = tag != null ? '[$tag] ' : '';
    return '$timestamp ${level.label}: $tagInfo$message';
  }

  /// Get color for different log levels (for better visibility in debug console)
  static String _getColorCode(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '\x1B[36m'; // Cyan
      case LogLevel.info:
        return '\x1B[32m'; // Green
      case LogLevel.warning:
        return '\x1B[33m'; // Yellow
      case LogLevel.error:
        return '\x1B[31m'; // Red
    }
  }

  /// Reset color
  static const String _resetColor = '\x1B[0m';

  /// Internal logging method
  static void _log(
    String message,
    LogLevel level, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_shouldLog(level)) return;

    // Track tag usage for debugging
    if (tag != null) {
      _tagCounts[tag] = (_tagCounts[tag] ?? 0) + 1;
    }

    final formattedMessage = _formatMessage(message, level, tag);

    if (kDebugMode) {
      // Use colored output in debug mode
      final coloredMessage =
          '${_getColorCode(level)}$formattedMessage$_resetColor';
      print(coloredMessage);

      // Print error and stack trace if provided
      if (error != null) {
        print('${_getColorCode(level)}Error: $error$_resetColor');
      }
      if (stackTrace != null) {
        print('${_getColorCode(level)}Stack trace:\n$stackTrace$_resetColor');
      }
    } else {
      // Use developer.log for better performance in release builds
      developer.log(
        message,
        name: tag ?? 'App',
        level: level.priority * 300, // Convert to developer log levels
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Log debug message (lowest priority)
  /// Only shown in development environment
  static void debug(String message, {String? tag}) {
    _log(message, LogLevel.debug, tag: tag);
  }

  /// Log info message
  /// Shown in development and preprod environments
  static void info(String message, {String? tag}) {
    _log(message, LogLevel.info, tag: tag);
  }

  /// Log warning message
  /// Shown in development and preprod environments
  static void warning(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      message,
      LogLevel.warning,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log error message (highest priority)
  /// Always logged unless completely disabled
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      message,
      LogLevel.error,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log method entry (for debugging method calls)
  static void methodEntry(
    String methodName, {
    String? tag,
    Map<String, dynamic>? params,
  }) {
    if (params != null && params.isNotEmpty) {
      debug(
        '→ $methodName(${params.entries.map((e) => '${e.key}: ${e.value}').join(', ')})',
        tag: tag,
      );
    } else {
      debug('→ $methodName()', tag: tag);
    }
  }

  /// Log method exit (for debugging method calls)
  static void methodExit(String methodName, {String? tag, result}) {
    if (result != null) {
      debug('← $methodName() -> $result', tag: tag);
    } else {
      debug('← $methodName()', tag: tag);
    }
  }

  /// Log API request
  static void apiRequest(
    String method,
    String url, {
    String? tag,
    Map<String, dynamic>? headers,
    body,
  }) {
    final requestTag = tag ?? 'API';
    info('$method $url', tag: requestTag);

    if (headers != null && headers.isNotEmpty) {
      debug('Headers: $headers', tag: requestTag);
    }

    if (body != null) {
      debug('Body: $body', tag: requestTag);
    }
  }

  /// Log API response
  static void apiResponse(
    String method,
    String url,
    int statusCode, {
    String? tag,
    body,
    int? duration,
  }) {
    final requestTag = tag ?? 'API';
    final durationInfo = duration != null ? ' (${duration}ms)' : '';

    if (statusCode >= 200 && statusCode < 300) {
      info('$method $url -> $statusCode$durationInfo', tag: requestTag);
    } else if (statusCode >= 400) {
      warning('$method $url -> $statusCode$durationInfo', tag: requestTag);
    } else {
      debug('$method $url -> $statusCode$durationInfo', tag: requestTag);
    }

    if (body != null && _shouldLog(LogLevel.debug)) {
      debug('Response: $body', tag: requestTag);
    }
  }

  /// Log user action (for analytics/debugging)
  static void userAction(
    String action, {
    String? tag,
    Map<String, dynamic>? context,
  }) {
    final actionTag = tag ?? 'UserAction';
    if (context != null && context.isNotEmpty) {
      info('User: $action | Context: $context', tag: actionTag);
    } else {
      info('User: $action', tag: actionTag);
    }
  }

  /// Log state change (for BLoC/Cubit debugging)
  static void stateChange(String from, String to, {String? tag, event}) {
    final stateTag = tag ?? 'State';
    if (event != null) {
      debug('State: $from -> $to | Event: $event', tag: stateTag);
    } else {
      debug('State: $from -> $to', tag: stateTag);
    }
  }

  /// Get logging statistics (useful for debugging)
  static Map<String, dynamic> getStats() => {
    'isEnabled': _loggingEnabled,
    'environment': EnvironmentConfig.environment.name,
    'minimumLevel': _minimumLogLevel.label,
    'tagUsage': Map.from(_tagCounts),
  };

  /// Clear logging statistics
  static void clearStats() {
    _tagCounts.clear();
  }

  /// Manually enable/disable logging (for testing)
  static void setEnabled(bool enabled) {
    _loggingEnabled = enabled;
  }

  /// Set minimum log level (for testing)
  static void setMinimumLevel(LogLevel level) {
    _minimumLogLevel = level;
  }
}
