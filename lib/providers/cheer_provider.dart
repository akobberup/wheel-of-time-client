import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cheer.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

/// Provider til at sende og slette cheers.
/// Refresher completed tasks efter ændringer for at opdatere cheers inline.
class CheerNotifier extends StateNotifier<AsyncValue<void>> {
  final ApiService _apiService;
  final Ref _ref;

  CheerNotifier(this._apiService, this._ref) : super(const AsyncValue.data(null));

  /// Send eller opdater en cheer på en task instance.
  Future<CheerResponse?> sendCheer(int taskInstanceId, {
    String? emoji,
    String? message,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _apiService.cheerTaskInstance(
        taskInstanceId,
        emoji: emoji,
        message: message,
      );
      state = const AsyncValue.data(null);
      return response;
    } catch (e, st) {
      developer.log('Fejl ved afsendelse af cheer: $e', name: 'CheerProvider');
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Slet egen cheer fra en task instance.
  Future<bool> deleteCheer(int taskInstanceId) async {
    try {
      await _apiService.deleteCheer(taskInstanceId);
      return true;
    } catch (e) {
      developer.log('Fejl ved sletning af cheer: $e', name: 'CheerProvider');
      return false;
    }
  }
}

/// Provider for cheer-funktionalitet.
final cheerProvider = StateNotifierProvider<CheerNotifier, AsyncValue<void>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return CheerNotifier(apiService, ref);
});

/// Provider for pending cheer fra push notification.
/// Sættes når brugeren trykker på en TASK_COMPLETED_BY_OTHER notification.
final pendingCheerProvider = StateProvider<int?>((ref) => null);
