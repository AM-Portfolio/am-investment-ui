import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../../../shared/widgets/backgrounds/interactive_background.dart';
import '../../../../shared/widgets/media/background_audio_control.dart';
import '../../../../shared/widgets/media/theme_selector.dart';
import '../widgets/login_form.dart';
import 'forgot_password_page.dart'; // Actually ForgotPasswordForm
import 'register_page.dart'; // Actually RegisterForm

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key, 
    this.onLogin,
    this.initialView = AuthView.login,
  });
  
  final Function(String userId)? onLogin;
  final AuthView initialView;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum AuthView { login, register, forgotPassword }

class _LoginScreenState extends State<LoginScreen> {
  BackgroundTheme _currentTheme = BackgroundTheme.nebula;
  late AuthView _currentView;

  @override
  void initState() {
    super.initState();
    _currentView = widget.initialView;
  }

  void _switchView(AuthView view) {
    setState(() {
      _currentView = view;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient (Persistent)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1A1A2E), // Dark Navy
                    const Color(0xFF16213E), // Slightly lighter Navy
                    const Color(0xFF0F3460).withValues(alpha: 0.8), // Deep Blue
                  ],
                ),
              ),
            ),
          ),
          
          // Full Screen Background Animation (Persistent)
          Positioned.fill(
            child: InteractiveBackground(
              baseColor: Theme.of(context).primaryColor,
              highlightColor: _currentTheme == BackgroundTheme.market 
                  ? Colors.greenAccent 
                  : Colors.tealAccent,
              theme: _currentTheme,
            ),
          ),

          // Content Layer (Swappable)
          Positioned.fill(
            child: kIsWeb
                ? _buildWebLayout()
                : _buildCenteredLayout(),
          ),

          // Controls Layer (Persistent)
          Positioned(
            top: 24,
            right: 24,
            child: Row(
              children: [
                ThemeSelector(
                  currentTheme: _currentTheme,
                  onThemeChanged: (theme) => setState(() => _currentTheme = theme),
                ),
                const SizedBox(width: 16),
                const BackgroundAudioControl(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebLayout() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Row(
          children: [
            // Left side - Branding (Fixed)
            Expanded(
              flex: 5,
              child: _buildBranding(),
            ),
            // Right side - Swappable Form
            Expanded(
              flex: 4,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(48),
                  child: _buildGlassContainer(_buildCurrentForm()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenteredLayout() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             _buildMobileBranding(),
             const SizedBox(height: 48),
            _buildGlassContainer(_buildCurrentForm()),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentForm() {
    // Use AnimatedSwitcher for smooth transitions between forms
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: KeyedSubtree(
        key: ValueKey<AuthView>(_currentView),
        child: _getFormWidget(),
      ),
    );
  }

  Widget _getFormWidget() {
    switch (_currentView) {
      case AuthView.login:
        return LoginForm(
          onRegister: () => _switchView(AuthView.register),
          onForgotPassword: () => _switchView(AuthView.forgotPassword),
        );
      case AuthView.register:
        return RegisterForm(
          onLogin: () => _switchView(AuthView.login),
        );
      case AuthView.forgotPassword:
        return ForgotPasswordForm(
          onLogin: () => _switchView(AuthView.login),
        );
    }
  }

  Widget _buildGlassContainer(Widget child) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          decoration: BoxDecoration(
             color: Colors.white.withValues(alpha: 0.7),
             borderRadius: BorderRadius.circular(24),
             border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
             boxShadow: [
               BoxShadow(
                 color: Colors.black.withValues(alpha: 0.1),
                 blurRadius: 30,
                 spreadRadius: 5,
               ),
             ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildBranding() {
     return Padding(
        padding: const EdgeInsets.all(64),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                size: 80,
                color: Colors.white.withValues(alpha: 0.95),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'AM Investment',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 64, // Larger
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    offset: const Offset(2, 2),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your gateway to smart portfolio management',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: 24,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    offset: const Offset(1, 1),
                    blurRadius: 5,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            _buildFeatureItem('📊 Real-time portfolio analytics'),
            const SizedBox(height: 16),
            _buildFeatureItem('📈 Smart investment tracking'),
            const SizedBox(height: 16),
            _buildFeatureItem('🔍 Market insights & analysis'),
            const SizedBox(height: 16),
            _buildFeatureItem('💼 Professional portfolio tools'),
          ],
        ),
      );
  }

   Widget _buildMobileBranding() {
    return Column(
      children: [
         Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
          child: Icon(
            Icons.account_balance_wallet_rounded,
            size: 80,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'AM Investment',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                 shadows: [Shadow(color: Colors.black45, blurRadius: 5)],
              ),
        ),
      ],
    );
   }

  Widget _buildFeatureItem(String text) {
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}
