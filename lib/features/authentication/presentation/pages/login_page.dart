import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:am_common_ui/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:am_common_ui/features/authentication/presentation/cubit/auth_state.dart';
import '../cubit/feature_flag_cubit.dart';
import '../cubit/feature_flag_state.dart';
import '../widgets/demo_login_button_widget.dart';
import '../widgets/email_login_form_widget.dart';
import '../widgets/feature_flag_panel_widget.dart';
import '../widgets/google_login_button_widget.dart';
import 'package:am_common_ui/am_common_ui.dart' hide EmailLoginFormWidget, GoogleLoginButtonWidget, DemoLoginButtonWidget, FeatureFlagPanelWidget, FeatureFlagCubit, FeatureFlagState;

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
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        builder: (context, state) => Stack(
          children: [
            // Interactive particle background with cursor effects
            InteractiveParticleBackground(
              particleCount: 120, // More particles
              highlightRadius: 180.0,
              particleSize: 4.0, // Slightly larger
              particleColor: Colors.blueAccent.withOpacity(0.2), // More visible
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFE0F7FA), // Very light cyan
                      Color(0xFFE1F5FE), // Light blue
                      Color(0xFFF3E5F5), // Light purple
                    ],
                  ),
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
                    // App Icon
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // App title
                    const Text(
                      'AM Investment',
                      style: TextStyle(
                        fontSize: 28, 
                        fontWeight: FontWeight.bold, 
                        color: Color(0xFF1A1F36), // Dark slate
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Login card
                    Theme(
                      data: ThemeData.light().copyWith(
                        inputDecorationTheme: InputDecorationTheme(
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          labelStyle: TextStyle(color: Colors.grey.shade700),
                          prefixIconColor: Colors.grey.shade600,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.blue, width: 2),
                          ),
                        ),
                      ),
                      child: Card(
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.1),
                        color: Colors.white,
                        surfaceTintColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Email/Password form
                              if (state is AuthLoading)
                                const Center(child: CircularProgressIndicator())
                              else
                                const EmailLoginFormWidget(),
      
                              const SizedBox(height: 24),
      
                              // Divider
                              Row(
                                children: [
                                  Expanded(child: Divider(color: Colors.grey.shade300)),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16), 
                                    child: Text('OR', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  ),
                                  Expanded(child: Divider(color: Colors.grey.shade300)),
                                ],
                              ),
      
                              const SizedBox(height: 24),
      
                              // Google login button
                              const GoogleLoginButtonWidget(),
      
                              const SizedBox(height: 16),
      
                              // Demo login button
                              const DemoLoginButtonWidget(),
      
                              const SizedBox(height: 24),
      
                              // Forgot password link
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pushNamed('/forgot-password');
                                },
                                child: const Text('Forgot Password?', style: TextStyle(fontSize: 14, color: Colors.blue)),
                              ),
      
                              const SizedBox(height: 8),
      
                              // Register link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Don't have an account?", style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pushNamed('/register');
                                    },
                                    child: const Text(
                                      'Create Account',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Developer control panel (Always visible toggle or button at bottom)
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Column(
                children: [
                   GestureDetector(
                     onTap: () {
                       // Toggle visibility of panel or show bottom sheet
                       context.read<FeatureFlagCubit>().toggleDeveloperPanel();
                     },
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         const Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.grey),
                         const SizedBox(width: 8),
                         Text(
                           'Developer Options', 
                           style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                         ),
                       ],
                     ),
                   ),
                   BlocBuilder<FeatureFlagCubit, FeatureFlagState>(
                    builder: (context, flagState) {
                      if (flagState.flags.showDeveloperPanel) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 16.0),
                          child: FeatureFlagPanelWidget(),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
