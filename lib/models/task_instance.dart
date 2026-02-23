import 'package:freezed_annotation/freezed_annotation.dart';
import 'cheer.dart';

part 'task_instance.freezed.dart';
part 'task_instance.g.dart';

/// Status for a task instance in the timeline
enum TaskInstanceStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('EXPIRED')
  expired,
  @JsonValue('DISMISSED')
  dismissed,
}

@freezed
class TaskInstanceResponse with _$TaskInstanceResponse {
  const factory TaskInstanceResponse({
    required int id,
    required int taskId,
    int? taskListId,
    required String taskName,
    // userId og userName kan være null for EXPIRED/DISMISSED instances
    int? userId,
    String? userName,
    // completedDateTime kan være null for PENDING/DISMISSED instances
    DateTime? completedDateTime,
    DateTime? dismissedDateTime,
    String? optionalImagePath,
    String? optionalComment,
    @Default(false) bool contributedToStreak,
    // Timeline view fields
    @Default(TaskInstanceStatus.completed) TaskInstanceStatus status,
    DateTime? dueDate,
    @Default([]) List<CheerResponse> cheers,
  }) = _TaskInstanceResponse;

  factory TaskInstanceResponse.fromJson(Map<String, dynamic> json) =>
      _$TaskInstanceResponseFromJson(json);
}

@freezed
class RetroactiveCompleteRequest with _$RetroactiveCompleteRequest {
  const factory RetroactiveCompleteRequest({
    required int completedByUserId,
    String? optionalComment,
    int? optionalImageId,
  }) = _RetroactiveCompleteRequest;

  factory RetroactiveCompleteRequest.fromJson(Map<String, dynamic> json) =>
      _$RetroactiveCompleteRequestFromJson(json);
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
