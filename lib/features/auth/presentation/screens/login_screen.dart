import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/services/auth_service.dart';
import '../widgets/modern_login_form.dart';
import '../widgets/animated_login_elements.dart';
import '../widgets/login_background.dart';
import '../widgets/app_logo.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  
  bool _isLoading = false;
  String? _errorMessage;
  
  LoginMethod _selectedLoginMethod = LoginMethod.email;
  
  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _authService.login(
      _identifierController.text.trim(),
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (!result.success) {
      setState(() {
        _errorMessage = result.error;
      });
      return;
    }

    // Navigate to home screen or dashboard
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }
  
  // Quick login with test user
  Future<void> _quickLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    // Set the appropriate identifier based on selected login method
    switch (_selectedLoginMethod) {
      case LoginMethod.email:
        _identifierController.text = 'demo@example.com';
        break;
      case LoginMethod.username:
        _identifierController.text = 'demouser';
        break;
      case LoginMethod.phone:
        _identifierController.text = '+1234567890';
        break;
    }
    
    _passwordController.text = 'password123';
    
    // Small delay to show the filled fields before login
    await Future.delayed(const Duration(milliseconds: 300));
    
    final result = await _authService.login(
      _identifierController.text.trim(),
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (!result.success) {
      setState(() {
        _errorMessage = result.error;
      });
      return;
    }

    // Navigate to home screen or dashboard
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Set system overlay style for status bar
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Theme.of(context).primaryColor,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
    
    return Scaffold(
      body: LoginBackground(
        child: _buildResponsiveLayout(),
      ),
    );
  }

  Widget _buildResponsiveLayout() {
    // Use different layouts for web and mobile
    if (kIsWeb) {
      return _buildWebLayout();
    }
    return _buildMobileLayout();
  }

  Widget _buildWebLayout() {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 8,
            color: Colors.black.withOpacity(0.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  // Logo
                  AnimatedLoginElements.fadeInAnimation(
                    child: AnimatedLoginElements.scaleAnimation(
                      child: const AppLogoWithText(
                        logoSize: 70,
                        fontSize: 28,
                        color: Colors.white,
                        vertical: true,
                      ),
                      delay: 0,
                    ),
                    delay: 0,
                  ),
                  const SizedBox(height: 40),
                  
                  // Login form
                  _buildLoginForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Logo
              AnimatedLoginElements.fadeInAnimation(
                child: AnimatedLoginElements.scaleAnimation(
                  child: const AppLogoWithText(
                    logoSize: 70,
                    fontSize: 28,
                    color: Colors.white,
                    vertical: true,
                  ),
                  delay: 0,
                ),
                delay: 0,
              ),
              const SizedBox(height: 40),
              
              // Login form with glass effect
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: _buildLoginForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return AnimatedLoginElements.fadeInAnimation(
      child: ModernLoginForm(
        formKey: _formKey,
        identifierController: _identifierController,
        passwordController: _passwordController,
        isLoading: _isLoading,
        errorMessage: _errorMessage,
        onLogin: _login,
        onQuickLogin: _quickLogin,
        onForgotPassword: () {
          // Navigate to forgot password screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Forgot password feature coming soon')),
          );
        },
        onRegister: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const RegisterScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOutCubic;
                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);
                return SlideTransition(position: offsetAnimation, child: child);
              },
            ),
          );
        },
        selectedLoginMethod: _selectedLoginMethod,
        onLoginMethodChanged: (Set<LoginMethod> selection) {
          setState(() {
            _selectedLoginMethod = selection.first;
            // Clear the identifier field when switching login methods
            _identifierController.clear();
          });
        },
      ),
      delay: 200,
    );
  }
  
}
