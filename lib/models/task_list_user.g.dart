// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_list_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TaskListUserResponseImpl _$$TaskListUserResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$TaskListUserResponseImpl(
      id: (json['id'] as num).toInt(),
      taskListId: (json['taskListId'] as num).toInt(),
      taskListName: json['taskListName'] as String,
      userId: (json['userId'] as num).toInt(),
      userName: json['userName'] as String,
      userEmail: json['userEmail'] as String,
      userAdminLevel: $enumDecode(_$AdminLevelEnumMap, json['userAdminLevel']),
      addedDate: DateTime.parse(json['addedDate'] as String),
      addedByUserName: json['addedByUserName'] as String,
    );

Map<String, dynamic> _$$TaskListUserResponseImplToJson(
        _$TaskListUserResponseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'taskListId': instance.taskListId,
      'taskListName': instance.taskListName,
      'userId': instance.userId,
      'userName': instance.userName,
      'userEmail': instance.userEmail,
      'userAdminLevel': instance.userAdminLevel,
      'addedDate': instance.addedDate.toIso8601String(),
      'addedByUserName': instance.addedByUserName,
    };

const _$AdminLevelEnumMap = {
  AdminLevel.CAN_EDIT: 'CAN_EDIT',
  AdminLevel.CAN_VIEW: 'CAN_VIEW',
};
