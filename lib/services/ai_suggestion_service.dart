import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// Response model for task list suggestions from the AI API
class TaskListSuggestionResponse {
  final List<String> suggestions;
  final int responseTimeMs;

  TaskListSuggestionResponse({
    required this.suggestions,
    required this.responseTimeMs,
  });

  factory TaskListSuggestionResponse.fromJson(Map<String, dynamic> json) {
    return TaskListSuggestionResponse(
      suggestions: (json['suggestions'] as List<dynamic>).cast<String>(),
      responseTimeMs: json['responseTimeMs'] as int,
    );
  }
}

/// Model representing a single task suggestion with repeat pattern
class TaskSuggestion {
  final String name;
  final String repeatUnit;
  final int repeatDelta;

  TaskSuggestion({
    required this.name,
    required this.repeatUnit,
    required this.repeatDelta,
  });

  factory TaskSuggestion.fromJson(Map<String, dynamic> json) {
    return TaskSuggestion(
      name: json['name'] as String,
      repeatUnit: json['repeatUnit'] as String,
      repeatDelta: json['repeatDelta'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'repeatUnit': repeatUnit,
      'repeatDelta': repeatDelta,
    };
  }
}

/// Response model for task suggestions from the AI API
/// Contains task suggestions with recommended repeat patterns
class TaskSuggestionResponse {
  final List<TaskSuggestion> suggestions;
  final int responseTimeMs;

  TaskSuggestionResponse({
    required this.suggestions,
    required this.responseTimeMs,
  });

  factory TaskSuggestionResponse.fromJson(Map<String, dynamic> json) {
    final suggestionsList = json['suggestions'] as List<dynamic>;
    return TaskSuggestionResponse(
      suggestions: suggestionsList
          .map((item) => TaskSuggestion.fromJson(item as Map<String, dynamic>))
          .toList(),
      responseTimeMs: json['responseTimeMs'] as int,
    );
  }
}

/// Exception thrown when AI suggestion API calls fail
class AiSuggestionException implements Exception {
  final String message;
  final int? statusCode;

  AiSuggestionException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

/// Service responsible for fetching AI-powered suggestions for task lists and tasks.
/// Uses OpenAI-powered backend to provide intelligent, context-aware suggestions.
class AiSuggestionService {
  static String get baseUrl => ApiConfig.baseUrl;

  final http.Client _client;
  String? _token;

  /// Constructor allows dependency injection of HTTP client for testing.
  AiSuggestionService({http.Client? client}) : _client = client ?? http.Client();

  /// Sets the authentication token for API requests
  void setToken(String? token) {
    _token = token;
  }

  /// Constructs headers for authenticated API requests
  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  /// Fetches AI-powered suggestions for task list names.
  ///
  /// Parameters:
  /// - [partialInput]: The text the user has typed so far (minimum 2 characters recommended)
  /// - [maxSuggestions]: Maximum number of suggestions to return (default: 3)
  ///
  /// Returns a [TaskListSuggestionResponse] with suggestions and timing information.
  /// Throws [AiSuggestionException] if the request fails.
  ///
  /// Example:
  /// ```dart
  /// final suggestions = await service.getTaskListSuggestions('træn', maxSuggestions: 3);
  /// // suggestions.suggestions = ['Træning og Fitness', 'Træningsrutine', 'Ugentlig Træning']
  /// ```
  Future<TaskListSuggestionResponse> getTaskListSuggestions({
    required String partialInput,
    int maxSuggestions = 3,
  }) async {
    try {
      developer.log(
        '>>> POST /api/ai/suggestions/task-lists (partial: "$partialInput")',
        name: 'AiSuggestionService',
      );

      final response = await _client.post(
        Uri.parse('$baseUrl/api/ai/suggestions/task-lists'),
        headers: _getHeaders(),
        body: jsonEncode({
          'partialInput': partialInput,
          'maxSuggestions': maxSuggestions,
        }),
      );

      developer.log(
        '<<< POST /api/ai/suggestions/task-lists - Status: ${response.statusCode}',
        name: 'AiSuggestionService',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final result = TaskListSuggestionResponse.fromJson(data);

        developer.log(
          'Got ${result.suggestions.length} suggestions in ${result.responseTimeMs}ms',
          name: 'AiSuggestionService',
        );

        return result;
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw AiSuggestionException(
          errorData['message'] ?? 'Failed to get task list suggestions',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is AiSuggestionException) rethrow;
      developer.log('Error fetching task list suggestions: $e', name: 'AiSuggestionService');
      throw AiSuggestionException('Network error: $e');
    }
  }

  /// Fetches AI-powered suggestions for task names within a specific task list.
  /// The AI considers the context of the task list to provide relevant suggestions.
  ///
  /// Parameters:
  /// - [taskListId]: The ID of the task list for context
  /// - [partialInput]: The text the user has typed so far (minimum 2 characters recommended)
  /// - [maxSuggestions]: Maximum number of suggestions to return (default: 3)
  ///
  /// Returns a [TaskSuggestionResponse] with suggestions and timing information.
  /// Throws [AiSuggestionException] if the request fails.
  ///
  /// Example:
  /// ```dart
  /// final suggestions = await service.getTaskSuggestions(
  ///   taskListId: 5,
  ///   partialInput: 'løb',
  ///   maxSuggestions: 3,
  /// );
  /// // suggestions.suggestions = ['Løb 5 km om morgenen', 'Planlæg løberute', 'Køb nye løbesko']
  /// ```
  Future<TaskSuggestionResponse> getTaskSuggestions({
    required int taskListId,
    required String partialInput,
    int maxSuggestions = 3,
  }) async {
    try {
      developer.log(
        '>>> POST /api/ai/suggestions/tasks (listId: $taskListId, partial: "$partialInput")',
        name: 'AiSuggestionService',
      );

      final response = await _client.post(
        Uri.parse('$baseUrl/api/ai/suggestions/tasks'),
        headers: _getHeaders(),
        body: jsonEncode({
          'taskListId': taskListId,
          'partialInput': partialInput,
          'maxSuggestions': maxSuggestions,
        }),
      );

      developer.log(
        '<<< POST /api/ai/suggestions/tasks - Status: ${response.statusCode}',
        name: 'AiSuggestionService',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final result = TaskSuggestionResponse.fromJson(data);

        developer.log(
          'Got ${result.suggestions.length} suggestions in ${result.responseTimeMs}ms',
          name: 'AiSuggestionService',
        );

        return result;
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw AiSuggestionException(
          errorData['message'] ?? 'Failed to get task suggestions',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is AiSuggestionException) rethrow;
      developer.log('Error fetching task suggestions: $e', name: 'AiSuggestionService');
      throw AiSuggestionException('Network error: $e');
    }
  }
}
