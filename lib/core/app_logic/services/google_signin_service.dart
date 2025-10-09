import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import '../domain/entities/user.dart';
import '../../utils/logger.dart';

class GoogleSignInService {
  static final GoogleSignInService _instance = GoogleSignInService._internal();
  factory GoogleSignInService() => _instance;
  GoogleSignInService._internal();

  bool _isInitialized = false;

  Future<void> initialize({String? webClientId}) async {
    if (_isInitialized) return;

    try {
      await GoogleSignIn.instance.initialize(
        clientId: webClientId,
      );

      AppLogger.info('Google Sign-In initialized', tag: 'GoogleSignInService');
      _isInitialized = true;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to initialize Google Sign-In',
        tag: 'GoogleSignInService',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<User?> signIn() async {
    if (!_isInitialized) {
      throw Exception('GoogleSignInService not initialized. Call initialize() first.');
    }

    try {
      AppLogger.info('Starting Google Sign-In flow', tag: 'GoogleSignInService');

      GoogleSignInAccount? googleUser;

      if (kIsWeb) {
        AppLogger.info('Web platform: Attempting lightweight authentication', tag: 'GoogleSignInService');
        googleUser = await GoogleSignIn.instance.attemptLightweightAuthentication();
        
        if (googleUser == null) {
          AppLogger.warning(
            'Web platform: Lightweight authentication returned null. '
            'Google Sign-In on web requires user interaction with the Google button. '
            'This is a limitation of Google Identity Services on web.',
            tag: 'GoogleSignInService',
          );
          // For web, we need to rely on the authenticationEvents stream
          // or use the renderButton() approach from google_sign_in_web
          throw Exception(
            'Google Sign-In on web requires the official Google button. '
            'Please use the "Continue with Google" button to sign in.'
          );
        }
      } else {
        if (GoogleSignIn.instance.supportsAuthenticate()) {
          AppLogger.info('Mobile platform: Using authenticate()', tag: 'GoogleSignInService');
          googleUser = await GoogleSignIn.instance.authenticate();
        } else {
          AppLogger.warning('Platform does not support authenticate()', tag: 'GoogleSignInService');
        }
      }

      if (googleUser == null) {
        AppLogger.info('User cancelled Google Sign-In', tag: 'GoogleSignInService');
        return null;
      }

      AppLogger.info(
        'Google Sign-In successful for: ${googleUser.email}',
        tag: 'GoogleSignInService',
      );

      final nameParts = (googleUser.displayName ?? '').split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : 'Google';
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : 'User';

      return User(
        id: googleUser.id,
        email: googleUser.email,
        password: '',
        firstName: firstName,
        lastName: lastName,
        userName: googleUser.email,
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Google Sign-In failed',
        tag: 'GoogleSignInService',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
      AppLogger.info('Google Sign-Out successful', tag: 'GoogleSignInService');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Google Sign-Out failed',
        tag: 'GoogleSignInService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Stream<GoogleSignInAuthenticationEvent> get authenticationEvents =>
      GoogleSignIn.instance.authenticationEvents;
}
