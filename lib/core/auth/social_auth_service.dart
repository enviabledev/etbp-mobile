import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SocialAuthService {
  // serverClientId MUST be the WEB client ID — this is how Google issues an idToken on Android
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: '555019812841-9k98drsb01i2gl0h4birm7ogu6odg2hp.apps.googleusercontent.com',
  );

  Future<String?> googleSignIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        debugPrint('Google sign-in: user cancelled');
        return null;
      }
      final auth = await account.authentication;
      debugPrint('Google sign-in: ${account.email}');
      debugPrint('Google idToken present: ${auth.idToken != null}');
      if (auth.idToken == null) {
        debugPrint('ERROR: No idToken received. Check serverClientId and SHA-1 fingerprint in Firebase.');
        return null;
      }
      return auth.idToken;
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      return null;
    }
  }

  Future<Map<String, String>?> appleSignIn() async {
    if (!Platform.isIOS) return null;
    try {
      // Apple Sign-In only on iOS
      // Requires sign_in_with_apple package
      // For now return null - will be implemented when iOS build is configured
      debugPrint('Apple sign-in: iOS only');
      return null;
    } catch (e) {
      debugPrint('Apple sign-in error: $e');
      return null;
    }
  }

  Future<void> googleSignOut() async {
    await _googleSignIn.signOut();
  }
}
