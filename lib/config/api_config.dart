import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

/// Configuration for API endpoints based on environment
class ApiConfig {
  // Private constructor to prevent instantiation
  ApiConfig._();

  /// Base URL for API requests
  /// - Debug mode: 10.0.2.2:8080 for Android emulator, localhost:8080 for web and other platforms
  /// - Production mode: configurable via environment variable or default
  static String get baseUrl {
    if (kDebugMode) {
      // Development environment
      // Web always uses localhost
      if (kIsWeb) {
        return 'http://localhost:8080/wheel-of-time/api';
      }
      // Android emulator uses 10.0.2.2 to access host machine's localhost
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8080/wheel-of-time/api';
      }
      // For iOS simulator and other platforms, localhost works fine
      return 'http://localhost:8080/wheel-of-time/api';
    } else {
      // Production environment - this should be configured via environment variables
      // or a build configuration in a real production setup
      const String prodUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'https://t16software.dev/wheel-of-time/api');
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
