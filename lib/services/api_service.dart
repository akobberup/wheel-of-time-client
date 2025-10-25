import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_response.dart';
import '../models/login_request.dart';

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
  static const String baseUrl = 'http://localhost:8080';

  final http.Client _client;
  String? _token;

  /// Constructor allows dependency injection of HTTP client for testing purposes.
  /// If no client is provided, uses the default http.Client().
  ApiService({http.Client? client}) : _client = client ?? http.Client();

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

  /// Registers a new user account with the backend API.
  /// Returns AuthResponse with user details and authentication token on success.
  /// Throws ApiException if registration fails or network error occurs.
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/auth/register'),
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
      final response = await _client.post(
        Uri.parse('$baseUrl/api/auth/login'),
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

  /// Validates the current authentication token by making an authenticated request.
  /// Returns true if the token is valid and accepted by the server, false otherwise.
  /// This implementation uses a health check endpoint rather than a dedicated token validation endpoint.
  /// If the server accepts the authenticated request to the health endpoint, it assumes the token is valid.
  Future<bool> validateToken() async {
    if (_token == null) return false;

    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/actuator/health'),
        headers: _getHeaders(includeAuth: true),
      );

      return response.statusCode == 200;
    } catch (e) {
      // Any network error or exception is treated as an invalid token.
      return false;
    }
  }
}
