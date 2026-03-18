import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SocialAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  Future<String?> googleSignIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null;
      final auth = await account.authentication;
      debugPrint('Google sign-in: ${account.email}');
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
