import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';

part 'schedule.freezed.dart';

/// Base class for task schedules using freezed unions
/// Matches the polymorphic structure from the backend
@freezed
class TaskSchedule with _$TaskSchedule {
  /// Interval-based schedule: "Every X days/weeks/months/years"
  const factory TaskSchedule.interval({
    required RepeatUnit repeatUnit,
    required int repeatDelta,
    required String description,
    /// Active months for seasonal scheduling. Null or empty means year-round.
    Set<Month>? activeMonths,
  }) = IntervalSchedule;

  /// Weekly pattern schedule: "Weekly on specific days"
  const factory TaskSchedule.weeklyPattern({
    required int repeatWeeks,
    required Set<DayOfWeek> daysOfWeek,
    required String description,
    /// Active months for seasonal scheduling. Null or empty means year-round.
    Set<Month>? activeMonths,
  }) = WeeklyPatternSchedule;

  factory TaskSchedule.fromJson(Map<String, dynamic> json) {
    // Jackson polymorphism uses 'type' field to discriminate
    final type = json['type'] as String?;

    // Parse activeMonths if present
    Set<Month>? activeMonths;
    if (json['activeMonths'] != null) {
      activeMonths = (json['activeMonths'] as List<dynamic>)
          .map((e) => Month.fromJson(e as String))
          .toSet();
    }

    switch (type) {
      case 'INTERVAL':
        return TaskSchedule.interval(
          repeatUnit: RepeatUnit.fromJson(json['repeatUnit'] as String),
          repeatDelta: json['repeatDelta'] as int,
          description: json['description'] as String,
          activeMonths: activeMonths,
        );
      case 'WEEKLY_PATTERN':
        return TaskSchedule.weeklyPattern(
          repeatWeeks: json['repeatWeeks'] as int,
          daysOfWeek: (json['daysOfWeek'] as List<dynamic>)
              .map((e) => DayOfWeek.fromJson(e as String))
              .toSet(),
          description: json['description'] as String,
          activeMonths: activeMonths,
        );
      default:
        throw ArgumentError('Unknown schedule type: $type');
    }
  }
}

/// Extension to convert TaskSchedule to JSON
/// Matches backend Jackson format with type discriminator
extension TaskScheduleToJson on TaskSchedule {
  Map<String, dynamic> toJson() {
    return when(
      interval: (repeatUnit, repeatDelta, description, activeMonths) => {
        'type': 'INTERVAL',
        'repeatUnit': repeatUnit.toJson(),
        'repeatDelta': repeatDelta,
        'description': description,
        if (activeMonths != null && activeMonths.isNotEmpty)
          'activeMonths': activeMonths.map((m) => m.toJson()).toList(),
      },
      weeklyPattern: (repeatWeeks, daysOfWeek, description, activeMonths) => {
        'type': 'WEEKLY_PATTERN',
        'repeatWeeks': repeatWeeks,
        'daysOfWeek': daysOfWeek.map((d) => d.toJson()).toList(),
        'description': description,
        if (activeMonths != null && activeMonths.isNotEmpty)
          'activeMonths': activeMonths.map((m) => m.toJson()).toList(),
      },
    );
  }

  /// Returns true if this schedule has seasonal restrictions
  bool get isSeasonal {
    return when(
      interval: (_, __, ___, activeMonths) =>
          activeMonths != null && activeMonths.isNotEmpty,
      weeklyPattern: (_, __, ___, activeMonths) =>
          activeMonths != null && activeMonths.isNotEmpty,
    );
  }

  /// Returns the active months, or null if year-round
  Set<Month>? get activeMonths {
    return when(
      interval: (_, __, ___, activeMonths) => activeMonths,
      weeklyPattern: (_, __, ___, activeMonths) => activeMonths,
    );
  }
}
