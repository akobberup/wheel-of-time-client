import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';
import 'local_time.dart';
import 'streak.dart';

part 'task.freezed.dart';
part 'task.g.dart';

@freezed
class TaskResponse with _$TaskResponse {
  const factory TaskResponse({
    required int id,
    required String name,
    String? description,
    required int taskListId,
    required String taskListName,
    required RepeatUnit repeatUnit,
    required int repeatDelta,
    LocalTime? alarmAtTimeOfDay,
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
    required RepeatUnit repeatUnit,
    required int repeatDelta,
    LocalTime? alarmAtTimeOfDay,
    int? completionWindowHours,
    required DateTime firstRunDate,
    int? sortOrder,
    int? taskImageId,
  }) = _CreateTaskRequest;

  factory CreateTaskRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateTaskRequestFromJson(json);

  Map<String, dynamic> toJson() => {
        'name': name,
        if (description != null) 'description': description,
        'taskListId': taskListId,
        'repeatUnit': repeatUnit.toJson(),
        'repeatDelta': repeatDelta,
        if (alarmAtTimeOfDay != null)
          'alarmAtTimeOfDay': alarmAtTimeOfDay!.toJson(),
        if (completionWindowHours != null)
          'completionWindowHours': completionWindowHours,
        'firstRunDate': firstRunDate.toIso8601String().split('T')[0],
        if (sortOrder != null) 'sortOrder': sortOrder,
        if (taskImageId != null) 'taskImageId': taskImageId,
      };
}

@freezed
class UpdateTaskRequest with _$UpdateTaskRequest {
  const factory UpdateTaskRequest({
    String? name,
    String? description,
    RepeatUnit? repeatUnit,
    int? repeatDelta,
    LocalTime? alarmAtTimeOfDay,
    int? completionWindowHours,
    int? sortOrder,
    bool? isActive,
    int? taskImageId,
  }) = _UpdateTaskRequest;

  factory UpdateTaskRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateTaskRequestFromJson(json);

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (repeatUnit != null) 'repeatUnit': repeatUnit!.toJson(),
        if (repeatDelta != null) 'repeatDelta': repeatDelta,
        if (alarmAtTimeOfDay != null)
          'alarmAtTimeOfDay': alarmAtTimeOfDay!.toJson(),
        if (completionWindowHours != null)
          'completionWindowHours': completionWindowHours,
        if (sortOrder != null) 'sortOrder': sortOrder,
        if (isActive != null) 'isActive': isActive,
        if (taskImageId != null) 'taskImageId': taskImageId,
      };
}
