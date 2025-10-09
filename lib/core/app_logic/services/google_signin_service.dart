import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

import '../../utils/logger.dart';
import '../domain/entities/user.dart';
import 'google_signin_web.dart' if (dart.library.io) 'google_signin_stub.dart';

class GoogleSignInService {
  factory GoogleSignInService() => _instance;
  GoogleSignInService._internal();
  static final GoogleSignInService _instance = GoogleSignInService._internal();

  bool _isInitialized = false;

  Future<void> initialize({String? webClientId}) async {
    if (_isInitialized) return;

    try {
      if (kIsWeb && webClientId != null) {
        // Initialize web-specific implementation
        final webSignIn = GoogleSignInWeb();
        webSignIn.initialize(webClientId);
        AppLogger.info(
          'Google Sign-In Web initialized',
          tag: 'GoogleSignInService',
        );
      } else {
        // Initialize mobile implementation
        await GoogleSignIn.instance.initialize(clientId: webClientId);
        AppLogger.info(
          'Google Sign-In Mobile initialized',
          tag: 'GoogleSignInService',
        );
      }

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
      throw Exception(
        'GoogleSignInService not initialized. Call initialize() first.',
      );
    }

    try {
      AppLogger.info(
        'Starting Google Sign-In flow',
        tag: 'GoogleSignInService',
      );

      // Web platform - use custom web implementation
      if (kIsWeb) {
        AppLogger.info(
          'Web platform: Using Google Identity Services',
          tag: 'GoogleSignInService',
        );

        // Use the web-specific implementation
        final webSignIn = GoogleSignInWeb();
        final user = await webSignIn.signIn();

        if (user != null) {
          AppLogger.info(
            'Google Sign-In successful for: ${user.email}',
            tag: 'GoogleSignInService',
          );
        }

        return user;
      }
      // Mobile platforms - use authenticate
      else {
        AppLogger.info(
          'Mobile platform: Using authenticate()',
          tag: 'GoogleSignInService',
        );

        GoogleSignInAccount googleUser;
        try {
          googleUser = await GoogleSignIn.instance.authenticate();

          AppLogger.info(
            'Google Sign-In successful for: ${googleUser.email}',
            tag: 'GoogleSignInService',
          );
        } catch (e) {
          AppLogger.info(
            'User cancelled Google Sign-In or authentication failed',
            tag: 'GoogleSignInService',
          );
          return null;
        }

        final nameParts = (googleUser.displayName ?? '').split(' ');
        final firstName = nameParts.isNotEmpty ? nameParts.first : 'Google';
        final lastName = nameParts.length > 1
            ? nameParts.sublist(1).join(' ')
            : 'User';

        return User(
          id: googleUser.id,
          email: googleUser.email,
          password: '',
          firstName: firstName,
          lastName: lastName,
          userName: googleUser.email,
        );
      }
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
