import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/log_queue_service.dart';

/// Provider for LogQueueService - singleton til hele app'en.
///
/// Ejer http.Client'en der bruges til log-afsendelse og lukker den ved dispose.
final logQueueProvider = Provider<LogQueueService>((ref) {
  final service = LogQueueService();
  ref.onDispose(service.dispose);
  return service;
});
