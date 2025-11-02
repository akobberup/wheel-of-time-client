import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_list_user.dart';
import '../models/enums.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

// Provider for users of a specific task list
final taskListUsersProvider = FutureProvider.family<List<TaskListUserResponse>, int>((ref, taskListId) async {
  final apiService = ref.watch(apiServiceProvider);
  final authState = ref.watch(authProvider);

  // Ensure token is set
  if (authState.user?.token != null) {
    apiService.setToken(authState.user!.token);
  }

  return apiService.getUsersByTaskList(taskListId);
});

// Notifier for managing task list users
final taskListUserNotifierProvider = StateNotifierProvider.family<TaskListUserNotifier, AsyncValue<List<TaskListUserResponse>>, int>(
  (ref, taskListId) {
    final apiService = ref.watch(apiServiceProvider);
    final authState = ref.watch(authProvider);

    // Set token on API service whenever auth state changes
    if (authState.user?.token != null) {
      apiService.setToken(authState.user!.token);
    }

    return TaskListUserNotifier(apiService, taskListId);
  },
);

class TaskListUserNotifier extends StateNotifier<AsyncValue<List<TaskListUserResponse>>> {
  final ApiService _apiService;
  final int taskListId;

  TaskListUserNotifier(this._apiService, this.taskListId) : super(const AsyncValue.loading()) {
    loadUsers();
  }

  Future<void> loadUsers() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _apiService.getUsersByTaskList(taskListId));
  }

  Future<bool> updateUserAdminLevel(int userId, AdminLevel newAdminLevel) async {
    try {
      await _apiService.updateUserAdminLevel(taskListId, userId, newAdminLevel);
      await loadUsers(); // Refresh the list
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> removeUser(int userId) async {
    try {
      await _apiService.removeUserFromTaskList(taskListId, userId);
      await loadUsers(); // Refresh the list
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }
}
