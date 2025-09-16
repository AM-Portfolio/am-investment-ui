import 'package:flutter/material.dart';
import '../widgets/shared/layouts/main_web_layout.dart';
import '../core/services/auth_service.dart';

/// Main entry point for the web application
/// Uses the MainWebLayout to handle navigation without full page reloads
class WebAppEntry extends StatelessWidget {
  /// Constructor
  const WebAppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    // Get current user ID from auth service
    final userId = AuthService().currentState.user?.id ?? 'default_user';
    
    // Use MainWebLayout to handle navigation without full page reloads
    return MainWebLayout(userId: userId);
  }
}
