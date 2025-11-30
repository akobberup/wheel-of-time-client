import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_instance.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

/// State for recently completed tasks with pagination support
class CompletedTasksState {
  final List<TaskInstanceResponse> completedTasks;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final bool isExpanded;
  final String? error;

  const CompletedTasksState({
    this.completedTasks = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.isExpanded = false,
    this.error,
  });

  CompletedTasksState copyWith({
    List<TaskInstanceResponse>? completedTasks,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    bool? isExpanded,
    String? error,
  }) {
    return CompletedTasksState(
      completedTasks: completedTasks ?? this.completedTasks,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      isExpanded: isExpanded ?? this.isExpanded,
      error: error,
    );
  }
}

/// Provider for recently completed tasks
final completedTasksProvider =
    StateNotifierProvider<CompletedTasksNotifier, CompletedTasksState>(
  (ref) {
    final apiService = ref.watch(apiServiceProvider);
    final authState = ref.watch(authProvider);

    // Set token on API service whenever auth state changes
    if (authState.user?.token != null) {
      apiService.setToken(authState.user!.token);
    }

    return CompletedTasksNotifier(apiService);
  },
);

/// Notifier for managing recently completed tasks
class CompletedTasksNotifier extends StateNotifier<CompletedTasksState> {
  final ApiService _apiService;
  static const int _pageSize = 10;

  CompletedTasksNotifier(this._apiService)
      : super(const CompletedTasksState());

  /// Loads initial completed tasks (called when section is expanded)
  Future<void> loadInitial() async {
    if (state.completedTasks.isNotEmpty) return; // Already loaded

    state = state.copyWith(isLoading: true, error: null);

    try {
      final completedTasks = await _apiService.getRecentlyCompletedTasks(
        limit: _pageSize,
        offset: 0,
      );

      state = state.copyWith(
        completedTasks: completedTasks,
        isLoading: false,
        hasMore: completedTasks.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Loads more completed tasks (pagination)
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);

    try {
      final newTasks = await _apiService.getRecentlyCompletedTasks(
        limit: _pageSize,
        offset: state.completedTasks.length,
      );

      state = state.copyWith(
        completedTasks: [...state.completedTasks, ...newTasks],
        isLoadingMore: false,
        hasMore: newTasks.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  /// Toggles the expanded state of the completed section
  Future<void> toggleExpanded() async {
    final newExpanded = !state.isExpanded;
    state = state.copyWith(isExpanded: newExpanded);

    // Load data when expanding for the first time
    if (newExpanded && state.completedTasks.isEmpty) {
      await loadInitial();
    }
  }

  /// Sets the expanded state directly
  void setExpanded(bool expanded) {
    state = state.copyWith(isExpanded: expanded);
  }

  /// Refreshes the completed tasks list
  Future<void> refresh() async {
    state = state.copyWith(
      completedTasks: [],
      hasMore: true,
    );
    await loadInitial();
  }
}
