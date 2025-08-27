import 'package:flutter/material.dart';
import 'config/environment.dart';
import 'core/services/auth_service.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';

void main() {
  // Set environment based on compile-time constants
  // This will be overridden by build arguments in CI/CD
  EnvironmentConfig.setEnvironment(const String.fromEnvironment('ENV', defaultValue: 'production'));
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService _authService = AuthService();
  AuthState _authState = AuthState.unauthenticated();
  
  @override
  void initState() {
    super.initState();
    _authService.authStateChanges.listen((state) {
      setState(() {
        _authState = state;
      });
    });
    
    // Check if user is already logged in
    _authService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: EnvironmentConfig.settings['appTitle'],
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: EnvironmentConfig.environment == Environment.preprod ? Brightness.light : Brightness.light,
      ),
      initialRoute: _authState.isAuthenticated ? '/home' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
      debugShowCheckedModeBanner: EnvironmentConfig.environment == Environment.preprod,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final List<String> _tasks = [];
  final TextEditingController _controller = TextEditingController();

  void _addTask() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _tasks.add(text);
      });
      _controller.clear();
    }
  }

  void _removeTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  void _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My To-Do List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Enter a task',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addTask,
                ),
              ),
              onSubmitted: (_) => _addTask(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _tasks.isEmpty
                  ? const Center(child: Text('No tasks yet. Add one!'))
                  : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (ctx, index) => Dismissible(
                        key: Key(_tasks[index]),
                        onDismissed: (_) => _removeTask(index),
                        child: Card(
                          child: ListTile(
                            title: Text(_tasks[index]),
                            trailing: const Icon(Icons.delete_outline),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
