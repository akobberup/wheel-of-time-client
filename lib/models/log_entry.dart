import 'package:freezed_annotation/freezed_annotation.dart';

part 'log_entry.freezed.dart';
part 'log_entry.g.dart';

/// Log-niveauer til remote logging
enum LogLevel {
  @JsonValue('DEBUG')
  debug,
  @JsonValue('INFO')
  info,
  @JsonValue('WARNING')
  warning,
  @JsonValue('ERROR')
  error,
}

/// Remote log entry der sendes til backend
@freezed
class LogEntry with _$LogEntry {
  const factory LogEntry({
    required LogLevel level,
    required String message,
    required String timestamp,
    required String version,
    String? userId,
    String? category,
    Map<String, dynamic>? metadata,
    String? stackTrace,
    String? errorType,
  }) = _LogEntry;

  factory LogEntry.fromJson(Map<String, dynamic> json) =>
      _$LogEntryFromJson(json);
}
