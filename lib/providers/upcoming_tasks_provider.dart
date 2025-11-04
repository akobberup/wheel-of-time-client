import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_occurrence.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

/// State class for upcoming tasks with pagination support
class UpcomingTasksState {
  final List<UpcomingTaskOccurrenceResponse> occurrences;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const UpcomingTasksState({
    this.occurrences = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  UpcomingTasksState copyWith({
    List<UpcomingTaskOccurrenceResponse>? occurrences,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
  }) {
    return UpcomingTasksState(
      occurrences: occurrences ?? this.occurrences,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

/// Provider for upcoming task occurrences with infinite scroll support
final upcomingTasksProvider = StateNotifierProvider<UpcomingTasksNotifier, UpcomingTasksState>(
  (ref) {
    final apiService = ref.watch(apiServiceProvider);
    final authState = ref.watch(authProvider);

    // Set token on API service whenever auth state changes
    if (authState.user?.token != null) {
      apiService.setToken(authState.user!.token);
    }

    return UpcomingTasksNotifier(apiService);
  },
);

/// Notifier for managing upcoming task occurrences with pagination
class UpcomingTasksNotifier extends StateNotifier<UpcomingTasksState> {
  final ApiService _apiService;
  static const int _pageSize = 20;

  UpcomingTasksNotifier(this._apiService) : super(const UpcomingTasksState(isLoading: true)) {
    loadInitial();
  }

  /// Loads the initial page of task occurrences
  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final List<UpcomingTaskOccurrenceResponse> occurrences = await _apiService.getUpcomingTaskOccurrences(
        limit: _pageSize,
        offset: 0,
      );

      state = state.copyWith(
        occurrences: occurrences,
        isLoading: false,
        hasMore: occurrences.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Loads the next page of task occurrences
  Future<void> loadMore() async {
    // Don't load if already loading or no more items
    if (state.isLoadingMore || !state.hasMore || state.isLoading) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);

    try {
      final newOccurrences = await _apiService.getUpcomingTaskOccurrences(
        limit: _pageSize,
        offset: state.occurrences.length,
      );

      state = state.copyWith(
        occurrences: [...state.occurrences, ...newOccurrences],
        isLoadingMore: false,
        hasMore: newOccurrences.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  /// Refreshes the list (pull to refresh)
  Future<void> refresh() async {
    await loadInitial();
  }
}
