import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_instance.freezed.dart';
part 'task_instance.g.dart';

/// Status for a task instance in the timeline
enum TaskInstanceStatus {
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('EXPIRED')
  expired,
}

@freezed
class TaskInstanceResponse with _$TaskInstanceResponse {
  const factory TaskInstanceResponse({
    required int id,
    required int taskId,
    required String taskName,
    required int userId,
    required String userName,
    required DateTime completedDateTime,
    String? optionalImagePath,
    String? optionalComment,
    @Default(false) bool contributedToStreak,
    // Timeline view fields
    @Default(TaskInstanceStatus.completed) TaskInstanceStatus status,
    DateTime? dueDate,
  }) = _TaskInstanceResponse;

  factory TaskInstanceResponse.fromJson(Map<String, dynamic> json) =>
      _$TaskInstanceResponseFromJson(json);
}

@freezed
class CreateTaskInstanceRequest with _$CreateTaskInstanceRequest {
  const factory CreateTaskInstanceRequest({
    required int taskId,
    DateTime? completedDateTime,
    int? optionalImageId,
    String? optionalComment,
  }) = _CreateTaskInstanceRequest;

  factory CreateTaskInstanceRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateTaskInstanceRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => {
        'taskId': taskId,
        if (completedDateTime != null)
          'completedDateTime': completedDateTime!.toUtc().toIso8601String(),
        if (optionalImageId != null) 'optionalImageId': optionalImageId,
        if (optionalComment != null) 'optionalComment': optionalComment,
      };
}
