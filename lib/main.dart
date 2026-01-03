import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'package:am_common_ui/config/config_service.dart';  // Migrated
import 'di/injection.dart';

/// SINGLE entry point for Android, iOS, and Web.
/// Flutter handles platform detection automatically.
import 'package:am_common_ui/core/utils/logger.dart';

/// SINGLE entry point for Android, iOS, and Web.
/// Flutter handles platform detection automatically.
void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Logger
  AppLogger.initialize();
  AppLogger.info('🚀 AM Investment UI starting up...', tag: 'App');

  // Initialize configuration service
  try {
    await ConfigService.initialize();
    AppLogger.info('✅ ConfigService initialized', tag: 'App');
  } catch (e, stack) {
    AppLogger.error('❌ ConfigService initialization failed', tag: 'App', error: e, stackTrace: stack);
  }

  // Setup dependency injection
  try {
    await setupDependencyInjection();
    AppLogger.info('✅ DependencyInjection setup complete', tag: 'App');
  } catch (e, stack) {
    AppLogger.error('❌ DependencyInjection setup failed', tag: 'App', error: e, stackTrace: stack);
  }

  // Run the app with dependency injection setup
  runApp(const ProviderScope(child: App()));
}

