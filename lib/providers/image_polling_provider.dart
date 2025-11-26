import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';
import 'task_list_provider.dart';
import 'task_provider.dart';

/// Provider til at håndtere polling efter billede-generering
/// Bruges til at opdatere UI når DALL-E har genereret et billede
final imagePollingProvider = Provider<ImagePollingService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final authState = ref.watch(authProvider);

  if (authState.user?.token != null) {
    apiService.setToken(authState.user!.token);
  }

  return ImagePollingService(ref, apiService);
});

/// Service der poller for billede-opdateringer efter oprettelse af tasks/task lists
class ImagePollingService {
  final Ref _ref;
  final ApiService _apiService;

  /// Maksimalt antal polling-forsøg før vi stopper
  static const int _maxPollingAttempts = 30;

  /// Interval mellem polling-forsøg
  static const Duration _pollingInterval = Duration(seconds: 1);

  ImagePollingService(this._ref, this._apiService);

  /// Starter polling for en nyoprettet opgaveliste
  /// Poller indtil billedet er genereret eller max forsøg er nået
  void pollForTaskListImage(int taskListId) {
    _pollForTaskListImage(taskListId, 0);
  }

  /// Starter polling for en nyoprettet opgave
  /// Poller indtil billedet er genereret eller max forsøg er nået
  void pollForTaskImage(int taskId, int taskListId) {
    _pollForTaskImage(taskId, taskListId, 0);
  }

  /// Intern metode til at polle for opgaveliste-billede
  Future<void> _pollForTaskListImage(int taskListId, int attempt) async {
    if (attempt >= _maxPollingAttempts) return;

    await Future.delayed(_pollingInterval);

    try {
      final taskList = await _apiService.getTaskList(taskListId);

      if (taskList.taskListImagePath != null && taskList.taskListImagePath!.isNotEmpty) {
        // Billede er genereret - opdater listen
        _ref.read(taskListProvider.notifier).loadAllTaskLists();
      } else {
        // Billede ikke genereret endnu - prøv igen
        _pollForTaskListImage(taskListId, attempt + 1);
      }
    } catch (e) {
      // Ved fejl, prøv igen op til max forsøg
      if (attempt < _maxPollingAttempts - 1) {
        _pollForTaskListImage(taskListId, attempt + 1);
      }
    }
  }

  /// Intern metode til at polle for opgave-billede
  Future<void> _pollForTaskImage(int taskId, int taskListId, int attempt) async {
    if (attempt >= _maxPollingAttempts) return;

    await Future.delayed(_pollingInterval);

    try {
      final task = await _apiService.getTask(taskId);

      if (task.taskImagePath != null && task.taskImagePath!.isNotEmpty) {
        // Billede er genereret - opdater listen
        _ref.read(tasksProvider(taskListId).notifier).loadTasks();
      } else {
        // Billede ikke genereret endnu - prøv igen
        _pollForTaskImage(taskId, taskListId, attempt + 1);
      }
    } catch (e) {
      // Ved fejl, prøv igen op til max forsøg
      if (attempt < _maxPollingAttempts - 1) {
        _pollForTaskImage(taskId, taskListId, attempt + 1);
      }
    }
  }
}
