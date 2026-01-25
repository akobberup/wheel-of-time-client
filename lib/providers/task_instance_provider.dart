import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_instance.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

// Provider for task instances by task
final taskInstancesProvider = StateNotifierProvider.family<TaskInstancesNotifier, AsyncValue<List<TaskInstanceResponse>>, int>(
  (ref, taskId) {
    final apiService = ref.watch(apiServiceProvider);
    final authState = ref.watch(authProvider);

    // Set token on API service whenever auth state changes
    if (authState.user?.token != null) {
      apiService.setToken(authState.user!.token);
    }

    return TaskInstancesNotifier(apiService, taskId);
  },
);

class TaskInstancesNotifier extends StateNotifier<AsyncValue<List<TaskInstanceResponse>>> {
  final ApiService _apiService;
  final int taskId;

  TaskInstancesNotifier(this._apiService, this.taskId) : super(const AsyncValue.loading()) {
    loadTaskInstances();
  }

  Future<void> loadTaskInstances() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _apiService.getTaskInstancesByTask(taskId));
  }

  Future<TaskInstanceResponse?> createTaskInstance(CreateTaskInstanceRequest request) async {
    try {
      final instance = await _apiService.createTaskInstance(request);
      await loadTaskInstances(); // Refresh the list
      return instance;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }

  Future<TaskInstanceResponse?> dismissTaskInstance(int taskInstanceId) async {
    try {
      final instance = await _apiService.dismissTaskInstance(taskInstanceId);
      await loadTaskInstances(); // Refresh the list
      return instance;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }
}

// Provider for task instances by task list
final taskListInstancesProvider = FutureProvider.family<List<TaskInstanceResponse>, int>((ref, taskListId) async {
  final apiService = ref.watch(apiServiceProvider);
  final authState = ref.watch(authProvider);

  // Ensure token is set
  if (authState.user?.token != null) {
    apiService.setToken(authState.user!.token);
  }

  return apiService.getTaskInstancesByTaskList(taskListId);
});
