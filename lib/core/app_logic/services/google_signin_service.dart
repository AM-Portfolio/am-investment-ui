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

      if (GoogleSignIn.instance.supportsAuthenticate()) {
        googleUser = await GoogleSignIn.instance.authenticate();
      } else {
        AppLogger.info(
          'Platform does not support authenticate(). Use web button instead.',
          tag: 'GoogleSignInService',
        );
        return null;
      }

      if (googleUser == null) {
        AppLogger.info('User cancelled Google Sign-In', tag: 'GoogleSignInService');
        return null;
      }

      AppLogger.info(
        'Google Sign-In successful',
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
