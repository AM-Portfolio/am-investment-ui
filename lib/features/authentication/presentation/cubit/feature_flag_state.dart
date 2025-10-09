import 'package:equatable/equatable.dart';
import '../../../../core/config/feature_flags.dart';

/// Feature flag state
class FeatureFlagState extends Equatable {
  const FeatureFlagState(this.flags);
  final FeatureFlags flags;

  @override
  List<Object?> get props => [flags];
}
