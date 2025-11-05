import 'package:flutter/foundation.dart';

/// Configuration for API endpoints based on environment
class ApiConfig {
  // Private constructor to prevent instantiation
  ApiConfig._();

  /// Base URL for API requests
  /// - Debug mode: localhost:8080
  /// - Production mode: configurable via environment variable or default
  static String get baseUrl {
    if (kDebugMode) {
      // Development environment - use localhost
      return 'http://localhost:8080';
    } else {
      // Production environment - this should be configured via environment variables
      // or a build configuration in a real production setup
      const String prodUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'https://api.wheeloftime.com');
      return prodUrl;
    }
  }

  /// Gets the full URL for an image path
  ///
  /// Example:
  /// ```dart
  /// ApiConfig.getImageUrl('/images/task-icon.png')
  /// // Returns: 'http://localhost:8080/images/task-icon.png' (in debug)
  /// ```
  static String getImageUrl(String path) {
    // Remove leading slash if present to avoid double slashes
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '$baseUrl/$cleanPath';
  }

  /// Gets the full URL for an API endpoint
  ///
  /// Example:
  /// ```dart
  /// ApiConfig.getApiUrl('/api/tasks')
  /// // Returns: 'http://localhost:8080/api/tasks' (in debug)
  /// ```
  static String getApiUrl(String endpoint) {
    // Remove leading slash if present to avoid double slashes
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    return '$baseUrl/$cleanEndpoint';
  }

  /// Returns true if running in development/debug mode
  static bool get isDevelopment => kDebugMode;

  /// Returns true if running in production/release mode
  static bool get isProduction => !kDebugMode;
}
