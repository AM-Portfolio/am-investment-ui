import 'package:flutter/services.dart';

/// Properties loader similar to Spring's @Value concept
class AppProperties {
  static final AppProperties _instance = AppProperties._internal();
  factory AppProperties() => _instance;
  AppProperties._internal();

  final Map<String, String> _properties = {};
  bool _isLoaded = false;

  /// Load properties from assets/application.properties
  /// @param environment - Optional environment name to load specific properties
  Future<void> loadProperties({String? environment}) async {
    if (_isLoaded) return;

    // Try to load from assets/application.properties
    try {
      final propertiesContent = await rootBundle.loadString('assets/application.properties');
      _parseProperties(propertiesContent);
      print('Loaded main properties file: application.properties');
    } catch (e) {
      print('Error loading main properties file: $e');
      throw Exception('Failed to load application.properties: $e');
    }
    
    // Determine environment - priority: parameter > environment variable > default
    String env = environment ?? 
                const String.fromEnvironment('ENV', defaultValue: '') ??
                const String.fromEnvironment('FLUTTER_ENV', defaultValue: '');
    
    // Use default if env is empty
    if (env.isEmpty) {
      env = 'dev';
    }
    
    print('Using environment: $env');
    
    // Override with environment-specific properties if they exist
    try {
      final envPropertiesContent = await rootBundle.loadString('assets/application-$env.properties');
      _parseProperties(envPropertiesContent);
      print('Loaded environment-specific properties: application-$env.properties');
    } catch (e) {
      print('Environment-specific properties file not found: application-$env.properties');
      // This is not an error - environment-specific files are optional
    }
    
    _isLoaded = true;
  }

  /// Parse properties file content
  void _parseProperties(String content) {
    final lines = content.split('\n');
    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty || trimmedLine.startsWith('#')) {
        continue; // Skip empty lines and comments
      }
      
      final equalIndex = trimmedLine.indexOf('=');
      if (equalIndex > 0) {
        final key = trimmedLine.substring(0, equalIndex).trim();
        final value = trimmedLine.substring(equalIndex + 1).trim();
        _properties[key] = value;
      }
    }
  }

  /// Get property value (similar to Spring's @Value)
  String getValue(String key, {String? defaultValue}) {
    // First check environment variables
    final envValue = const String.fromEnvironment('DEFAULT_ENV_VAR');
    if (envValue.isNotEmpty) {
      return envValue;
    }
    
    // Then check properties file
    final value = _properties[key];
    if (value == null && defaultValue == null) {
      throw Exception('Property "$key" not found in properties file and no default value provided');
    }
    return value ?? defaultValue ?? '';
  }

  /// Get property as int
  int getIntValue(String key, {int? defaultValue}) {
    final value = getValue(key, defaultValue: defaultValue?.toString());
    final parsedValue = int.tryParse(value);
    if (parsedValue == null && defaultValue == null) {
      throw Exception('Property "$key" is not a valid integer: $value');
    }
    return parsedValue ?? defaultValue ?? 0;
  }

  /// Get property as bool
  bool getBoolValue(String key, {bool? defaultValue}) {
    final value = getValue(key, defaultValue: defaultValue?.toString()).toLowerCase();
    if (value == 'true' || value == '1' || value == 'yes') return true;
    if (value == 'false' || value == '0' || value == 'no') return false;
    
    if (defaultValue == null) {
      throw Exception('Property "$key" is not a valid boolean: $value');
    }
    return defaultValue;
  }

  /// Get property as double
  double getDoubleValue(String key, {double? defaultValue}) {
    final value = getValue(key, defaultValue: defaultValue?.toString());
    final parsedValue = double.tryParse(value);
    if (parsedValue == null && defaultValue == null) {
      throw Exception('Property "$key" is not a valid double: $value');
    }
    return parsedValue ?? defaultValue ?? 0.0;
  }

  /// Check if property exists
  bool hasProperty(String key) {
    return _properties.containsKey(key) || 
           const String.fromEnvironment('DEFAULT_ENV_VAR').isNotEmpty;
  }

  /// Get all properties
  Map<String, String> getAllProperties() {
    return Map.unmodifiable(_properties);
  }

  /// Set property at runtime (for testing/development)
  void setProperty(String key, String value) {
    _properties[key] = value;
  }

  /// Reload properties
  /// @param environment - Optional environment name to load specific properties
  Future<void> reload({String? environment}) async {
    _properties.clear();
    _isLoaded = false;
    await loadProperties(environment: environment);
  }
}

/// Annotation for marking fields that should be injected with property values
class Value {
  final String key;
  final String? defaultValue;
  
  const Value(this.key, {this.defaultValue});
}

/// Property injection mixin
mixin PropertyInjection {
  final AppProperties _properties = AppProperties();

  /// Get property value
  String property(String key, {String? defaultValue}) {
    return _properties.getValue(key, defaultValue: defaultValue);
  }

  /// Get property as int
  int intProperty(String key, {int? defaultValue}) {
    return _properties.getIntValue(key, defaultValue: defaultValue);
  }

  /// Get property as bool
  bool boolProperty(String key, {bool? defaultValue}) {
    return _properties.getBoolValue(key, defaultValue: defaultValue);
  }

  /// Get property as double
  double doubleProperty(String key, {double? defaultValue}) {
    return _properties.getDoubleValue(key, defaultValue: defaultValue);
  }

  /// Set property at runtime (for testing/development)
  void updateProperty(String key, String value) {
    _properties.setProperty(key, value);
  }
}