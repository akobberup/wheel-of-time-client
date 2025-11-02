import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

// Provider for tasks in a specific task list
final tasksProvider = StateNotifierProvider.family<TasksNotifier, AsyncValue<List<TaskResponse>>, int>(
  (ref, taskListId) {
    final apiService = ref.watch(apiServiceProvider);
    final authState = ref.watch(authProvider);

    // Set token on API service whenever auth state changes
    if (authState.user?.token != null) {
      apiService.setToken(authState.user!.token);
    }

    return TasksNotifier(apiService, taskListId);
  },
);

class TasksNotifier extends StateNotifier<AsyncValue<List<TaskResponse>>> {
  final ApiService _apiService;
  final int taskListId;

  TasksNotifier(this._apiService, this.taskListId) : super(const AsyncValue.loading()) {
    loadTasks();
  }

  Future<void> loadTasks({bool activeOnly = false}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _apiService.getTasksByTaskList(taskListId, activeOnly: activeOnly));
  }

  Future<TaskResponse?> createTask(CreateTaskRequest request) async {
    try {
      final task = await _apiService.createTask(request);
      await loadTasks(); // Refresh the list
      return task;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }

  Future<TaskResponse?> updateTask(int id, UpdateTaskRequest request) async {
    try {
      final task = await _apiService.updateTask(id, request);
      await loadTasks(); // Refresh the list
      return task;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }

  Future<bool> deleteTask(int id) async {
    try {
      await _apiService.deleteTask(id);
      await loadTasks(); // Refresh the list
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }
}

// Provider for a single task detail
final taskDetailProvider = FutureProvider.family<TaskResponse, int>((ref, id) async {
  final apiService = ref.watch(apiServiceProvider);
  final authState = ref.watch(authProvider);

  // Ensure token is set
  if (authState.user?.token != null) {
    apiService.setToken(authState.user!.token);
  }

  return apiService.getTask(id);
});
