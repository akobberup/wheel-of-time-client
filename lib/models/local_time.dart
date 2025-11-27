import 'package:freezed_annotation/freezed_annotation.dart';

part 'local_time.freezed.dart';

@freezed
class LocalTime with _$LocalTime {
  const LocalTime._();

  const factory LocalTime({
    required int hour,
    required int minute,
    @Default(0) int second,
    @Default(0) int nano,
  }) = _LocalTime;

  /// Parser ISO-8601 tidsstreng som "09:30:00" eller "09:30"
  factory LocalTime.fromTimeString(String json) {
    final parts = json.split(':');
    return LocalTime(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
      second: parts.length > 2 ? int.parse(parts[2].split('.')[0]) : 0,
      nano: 0,
    );
  }

  /// Serialiserer til ISO-8601 tidsformat som Java's LocalTime forventer
  String toTimeString() {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    final s = second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  factory LocalTime.now() {
    final now = DateTime.now();
    return LocalTime(hour: now.hour, minute: now.minute);
  }

  factory LocalTime.fromTimeOfDay(int hour, int minute) {
    return LocalTime(hour: hour, minute: minute);
  }
}

/// JsonConverter til serialisering af LocalTime som ISO-8601 tidsstreng
class LocalTimeConverter implements JsonConverter<LocalTime?, String?> {
  const LocalTimeConverter();

  @override
  LocalTime? fromJson(String? json) =>
      json == null ? null : LocalTime.fromTimeString(json);

  @override
  String? toJson(LocalTime? object) => object?.toTimeString();
}

extension LocalTimeExtension on LocalTime {
  String toDisplayString() {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  DateTime toDateTime(DateTime date) {
    return DateTime(date.year, date.month, date.day, hour, minute, second);
  }
}


