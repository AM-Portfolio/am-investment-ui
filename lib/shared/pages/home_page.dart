import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:am_common_ui/features/authentication/presentation/cubit/auth_cubit.dart';  // Migrated to am_common_ui
import 'package:am_common_ui/features/authentication/presentation/cubit/auth_state.dart';  // Migrated to am_common_ui

/// Home page shown after authentication
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => BlocListener<AuthCubit, AuthState>(
    listener: (context, state) {
      if (state is Unauthenticated) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    },
    child: Scaffold(
      appBar: AppBar(
        title: const Text('AM Investment - Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthCubit>().logout();
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 100,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Welcome!',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Logged in as: ${state.user.email}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Display Name: ${state.user.displayName ?? "N/A"}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Auth Method: ${state.user.authMethod}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (state.user.isDemo)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade700),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info_outline, color: Colors.amber),
                          SizedBox(width: 8),
                          Text(
                            '🎭 Demo Mode',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 48),
                  const Text(
                    '✅ Authentication feature is working correctly!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    ),
  );
}
