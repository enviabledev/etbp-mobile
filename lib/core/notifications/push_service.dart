import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:etbp_mobile/core/auth/auth_provider.dart';
import 'package:etbp_mobile/core/api/endpoints.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message: ${message.messageId}');
}

class PushNotificationService {
  final Ref _ref;
  PushNotificationService(this._ref);

  Future<void> initialize() async {
    debugPrint('Push: initializing...');
    final messaging = FirebaseMessaging.instance;

    // Request permission
    debugPrint('Push: requesting permission...');
    final settings = await messaging.requestPermission(
      alert: true, badge: true, sound: true,
    );
    debugPrint('Push: permission = ${settings.authorizationStatus}');

    // Get token and register
    debugPrint('Push: getting token...');
    final token = await messaging.getToken();
    if (token != null) {
      debugPrint('Push: token = ${token.substring(0, 30)}...');
      await _registerToken(token);
    } else {
      debugPrint('Push: token is null');
    }

    // Listen for token refresh
    messaging.onTokenRefresh.listen(_registerToken);

    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Notification tap (app in background)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if app was opened from terminated state via notification
    final initial = await messaging.getInitialMessage();
    if (initial != null) _handleNotificationTap(initial);
  }

  Future<void> _registerToken(String token) async {
    try {
      debugPrint('Push: registering with backend...');
      final api = _ref.read(apiClientProvider);
      await api.post(Endpoints.registerDevice, data: {
        'token': token,
        'device_type': Platform.isIOS ? 'ios' : 'android',
        'app_type': 'customer',
      });
      debugPrint('Push: registered successfully');
    } catch (e) {
      debugPrint('Push: registration failed: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground push: ${message.notification?.title}');
    // The message will be handled by the UI layer via a stream or overlay
  }

  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    final type = data['type'];
    debugPrint('Notification tap: type=$type');
    // Navigation will be handled by the router based on type
  }

  Future<void> unregister() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        final api = _ref.read(apiClientProvider);
        await api.post(Endpoints.unregisterDevice, data: {
          'token': token,
          'device_type': Platform.isIOS ? 'ios' : 'android',
          'app_type': 'customer',
        });
      }
    } catch (_) {}
  }
}

final pushServiceProvider = Provider<PushNotificationService>(
  (ref) => PushNotificationService(ref),
);
