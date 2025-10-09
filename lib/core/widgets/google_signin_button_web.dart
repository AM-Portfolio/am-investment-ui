import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// A widget that renders the official Google Sign-In button for web platform
/// This uses the renderButton method required by google_sign_in v7.x on web
class GoogleSignInButtonWeb extends StatefulWidget {
  const GoogleSignInButtonWeb({
    required this.onSignedIn,
    super.key,
    this.buttonText = 'Sign in with Google',
  });

  final Function(GoogleSignInAccount user) onSignedIn;
  final String buttonText;

  @override
  State<GoogleSignInButtonWeb> createState() => _GoogleSignInButtonWebState();
}

class _GoogleSignInButtonWebState extends State<GoogleSignInButtonWeb> {
  @override
  void initState() {
    super.initState();
    _setupAuthenticationListener();
  }

  void _setupAuthenticationListener() {
    // Listen to authentication events
    GoogleSignIn.instance.authenticationEvents.listen((event) {
      // Extract the user from the event and call the callback
      // The event structure in v7.x provides the signed-in user
      if (event.user != null) {
        widget.onSignedIn(event.user!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use GoogleSignIn.renderButton to create the official button
    // This is required for web platform in google_sign_in v7.x
    return GoogleSignIn.instance.renderButton(
      configuration: GSIButtonConfiguration(
        text: GSIButtonText.signinWith,
        shape: GSIButtonShape.pill,
        size: GSIButtonSize.large,
      ),
    );
  }
}
