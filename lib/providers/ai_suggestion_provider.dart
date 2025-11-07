import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_suggestion_service.dart';
import 'auth_provider.dart';

/// Provider for the AI suggestion service.
/// Automatically syncs with the authentication token from authProvider.
final aiSuggestionServiceProvider = Provider<AiSuggestionService>((ref) {
  final service = AiSuggestionService();

  // Watch auth state and keep token in sync
  final authState = ref.watch(authProvider);
  if (authState.isAuthenticated && authState.user?.token != null) {
    service.setToken(authState.user!.token);
  } else {
    service.setToken(null);
  }

  return service;
});
