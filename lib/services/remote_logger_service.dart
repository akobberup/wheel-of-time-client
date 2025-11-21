import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/log_entry.dart';
import '../config/api_config.dart';
import '../config/version_config.dart';

/// Service til remote logging af errors, events og bruger-tracking
///
/// Sender logs til backend API for central logging og monitoring
class RemoteLoggerService {
  final http.Client _client;
  String? _userId;

  RemoteLoggerService({http.Client? client})
      : _client = client ?? http.Client();

  /// Opdater bruger ID for logging context
  void setUserId(String? userId) {
    _userId = userId;
  }

  /// Log debug-besked (kun i development)
  Future<void> debug(
    String message, {
    String? category,
    Map<String, dynamic>? metadata,
  }) async {
    if (kDebugMode) {
      await _log(
        level: LogLevel.debug,
        message: message,
        category: category,
        metadata: metadata,
      );
    }
  }

  /// Log info-besked (generel tracking)
  Future<void> info(
    String message, {
    String? category,
    Map<String, dynamic>? metadata,
  }) async {
    await _log(
      level: LogLevel.info,
      message: message,
      category: category,
      metadata: metadata,
    );
  }

  /// Log warning (potentielle problemer)
  Future<void> warning(
    String message, {
    String? category,
    Map<String, dynamic>? metadata,
  }) async {
    await _log(
      level: LogLevel.warning,
      message: message,
      category: category,
      metadata: metadata,
    );
  }

  /// Log error med stack trace
  Future<void> error(
    String message, {
    String? category,
    Map<String, dynamic>? metadata,
    Object? error,
    StackTrace? stackTrace,
  }) async {
    await _log(
      level: LogLevel.error,
      message: message,
      category: category,
      metadata: metadata,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log bruger-event for tracking (login, logout, feature usage, etc.)
  Future<void> trackEvent(
    String eventName, {
    Map<String, dynamic>? properties,
  }) async {
    await info(
      eventName,
      category: 'user_tracking',
      metadata: properties,
    );
  }

  /// Intern metode til at sende log til backend
  Future<void> _log({
    required LogLevel level,
    required String message,
    String? category,
    Map<String, dynamic>? metadata,
    Object? error,
    StackTrace? stackTrace,
  }) async {
    try {
      final logEntry = LogEntry(
        level: level,
        message: message,
        timestamp: DateTime.now().toUtc().toIso8601String(),
        clientVersion: VersionConfig.version,
        userId: _userId,
        category: category,
        metadata: metadata,
        stackTrace: stackTrace?.toString(),
        errorType: error?.runtimeType.toString(),
      );

      // Log lokalt til console i development
      if (kDebugMode) {
        developer.log(
          message,
          name: 'RemoteLogger',
          error: error,
          stackTrace: stackTrace,
          level: _getDeveloperLogLevel(level),
        );
      }

      // Send til backend (fire-and-forget)
      _sendToBackend(logEntry);
    } catch (e) {
      // Fejl i logging må aldrig crashe appen
      developer.log(
        'Failed to log remotely: $e',
        name: 'RemoteLogger',
        error: e,
      );
    }
  }

  /// Send log entry til backend API (async, non-blocking)
  Future<void> _sendToBackend(LogEntry logEntry) async {
    try {
      final url = '${ApiConfig.baseUrl}/api/logs';
      final response = await _client
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(logEntry.toJson()),
          )
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => http.Response('Timeout', 408),
          );

      if (response.statusCode >= 400) {
        developer.log(
          'Failed to send log to backend: ${response.statusCode}',
          name: 'RemoteLogger',
        );
      }
    } catch (e) {
      // Ignorer fejl - logging må ikke crashe appen
      developer.log(
        'Error sending log to backend: $e',
        name: 'RemoteLogger',
      );
    }
  }

  /// Konverter LogLevel til developer log level
  int _getDeveloperLogLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500; // FINE
      case LogLevel.info:
        return 800; // INFO
      case LogLevel.warning:
        return 900; // WARNING
      case LogLevel.error:
        return 1000; // SEVERE
    }
  }

  /// Cleanup
  void dispose() {
    _client.close();
  }
}
