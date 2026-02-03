import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_list.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

final taskListProvider = StateNotifierProvider<TaskListNotifier, AsyncValue<List<TaskListResponse>>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final authState = ref.watch(authProvider);

  // Set token on API service whenever auth state changes
  if (authState.user?.token != null) {
    apiService.setToken(authState.user!.token);
  }

  return TaskListNotifier(apiService);
});

class TaskListNotifier extends StateNotifier<AsyncValue<List<TaskListResponse>>> {
  final ApiService _apiService;

  TaskListNotifier(this._apiService) : super(const AsyncValue.loading()) {
    loadAllTaskLists();
  }

  Future<void> loadAllTaskLists() async {
    if (!mounted) return;
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() => _apiService.getAllTaskLists());
    if (mounted) state = result;
  }

  Future<void> loadOwnedTaskLists() async {
    if (!mounted) return;
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() => _apiService.getOwnedTaskLists());
    if (mounted) state = result;
  }

  Future<void> loadSharedTaskLists() async {
    if (!mounted) return;
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() => _apiService.getSharedTaskLists());
    if (mounted) state = result;
  }

  Future<TaskListResponse?> createTaskList(CreateTaskListRequest request) async {
    try {
      final taskList = await _apiService.createTaskList(request);
      await loadAllTaskLists();
      return taskList;
    } catch (e) {
      if (mounted) state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }

  Future<TaskListResponse?> updateTaskList(int id, UpdateTaskListRequest request) async {
    try {
      final taskList = await _apiService.updateTaskList(id, request);
      await loadAllTaskLists();
      return taskList;
    } catch (e) {
      if (mounted) state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }

  Future<bool> deleteTaskList(int id) async {
    try {
      await _apiService.deleteTaskList(id);
      await loadAllTaskLists();
      return true;
    } catch (e) {
      if (mounted) state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }
}

// Provider for a single task list detail
final taskListDetailProvider = FutureProvider.family<TaskListResponse, int>((ref, id) async {
  final apiService = ref.watch(apiServiceProvider);
  final authState = ref.watch(authProvider);

  // Ensure token is set
  if (authState.user?.token != null) {
    apiService.setToken(authState.user!.token);
  }

  return apiService.getTaskList(id);
});
