import 'package:freezed_annotation/freezed_annotation.dart';

part 'local_time.freezed.dart';
part 'local_time.g.dart';

@freezed
class LocalTime with _$LocalTime {
  const factory LocalTime({
    required int hour,
    required int minute,
    @Default(0) int second,
    @Default(0) int nano,
  }) = _LocalTime;

  factory LocalTime.fromJson(Map<String, dynamic> json) =>
      _$LocalTimeFromJson(json);

  factory LocalTime.now() {
    final now = DateTime.now();
    return LocalTime(hour: now.hour, minute: now.minute);
  }

  factory LocalTime.fromTimeOfDay(int hour, int minute) {
    return LocalTime(hour: hour, minute: minute);
  }
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
