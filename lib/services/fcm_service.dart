import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Service til håndtering af Firebase Cloud Messaging for push notifications.
class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  FirebaseMessaging? _messaging;
  String? _token;

  /// Initialiserer Firebase og FCM.
  /// Returnerer FCM token hvis tilgængeligt.
  Future<String?> initialize() async {
    // Kun initialiser på mobile platforme
    if (kIsWeb) {
      debugPrint('FCM: Web platform - skipping initialization');
      return null;
    }

    try {
      // Initialiser Firebase
      await Firebase.initializeApp();
      debugPrint('FCM: Firebase initialiseret');

      _messaging = FirebaseMessaging.instance;

      // Request notification permissions (iOS og Android 13+)
      final settings = await _messaging!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint('FCM: Permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Hent FCM token
        _token = await _messaging!.getToken();
        debugPrint('FCM: Token hentet: ${_token?.substring(0, 20)}...');

        // Lyt efter token refresh
        _messaging!.onTokenRefresh.listen((newToken) {
          debugPrint('FCM: Token refreshed');
          _token = newToken;
          // TODO: Registrer nyt token hos backend
        });

        // Opsæt message handlers
        _setupMessageHandlers();

        return _token;
      } else {
        debugPrint('FCM: Notifications ikke tilladt');
        return null;
      }
    } catch (e) {
      debugPrint('FCM: Fejl ved initialisering: $e');
      return null;
    }
  }

  /// Henter nuværende FCM token.
  String? get token => _token;

  /// Opsætter handlers for indkommende beskeder.
  void _setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('FCM: Modtog foreground besked: ${message.notification?.title}');
      // Vis lokal notification her hvis ønsket
    });

    // Når bruger trykker på notification (app var i baggrunden)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('FCM: Bruger åbnede notification: ${message.notification?.title}');
      // Navigate til relevant skærm baseret på message.data
    });
  }

  /// Henter initial notification hvis app blev åbnet fra en notification.
  Future<RemoteMessage?> getInitialMessage() async {
    if (_messaging == null) return null;
    return await _messaging!.getInitialMessage();
  }
}

/// Top-level handler for background messages.
/// Skal være en top-level funktion (ikke en metode i en klasse).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialiser Firebase (nødvendigt i background isolate)
  await Firebase.initializeApp();
  debugPrint('FCM: Håndterer background besked: ${message.messageId}');
}
