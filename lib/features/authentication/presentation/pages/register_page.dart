import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/registration_form_widget.dart';

/// User registration form for use inside persistent shell
class RegisterForm extends StatelessWidget {
  const RegisterForm({super.key, required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) => BlocConsumer<AuthCubit, AuthState>(
    listener: (context, state) {
      if (state is Authenticated) {
        // Navigate to home page after successful registration
        Navigator.of(context).pushReplacementNamed('/home');
      } else if (state is AuthError) {
        // Check if message contains User ID (UUID)
        if (state.message.contains('User ID:')) {
          // Extract UUID from message
          final uuidMatch = RegExp(
            r'User ID: ([a-f0-9-]+)',
          ).firstMatch(state.message);
          final userId = uuidMatch?.group(1) ?? '';

          // Show dialog with copy button
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[600]),
                  const SizedBox(width: 8),
                  const Text('Account Created!'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your account has been created successfully.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Copy your User ID to activate:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            userId,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          tooltip: 'Copy to clipboard',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: userId));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('UUID copied to clipboard!'),
                                duration: Duration(seconds: 2),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Open Developer Controls on the login screen to activate your account.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    onLogin(); // Back to login via callback
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          // Show regular error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      }
    },
    builder: (context, state) => Column(
      children: [
        const Text(
          'Create Account ✨',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Registration form
        if (state is AuthLoading)
          const Center(child: CircularProgressIndicator())
        else
          const RegistrationFormWidget(),

        const SizedBox(height: 24),

        // Already have account link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Already have an account? '),
            TextButton(onPressed: onLogin, child: const Text('Sign In')),
          ],
        ),
      ],
    ),
  );
}
