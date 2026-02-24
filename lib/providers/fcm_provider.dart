import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/fcm_service.dart';
import 'auth_provider.dart';

/// Provider der håndterer FCM token lifecycle.
/// Registrerer automatisk token hos backend ved login og afregistrerer ved logout.
class FcmNotifier extends StateNotifier<String?> {
  final ApiService _apiService;
  final Ref _ref;
  bool _wasAuthenticated = false;

  FcmNotifier(this._apiService, this._ref) : super(null) {
    // Lyt til auth state ændringer
    _ref.listen<AuthState>(authProvider, (previous, next) {
      _handleAuthStateChange(next);
    });
  }

  /// Håndterer auth state ændringer for at registrere/afregistrere FCM token.
  void _handleAuthStateChange(AuthState authState) {
    if (authState.isLoading) return;

    if (authState.isAuthenticated && !_wasAuthenticated) {
      // Bruger loggede lige ind - registrer FCM token
      _wasAuthenticated = true;
      _registerTokenWithBackend();
    } else if (!authState.isAuthenticated && _wasAuthenticated) {
      // Bruger loggede ud - afregistrer FCM token
      _wasAuthenticated = false;
      _unregisterTokenFromBackend();
    }
  }

  /// Registrerer FCM token hos backend.
  Future<void> _registerTokenWithBackend() async {
    // Skip på web - FCM er kun til mobile
    if (kIsWeb) return;

    try {
      final fcmService = FcmService();
      final token = fcmService.token;

      if (token != null) {
        developer.log('FCM: Registrerer token hos backend...', name: 'FcmProvider');
        await _apiService.registerFcmToken(token);
        state = token;
        developer.log('FCM: Token registreret', name: 'FcmProvider');
      } else {
        developer.log('FCM: Intet token tilgængeligt til registration', name: 'FcmProvider');
      }
    } catch (e) {
      developer.log('FCM: Fejl ved token registration: $e', name: 'FcmProvider');
      // Fejl logges men stopper ikke flow - push notifications er ikke kritiske
    }
  }

  /// Afregistrerer FCM token fra backend ved logout.
  Future<void> _unregisterTokenFromBackend() async {
    if (kIsWeb) return;

    final token = state;
    if (token == null) return;

    try {
      developer.log('FCM: Afregistrerer token fra backend...', name: 'FcmProvider');
      await _apiService.unregisterFcmToken(token);
      state = null;
      developer.log('FCM: Token afregistreret', name: 'FcmProvider');
    } catch (e) {
      developer.log('FCM: Fejl ved token afregistrering: $e', name: 'FcmProvider');
      // Ignorer fejl - tokenet vil alligevel blive ugyldigt
    }
  }

  /// Manuelt registrer token (f.eks. efter token refresh fra Firebase).
  Future<void> refreshToken() async {
    if (kIsWeb) return;

    final fcmService = FcmService();
    final newToken = await fcmService.initialize();

    if (newToken != null && newToken != state) {
      try {
        await _apiService.registerFcmToken(newToken);
        state = newToken;
        developer.log('FCM: Token opdateret hos backend', name: 'FcmProvider');
      } catch (e) {
        developer.log('FCM: Fejl ved token opdatering: $e', name: 'FcmProvider');
      }
    }
  }
}

/// Provider for FCM token management.
/// Håndterer automatisk registration/afregistrering ved auth state ændringer.
final fcmProvider = StateNotifierProvider<FcmNotifier, String?>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return FcmNotifier(apiService, ref);
});

/// Data class for pending notification navigation.
class PendingNotificationNavigation {
  final String type;
  final int? taskInstanceId;
  final int? taskListId;
  final String? taskListName;

  PendingNotificationNavigation({
    required this.type,
    this.taskInstanceId,
    this.taskListId,
    this.taskListName,
  });

  factory PendingNotificationNavigation.fromData(Map<String, dynamic> data) {
    return PendingNotificationNavigation(
      type: data['type'] as String? ?? '',
      taskInstanceId: _parseInt(data['taskInstanceId']),
      taskListId: _parseInt(data['taskListId']),
      taskListName: data['taskListName'] as String?,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Returnerer den route der skal navigeres til baseret på notification type.
  String? getNavigationRoute() {
    switch (type) {
      case 'TASK_COMPLETED_BY_OTHER':
        // Naviger altid til home så CheerBottomSheet kan åbnes via pendingCheerProvider
        return '/';

      case 'TASK_DUE':
      case 'TASK_EXPIRING_SOON':
      case 'TASK_OVERDUE':
      case 'TASK_DISMISSED_BY_OTHER':
      case 'CHEER_RECEIVED':
        // For task-relaterede notifications, gå til task listen hvis muligt
        if (taskListId != null) {
          return '/lists/$taskListId';
        }
        return '/';

      case 'INVITATION_RECEIVED':
      case 'INVITATION_ACCEPTED':
      case 'INVITATION_DECLINED':
        // For invitation notifications, gå til notifications skærm
        return '/notifications';

      default:
        developer.log('FCM: Ukendt notification type: $type', name: 'FcmProvider');
        return '/';
    }
  }
}

/// Notifier der holder styr på pending notification navigation.
class NotificationNavigationNotifier extends StateNotifier<PendingNotificationNavigation?> {
  StreamSubscription<Map<String, dynamic>>? _subscription;

  NotificationNavigationNotifier() : super(null) {
    // Skip på web
    if (kIsWeb) return;

    final fcmService = FcmService();

    // Tjek om der er en pending notification fra før vi subscribede
    // Dette håndterer tilfælde hvor notification tap skete før provider blev oprettet
    final pendingData = fcmService.consumePendingNotification();
    if (pendingData != null) {
      developer.log('FCM: Fandt cached pending notification: $pendingData', name: 'FcmProvider');
      state = PendingNotificationNavigation.fromData(pendingData);
    }

    // Lyt til fremtidige notification tap events fra FcmService
    _subscription = fcmService.onNotificationTap.listen((data) {
      developer.log('FCM: Modtog notification tap data: $data', name: 'FcmProvider');
      state = PendingNotificationNavigation.fromData(data);
    });
  }

  /// Marker navigation som håndteret.
  void clearPendingNavigation() {
    state = null;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Provider for notification-triggered navigation.
/// Watch denne provider for at reagere på notification taps.
final notificationNavigationProvider =
    StateNotifierProvider<NotificationNavigationNotifier, PendingNotificationNavigation?>((ref) {
  return NotificationNavigationNotifier();
});
