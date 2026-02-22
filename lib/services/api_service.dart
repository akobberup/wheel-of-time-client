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
import '../models/visual_theme.dart';
import '../models/enums.dart';
import '../models/task_responsible.dart';
import '../models/cheer.dart';
import '../config/api_config.dart';
import 'remote_logger_service.dart';

/// Nøgler til lokaliserede fejlmeddelelser.
/// Disse matcher getters i AppStrings klassen.
enum ApiErrorKey {
  // Auth
  registrationFailed,
  loginFailed,
  failedToSendResetEmail,
  failedToResetPassword,
  failedToRefreshToken,
  sessionExpired,
  failedToRequestAccountDeletion,

  // Task Lists
  failedToLoadTaskLists,
  failedToLoadOwnedTaskLists,
  failedToLoadSharedTaskLists,
  failedToLoadTaskList,
  failedToCreateTaskList,
  failedToUpdateTaskList,
  failedToDeleteTaskList,

  // Tasks
  failedToLoadTasks,
  failedToLoadTask,
  failedToCreateTask,
  failedToUpdateTask,
  failedToDeleteTask,
  failedToLoadUpcomingTasks,
  failedToLoadUpcomingOccurrences,
  failedToCompleteTask,

  // Task Instances
  failedToLoadTaskInstances,
  failedToLoadTaskInstance,
  failedToCreateTaskInstance,
  failedToCheerTask,
  failedToDeleteCheer,
  failedToLoadRecentlyCompleted,

  // Streaks
  failedToLoadCurrentStreak,
  failedToLoadLongestStreak,
  failedToLoadStreaks,

  // Invitations
  failedToLoadPendingInvitations,
  failedToLoadInvitations,
  failedToLoadTaskListInvitations,
  failedToLoadInvitation,
  failedToCreateInvitation,
  failedToAcceptInvitation,
  failedToDeclineInvitation,
  failedToCancelInvitation,

  // Task List Users
  failedToLoadTaskListUsers,
  failedToUpdateUserAdminLevel,
  failedToRemoveUser,

  // Images
  failedToUploadImage,
  failedToDeleteImage,

  // Completion Message
  failedToLoadCompletionMessage,

  // User Settings
  failedToLoadUserSettings,
  failedToUpdateUserSettings,

  // Visual Themes
  failedToLoadVisualThemes,
  failedToLoadVisualTheme,

  // Content Moderation
  contentModerationViolation,

  // Push Notifications
  failedToRegisterFcmToken,
  failedToUnregisterFcmToken,

  // Generic
  networkError,
  unknownError,
}

/// Custom exception class for API-related errors.
/// Includes the error message, optional HTTP status code, and a localization key
/// for better error handling and translation support.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final ApiErrorKey? errorKey;

  ApiException(this.message, [this.statusCode, this.errorKey]);

  /// Factory constructor med errorKey for lokalisering
  factory ApiException.withKey(ApiErrorKey key, String fallbackMessage, [int? statusCode]) {
    return ApiException(fallbackMessage, statusCode, key);
  }

  @override
  String toString() => message;
}

/// Service class responsible for all API communication with the backend server.
/// Handles authentication, token management, and HTTP requests.
class ApiService {
  // Use ApiConfig for environment-aware base URL
  static String get baseUrl => ApiConfig.baseUrl;
  
  // HTTP status codes
  static const int _statusUnprocessableEntity = 422;

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

  /// Logger for API-relaterede fejl - sender til remote og kaster ApiException
  /// Bruges i catch blocks for at sikre alle fejl bliver logget
  /// Stack trace giver info om hvilken metode fejlen skete i
  Never _logAndThrowError(Object error, StackTrace stackTrace) {
    _logger?.error(
      'API error: $error',
      category: 'api_error',
      error: error,
      stackTrace: stackTrace,
      metadata: {
        'errorType': error.runtimeType.toString(),
      },
    );
    throw ApiException.withKey(ApiErrorKey.networkError, 'Network error: $error');
  }

  /// Parser en errorKey string fra API response til ApiErrorKey enum.
  /// Returnerer null hvis key er null eller ukendt.
  ApiErrorKey? _parseErrorKey(String? key) {
    if (key == 'CONTENT_MODERATION_VIOLATION') {
      return ApiErrorKey.contentModerationViolation;
    }
    return null;
  }
  
  /// Håndterer HTTP 422 (Unprocessable Entity) responses med content moderation fejl.
  /// Parser errorKey fra response og kaster ApiException med korrekt fejlnøgle.
  /// 
  /// Bruges når backend blokerer indhold via OpenAI Moderation API.
  Never _handleContentModerationError(http.Response response, ApiErrorKey defaultErrorKey) {
    final errorData = jsonDecode(response.body);
    final errorKey = _parseErrorKey(errorData['errorKey']);
    throw ApiException.withKey(
      errorKey ?? defaultErrorKey,
      errorData['message'] ?? 'Content blocked',
      response.statusCode,
    );
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
        throw ApiException.withKey(
          ApiErrorKey.registrationFailed,
          errorData['message'] ?? 'Registration failed',
          response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
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
        throw ApiException.withKey(
          ApiErrorKey.loginFailed,
          errorData['message'] ?? 'Login failed',
          response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
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
        throw ApiException.withKey(
          ApiErrorKey.failedToSendResetEmail,
          errorData['message'] ?? 'Failed to send password reset email',
          response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
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
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
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
        throw ApiException.withKey(
          ApiErrorKey.failedToResetPassword,
          errorData['message'] ?? 'Failed to reset password',
          response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
    }
  }

  /// Anmoder om sletning af brugerens konto.
  /// Sender en bekræftelses-email til brugerens registrerede email.
  /// Kontoen vil først blive slettet når brugeren klikker på linket i emailen.
  /// Kræver autentificering.
  Future<void> requestAccountDeletion() async {
    try {
      final response = await _loggedPost(
        '$baseUrl/api/account/request-deletion',
        headers: _getHeaders(includeAuth: true),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw ApiException.withKey(
          ApiErrorKey.failedToRequestAccountDeletion,
          errorData['message'] ?? 'Failed to request account deletion',
          response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
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
        throw ApiException.withKey(
          ApiErrorKey.failedToRefreshToken,
          errorData['message'] ?? 'Failed to refresh token',
          response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
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
        throw ApiException.withKey(ApiErrorKey.failedToLoadTaskLists, 'Failed to load task lists', response.statusCode);
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
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
        throw ApiException.withKey(ApiErrorKey.failedToLoadOwnedTaskLists, 'Failed to load owned task lists', response.statusCode);
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
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
        throw ApiException.withKey(ApiErrorKey.failedToLoadSharedTaskLists, 'Failed to load shared task lists', response.statusCode);
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
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
        throw ApiException.withKey(ApiErrorKey.failedToLoadTaskList, 'Failed to load task list', response.statusCode);
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
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
      } else if (response.statusCode == _statusUnprocessableEntity) {
        _handleContentModerationError(response, ApiErrorKey.failedToCreateTaskList);
      } else {
        final errorData = jsonDecode(response.body);
        throw ApiException.withKey(
          ApiErrorKey.failedToCreateTaskList,
          errorData['message'] ?? 'Failed to create task list',
          response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
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
      } else if (response.statusCode == _statusUnprocessableEntity) {
        _handleContentModerationError(response, ApiErrorKey.failedToUpdateTaskList);
      } else {
        final errorData = jsonDecode(response.body);
        throw ApiException.withKey(
          ApiErrorKey.failedToUpdateTaskList,
          errorData['message'] ?? 'Failed to update task list',
          response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
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
        throw ApiException.withKey(
          ApiErrorKey.failedToDeleteTaskList,
          errorData['message'] ?? 'Failed to delete task list',
          response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
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
        throw ApiException.withKey(ApiErrorKey.failedToLoadTasks, 'Failed to load tasks', response.statusCode);
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
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
        throw ApiException.withKey(ApiErrorKey.failedToLoadTask, 'Failed to load task', response.statusCode);
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
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
      } else if (response.statusCode == _statusUnprocessableEntity) {
        _handleContentModerationError(response, ApiErrorKey.failedToCreateTask);
      } else {
        final errorData = jsonDecode(response.body);
        throw ApiException.withKey(
          ApiErrorKey.failedToCreateTask,
          errorData['message'] ?? 'Failed to create task',
          response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
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
      } else if (response.statusCode == _statusUnprocessableEntity) {
        _handleContentModerationError(response, ApiErrorKey.failedToUpdateTask);
      } else {
        final errorData = jsonDecode(response.body);
        throw ApiException.withKey(
          ApiErrorKey.failedToUpdateTask,
          errorData['message'] ?? 'Failed to update task',
          response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
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
        throw ApiException.withKey(
          ApiErrorKey.failedToDeleteTask,
          errorData['message'] ?? 'Failed to delete task',
          response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
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
        throw ApiException.withKey(ApiErrorKey.failedToLoadUpcomingTasks, 'Failed to load upcoming tasks', response.statusCode);
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
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
        throw ApiException.withKey(ApiErrorKey.failedToLoadUpcomingOccurrences, 'Failed to load upcoming task occurrences', response.statusCode);
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
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
        throw ApiException.withKey(ApiErrorKey.failedToLoadTaskInstances, 'Failed to load task instances', response.statusCode);
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
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
        throw ApiException.withKey(ApiErrorKey.failedToLoadTaskInstances, 'Failed to load task instances', response.statusCode);
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
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
        throw ApiException.withKey(ApiErrorKey.failedToLoadTaskInstance, 'Failed to load task instance', response.statusCode);
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
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
        throw ApiException.withKey(
          ApiErrorKey.failedToCreateTaskInstance,
          errorData['message'] ?? 'Failed to create task instance',
          response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
    }
  }

  /// Dismiss a task instance (skip without affecting streak)
  Future<TaskInstanceResponse> dismissTaskInstance(int taskInstanceId) async {
    try {
      final response = await _loggedPost(
        '$baseUrl/api/task-instances/$taskInstanceId/dismiss',
        headers: _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        return TaskInstanceResponse.fromJson(jsonDecode(response.body));
      } else {
        final errorData = jsonDecode(response.body);
        throw ApiException.withKey(
          ApiErrorKey.failedToCreateTaskInstance,
          errorData['message'] ?? 'Failed to dismiss task instance',
          response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
    }
  }

  /// Dismiss a task occurrence by taskId and dueDate
  /// Used for future occurrences that don't have a spawned instance yet
  Future<TaskInstanceResponse> dismissTaskOccurrence(int taskId, DateTime dueDate) async {
    try {
      final dueDateStr = '${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}';
      final response = await _loggedPost(
        '$baseUrl/api/task-instances/task/$taskId/dismiss?dueDate=$dueDateStr',
        headers: _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        return TaskInstanceResponse.fromJson(jsonDecode(response.body));
      } else {
        final errorData = jsonDecode(response.body);
        throw ApiException.withKey(
          ApiErrorKey.failedToCreateTaskInstance,
          errorData['message'] ?? 'Failed to dismiss task occurrence',
          response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
    }
  }

  /// Get recently completed task instances with pagination
  /// Returns the last [limit] completed tasks starting from [offset]
  Future<List<TaskInstanceResponse>> getRecentlyCompletedTasks({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _loggedGet(
        '$baseUrl/api/task-instances/completed/recent?limit=$limit&offset=$offset',
        headers: _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => TaskInstanceResponse.fromJson(json)).toList();
      } else {
        throw ApiException.withKey(ApiErrorKey.failedToLoadRecentlyCompleted, 'Failed to load recently completed tasks', response.statusCode);
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
    }
  }

  // ============================================================================
  // CHEERS
  // ============================================================================

  /// Opret eller opdater en cheer på en task instance
  Future<CheerResponse> cheerTaskInstance(int taskInstanceId, {
    required String emoji,
    String? message,
  }) async {
    try {
      final response = await _loggedPut(
        '$baseUrl/api/task-instances/$taskInstanceId/cheers',
        headers: _getHeaders(includeAuth: true),
        body: jsonEncode({
          'emoji': emoji,
          if (message != null) 'message': message,
        }),
      );

      if (response.statusCode == 200) {
        return CheerResponse.fromJson(jsonDecode(response.body));
      } else {
        _handleContentModerationError(response, ApiErrorKey.failedToCheerTask);
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
    }
  }

  /// Hent alle cheers for en task instance
  Future<List<CheerResponse>> getCheersForTaskInstance(int taskInstanceId) async {
    try {
      final response = await _loggedGet(
        '$baseUrl/api/task-instances/$taskInstanceId/cheers',
        headers: _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => CheerResponse.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ApiException.withKey(ApiErrorKey.failedToCheerTask, 'Failed to load cheers', response.statusCode);
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
    }
  }

  /// Slet egen cheer fra en task instance
  Future<void> deleteCheer(int taskInstanceId) async {
    try {
      final response = await _loggedDelete(
        '$baseUrl/api/task-instances/$taskInstanceId/cheers',
        headers: _getHeaders(includeAuth: true),
      );

      if (response.statusCode != 204) {
        throw ApiException.withKey(ApiErrorKey.failedToDeleteCheer, 'Failed to delete cheer', response.statusCode);
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
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
        throw ApiException.withKey(ApiErrorKey.failedToLoadCurrentStreak, 'Failed to load current streak', response.statusCode);
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
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
        throw ApiException.withKey(ApiErrorKey.failedToLoadLongestStreak, 'Failed to load longest streak', response.statusCode);
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
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
        throw ApiException.withKey(ApiErrorKey.failedToLoadStreaks, 'Failed to load streaks', response.statusCode);
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
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
        throw ApiException.withKey(ApiErrorKey.failedToLoadPendingInvitations, 'Failed to load pending invitations', response.statusCode);
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
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
        throw ApiException.withKey(ApiErrorKey.failedToLoadInvitations, 'Failed to load invitations', response.statusCode);
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
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
        throw ApiException.withKey(ApiErrorKey.failedToLoadTaskListInvitations, 'Failed to load task list invitations', response.statusCode);
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
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
        throw ApiException.withKey(ApiErrorKey.failedToLoadInvitation, 'Failed to load invitation', response.statusCode);
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
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
        throw ApiException.withKey(
          ApiErrorKey.failedToCreateInvitation,
          errorData['message'] ?? 'Failed to create invitation',
          response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
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
        throw ApiException.withKey(
          ApiErrorKey.failedToAcceptInvitation,
          errorData['message'] ?? 'Failed to accept invitation',
          response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
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
        throw ApiException.withKey(
          ApiErrorKey.failedToDeclineInvitation,
          errorData['message'] ?? 'Failed to decline invitation',
          response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
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
        throw ApiException.withKey(
          ApiErrorKey.failedToCancelInvitation,
          errorData['message'] ?? 'Failed to cancel invitation',
          response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
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
        throw ApiException.withKey(ApiErrorKey.failedToLoadTaskListUsers, 'Failed to load task list users', response.statusCode);
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
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
        throw ApiException.withKey(
          ApiErrorKey.failedToUpdateUserAdminLevel,
          errorData['message'] ?? 'Failed to update user admin level',
          response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
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
        throw ApiException.withKey(
          ApiErrorKey.failedToRemoveUser,
          errorData['message'] ?? 'Failed to remove user',
          response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
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
        throw ApiException.withKey(
          ApiErrorKey.failedToUploadImage,
          errorData['message'] ?? 'Failed to upload image',
          response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
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
        throw ApiException.withKey(
          ApiErrorKey.failedToDeleteImage,
          errorData['message'] ?? 'Failed to delete image',
          response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
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
        throw ApiException.withKey(ApiErrorKey.failedToLoadCompletionMessage, 'Failed to load completion message', response.statusCode);
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
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
        throw ApiException.withKey(ApiErrorKey.failedToLoadUserSettings, 'Failed to load user settings', response.statusCode);
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
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
        throw ApiException.withKey(ApiErrorKey.failedToUpdateUserSettings, 'Failed to update user settings', response.statusCode);
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
    }
  }

  // ===================== Visual Themes =====================

  /// Henter alle tilgængelige visuelle temaer
  /// Bruges til at vise tema-vælger i UI
  Future<List<VisualThemeResponse>> getAllVisualThemes() async {
    try {
      final response = await _loggedGet(
        '$baseUrl/api/visual-themes',
        headers: _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList
            .map((json) => VisualThemeResponse.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ApiException.withKey(ApiErrorKey.failedToLoadVisualThemes, 'Failed to load visual themes', response.statusCode);
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
    }
  }

  /// Henter et specifikt visuelt tema baseret på ID
  Future<VisualThemeResponse> getVisualThemeById(int id) async {
    try {
      final response = await _loggedGet(
        '$baseUrl/api/visual-themes/$id',
        headers: _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        return VisualThemeResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      } else {
        throw ApiException.withKey(ApiErrorKey.failedToLoadVisualTheme, 'Failed to load visual theme', response.statusCode);
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
    }
  }

  // ============================================================================
  // PUSH NOTIFICATIONS
  // ============================================================================

  /// Registrerer en FCM token hos backend.
  /// Tokenet bruges til at sende push notifications til denne enhed.
  /// [token] er FCM tokenet fra Firebase Messaging.
  /// [deviceId] er en valgfri enhedsidentifikator.
  Future<void> registerFcmToken(String token, {String? deviceId}) async {
    try {
      final body = {
        'token': token,
        if (deviceId != null) 'deviceId': deviceId,
      };

      final response = await _loggedPost(
        '$baseUrl/api/push-notifications/register',
        headers: _getHeaders(includeAuth: true),
        body: jsonEncode(body),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorData = jsonDecode(response.body);
        throw ApiException.withKey(
          ApiErrorKey.failedToRegisterFcmToken,
          errorData['message'] ?? 'Failed to register FCM token',
          response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
    }
  }

  /// Afregistrerer en FCM token fra backend.
  /// Bruges ved logout eller når brugeren fravælger push notifications.
  Future<void> unregisterFcmToken(String token) async {
    try {
      final response = await _loggedDelete(
        '$baseUrl/api/push-notifications/unregister?token=$token',
        headers: _getHeaders(includeAuth: true),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        final errorData = jsonDecode(response.body);
        throw ApiException.withKey(
          ApiErrorKey.failedToUnregisterFcmToken,
          errorData['message'] ?? 'Failed to unregister FCM token',
          response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
    }
  }

  // ============================================================================
  // TASK RESPONSIBLE
  // ============================================================================

  /// Henter ansvarskonfiguration for en task.
  /// Returnerer null hvis ingen konfiguration findes (implicit ALL strategi).
  Future<TaskResponsibleConfigResponse?> getTaskResponsibleConfig(int taskId) async {
    try {
      final response = await _loggedGet(
        '$baseUrl/api/tasks/$taskId/responsible',
        headers: _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        return TaskResponsibleConfigResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 204) {
        return null; // Ingen config = ALL strategi
      } else {
        throw ApiException.withKey(
          ApiErrorKey.failedToLoadTasks,
          'Failed to load responsible config',
          response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
    }
  }

  /// Opretter eller opdaterer ansvarskonfiguration for en task.
  Future<TaskResponsibleConfigResponse> setTaskResponsibleConfig(
    int taskId,
    TaskResponsibleConfigRequest request,
  ) async {
    try {
      final response = await _loggedPut(
        '$baseUrl/api/tasks/$taskId/responsible',
        headers: _getHeaders(includeAuth: true),
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return TaskResponsibleConfigResponse.fromJson(jsonDecode(response.body));
      } else {
        final errorData = jsonDecode(response.body);
        throw ApiException.withKey(
          ApiErrorKey.failedToUpdateTask,
          errorData['message'] ?? 'Failed to update responsible config',
          response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
    }
  }

  /// Fjerner ansvarskonfiguration for en task (falder tilbage til ALL strategi).
  Future<void> removeTaskResponsibleConfig(int taskId) async {
    try {
      final response = await _loggedDelete(
        '$baseUrl/api/tasks/$taskId/responsible',
        headers: _getHeaders(includeAuth: true),
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw ApiException.withKey(
          ApiErrorKey.failedToUpdateTask,
          'Failed to remove responsible config',
          response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      _logAndThrowError(e, stackTrace);
    }
  }
}
