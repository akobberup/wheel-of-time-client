import 'package:freezed_annotation/freezed_annotation.dart';
import 'visual_theme.dart';

part 'task_list.freezed.dart';
part 'task_list.g.dart';

@freezed
class TaskListResponse with _$TaskListResponse {
  const factory TaskListResponse({
    required int id,
    required String name,
    String? description,
    required int ownerId,
    required String ownerName,
    required VisualThemeResponse visualTheme,
    @Default(0) int taskCount,
    @Default(0) int activeTaskCount,
    @Default(0) int memberCount,
  }) = _TaskListResponse;

  factory TaskListResponse.fromJson(Map<String, dynamic> json) =>
      _$TaskListResponseFromJson(json);
}

@freezed
class CreateTaskListRequest with _$CreateTaskListRequest {
  const factory CreateTaskListRequest({
    required String name,
    String? description,
    int? visualThemeId,
  }) = _CreateTaskListRequest;

  factory CreateTaskListRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateTaskListRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => {
        'name': name,
        if (description != null) 'description': description,
        if (visualThemeId != null) 'visualThemeId': visualThemeId,
      };
}

@freezed
class UpdateTaskListRequest with _$UpdateTaskListRequest {
  const factory UpdateTaskListRequest({
    String? name,
    String? description,
    int? visualThemeId,
  }) = _UpdateTaskListRequest;

  factory UpdateTaskListRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateTaskListRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (visualThemeId != null) 'visualThemeId': visualThemeId,
      };
}
