import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/remote_logger_service.dart';
import 'log_queue_provider.dart';

/// Provider for RemoteLoggerService singleton.
///
/// Bygger på [logQueueProvider] som ejer netværks-klienten og den persistente kø.
final remoteLoggerProvider = Provider<RemoteLoggerService>((ref) {
  final queue = ref.watch(logQueueProvider);
  return RemoteLoggerService(logQueue: queue);
});
