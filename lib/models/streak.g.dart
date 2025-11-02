// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StreakResponseImpl _$$StreakResponseImplFromJson(Map<String, dynamic> json) =>
    _$StreakResponseImpl(
      id: (json['id'] as num).toInt(),
      taskId: (json['taskId'] as num).toInt(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      isActive: json['isActive'] as bool? ?? true,
      streakCount: (json['streakCount'] as num?)?.toInt() ?? 0,
      instanceCount: (json['instanceCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$StreakResponseImplToJson(
        _$StreakResponseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'taskId': instance.taskId,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'isActive': instance.isActive,
      'streakCount': instance.streakCount,
      'instanceCount': instance.instanceCount,
    };
