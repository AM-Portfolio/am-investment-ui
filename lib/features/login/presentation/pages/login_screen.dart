import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../providers/login_providers.dart';
import '../../../../core/utils/logger.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final Function(String userId)? onLogin;
  
  const LoginScreen({
    super.key,
    this.onLogin,
  });

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
    AppLogger.userAction('Login attempt', tag: 'LoginScreen', context: {
      'email': _emailController.text,
      'hasPassword': _passwordController.text.isNotEmpty
    });
    
    if (!_formKey.currentState!.validate()) {
      AppLogger.info('Login validation failed', tag: 'LoginScreen');
      return;
    }

    try {
      AppLogger.info('Starting login process', tag: 'LoginScreen');
      // Use Riverpod authentication provider
      await ref.read(authStateNotifierProvider.notifier).login(
        _emailController.text,
        _passwordController.text,
      );
      
      AppLogger.info('Login successful for user: ${_emailController.text}', tag: 'LoginScreen');
      
      // Call the optional callback for compatibility
      if (widget.onLogin != null) {
        widget.onLogin!(_emailController.text);
      }
    } catch (error) {
      AppLogger.error('Login failed', tag: 'LoginScreen', error: error, 
          stackTrace: StackTrace.current);
      
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
      await ref.read(authStateNotifierProvider.notifier).login(
        "ssd2658",
        "password",
      );
      
      AppLogger.info('Demo login successful', tag: 'LoginScreen');
      
      // Call the optional callback for compatibility
      if (widget.onLogin != null) {
        widget.onLogin!("ssd2658");
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateNotifierProvider);
    final isLoading = authState.isLoading;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        centerTitle: PlatformUtils.isMobile,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(PlatformUtils.isMobile ? 16 : 24),
            child: Container(
              width: PlatformUtils.isMobile ? double.infinity : 400,
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App logo or icon for mobile
                    if (PlatformUtils.isMobile) ...[
                      Icon(
                        Icons.account_balance,
                        size: 64,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      'Welcome Back',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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
                      width: double.infinity,
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
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: isLoading ? null : _handleDemoLogin,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Theme.of(context).primaryColor),
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
                    if (PlatformUtils.isMobile) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Platform: ${PlatformUtils.platformName}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}