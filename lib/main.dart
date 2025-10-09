import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'config/config_service.dart';
import 'di/injection.dart';

/// SINGLE entry point for Android, iOS, and Web.
/// Flutter handles platform detection automatically.
void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize configuration service
  await ConfigService.initialize();

  // Setup dependency injection
  await setupDependencyInjection();

  // Run the app with dependency injection setup
  runApp(const ProviderScope(child: App()));
}
