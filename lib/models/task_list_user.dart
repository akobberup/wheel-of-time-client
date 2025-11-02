import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';

part 'task_list_user.freezed.dart';
part 'task_list_user.g.dart';

@freezed
class TaskListUserResponse with _$TaskListUserResponse {
  const factory TaskListUserResponse({
    required int id,
    required int taskListId,
    required String taskListName,
    required int userId,
    required String userName,
    required String userEmail,
    required AdminLevel userAdminLevel,
    required DateTime addedDate,
    required String addedByUserName,
  }) = _TaskListUserResponse;

  factory TaskListUserResponse.fromJson(Map<String, dynamic> json) =>
      _$TaskListUserResponseFromJson(json);
}
