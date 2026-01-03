import 'package:get_it/get_it.dart';
import 'package:am_common_ui/am_common_ui.dart';

final getIt = GetIt.instance;

/// Setup dependency injection
Future<void> setupDependencyInjection() async {
  // Register SecureStorageService for Market module compatibility
  if (!getIt.isRegistered<SecureStorageService>()) {
    getIt.registerSingleton<SecureStorageService>(SecureStorageService());
  }
  
  // Note: Authentication now uses Riverpod providers
  // No additional DI setup needed for the stable login system
}
