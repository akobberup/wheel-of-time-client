import 'package:freezed_annotation/freezed_annotation.dart';
import 'local_time.dart';
import 'streak.dart';
import 'schedule.dart';

part 'task.freezed.dart';
part 'task.g.dart';

/// JsonConverter for TaskSchedule to handle polymorphic serialization
class TaskScheduleConverter implements JsonConverter<TaskSchedule, Map<String, dynamic>> {
  const TaskScheduleConverter();

  @override
  TaskSchedule fromJson(Map<String, dynamic> json) => TaskSchedule.fromJson(json);

  @override
  Map<String, dynamic> toJson(TaskSchedule schedule) => schedule.toJson();
}

@freezed
class TaskResponse with _$TaskResponse {
  const factory TaskResponse({
    required int id,
    required String name,
    String? description,
    required int taskListId,
    required String taskListName,
    @TaskScheduleConverter() required TaskSchedule schedule,
    @LocalTimeConverter() LocalTime? alarmAtTimeOfDay,
    int? completionWindowHours,
    required DateTime firstRunDate,
    DateTime? nextDueDate,
    @Default(0) int sortOrder,
    @Default(true) bool isActive,
    String? taskImagePath,
    @Default(0) int totalCompletions,
    StreakResponse? currentStreak,
  }) = _TaskResponse;

  factory TaskResponse.fromJson(Map<String, dynamic> json) =>
      _$TaskResponseFromJson(json);
}

@freezed
class CreateTaskRequest with _$CreateTaskRequest {
  const factory CreateTaskRequest({
    required String name,
    String? description,
    required int taskListId,
    @TaskScheduleConverter() required TaskSchedule schedule,
    @LocalTimeConverter() LocalTime? alarmAtTimeOfDay,
    int? completionWindowHours,
    required DateTime firstRunDate,
    int? sortOrder,
    int? taskImageId,
  }) = _CreateTaskRequest;

  factory CreateTaskRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateTaskRequestFromJson(json);
}

@freezed
class UpdateTaskRequest with _$UpdateTaskRequest {
  const factory UpdateTaskRequest({
    String? name,
    String? description,
    @TaskScheduleConverter() TaskSchedule? schedule,
    @LocalTimeConverter() LocalTime? alarmAtTimeOfDay,
    int? completionWindowHours,
    int? sortOrder,
    bool? isActive,
    int? taskImageId,
  }) = _UpdateTaskRequest;

  factory UpdateTaskRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateTaskRequestFromJson(json);
}
