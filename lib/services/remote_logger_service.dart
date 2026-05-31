import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../models/log_entry.dart';
import '../config/version_config.dart';
import 'log_queue_service.dart';

/// Service til remote logging af errors, events og bruger-tracking
///
/// WARNING/ERROR lægges i en persistent retry-kø ([LogQueueService.enqueue]) så
/// de overlever nedetid (fx en deploy) og sendes når backenden er tilbage.
/// INFO/DEBUG/analytics sendes fire-and-forget ([LogQueueService.sendImmediate])
/// da tab af dem ved nedetid er ligegyldigt.
class RemoteLoggerService {
  final LogQueueService _logQueue;
  String? _userId;

  RemoteLoggerService({required LogQueueService logQueue})
      : _logQueue = logQueue;

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

      // WARNING/ERROR persisteres med retry så de overlever nedetid;
      // resten sendes fire-and-forget.
      if (level == LogLevel.warning || level == LogLevel.error) {
        await _logQueue.enqueue(logEntry);
      } else {
        _logQueue.sendImmediate(logEntry);
      }
    } catch (e) {
      // Fejl i logging må aldrig crashe appen
      developer.log(
        'Failed to log remotely: $e',
        name: 'RemoteLogger',
        error: e,
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

  /// Cleanup. Selve netværks-klienten ejes og lukkes af [LogQueueService].
  void dispose() {}
}
