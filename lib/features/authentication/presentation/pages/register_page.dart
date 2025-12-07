import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/registration_form_widget.dart';

/// User registration form for use inside persistent shell
class RegisterForm extends StatelessWidget {
  const RegisterForm({
    super.key, 
    required this.onLogin,
  });

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) => BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          // Navigate to home page after successful registration
          Navigator.of(context).pushReplacementNamed('/home');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
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
              TextButton(
                onPressed: onLogin,
                child: const Text('Sign In'),
              ),
            ],
          ),
        ],
      ),
    );
}
