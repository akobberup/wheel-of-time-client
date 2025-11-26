import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import '../models/auth_response.dart';
import '../models/login_request.dart';
import '../models/task_list.dart';
import '../models/task.dart';
import '../models/task_occurrence.dart';
import '../models/task_instance.dart';
import '../models/invitation.dart';
import '../models/task_list_user.dart';
import '../models/streak.dart';
import '../models/image.dart';
import '../models/user_settings.dart';
import '../models/enums.dart';
import '../config/api_config.dart';
import 'remote_logger_service.dart';

/// Custom exception class for API-related errors.
/// Includes the error message and optional HTTP status code for better error handling.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

/// Service class responsible for all API communication with the backend server.
/// Handles authentication, token management, and HTTP requests.
class ApiService {
  // Use ApiConfig for environment-aware base URL
  static String get baseUrl => ApiConfig.baseUrl;

  final http.Client _client;
  final RemoteLoggerService? _logger;
  String? _token;

  /// Constructor allows dependency injection of HTTP client for testing purposes.
  /// If no client is provided, uses the default http.Client().
  ApiService({
    http.Client? client,
    RemoteLoggerService? logger,
  })  : _client = client ?? http.Client(),
        _logger = logger;

  /// Updates the stored authentication token.
  /// This token will be included in subsequent authenticated requests.
  void setToken(String? token) {
    _token = token;
  }

  /// Constructs HTTP headers for API requests.
  /// If includeAuth is true and a token exists, adds the Bearer token to Authorization header.
  Map<String, String> _getHeaders({bool includeAuth = false}) {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (includeAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  /// Wrapper for HTTP GET with logging
  Future<http.Response> _loggedGet(String url, {Map<String, String>? headers}) async {
    developer.log('>>> GET $url', name: 'ApiService');

    final response = await _client.get(Uri.parse(url), headers: headers);

    developer.log('<<< GET $url - Status: ${response.statusCode}', name: 'ApiService');
    developer.log('Response body: ${response.body}', name: 'ApiService');

    // Log errors to remote
    if (response.statusCode >= 400) {
      _logger?.warning(
        'API GET request failed',
        category: 'api',
        metadata: {
          'url': url,
          'statusCode': response.statusCode,
          'responseBody': response.body.length > 200
              ? '${response.body.substring(0, 200)}...'
              : response.body,
        },
      );
    }

    return response;
  }

  /// Wrapper for HTTP POST with logging
  Future<http.Response> _loggedPost(String url, {Map<String, String>? headers, Object? body}) async {
    developer.log('>>> POST $url', name: 'ApiService');
    if (body != null) {
      developer.log('Request body: $body', name: 'ApiService');
    }

    final response = await _client.post(Uri.parse(url), headers: headers, body: body);

    developer.log('<<< POST $url - Status: ${response.statusCode}', name: 'ApiService');
    developer.log('Response body: ${response.body}', name: 'ApiService');

    // Log errors to remote
    if (response.statusCode >= 400) {
      _logger?.warning(
        'API POST request failed',
        category: 'api',
        metadata: {
          'url': url,
          'statusCode': response.statusCode,
          'responseBody': response.body.length > 200
              ? '${response.body.substring(0, 200)}...'
              : response.body,
        },
      );
    }

    return response;
  }

  /// Wrapper for HTTP PUT with logging
  Future<http.Response> _loggedPut(String url, {Map<String, String>? headers, Object? body}) async {
    developer.log('>>> PUT $url', name: 'ApiService');
    if (body != null) {
      developer.log('Request body: $body', name: 'ApiService');
    }

    final response = await _client.put(Uri.parse(url), headers: headers, body: body);

    developer.log('<<< PUT $url - Status: ${response.statusCode}', name: 'ApiService');
    developer.log('Response body: ${response.body}', name: 'ApiService');

    // Log errors to remote
    if (response.statusCode >= 400) {
      _logger?.warning(
        'API PUT request failed',
        category: 'api',
        metadata: {
          'url': url,
          'statusCode': response.statusCode,
          'responseBody': response.body.length > 200
              ? '${response.body.substring(0, 200)}...'
              : response.body,
        },
      );
    }

    return response;
  }

  /// Wrapper for HTTP DELETE with logging
  Future<http.Response> _loggedDelete(String url, {Map<String, String>? headers}) async {
    developer.log('>>> DELETE $url', name: 'ApiService');

    final response = await _client.delete(Uri.parse(url), headers: headers);

    developer.log('<<< DELETE $url - Status: ${response.statusCode}', name: 'ApiService');
    developer.log('Response body: ${response.body}', name: 'ApiService');

    // Log errors to remote
    if (response.statusCode >= 400) {
      _logger?.warning(
        'API DELETE request failed',
        category: 'api',
        metadata: {
          'url': url,
          'statusCode': response.statusCode,
          'responseBody': response.body.length > 200
              ? '${response.body.substring(0, 200)}...'
              : response.body,
        },
      );
    }

    return response;
  }

  /// Registers a new user account with the backend API.
  /// Returns AuthResponse with user details and authentication token on success.
  /// Throws ApiException if registration fails or network error occurs.
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _loggedPost(
        '$baseUrl/api/auth/register',
        headers: _getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return AuthResponse.fromJson(data);
      } else {
        // Extract error message from response body if available, otherwise use default message.
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw ApiException(
          errorData['message'] ?? 'Registration failed',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Authenticates a user with email and password.
  /// Returns AuthResponse with user details and authentication token on success.
  /// Throws ApiException if login fails or network error occurs.
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _loggedPost(
        '$baseUrl/api/auth/login',
        headers: _getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return AuthResponse.fromJson(data);
      } else {
        // Extract error message from response body if available, otherwise use default message.
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw ApiException(
          errorData['message'] ?? 'Login failed',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Validates the current authentication token by checking its expiration time.
  /// Returns true if the token exists and is not expired, false otherwise.
  /// This implementation decodes the JWT and checks the 'exp' claim without making a network request.
  /// Tokens are considered valid if they have at least 60 seconds remaining before expiration.
  Future<bool> validateToken() async {
    if (_token == null) return false;

    try {
      // Decode the JWT token to check expiration
      final expiryDate = Jwt.getExpiryDate(_token!);
      final now = DateTime.now();

      developer.log('Token expiry: $expiryDate, Current time: $now', name: 'ApiService');

      final isExpired = Jwt.isExpired(_token!);

      if (isExpired) {
        developer.log('Token is expired (exp < now)', name: 'ApiService');
        return false;
      }

      // Check if token expires within the next 60 seconds (grace period)
      final remainingTime = expiryDate?.difference(now);
      if (remainingTime != null && remainingTime.inSeconds < 60) {
        developer.log('Token expires in ${remainingTime.inSeconds}s, treating as expired', name: 'ApiService');
        return false;
      }

      developer.log('Token is valid (expires in ${remainingTime?.inMinutes ?? "unknown"} minutes)', name: 'ApiService');
      return true;
    } catch (e) {
      // Any error decoding the token is treated as invalid
      developer.log('Error validating token: $e', name: 'ApiService');
      _logger?.error(
        'Token validation error',
        category: 'auth',
        error: e,
        metadata: {'hasToken': _token != null},
      );
      return false;
    }
  }

  /// Requests a password reset email for the specified email address.
  /// The backend will send an email with a reset link if the account exists.
  /// Throws ApiException if the request fails or network error occurs.
  Future<void> forgotPassword(String email) async {
    try {
      final response = await _loggedPost(
        '$baseUrl/api/auth/forgot-password',
        headers: _getHeaders(),
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw ApiException(
          errorData['message'] ?? 'Failed to send password reset email',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Validates a password reset token without actually resetting the password.
  /// Useful for checking if a reset link is still valid before showing the reset form.
  /// Returns true if the token is valid, throws ApiException if invalid or expired.
  Future<bool> validateResetToken(String token) async {
    try {
      final response = await _loggedGet(
        '$baseUrl/api/auth/validate-reset-token?token=$token',
        headers: _getHeaders(),
      );

      return response.statusCode == 200;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Resets the user's password using a valid reset token.
  /// The token is typically received via email after requesting a password reset.
  /// Throws ApiException if the token is invalid/expired or if the reset fails.
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      final response = await _loggedPost(
        '$baseUrl/api/auth/reset-password',
        headers: _getHeaders(),
        body: jsonEncode({
          'token': token,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw ApiException(
          errorData['message'] ?? 'Failed to reset password',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Refreshes the access token using a refresh token.
  /// Returns new AuthResponse with fresh access token and refresh token.
  /// The old refresh token is automatically revoked by the server.
  /// Throws ApiException if the refresh token is invalid, expired, or revoked.
  Future<AuthResponse> refreshAccessToken(String refreshToken) async {
    try {
      final response = await _loggedPost(
        '$baseUrl/api/auth/refresh',
        headers: _getHeaders(),
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return AuthResponse.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw ApiException(
          errorData['message'] ?? 'Failed to refresh token',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  // ============================================================================
  // TASK LISTS
  // ============================================================================

  /// Get all accessible task lists (owned + shared)
  Future<List<TaskListResponse>> getAllTaskLists() async {
    try {
      final response = await _loggedGet(
        '$baseUrl/api/task-lists',
        headers: _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => TaskListResponse.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to load task lists', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Get owned task lists
  Future<List<TaskListResponse>> getOwnedTaskLists() async {
    try {
      final response = await _loggedGet(
        '$baseUrl/api/task-lists/owned',
        headers: _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => TaskListResponse.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to load owned task lists', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Get shared task lists
  Future<List<TaskListResponse>> getSharedTaskLists() async {
    try {
      final response = await _loggedGet(
        '$baseUrl/api/task-lists/shared',
        headers: _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => TaskListResponse.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to load shared task lists', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Get specific task list by ID
  Future<TaskListResponse> getTaskList(int id) async {
    try {
      final response = await _loggedGet(
        '$baseUrl/api/task-lists/$id',
        headers: _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        return TaskListResponse.fromJson(jsonDecode(response.body));
      } else {
        throw ApiException('Failed to load task list', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Create new task list
  Future<TaskListResponse> createTaskList(CreateTaskListRequest request) async {
    try {
      final response = await _loggedPost(
        '$baseUrl/api/task-lists',
        headers: _getHeaders(includeAuth: true),
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return TaskListResponse.fromJson(jsonDecode(response.body));
      } else {
        final errorData = jsonDecode(response.body);
        throw ApiException(
          errorData['message'] ?? 'Failed to create task list',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Update task list
  Future<TaskListResponse> updateTaskList(int id, UpdateTaskListRequest request) async {
    try {
      final response = await _loggedPut(
        '$baseUrl/api/task-lists/$id',
        headers: _getHeaders(includeAuth: true),
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return TaskListResponse.fromJson(jsonDecode(response.body));
      } else {
        final errorData = jsonDecode(response.body);
        throw ApiException(
          errorData['message'] ?? 'Failed to update task list',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Delete task list
  Future<void> deleteTaskList(int id) async {
    try {
      final response = await _loggedDelete(
        '$baseUrl/api/task-lists/$id',
        headers: _getHeaders(includeAuth: true),
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw ApiException(
          errorData['message'] ?? 'Failed to delete task list',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  // ============================================================================
  // TASKS
  // ============================================================================

  /// Get tasks by task list
  Future<List<TaskResponse>> getTasksByTaskList(int taskListId, {bool activeOnly = false}) async {
    try {
      final response = await _loggedGet(
        '$baseUrl/api/tasks/task-list/$taskListId?activeOnly=$activeOnly',
        headers: _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => TaskResponse.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to load tasks', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Get specific task
  Future<TaskResponse> getTask(int id) async {
    try {
      final response = await _loggedGet(
        '$baseUrl/api/tasks/$id',
        headers: _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        return TaskResponse.fromJson(jsonDecode(response.body));
      } else {
        throw ApiException('Failed to load task', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Create task
  Future<TaskResponse> createTask(CreateTaskRequest request) async {
    try {
      final response = await _loggedPost(
        '$baseUrl/api/tasks',
        headers: _getHeaders(includeAuth: true),
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return TaskResponse.fromJson(jsonDecode(response.body));
      } else {
        final errorData = jsonDecode(response.body);
        throw ApiException(
          errorData['message'] ?? 'Failed to create task',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Update task
  Future<TaskResponse> updateTask(int id, UpdateTaskRequest request) async {
    try {
      final response = await _loggedPut(
        '$baseUrl/api/tasks/$id',
        headers: _getHeaders(includeAuth: true),
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return TaskResponse.fromJson(jsonDecode(response.body));
      } else {
        final errorData = jsonDecode(response.body);
        throw ApiException(
          errorData['message'] ?? 'Failed to update task',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Delete task
  Future<void> deleteTask(int id) async {
    try {
      final response = await _loggedDelete(
        '$baseUrl/api/tasks/$id',
        headers: _getHeaders(includeAuth: true),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        final errorData = jsonDecode(response.body);
        throw ApiException(
          errorData['message'] ?? 'Failed to delete task',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Get tasks due within specified number of days
  Future<List<TaskResponse>> getTasksDueWithinDays({int days = 14}) async {
    try {
      final response = await _loggedGet(
        '$baseUrl/api/tasks/due-within-days?days=$days',
        headers: _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => TaskResponse.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to load upcoming tasks', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Get paginated upcoming task occurrences
  /// Returns the next [limit] occurrences starting from [offset]
  Future<List<UpcomingTaskOccurrenceResponse>> getUpcomingTaskOccurrences({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _loggedGet(
        '$baseUrl/api/tasks/upcoming-occurrences?limit=$limit&offset=$offset',
        headers: _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => UpcomingTaskOccurrenceResponse.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to load upcoming task occurrences', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  // ============================================================================
  // TASK INSTANCES
  // ============================================================================

  /// Get task instances by task
  Future<List<TaskInstanceResponse>> getTaskInstancesByTask(int taskId) async {
    try {
      final response = await _loggedGet(
        '$baseUrl/api/task-instances/task/$taskId',
        headers: _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => TaskInstanceResponse.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to load task instances', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Get task instances by task list
  Future<List<TaskInstanceResponse>> getTaskInstancesByTaskList(int taskListId) async {
    try {
      final response = await _loggedGet(
        '$baseUrl/api/task-instances/task-list/$taskListId',
        headers: _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => TaskInstanceResponse.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to load task instances', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Get specific task instance
  Future<TaskInstanceResponse> getTaskInstance(int id) async {
    try {
      final response = await _loggedGet(
        '$baseUrl/api/task-instances/$id',
        headers: _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        return TaskInstanceResponse.fromJson(jsonDecode(response.body));
      } else {
        throw ApiException('Failed to load task instance', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Create task instance (complete a task)
  Future<TaskInstanceResponse> createTaskInstance(CreateTaskInstanceRequest request) async {
    try {
      final response = await _loggedPost(
        '$baseUrl/api/task-instances',
        headers: _getHeaders(includeAuth: true),
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return TaskInstanceResponse.fromJson(jsonDecode(response.body));
      } else {
        final errorData = jsonDecode(response.body);
        throw ApiException(
          errorData['message'] ?? 'Failed to create task instance',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  // ============================================================================
  // STREAKS
  // ============================================================================

  /// Get current streak for task
  Future<StreakResponse?> getCurrentStreak(int taskId) async {
    try {
      final response = await _loggedGet(
        '$baseUrl/api/task-instances/task/$taskId/streak/current',
        headers: _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final body = response.body;
        if (body.isEmpty) return null;
        return StreakResponse.fromJson(jsonDecode(body));
      } else {
        throw ApiException('Failed to load current streak', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Get longest streak for task
  Future<StreakResponse?> getLongestStreak(int taskId) async {
    try {
      final response = await _loggedGet(
        '$baseUrl/api/task-instances/task/$taskId/streak/longest',
        headers: _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final body = response.body;
        if (body.isEmpty) return null;
        return StreakResponse.fromJson(jsonDecode(body));
      } else {
        throw ApiException('Failed to load longest streak', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Get all streaks for task
  Future<List<StreakResponse>> getAllStreaks(int taskId) async {
    try {
      final response = await _loggedGet(
        '$baseUrl/api/task-instances/task/$taskId/streaks',
        headers: _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => StreakResponse.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to load streaks', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  // ============================================================================
  // INVITATIONS
  // ============================================================================

  /// Get my pending invitations
  Future<List<InvitationResponse>> getMyPendingInvitations() async {
    try {
      final response = await _loggedGet(
        '$baseUrl/api/invitations/my-invitations/pending',
        headers: _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => InvitationResponse.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to load pending invitations', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Get all my invitations
  Future<List<InvitationResponse>> getMyInvitations() async {
    try {
      final response = await _loggedGet(
        '$baseUrl/api/invitations/my-invitations',
        headers: _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => InvitationResponse.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to load invitations', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Get invitations for task list
  Future<List<InvitationResponse>> getInvitationsByTaskList(int taskListId) async {
    try {
      final response = await _loggedGet(
        '$baseUrl/api/invitations/task-list/$taskListId',
        headers: _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => InvitationResponse.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to load task list invitations', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Get specific invitation
  Future<InvitationResponse> getInvitation(int id) async {
    try {
      final response = await _loggedGet(
        '$baseUrl/api/invitations/$id',
        headers: _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        return InvitationResponse.fromJson(jsonDecode(response.body));
      } else {
        throw ApiException('Failed to load invitation', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Create invitation
  Future<InvitationResponse> createInvitation(CreateInvitationRequest request) async {
    try {
      final response = await _loggedPost(
        '$baseUrl/api/invitations',
        headers: _getHeaders(includeAuth: true),
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return InvitationResponse.fromJson(jsonDecode(response.body));
      } else {
        final errorData = jsonDecode(response.body);
        throw ApiException(
          errorData['message'] ?? 'Failed to create invitation',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Accept invitation
  Future<InvitationResponse> acceptInvitation(int id) async {
    try {
      final response = await _loggedPost(
        '$baseUrl/api/invitations/$id/accept',
        headers: _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        return InvitationResponse.fromJson(jsonDecode(response.body));
      } else {
        final errorData = jsonDecode(response.body);
        throw ApiException(
          errorData['message'] ?? 'Failed to accept invitation',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Decline invitation
  Future<InvitationResponse> declineInvitation(int id) async {
    try {
      final response = await _loggedPost(
        '$baseUrl/api/invitations/$id/decline',
        headers: _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        return InvitationResponse.fromJson(jsonDecode(response.body));
      } else {
        final errorData = jsonDecode(response.body);
        throw ApiException(
          errorData['message'] ?? 'Failed to decline invitation',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Cancel invitation
  Future<void> cancelInvitation(int id) async {
    try {
      final response = await _loggedDelete(
        '$baseUrl/api/invitations/$id',
        headers: _getHeaders(includeAuth: true),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        final errorData = jsonDecode(response.body);
        throw ApiException(
          errorData['message'] ?? 'Failed to cancel invitation',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  // ============================================================================
  // TASK LIST USERS
  // ============================================================================

  /// Get users for task list
  Future<List<TaskListUserResponse>> getUsersByTaskList(int taskListId) async {
    try {
      final response = await _loggedGet(
        '$baseUrl/api/task-list-users/task-list/$taskListId',
        headers: _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => TaskListUserResponse.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to load task list users', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Update user admin level
  Future<TaskListUserResponse> updateUserAdminLevel(
    int taskListId,
    int userId,
    AdminLevel newAdminLevel,
  ) async {
    try {
      final response = await _loggedPut(
        '$baseUrl/api/task-list-users?taskListId=$taskListId&userId=$userId&newAdminLevel=${newAdminLevel.toJson()}',
        headers: _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        return TaskListUserResponse.fromJson(jsonDecode(response.body));
      } else {
        final errorData = jsonDecode(response.body);
        throw ApiException(
          errorData['message'] ?? 'Failed to update user admin level',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Remove user from task list
  Future<void> removeUserFromTaskList(int taskListId, int userId) async {
    try {
      final response = await _loggedDelete(
        '$baseUrl/api/task-list-users?taskListId=$taskListId&userId=$userId',
        headers: _getHeaders(includeAuth: true),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        final errorData = jsonDecode(response.body);
        throw ApiException(
          errorData['message'] ?? 'Failed to remove user',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  // ============================================================================
  // IMAGES
  // ============================================================================

  /// Upload image
  Future<ImageUploadResponse> uploadImage(File imageFile, ImageSource imageSource) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/images?imageSource=${imageSource.toJson()}'),
      );

      request.headers.addAll(_getHeaders(includeAuth: true));
      request.headers.remove('Content-Type'); // Let http set the correct multipart content type

      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ImageUploadResponse.fromJson(jsonDecode(response.body));
      } else {
        final errorData = jsonDecode(response.body);
        throw ApiException(
          errorData['message'] ?? 'Failed to upload image',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Delete image
  Future<void> deleteImage(int id) async {
    try {
      final response = await _loggedDelete(
        '$baseUrl/api/images/$id',
        headers: _getHeaders(includeAuth: true),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        final errorData = jsonDecode(response.body);
        throw ApiException(
          errorData['message'] ?? 'Failed to delete image',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Get image URL - returnerer stien uændret hvis det allerede er en fuld URL
  String getImageUrl(String imagePath) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    return '$baseUrl$imagePath';
  }

  /// Get thumbnail URL - returnerer stien uændret hvis det allerede er en fuld URL
  String getThumbnailUrl(String thumbnailPath) {
    if (thumbnailPath.startsWith('http://') || thumbnailPath.startsWith('https://')) {
      return thumbnailPath;
    }
    return '$baseUrl$thumbnailPath';
  }

  // ============================================================================
  // TASK COMPLETION
  // ============================================================================

  /// Get completion message for a task
  /// Returns a personalized message to display when completing a task
  Future<String> getTaskCompletionMessage(int taskId) async {
    try {
      final response = await _loggedGet(
        '$baseUrl/api/tasks/$taskId/completion-message',
        headers: _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['message'] as String;
      } else {
        throw ApiException('Failed to load completion message', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  // ============================================================================
  // USER SETTINGS
  // ============================================================================

  /// Get user settings including theme preferences
  /// Returns the current user's settings (creates default if not exists)
  Future<UserSettingsResponse> getUserSettings() async {
    try {
      final response = await _loggedGet(
        '$baseUrl/api/user/settings',
        headers: _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        return UserSettingsResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      } else {
        throw ApiException('Failed to load user settings', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Update user settings (partial updates supported)
  /// Only updates fields that are not null in the request
  Future<UserSettingsResponse> updateUserSettings(
    UpdateUserSettingsRequest request,
  ) async {
    try {
      final response = await _loggedPut(
        '$baseUrl/api/user/settings',
        headers: _getHeaders(includeAuth: true),
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return UserSettingsResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      } else {
        throw ApiException('Failed to update user settings', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }
}
