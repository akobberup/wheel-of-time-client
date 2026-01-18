import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_settings.dart';
import 'auth_provider.dart';

/// Provider der håndterer user settings inklusiv push notification preferences.
/// Bruger AsyncNotifier til at håndtere loading state og fejl automatisk.
class UserSettingsNotifier extends AsyncNotifier<UserSettingsResponse> {
  @override
  Future<UserSettingsResponse> build() async {
    final apiService = ref.read(apiServiceProvider);
    return apiService.getUserSettings();
  }

  /// Opdaterer user settings med de angivne værdier.
  /// Kun felter med værdier vil blive opdateret.
  Future<void> updateSettings(UpdateUserSettingsRequest request) async {
    final apiService = ref.read(apiServiceProvider);

    // Optimistic update - opdater state med det samme
    final currentState = state.valueOrNull;
    if (currentState != null) {
      state = AsyncValue.data(
        UserSettingsResponse(
          id: currentState.id,
          userId: currentState.userId,
          mainThemeColor: request.mainThemeColor ?? currentState.mainThemeColor,
          darkModeEnabled: request.darkModeEnabled ?? currentState.darkModeEnabled,
          pushInvitations: request.pushInvitations ?? currentState.pushInvitations,
          pushInvitationResponses: request.pushInvitationResponses ?? currentState.pushInvitationResponses,
          pushTaskReminders: request.pushTaskReminders ?? currentState.pushTaskReminders,
          gender: request.gender ?? currentState.gender,
          birthYear: request.birthYear ?? currentState.birthYear,
          createdAt: currentState.createdAt,
          updatedAt: DateTime.now(),
        ),
      );
    }

    try {
      // Send opdatering til backend
      final updatedSettings = await apiService.updateUserSettings(request);
      state = AsyncValue.data(updatedSettings);
      developer.log('UserSettings opdateret', name: 'UserSettingsProvider');
    } catch (e, stack) {
      // Rollback til tidligere state ved fejl
      if (currentState != null) {
        state = AsyncValue.data(currentState);
      }
      developer.log('Fejl ved opdatering af settings: $e', name: 'UserSettingsProvider');
      state = AsyncValue.error(e, stack);
    }
  }

  /// Genindlæser settings fra backend.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

/// Provider for user settings.
final userSettingsProvider =
    AsyncNotifierProvider<UserSettingsNotifier, UserSettingsResponse>(
  UserSettingsNotifier.new,
);
