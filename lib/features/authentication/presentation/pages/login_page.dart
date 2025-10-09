import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../cubit/feature_flag_cubit.dart';
import '../cubit/feature_flag_state.dart';
import '../widgets/email_login_form_widget.dart';
import '../widgets/google_login_button_widget.dart';
import '../widgets/demo_login_button_widget.dart';
import '../widgets/feature_flag_panel_widget.dart';

/// Main login page with all authentication options
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            // Navigate to home page
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
        builder: (context, state) => Stack(
          children: [
            // Background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.shade900,
                    Colors.blue.shade600,
                    Colors.cyan.shade400,
                  ],
                ),
              ),
            ),

            // Content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App title
                    const Text(
                      '🌟 AM Investment UI',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Login card
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Welcome Back! 👋',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),

                            // Email/Password form
                            if (state is AuthLoading)
                              const Center(child: CircularProgressIndicator())
                            else
                              const EmailLoginFormWidget(),

                            const SizedBox(height: 24),

                            // Divider
                            const Row(
                              children: [
                                Expanded(child: Divider()),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text('OR'),
                                ),
                                Expanded(child: Divider()),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Google login button
                            const GoogleLoginButtonWidget(),

                            const SizedBox(height: 16),

                            // Demo login button
                            const DemoLoginButtonWidget(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Developer control panel
            BlocBuilder<FeatureFlagCubit, FeatureFlagState>(
              builder: (context, flagState) {
                if (flagState.flags.showDeveloperPanel) {
                  return const Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: FeatureFlagPanelWidget(),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    ),
  );
}
