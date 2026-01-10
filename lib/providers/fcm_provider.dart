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
