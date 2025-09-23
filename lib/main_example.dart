import 'package:flutter/material.dart';
import 'core/config/config_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize configuration
  await ConfigService.initialize(environment: 'development');
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AM Investment UI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: YourHomeScreen(),
    );
  }
}