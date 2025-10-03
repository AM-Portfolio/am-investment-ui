import '../../../models/heatmap.dart';

/// Base state class for heatmap-related states
abstract class HeatmapState {
  const HeatmapState();
}

/// Initial state when no data is loaded
class HeatmapInitial extends HeatmapState {
  const HeatmapInitial();
}

/// Loading state when data is being fetched
class HeatmapLoading extends HeatmapState {
  final String? message;

  const HeatmapLoading({this.message});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HeatmapLoading && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

/// Success state when data is loaded successfully
class HeatmapLoaded extends HeatmapState {
  final HeatmapData data;
  final DateTime lastUpdated;

  const HeatmapLoaded({required this.data, required this.lastUpdated});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HeatmapLoaded &&
        other.data == data &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode => data.hashCode ^ lastUpdated.hashCode;
}

/// Error state when data loading fails
class HeatmapError extends HeatmapState {
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  const HeatmapError({required this.message, this.error, this.stackTrace});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HeatmapError &&
        other.message == message &&
        other.error == error;
  }

  @override
  int get hashCode => message.hashCode ^ error.hashCode;
}

/// Refreshing state when data is being refreshed
class HeatmapRefreshing extends HeatmapState {
  final HeatmapData currentData;
  final String? message;

  const HeatmapRefreshing({required this.currentData, this.message});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HeatmapRefreshing &&
        other.currentData == currentData &&
        other.message == message;
  }

  @override
  int get hashCode => currentData.hashCode ^ message.hashCode;
}

/// Empty state when no data is available
class HeatmapEmpty extends HeatmapState {
  final String message;

  const HeatmapEmpty({this.message = 'No data available'});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HeatmapEmpty && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}
