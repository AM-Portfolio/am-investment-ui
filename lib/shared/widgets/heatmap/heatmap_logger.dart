import 'dart:developer' as developer;

import '../../../core/utils/logger.dart';

/// Specialized logger for heatmap functionality
/// Provides structured logging for heatmap operations, performance tracking,
/// and debugging assistance for heatmap components
class HeatmapLogger {
  static const String _tag = 'Heatmap';
  static final Map<String, DateTime> _operationStartTimes = {};
  static final Map<String, int> _eventCounts = {};

  /// Initialize the heatmap logger
  static void initialize() {
    AppLogger.initialize();
    AppLogger.info('HeatmapLogger initialized', tag: _tag);
  }

  /// Log heatmap initialization
  static void logInitialization({
    required String component,
    required String investmentType,
    Map<String, dynamic>? config,
  }) {
    AppLogger.info(
      'Heatmap component initialized: $component for $investmentType',
      tag: '$_tag.Init',
    );
    
    developer.log(
      'Heatmap initialization',
      name: '$_tag.Init',
      time: DateTime.now(),
    );
  }

  /// Log data loading operations
  static void logDataLoading({
    required String operation,
    int? dataSize,
    String? source,
  }) {
    final operationId = '${operation}_${DateTime.now().millisecondsSinceEpoch}';
    _operationStartTimes[operationId] = DateTime.now();
    
    AppLogger.info(
      'Starting data loading: $operation${dataSize != null ? ' (size: $dataSize)' : ''}${source != null ? ' from $source' : ''}',
      tag: '$_tag.Data',
    );
    
    developer.log(
      'Data loading started',
      name: '$_tag.Data',
      time: DateTime.now(),
    );
  }

  /// Log successful data loading completion
  static void logDataLoadingSuccess({
    required String operation,
    int? itemCount,
    String? processingInfo,
  }) {
    final operationId = _findOperationId(operation);
    final duration = _calculateDuration(operationId);
    
    AppLogger.info(
      'Data loading completed: $operation${duration != null ? ' (${duration.inMilliseconds}ms)' : ''}${itemCount != null ? ' - $itemCount items' : ''}${processingInfo != null ? ' - $processingInfo' : ''}',
      tag: '$_tag.Data',
    );
    
    if (operationId != null) {
      _operationStartTimes.remove(operationId);
    }
  }

  /// Log data loading errors
  static void logDataLoadingError({
    required String operation,
    required dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    final operationId = _findOperationId(operation);
    final duration = _calculateDuration(operationId);
    
    AppLogger.error(
      'Data loading failed: $operation${duration != null ? ' (${duration.inMilliseconds}ms)' : ''}',
      error: error,
      stackTrace: stackTrace,
      tag: '$_tag.Data.Error',
    );
    
    if (operationId != null) {
      _operationStartTimes.remove(operationId);
    }
  }

  /// Log filter changes
  static void logFilterChange({
    required String filterType,
    required dynamic oldValue,
    required dynamic newValue,
    String? component,
  }) {
    _incrementEventCount('filter_change');
    
    AppLogger.debug(
      'Filter changed: $filterType from $oldValue to $newValue${component != null ? ' in $component' : ''} (count: ${_eventCounts['filter_change']})',
      tag: '$_tag.Filter',
    );
  }

  /// Log tile interactions
  static void logTileInteraction({
    required String action,
    required String tileId,
    Map<String, dynamic>? tileData,
    String? component,
  }) {
    _incrementEventCount('tile_interaction');
    
    AppLogger.info(
      'Tile interaction: $action on $tileId${component != null ? ' in $component' : ''} (count: ${_eventCounts['tile_interaction']})',
      tag: '$_tag.Interaction',
    );
  }

  /// Log performance metrics
  static void logPerformance({
    required String operation,
    required Duration duration,
    Map<String, dynamic>? metrics,
  }) {
    // Log warning if operation is slow
    if (duration.inMilliseconds > 1000) {
      AppLogger.warning(
        'Slow operation detected: $operation took ${duration.inMilliseconds}ms',
        tag: '$_tag.Performance',
      );
    } else {
      AppLogger.debug(
        'Performance: $operation completed in ${duration.inMilliseconds}ms',
        tag: '$_tag.Performance',
      );
    }
    
    developer.log(
      'Performance metric',
      name: '$_tag.Performance',
      time: DateTime.now(),
    );
  }

  /// Log rendering operations
  static void logRendering({
    required String component,
    required String phase,
    int? itemCount,
  }) {
    AppLogger.debug(
      'Rendering: $component - $phase${itemCount != null ? ' ($itemCount items)' : ''}',
      tag: '$_tag.Render',
    );
  }

  /// Log state changes
  static void logStateChange({
    required String component,
    required String fromState,
    required String toState,
    Map<String, dynamic>? stateData,
  }) {
    AppLogger.debug(
      'State change: $component from $fromState to $toState${stateData != null ? ' with data' : ''}',
      tag: '$_tag.State',
    );
  }

  /// Log API calls related to heatmap data
  static void logApiCall({
    required String endpoint,
    required String method,
    Map<String, dynamic>? parameters,
    int? statusCode,
    Duration? duration,
  }) {
    if (statusCode != null && statusCode >= 400) {
      AppLogger.warning(
        'API call failed: $method $endpoint (status: $statusCode)',
        tag: '$_tag.API',
      );
    } else {
      AppLogger.info(
        'API call: $method $endpoint${duration != null ? ' (${duration.inMilliseconds}ms)' : ''}',
        tag: '$_tag.API',
      );
    }
  }

  /// Log warnings specific to heatmap operations
  static void logWarning({
    required String message,
    String? component,
    Map<String, dynamic>? context,
  }) {
    AppLogger.warning(
      message,
      tag: component != null ? '$_tag.$component' : _tag,
    );
  }

  /// Log errors specific to heatmap operations
  static void logError({
    required String message,
    required dynamic error,
    StackTrace? stackTrace,
    String? component,
    Map<String, dynamic>? context,
  }) {
    AppLogger.error(
      message,
      error: error,
      stackTrace: stackTrace,
      tag: component != null ? '$_tag.$component.Error' : '$_tag.Error',
    );
  }

  /// Get performance statistics
  static Map<String, dynamic> getPerformanceStats() {
    return {
      'activeOperations': _operationStartTimes.length,
      'eventCounts': Map.from(_eventCounts),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Clear performance tracking data
  static void clearPerformanceData() {
    _operationStartTimes.clear();
    _eventCounts.clear();
    AppLogger.info('Performance data cleared', tag: '$_tag.Performance');
  }

  // Helper methods
  static String? _findOperationId(String operation) {
    return _operationStartTimes.keys
        .where((key) => key.startsWith(operation))
        .firstOrNull;
  }

  static Duration? _calculateDuration(String? operationId) {
    if (operationId == null) return null;
    final startTime = _operationStartTimes[operationId];
    if (startTime == null) return null;
    return DateTime.now().difference(startTime);
  }

  static void _incrementEventCount(String eventType) {
    _eventCounts[eventType] = (_eventCounts[eventType] ?? 0) + 1;
  }
}

/// Extension to add null-aware firstOrNull method for older Dart versions
extension IterableExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}