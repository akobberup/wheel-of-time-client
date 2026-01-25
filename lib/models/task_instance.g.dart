// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_instance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TaskInstanceResponseImpl _$$TaskInstanceResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$TaskInstanceResponseImpl(
      id: (json['id'] as num).toInt(),
      taskId: (json['taskId'] as num).toInt(),
      taskName: json['taskName'] as String,
      userId: (json['userId'] as num?)?.toInt(),
      userName: json['userName'] as String?,
      completedDateTime: json['completedDateTime'] == null
          ? null
          : DateTime.parse(json['completedDateTime'] as String),
      dismissedDateTime: json['dismissedDateTime'] == null
          ? null
          : DateTime.parse(json['dismissedDateTime'] as String),
      optionalImagePath: json['optionalImagePath'] as String?,
      optionalComment: json['optionalComment'] as String?,
      contributedToStreak: json['contributedToStreak'] as bool? ?? false,
      status:
          $enumDecodeNullable(_$TaskInstanceStatusEnumMap, json['status']) ??
              TaskInstanceStatus.completed,
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
    );

Map<String, dynamic> _$$TaskInstanceResponseImplToJson(
        _$TaskInstanceResponseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'taskId': instance.taskId,
      'taskName': instance.taskName,
      'userId': instance.userId,
      'userName': instance.userName,
      'completedDateTime': instance.completedDateTime?.toIso8601String(),
      'dismissedDateTime': instance.dismissedDateTime?.toIso8601String(),
      'optionalImagePath': instance.optionalImagePath,
      'optionalComment': instance.optionalComment,
      'contributedToStreak': instance.contributedToStreak,
      'status': _$TaskInstanceStatusEnumMap[instance.status]!,
      'dueDate': instance.dueDate?.toIso8601String(),
    };

const _$TaskInstanceStatusEnumMap = {
  TaskInstanceStatus.pending: 'PENDING',
  TaskInstanceStatus.completed: 'COMPLETED',
  TaskInstanceStatus.expired: 'EXPIRED',
  TaskInstanceStatus.dismissed: 'DISMISSED',
};

_$CreateTaskInstanceRequestImpl _$$CreateTaskInstanceRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateTaskInstanceRequestImpl(
      taskId: (json['taskId'] as num).toInt(),
      completedDateTime: json['completedDateTime'] == null
          ? null
          : DateTime.parse(json['completedDateTime'] as String),
      optionalImageId: (json['optionalImageId'] as num?)?.toInt(),
      optionalComment: json['optionalComment'] as String?,
    );

Map<String, dynamic> _$$CreateTaskInstanceRequestImplToJson(
        _$CreateTaskInstanceRequestImpl instance) =>
    <String, dynamic>{
      'taskId': instance.taskId,
      'completedDateTime': instance.completedDateTime?.toIso8601String(),
      'optionalImageId': instance.optionalImageId,
      'optionalComment': instance.optionalComment,
    };
