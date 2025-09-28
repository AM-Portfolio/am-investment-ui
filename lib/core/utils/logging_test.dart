import 'package:flutter/material.dart';
import '../core/utils/logger.dart';
import '../config/environment.dart';

/// Example class showing how to use the centralized logging system
/// This demonstrates all the different logging capabilities
class LoggingExample {
  static void demonstrateLogging() {
    // Initialize if not already done
    AppLogger.initialize();
    
    // Basic logging examples
    AppLogger.debug('This is a debug message', tag: 'LoggingExample');
    AppLogger.info('Application started successfully', tag: 'LoggingExample');
    AppLogger.warning('This is a warning message', tag: 'LoggingExample');
    AppLogger.error('This is an error message', tag: 'LoggingExample');
    
    // Method tracing examples
    AppLogger.methodEntry('exampleMethod', tag: 'LoggingExample', 
        params: {'param1': 'value1', 'param2': 42});
    AppLogger.methodExit('exampleMethod', tag: 'LoggingExample', result: 'success');
    
    // API logging examples
    AppLogger.apiRequest('GET', 'https://api.example.com/users', 
        tag: 'LoggingExample', headers: {'Authorization': 'Bearer token'});
    AppLogger.apiResponse('GET', 'https://api.example.com/users', 200, 
        tag: 'LoggingExample', duration: 150);
    
    // User action logging
    AppLogger.userAction('Button clicked', tag: 'LoggingExample', 
        context: {'buttonId': 'login', 'page': 'LoginScreen'});
    
    // State change logging
    AppLogger.stateChange('Loading', 'Loaded', tag: 'LoggingExample', 
        event: 'Data fetched successfully');
    
    // Error with stack trace
    try {
      throw Exception('Example error for logging');
    } catch (e, stackTrace) {
      AppLogger.error('Caught exception', tag: 'LoggingExample', 
          error: e, stackTrace: stackTrace);
    }
    
    // Show logging statistics
    AppLogger.info('Logging stats: ${AppLogger.getStats()}', tag: 'LoggingExample');
  }
  
  /// Test logging in different environments
  static void testEnvironmentLogging() {
    AppLogger.info('=== Testing Development Environment ===', tag: 'LoggingTest');
    EnvironmentConfig.environment = Environment.development;
    _logTestMessages();
    
    AppLogger.info('=== Testing Preprod Environment ===', tag: 'LoggingTest');
    EnvironmentConfig.environment = Environment.preprod;
    _logTestMessages();
    
    AppLogger.info('=== Testing Production Environment ===', tag: 'LoggingTest');
    EnvironmentConfig.environment = Environment.production;
    _logTestMessages();
    
    // Reset to development for further testing
    EnvironmentConfig.environment = Environment.development;
  }
  
  static void _logTestMessages() {
    AppLogger.debug('Debug message - should only appear in dev', tag: 'LoggingTest');
    AppLogger.info('Info message - should appear in dev and preprod', tag: 'LoggingTest');
    AppLogger.warning('Warning message - should appear in dev and preprod', tag: 'LoggingTest');
    AppLogger.error('Error message - should appear in all environments (if logging enabled)', tag: 'LoggingTest');
    
    AppLogger.info('Current environment: ${EnvironmentConfig.environment.name}', tag: 'LoggingTest');
    AppLogger.info('Logging enabled: ${AppLogger.getStats()['isEnabled']}', tag: 'LoggingTest');
    AppLogger.info('Minimum level: ${AppLogger.getStats()['minimumLevel']}', tag: 'LoggingTest');
  }
}

/// Widget to demonstrate logging in action
class LoggingTestWidget extends StatelessWidget {
  const LoggingTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logging Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                AppLogger.userAction('Test basic logging clicked', tag: 'LoggingTestWidget');
                LoggingExample.demonstrateLogging();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Check console for logging output'))
                );
              },
              child: const Text('Test Basic Logging'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                AppLogger.userAction('Test environment logging clicked', tag: 'LoggingTestWidget');
                LoggingExample.testEnvironmentLogging();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Check console for environment logging tests'))
                );
              },
              child: const Text('Test Environment Logging'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                AppLogger.userAction('Show logging stats clicked', tag: 'LoggingTestWidget');
                final stats = AppLogger.getStats();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logging Statistics'),
                    content: Text(stats.toString()),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Show Logging Stats'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                AppLogger.userAction('Clear logging stats clicked', tag: 'LoggingTestWidget');
                AppLogger.clearStats();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logging statistics cleared'))
                );
              },
              child: const Text('Clear Stats'),
            ),
          ],
        ),
      ),
    );
  }
}