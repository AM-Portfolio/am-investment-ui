import '../domain/entities/user.dart';

/// Stub implementation for non-web platforms
/// This file is only imported on mobile (Android/iOS) platforms
/// The actual web implementation is in google_signin_web.dart
class GoogleSignInWeb {
  factory GoogleSignInWeb() => _instance;
  GoogleSignInWeb._internal();
  static final GoogleSignInWeb _instance = GoogleSignInWeb._internal();

  /// Initialize - no-op on mobile platforms
  void initialize(String clientId) {
    // This is a stub - web-specific functionality is not needed on mobile
  }

  /// Sign in - throws error on mobile platforms
  Future<User?> signIn() async {
    throw UnsupportedError(
      'GoogleSignInWeb is only supported on web platforms. '
      'Use GoogleSignIn package directly on mobile platforms.',
    );
  }

  /// Render button - no-op on mobile platforms
  void renderButton(String containerId) {
    // This is a stub - web-specific functionality is not needed on mobile
  }

  /// Sign out - no-op on mobile platforms
  void signOut() {
    // This is a stub - web-specific functionality is not needed on mobile
  }

  /// Cancel sign in - no-op on mobile platforms
  void cancelSignIn() {
    // This is a stub - web-specific functionality is not needed on mobile
  }
}
