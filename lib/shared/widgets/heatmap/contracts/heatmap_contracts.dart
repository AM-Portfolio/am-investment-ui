/// Barrel export file for heatmap contracts
///
/// This file provides a single import point for all heatmap contracts,
/// following the project's established pattern of using barrel exports.
///
/// Usage in shared components:
/// ```dart
/// import '../contracts/heatmap_contracts.dart';
/// ```
///
/// Usage in feature implementations:
/// ```dart
/// import '../../../../shared/widgets/heatmap/contracts/heatmap_contracts.dart';
/// ```
library;

export 'heatmap_data_contract.dart';
export 'heatmap_refresh_contract.dart';
