import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/remote_logger_service.dart';

/// Provider for RemoteLoggerService singleton
final remoteLoggerProvider = Provider<RemoteLoggerService>((ref) {
  return RemoteLoggerService();
});
