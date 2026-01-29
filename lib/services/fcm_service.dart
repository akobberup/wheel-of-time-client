import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Callback type for notification tap handling.
typedef NotificationTapCallback = void Function(Map<String, dynamic> data);

/// Service til håndtering af Firebase Cloud Messaging for push notifications.
class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  FirebaseMessaging? _messaging;
  String? _token;

  /// Stream controller for notification tap events.
  /// Bruges til at sende notification data til UI-laget for navigation.
  final _notificationTapController = StreamController<Map<String, dynamic>>.broadcast();

  /// Cached pending notification data - bruges når listener tilføjes efter event.
  Map<String, dynamic>? _pendingNotificationData;

  /// Stream af notification tap events.
  /// Lyt til denne stream for at håndtere navigation når bruger trykker på notification.
  Stream<Map<String, dynamic>> get onNotificationTap => _notificationTapController.stream;

  /// Henter og clearer pending notification data.
  /// Bruges af listeners der tilføjes efter notification tap event.
  Map<String, dynamic>? consumePendingNotification() {
    final data = _pendingNotificationData;
    _pendingNotificationData = null;
    return data;
  }

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

        // Tjek om app blev åbnet fra en notification (cold start)
        await _checkInitialMessage();

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
      // I foreground vises notification automatisk af systemet
      // Vi kunne vise en in-app notification her hvis ønsket
    });

    // Når bruger trykker på notification (app var i baggrunden)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('FCM: Bruger åbnede notification: ${message.notification?.title}');
      debugPrint('FCM: Notification data: ${message.data}');
      _handleNotificationTap(message.data);
    });
  }

  /// Tjekker om app blev åbnet fra en notification (cold start).
  Future<void> _checkInitialMessage() async {
    if (_messaging == null) return;

    final initialMessage = await _messaging!.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('FCM: App åbnet fra notification (cold start): ${initialMessage.notification?.title}');
      debugPrint('FCM: Initial notification data: ${initialMessage.data}');
      _handleNotificationTap(initialMessage.data);
    }
  }

  /// Håndterer notification tap ved at sende data til stream og cache det.
  void _handleNotificationTap(Map<String, dynamic> data) {
    if (data.isNotEmpty) {
      debugPrint('FCM: Sender notification tap event: $data');
      // Cache data så det kan hentes af listeners der tilføjes senere
      _pendingNotificationData = data;
      _notificationTapController.add(data);
    }
  }

  /// Henter initial notification hvis app blev åbnet fra en notification.
  /// @deprecated Brug onNotificationTap stream i stedet - initial message håndteres nu automatisk.
  Future<RemoteMessage?> getInitialMessage() async {
    if (_messaging == null) return null;
    return await _messaging!.getInitialMessage();
  }

  /// Rydder op i ressourcer.
  void dispose() {
    _notificationTapController.close();
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