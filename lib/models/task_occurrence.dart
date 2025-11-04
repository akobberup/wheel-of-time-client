import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';
import 'local_time.dart';
import 'streak.dart';

part 'task_occurrence.freezed.dart';
part 'task_occurrence.g.dart';

/// Represents a specific future occurrence of a recurring task.
/// Each occurrence has a unique combination of taskId and dueDate.
@freezed
class UpcomingTaskOccurrenceResponse with _$UpcomingTaskOccurrenceResponse {
  const factory UpcomingTaskOccurrenceResponse({
    required String occurrenceId,
    required int taskId,
    required String taskName,
    String? description,
    required int taskListId,
    required String taskListName,
    required DateTime dueDate,
    LocalTime? alarmAtTimeOfDay,
    int? completionWindowHours,
    String? taskImagePath,
    @Default(0) int totalCompletions,
    StreakResponse? currentStreak,
    required RepeatUnit repeatUnit,
    required int repeatDelta,
    @Default(1) int occurrenceNumber,
    @Default(false) bool isNextOccurrence,
  }) = _UpcomingTaskOccurrenceResponse;

  factory UpcomingTaskOccurrenceResponse.fromJson(
          Map<String, dynamic> json) =>
      _$UpcomingTaskOccurrenceResponseFromJson(json);
}
