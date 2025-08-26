import 'package:flutter/material.dart';
import 'config/environment.dart';

void main() {
  // Set environment based on compile-time constants
  // This will be overridden by build arguments in CI/CD
  EnvironmentConfig.setEnvironment(const String.fromEnvironment('ENV', defaultValue: 'production'));
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: EnvironmentConfig.settings['appTitle'],
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: EnvironmentConfig.environment == Environment.preprod ? Brightness.light : Brightness.light,
      ),
      home: const TodoScreen(),
      debugShowCheckedModeBanner: EnvironmentConfig.environment == Environment.preprod,
    );
  }
}

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My To-Do List')),
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
