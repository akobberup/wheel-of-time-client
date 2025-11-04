import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_instance.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

/// Provider for task completion history for a specific task.
/// Uses StateNotifier to manage loading state and provide refresh capability.
final taskHistoryProvider = StateNotifierProvider.family<
    TaskHistoryNotifier,
    AsyncValue<List<TaskInstanceResponse>>,
    int>(
  (ref, taskId) {
    final apiService = ref.watch(apiServiceProvider);
    final authState = ref.watch(authProvider);

    // Set token on API service whenever auth state changes
    if (authState.user?.token != null) {
      apiService.setToken(authState.user!.token);
    }

    return TaskHistoryNotifier(apiService, taskId);
  },
);

/// State notifier that manages task instance history for a specific task.
/// Automatically loads the history on creation and provides refresh capability.
class TaskHistoryNotifier
    extends StateNotifier<AsyncValue<List<TaskInstanceResponse>>> {
  final ApiService _apiService;
  final int taskId;

  TaskHistoryNotifier(this._apiService, this.taskId)
      : super(const AsyncValue.loading()) {
    loadHistory();
  }

  /// Loads the task completion history from the API.
  /// Updates the state with loading, data, or error states as appropriate.
  Future<void> loadHistory() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _apiService.getTaskInstancesByTask(taskId),
    );
  }

  /// Refreshes the history, typically called by pull-to-refresh.
  Future<void> refresh() async {
    await loadHistory();
  }
}
