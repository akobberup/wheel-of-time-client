import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_responsible.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

/// Provider for ansvarskonfiguration for en specifik task.
/// Bruger taskId som family parameter.
final taskResponsibleConfigProvider = StateNotifierProvider.family<
    TaskResponsibleConfigNotifier,
    AsyncValue<TaskResponsibleConfigResponse?>,
    int>((ref, taskId) {
  final apiService = ref.watch(apiServiceProvider);
  final authState = ref.watch(authProvider);

  // Sæt token på API service når auth state ændres
  if (authState.user?.token != null) {
    apiService.setToken(authState.user!.token);
  }

  return TaskResponsibleConfigNotifier(apiService, taskId);
});

/// StateNotifier der håndterer ansvarskonfiguration for en task.
class TaskResponsibleConfigNotifier
    extends StateNotifier<AsyncValue<TaskResponsibleConfigResponse?>> {
  final ApiService _apiService;
  final int taskId;

  TaskResponsibleConfigNotifier(this._apiService, this.taskId)
      : super(const AsyncValue.loading()) {
    loadConfig();
  }

  /// Indlæser ansvarskonfiguration fra API.
  Future<void> loadConfig() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _apiService.getTaskResponsibleConfig(taskId));
  }

  /// Opretter eller opdaterer ansvarskonfiguration.
  /// Returnerer den opdaterede konfiguration ved succes, null ved fejl.
  Future<TaskResponsibleConfigResponse?> setConfig(
    TaskResponsibleConfigRequest request,
  ) async {
    try {
      final config = await _apiService.setTaskResponsibleConfig(taskId, request);
      state = AsyncValue.data(config);
      return config;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }

  /// Fjerner ansvarskonfiguration (falder tilbage til ALL strategi).
  /// Returnerer true ved succes, false ved fejl.
  Future<bool> removeConfig() async {
    try {
      await _apiService.removeTaskResponsibleConfig(taskId);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }
}