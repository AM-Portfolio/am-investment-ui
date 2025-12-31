
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/config/app_properties.dart';
import '../constants/app_constants.dart';
import '../constants/api_endpoints.dart';

class FeatureConfigService {
  factory FeatureConfigService() => _instance;
  FeatureConfigService._internal();
  static final FeatureConfigService _instance = FeatureConfigService._internal();

  bool _isTradeEnabled = true;
  bool _isAuthEnabled = true;

  // Getters
  bool get isTradeEnabled => _isTradeEnabled;
  bool get isAuthEnabled => _isAuthEnabled;

  /// Initialize features from local properties
  Future<void> init() async {
    final props = AppProperties();
    _isTradeEnabled = props.getBoolValue(PropertyKeys.apiTradeEnabled, defaultValue: true);
    _isAuthEnabled = props.getBoolValue(PropertyKeys.apiAuthEnabled, defaultValue: true);
    
    // Optionally fetch from remote
    await fetchRemoteFeatures();
  }

  /// Fetch feature flags from remote API
  /// This allows dynamic toggling of features without redeploying
  Future<void> fetchRemoteFeatures() async {
    try {
      // Trying to fetch from a hypothetical features endpoint
      // Adjust path as per actual backend implementation if available
      // Using /users/v1/info as a placeholder/proxy if it contains system info
      // Or a dedicated /api/v1/features if it existed.
      // For now, checks against Trade API root or health to confirm availability
      
      final tradeUrl = ApiEndpoints.trades; 
      // Simple check: if we can hit the trade API root, it's enabled.
      // Or use a dedicated feature flag endpoint.
      // Since one doesn't exist, we rely on properties, but here is the scaffold.
      
      print('FeatureConfigService: Remote feature fetch not fully implemented (no endpoint). Using local properties.');
      
    } catch (e) {
      print('Failed to fetch remote features: $e');
    }
  }
}
