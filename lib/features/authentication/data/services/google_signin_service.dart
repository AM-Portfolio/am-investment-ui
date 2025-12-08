import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;

import '../../../../core/constants/auth_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Google Sign-In account
class GoogleSignInAccount {
  GoogleSignInAccount({
    required this.email,
    required this.id,
    required this.idToken,
  });

  final String email;
  final String id;
  final String idToken;

  Future<GoogleSignInAuthentication> get authentication async =>
      GoogleSignInAuthentication(idToken: idToken);
}

/// Google Sign-In authentication
class GoogleSignInAuthentication {
  GoogleSignInAuthentication({required this.idToken});

  final String? idToken;
}

/// Service for Google Sign-In using Google Identity Services (web)
class GoogleSignInService {
  Completer<GoogleSignInAccount?>? _signInCompleter;
  bool _initialized = false;

  /// Sign in with Google
  Future<GoogleSignInAccount?> signIn() async {
    try {
      AppLogger.info('🔵 Google Sign-In: Starting...');

      // Create new completer for this sign-in attempt
      _signInCompleter = Completer<GoogleSignInAccount?>();

      // Check if Google Identity Services is loaded
      final google = js.context['google'];
      if (google == null) {
        throw AuthException(
          'Google Identity Services not loaded. Check index.html',
        );
      }

      final accounts = google['accounts'];
      if (accounts == null) {
        throw AuthException('Google Accounts API not available');
      }

      final id = accounts['id'];
      if (id == null) {
        throw AuthException('Google ID API not available');
      }

      // Initialize Google Sign-In (once)
      if (!_initialized) {
        AppLogger.info('🔵 Initializing Google Identity Services...');

        id.callMethod('initialize', [
          js.JsObject.jsify({
            'client_id':
                '536930944518-v4406qrrj4o2pk594g2rc3sk6lfinlf6.apps.googleusercontent.com',
            'callback': js.allowInterop(_handleCredentialResponse),
            'use_fedcm_for_prompt': false,
          }),
        ]);

        _initialized = true;
      }

      // Trigger the sign-in popup
      AppLogger.info('🔵 Showing Google Sign-In popup...');
      id.callMethod('prompt', [
        js.JsObject.jsify({'moment_type': 'display'}),
      ]);

      // Wait for the callback
      final account = await _signInCompleter!.future.timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw AuthException('Google Sign-In timeout. Please try again.');
        },
      );

      AppLogger.info('✅ Google Sign-In successful!');
      return account;
    } catch (e) {
      AppLogger.error('❌ Google Sign-In failed: $e');
      throw AuthException(AuthConstants.googleSignInFailed);
    }
  }

  /// Handle credential response from Google
  void _handleCredentialResponse(dynamic response) {
    try {
      AppLogger.info('🔵 Received credential from Google');

      final credential = response['credential'];
      if (credential != null) {
        final idToken = credential.toString();

        AppLogger.info('🔵 ID Token received (length: ${idToken.length})');

        final account = GoogleSignInAccount(
          email: 'google-user', // Backend will decode from token
          id: 'google-id',
          idToken: idToken,
        );

        if (_signInCompleter != null && !_signInCompleter!.isCompleted) {
          _signInCompleter!.complete(account);
        }
      } else {
        AppLogger.error('❌ No credential in response');
        if (_signInCompleter != null && !_signInCompleter!.isCompleted) {
          _signInCompleter!.completeError(
            AuthException('No credential received from Google'),
          );
        }
      }
    } catch (e) {
      AppLogger.error('❌ Error handling credential: $e');
      if (_signInCompleter != null && !_signInCompleter!.isCompleted) {
        _signInCompleter!.completeError(e);
      }
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    try {
      final google = js.context['google'];
      final accounts = google?['accounts'];
      final id = accounts?['id'];
      id?.callMethod('disableAutoSelect', []);

      _initialized = false;
      AppLogger.info('✅ Google Sign-Out complete');
    } catch (e) {
      AppLogger.error('Google sign out error: $e');
    }
  }

  /// Check if user is signed in
  Future<bool> isSignedIn() async => false;

  /// Get currently signed in account
  GoogleSignInAccount? getCurrentAccount() => null;
}
