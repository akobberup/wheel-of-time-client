import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import '../services/ai_suggestion_service.dart';
import 'ai_suggestion_provider.dart';

/// Represents cached task suggestions with timestamp for expiration
class CachedTaskSuggestions {
  final List<TaskSuggestion> suggestions;
  final DateTime timestamp;

  CachedTaskSuggestions({
    required this.suggestions,
    required this.timestamp,
  });

  /// Checks if the cache is still valid (less than 5 minutes old)
  bool get isExpired {
    return DateTime.now().difference(timestamp).inMinutes >= 5;
  }
}

/// State notifier that manages the suggestion cache for different task lists.
/// Provides pre-caching functionality and automatic expiration after 5 minutes.
class SuggestionCacheNotifier extends StateNotifier<Map<int, CachedTaskSuggestions>> {
  final AiSuggestionService _aiService;

  SuggestionCacheNotifier(this._aiService) : super({});

  /// Retrieves cached suggestions for a task list if available and not expired.
  /// Returns null if no cache exists or if the cache has expired.
  List<TaskSuggestion>? getCachedSuggestions(int taskListId) {
    final cached = state[taskListId];

    if (cached == null) {
      developer.log(
        'No cached suggestions for task list $taskListId',
        name: 'SuggestionCache',
      );
      return null;
    }

    if (cached.isExpired) {
      developer.log(
        'Cached suggestions expired for task list $taskListId',
        name: 'SuggestionCache',
      );
      // Remove expired cache
      state = Map.from(state)..remove(taskListId);
      return null;
    }

    developer.log(
      'Retrieved ${cached.suggestions.length} cached suggestions for task list $taskListId',
      name: 'SuggestionCache',
    );
    return cached.suggestions;
  }

  /// Caches task suggestions for a specific task list
  void cacheSuggestions(int taskListId, List<TaskSuggestion> suggestions) {
    developer.log(
      'Caching ${suggestions.length} suggestions for task list $taskListId',
      name: 'SuggestionCache',
    );

    state = {
      ...state,
      taskListId: CachedTaskSuggestions(
        suggestions: suggestions,
        timestamp: DateTime.now(),
      ),
    };
  }

  /// Pre-fetches suggestions for a task list in the background.
  /// Uses empty partial input to get general suggestions.
  /// This is non-blocking and will not throw errors to the UI.
  Future<void> preFetchSuggestions(int taskListId) async {
    // Check if we already have valid cached suggestions
    if (getCachedSuggestions(taskListId) != null) {
      developer.log(
        'Skipping pre-fetch - valid cache exists for task list $taskListId',
        name: 'SuggestionCache',
      );
      return;
    }

    try {
      developer.log(
        'Pre-fetching suggestions for task list $taskListId',
        name: 'SuggestionCache',
      );

      final response = await _aiService.getTaskSuggestions(
        taskListId: taskListId,
        partialInput: '', // Empty input for general suggestions
        maxSuggestions: 5,
      );

      cacheSuggestions(taskListId, response.suggestions);

      developer.log(
        'Successfully pre-fetched ${response.suggestions.length} suggestions in ${response.responseTimeMs}ms',
        name: 'SuggestionCache',
      );
    } catch (e) {
      // Silently fail - pre-fetching is optional enhancement
      developer.log(
        'Pre-fetch failed for task list $taskListId: $e',
        name: 'SuggestionCache',
      );
    }
  }

  /// Clears all cached suggestions
  void clearCache() {
    developer.log('Clearing all cached suggestions', name: 'SuggestionCache');
    state = {};
  }

  /// Clears cached suggestions for a specific task list
  void clearCacheForTaskList(int taskListId) {
    developer.log(
      'Clearing cached suggestions for task list $taskListId',
      name: 'SuggestionCache',
    );
    state = Map.from(state)..remove(taskListId);
  }
}

/// Provider for the suggestion cache notifier.
/// Automatically initializes with the AI suggestion service.
final suggestionCacheProvider = StateNotifierProvider<SuggestionCacheNotifier, Map<int, CachedTaskSuggestions>>((ref) {
  final aiService = ref.watch(aiSuggestionServiceProvider);
  return SuggestionCacheNotifier(aiService);
});
