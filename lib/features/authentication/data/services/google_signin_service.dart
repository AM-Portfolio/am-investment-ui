import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/constants/auth_constants.dart';
import '../../../../core/errors/exceptions.dart';

/// Service for Google Sign-In
class GoogleSignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  /// Sign in with Google
  Future<GoogleSignInAccount?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      return account;
    } catch (e) {
      throw AuthException(AuthConstants.googleSignInFailed);
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      // Log but don't throw
      print('Google sign out failed: $e');
    }
  }

  /// Check if user is signed in
  Future<bool> isSignedIn() async => _googleSignIn.isSignedIn();

  /// Get currently signed in account
  Future<GoogleSignInAccount?> getCurrentAccount() async =>
      _googleSignIn.currentUser;
}
