// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TaskListResponseImpl _$$TaskListResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$TaskListResponseImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      ownerId: (json['ownerId'] as num).toInt(),
      ownerName: json['ownerName'] as String,
      taskListImagePath: json['taskListImagePath'] as String?,
      taskCount: (json['taskCount'] as num?)?.toInt() ?? 0,
      activeTaskCount: (json['activeTaskCount'] as num?)?.toInt() ?? 0,
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$TaskListResponseImplToJson(
        _$TaskListResponseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'ownerId': instance.ownerId,
      'ownerName': instance.ownerName,
      'taskListImagePath': instance.taskListImagePath,
      'taskCount': instance.taskCount,
      'activeTaskCount': instance.activeTaskCount,
      'memberCount': instance.memberCount,
    };

_$CreateTaskListRequestImpl _$$CreateTaskListRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateTaskListRequestImpl(
      name: json['name'] as String,
      description: json['description'] as String?,
      taskListImageId: (json['taskListImageId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$CreateTaskListRequestImplToJson(
        _$CreateTaskListRequestImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'taskListImageId': instance.taskListImageId,
    };

_$UpdateTaskListRequestImpl _$$UpdateTaskListRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$UpdateTaskListRequestImpl(
      name: json['name'] as String?,
      description: json['description'] as String?,
      taskListImageId: (json['taskListImageId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$UpdateTaskListRequestImplToJson(
        _$UpdateTaskListRequestImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'taskListImageId': instance.taskListImageId,
    };
