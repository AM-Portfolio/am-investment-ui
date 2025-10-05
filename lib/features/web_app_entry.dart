import 'package:flutter/material.dart';
import '../shared/widgets/layouts/web_layout.dart';
import '../core/app_logic/services/auth_service.dart';

/// Main entry point for the web application
/// Uses the WebLayout to handle navigation without full page reloads
class WebAppEntry extends StatelessWidget {
  /// Constructor
  const WebAppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    // Use WebLayout to handle navigation without full page reloads
    return WebLayout(
      child: Container(child: const Text('Welcome to AM Investment')),
    );
  }
}
