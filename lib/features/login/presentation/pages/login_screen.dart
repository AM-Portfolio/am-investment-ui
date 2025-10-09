import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../di/login_providers.dart';
import '../../../../core/utils/logger.dart';
import '../widgets/developer_controls_panel.dart';
import '../widgets/google_signin_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.onLogin});
  final Function(String userId)? onLogin;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    AppLogger.userAction(
      'Login attempt',
      tag: 'LoginScreen',
      context: {
        'email': _emailController.text,
        'hasPassword': _passwordController.text.isNotEmpty,
      },
    );

    if (!_formKey.currentState!.validate()) {
      AppLogger.info('Login validation failed', tag: 'LoginScreen');
      return;
    }

    try {
      AppLogger.info('Starting login process', tag: 'LoginScreen');
      // Use Riverpod authentication provider
      await ref
          .read(authStateNotifierProvider.notifier)
          .login(_emailController.text, _passwordController.text);

      AppLogger.info(
        'Login successful for user: ${_emailController.text}',
        tag: 'LoginScreen',
      );

      // Call the optional callback for compatibility
      if (widget.onLogin != null) {
        widget.onLogin!(_emailController.text);
      }
    } catch (error) {
      AppLogger.error(
        'Login failed',
        tag: 'LoginScreen',
        error: error,
        stackTrace: StackTrace.current,
      );

      // Error handling is managed by the provider, but show a snackbar for user feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleDemoLogin() async {
    AppLogger.userAction('Demo login attempt', tag: 'LoginScreen');

    try {
      AppLogger.info('Starting demo login process', tag: 'LoginScreen');
      // Demo login with predefined credentials
      await ref
          .read(authStateNotifierProvider.notifier)
          .login('ssd2658', 'password');

      AppLogger.info('Demo login successful', tag: 'LoginScreen');

      // Call the optional callback for compatibility
      if (widget.onLogin != null) {
        widget.onLogin!('ssd2658');
      }
    } catch (error) {
      AppLogger.error('Demo login failed', tag: 'LoginScreen', error: error);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Demo login failed: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    AppLogger.userAction('Google Sign-In attempt', tag: 'LoginScreen');

    try {
      await ref.read(authStateNotifierProvider.notifier).loginWithGoogle();

      AppLogger.info('Google Sign-In successful', tag: 'LoginScreen');

      if (widget.onLogin != null) {
        final user = ref.read(currentUserProvider);
        if (user != null) {
          widget.onLogin!(user.id);
        }
      }
    } catch (error) {
      AppLogger.error('Google Sign-In failed', tag: 'LoginScreen', error: error);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-In failed: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateNotifierProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: kIsWeb ? _buildWebLayout(isLoading) : _buildMobileLayout(isLoading),
    );
  }

  Widget _buildWebLayout(bool isLoading) {
    return Row(
      children: [
        // Left side - Branding
        Expanded(
          flex: 5,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.7),
                  Colors.deepPurple.shade300,
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -100,
                  left: -100,
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -150,
                  right: -150,
                  child: Container(
                    width: 500,
                    height: 500,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(64),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 80,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'AM Investment',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 48,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Your gateway to smart portfolio management',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 48),
                        _buildFeatureItem('📊 Real-time portfolio analytics'),
                        const SizedBox(height: 16),
                        _buildFeatureItem('📈 Advanced market insights'),
                        const SizedBox(height: 16),
                        _buildFeatureItem('🔒 Secure and reliable'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Right side - Login form
        Expanded(
          flex: 4,
          child: Container(
            color: Colors.grey.shade50,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(48),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: _buildLoginForm(isLoading),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(bool isLoading) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _buildLoginForm(isLoading),
        ),
      ),
    );
  }

  Widget _buildLoginForm(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (kIsWeb) ...[
            Icon(
              Icons.account_balance_wallet_rounded,
              size: 64,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
          ],
          Text(
            'Welcome Back',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in to your AM Investment account',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleLogin(),
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                  : const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade300)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey.shade300)),
            ],
          ),
          const SizedBox(height: 16),
          GoogleSignInButton(
            onPressed: isLoading ? null : _handleGoogleSignIn,
            isLoading: isLoading,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: isLoading ? null : _handleDemoLogin,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: Theme.of(context).primaryColor,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Demo Login',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // Developer controls panel
          if (kIsWeb) const DeveloperControlsPanel(),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}
