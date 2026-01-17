import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

/// Configuration for API endpoints based on environment
class ApiConfig {
  // Private constructor to prevent instantiation
  ApiConfig._();

  /// Base URL for API requests
  /// - Debug mode: Configurable via DEV_HOST env var, defaults to 10.0.2.2 for emulator
  /// - Production mode: configurable via environment variable or default
  ///
  /// For physical Android device testing, run with:
  /// flutter run --dart-define=DEV_HOST=192.168.x.x (your computer's IP)
  static String get baseUrl {
    if (kDebugMode) {
      // Development environment
      // Check for custom dev host (useful for physical device testing)
      const String devHost = String.fromEnvironment('DEV_HOST', defaultValue: '');

      if (devHost.isNotEmpty) {
        return 'http://$devHost:8080/aarshjulet';
      }

      // Web always uses localhost
      if (kIsWeb) {
        return 'http://localhost:8080/aarshjulet';
      }
      // Android emulator uses 10.0.2.2 to access host machine's localhost
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8080/aarshjulet';
      }
      // For iOS simulator and other platforms, localhost works fine
      return 'http://localhost:8080/aarshjulet';
    } else {
      // Production environment - this should be configured via environment variables
      // or a build configuration in a real production setup
      const String prodUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'https://t16software.dev/aarshjulet');
      return prodUrl;
    }
  }

  /// Gets the full URL for an image path
  ///
  /// Hvis stien allerede er en fuld URL (starter med http:// eller https://),
  /// returneres den uændret. Ellers tilføjes baseUrl.
  ///
  /// Example:
  /// ```dart
  /// ApiConfig.getImageUrl('/images/task-icon.png')
  /// // Returns: 'http://localhost:8080/images/task-icon.png' (in debug)
  /// ApiConfig.getImageUrl('http://example.com/image.png')
  /// // Returns: 'http://example.com/image.png' (unchanged)
  /// ```
  static String getImageUrl(String path) {
    // Hvis stien allerede er en fuld URL, returner den direkte
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    // Ellers tilføj baseUrl
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
