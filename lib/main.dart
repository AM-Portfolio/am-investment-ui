import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'config/config_service.dart';

/// SINGLE entry point for Android, iOS, and Web.
/// Flutter handles platform detection automatically.
void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize configuration service
  await ConfigService.initialize();
  
  // Run the app with dependency injection setup
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
