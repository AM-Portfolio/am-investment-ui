import 'dart:async';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

import '../../utils/logger.dart';
import '../domain/entities/user.dart';

/// Web-specific Google Sign-In implementation using Google Identity Services
class GoogleSignInWeb {
  factory GoogleSignInWeb() => _instance;
  GoogleSignInWeb._internal();
  static final GoogleSignInWeb _instance = GoogleSignInWeb._internal();

  String? _clientId;
  Completer<Map<String, dynamic>?>? _signInCompleter;

  /// Initialize Google Identity Services for web
  void initialize(String clientId) {
    _clientId = clientId;
    AppLogger.info('Google Sign-In Web initialized', tag: 'GoogleSignInWeb');

    // Listen for the custom event from JavaScript
    html.window.addEventListener('google-signin-success', (event) {
      try {
        // Read the response from the global variable
        final responseObj = js.context['googleSignInResponse'];

        if (responseObj == null) {
          AppLogger.error(
            'Google Sign-In response is null',
            tag: 'GoogleSignInWeb',
          );
          if (_signInCompleter != null && !_signInCompleter!.isCompleted) {
            _signInCompleter!.complete(null);
          }
          return;
        }

        // Extract data from JS object
        final credential = responseObj['credential'] as String?;
        final clientId = responseObj['clientId'] as String?;

        if (credential == null) {
          AppLogger.error(
            'Google Sign-In credential is null',
            tag: 'GoogleSignInWeb',
          );
          if (_signInCompleter != null && !_signInCompleter!.isCompleted) {
            _signInCompleter!.complete(null);
          }
          return;
        }

        final data = {'credential': credential, 'clientId': clientId};

        AppLogger.info(
          'Google Sign-In success event received',
          tag: 'GoogleSignInWeb',
        );

        if (_signInCompleter != null && !_signInCompleter!.isCompleted) {
          _signInCompleter!.complete(data);
        }

        // Clear the global variable
        js.context['googleSignInResponse'] = null;
      } catch (e) {
        AppLogger.error(
          'Error handling google-signin-success event',
          tag: 'GoogleSignInWeb',
          error: e,
        );
        if (_signInCompleter != null && !_signInCompleter!.isCompleted) {
          _signInCompleter!.completeError(e);
        }
      }
    });
  }

  /// Cancel the current sign-in attempt
  void cancelSignIn() {
    if (_signInCompleter != null && !_signInCompleter!.isCompleted) {
      _signInCompleter!.complete(null);
      AppLogger.info(
        'Google Sign-In cancelled by user',
        tag: 'GoogleSignInWeb',
      );
    }
  }

  /// Show Google One Tap prompt programmatically
  void _showGoogleOneTap() {
    if (_clientId == null || _clientId!.isEmpty) {
      AppLogger.error('Client ID not set', tag: 'GoogleSignInWeb');
      if (_signInCompleter != null && !_signInCompleter!.isCompleted) {
        _signInCompleter!.complete(null);
      }
      return;
    }

    // Use JavaScript interop to call google.accounts.id.prompt()
    try {
      // Check if Google Identity Services is available
      final google = js.context['google'];
      if (google == null) {
        AppLogger.error(
          'Google Identity Services not loaded',
          tag: 'GoogleSignInWeb',
        );
        if (_signInCompleter != null && !_signInCompleter!.isCompleted) {
          _signInCompleter!.complete(null);
        }
        return;
      }

      // Initialize Google Sign-In
      final accounts = google['accounts'];
      final id = accounts['id'];

      id.callMethod('initialize', [
        js.JsObject.jsify({
          'client_id': _clientId,
          'callback': js.context['handleGoogleSignIn'],
        }),
      ]);

      // Show the One Tap prompt
      id.callMethod('prompt', [
        js.allowInterop((notification) {
          final notificationStr = notification.toString();
          AppLogger.info(
            'Google One Tap notification: $notificationStr',
            tag: 'GoogleSignInWeb',
          );

          // Handle dismissal/skip cases - complete with null to stop loading
          if (notificationStr.contains('skipped') ||
              notificationStr.contains('dismissed') ||
              notificationStr.contains('opt_out')) {
            AppLogger.info(
              'User dismissed or skipped Google One Tap',
              tag: 'GoogleSignInWeb',
            );
            if (_signInCompleter != null && !_signInCompleter!.isCompleted) {
              _signInCompleter!.complete(null);
            }
          }
        }),
      ]);

      AppLogger.info('Google One Tap prompt triggered', tag: 'GoogleSignInWeb');
    } catch (e) {
      AppLogger.error(
        'Failed to trigger Google One Tap',
        tag: 'GoogleSignInWeb',
        error: e,
      );
      if (_signInCompleter != null && !_signInCompleter!.isCompleted) {
        _signInCompleter!.complete(null);
      }
    }
  }

  /// Render the Google Sign-In button in a container
  void renderButton(String containerId) {
    if (_clientId == null || _clientId!.isEmpty) {
      AppLogger.error(
        'Client ID not set. Check google.web.clientId in application.properties',
        tag: 'GoogleSignInWeb',
      );
      return;
    }

    AppLogger.info(
      'Rendering button with Client ID: ${_clientId!.substring(0, 20)}...',
      tag: 'GoogleSignInWeb',
    );

    // Wait for Google Identity Services to load
    Future.delayed(const Duration(milliseconds: 500), () {
      final container = html.document.getElementById(containerId);
      if (container == null) {
        AppLogger.error(
          'Container not found: $containerId',
          tag: 'GoogleSignInWeb',
        );
        return;
      }

      // Create the Google Sign-In button HTML
      container.innerHtml =
          '''
        <div id="g_id_onload"
             data-client_id="$_clientId"
             data-callback="handleGoogleSignIn"
             data-auto_prompt="false">
        </div>
        <div class="g_id_signin"
             data-type="standard"
             data-size="large"
             data-theme="outline"
             data-text="continue_with"
             data-shape="rectangular"
             data-logo_alignment="left"
             data-width="350">
        </div>
      ''';

      AppLogger.info('Google Sign-In button rendered', tag: 'GoogleSignInWeb');
    });
  }

  /// Sign in and wait for the user to complete the flow
  Future<User?> signIn() async {
    if (_clientId == null) {
      throw Exception(
        'Google Sign-In not initialized. Call initialize() first.',
      );
    }

    AppLogger.info(
      'Starting Google Sign-In flow on web',
      tag: 'GoogleSignInWeb',
    );

    // Create a new completer for this sign-in attempt
    _signInCompleter = Completer<Map<String, dynamic>?>();

    // Trigger Google One Tap programmatically
    _showGoogleOneTap();

    try {
      // Wait for the user to click the button and complete sign-in
      // Reduced timeout to 10 seconds so user isn't stuck waiting
      final result = await _signInCompleter!.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          AppLogger.warning(
            'Google One Tap did not appear or was dismissed',
            tag: 'GoogleSignInWeb',
          );
          // Return null to allow graceful cancellation
          return null;
        },
      );

      // If timeout returned null, return null (user cancelled or popup didn't appear)
      if (result == null) {
        AppLogger.info(
          'Google Sign-In cancelled or popup did not appear',
          tag: 'GoogleSignInWeb',
        );
        return null;
      }

      // Decode the JWT credential to get user info
      final credential = result['credential'] as String;
      final user = _decodeJwtCredential(credential);

      AppLogger.info(
        'Google Sign-In successful: ${user.email}',
        tag: 'GoogleSignInWeb',
      );
      return user;
    } catch (e) {
      AppLogger.error(
        'Google Sign-In failed',
        tag: 'GoogleSignInWeb',
        error: e,
      );
      rethrow;
    } finally {
      _signInCompleter = null;
    }
  }

  /// Decode JWT credential to extract user information
  User _decodeJwtCredential(String credential) {
    // JWT format: header.payload.signature
    final parts = credential.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid JWT credential');
    }

    // Decode the payload (second part)
    final payload = parts[1];
    // Add padding if necessary
    var normalizedPayload = payload.replaceAll('-', '+').replaceAll('_', '/');
    while (normalizedPayload.length % 4 != 0) {
      normalizedPayload += '=';
    }

    final decodedBytes = base64.decode(normalizedPayload);
    final decodedString = utf8.decode(decodedBytes);
    final Map<String, dynamic> userData = json.decode(decodedString);

    AppLogger.info('Decoded JWT payload', tag: 'GoogleSignInWeb');

    // Extract user information from JWT
    final email = userData['email'] as String;
    final name = userData['name'] as String? ?? email;
    final sub = userData['sub'] as String; // Google user ID
    final givenName = userData['given_name'] as String? ?? name;
    final familyName = userData['family_name'] as String? ?? '';

    return User(
      id: sub,
      email: email,
      firstName: givenName,
      lastName: familyName,
      userName: email,
      password: '', // Not used for Google Sign-In
    );
  }

  /// Sign out (for web, this just clears local state)
  void signOut() {
    _signInCompleter = null;
    AppLogger.info('Google Sign-Out successful', tag: 'GoogleSignInWeb');
  }
}
