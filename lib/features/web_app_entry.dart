import 'package:flutter/material.dart';
import '../shared/widgets/layouts/web_layout.dart';

/// Main entry point for the web application
/// Uses the WebLayout to handle navigation without full page reloads
class WebAppEntry extends StatelessWidget {
  /// Constructor
  const WebAppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    // Use WebLayout to handle navigation without full page reloads
    return const WebLayout(
      child: Center(child: Text('Welcome to AM Investment')),
    );
  }
}
