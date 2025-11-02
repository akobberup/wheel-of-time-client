// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TaskResponseImpl _$$TaskResponseImplFromJson(Map<String, dynamic> json) =>
    _$TaskResponseImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      taskListId: (json['taskListId'] as num).toInt(),
      taskListName: json['taskListName'] as String,
      repeatUnit: $enumDecode(_$RepeatUnitEnumMap, json['repeatUnit']),
      repeatDelta: (json['repeatDelta'] as num).toInt(),
      alarmAtTimeOfDay: json['alarmAtTimeOfDay'] == null
          ? null
          : LocalTime.fromJson(
              json['alarmAtTimeOfDay'] as Map<String, dynamic>),
      completionWindowHours: (json['completionWindowHours'] as num?)?.toInt(),
      firstRunDate: DateTime.parse(json['firstRunDate'] as String),
      nextDueDate: json['nextDueDate'] == null
          ? null
          : DateTime.parse(json['nextDueDate'] as String),
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      taskImagePath: json['taskImagePath'] as String?,
      totalCompletions: (json['totalCompletions'] as num?)?.toInt() ?? 0,
      currentStreak: json['currentStreak'] == null
          ? null
          : StreakResponse.fromJson(
              json['currentStreak'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$TaskResponseImplToJson(_$TaskResponseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'taskListId': instance.taskListId,
      'taskListName': instance.taskListName,
      'repeatUnit': instance.repeatUnit,
      'repeatDelta': instance.repeatDelta,
      'alarmAtTimeOfDay': instance.alarmAtTimeOfDay,
      'completionWindowHours': instance.completionWindowHours,
      'firstRunDate': instance.firstRunDate.toIso8601String(),
      'nextDueDate': instance.nextDueDate?.toIso8601String(),
      'sortOrder': instance.sortOrder,
      'isActive': instance.isActive,
      'taskImagePath': instance.taskImagePath,
      'totalCompletions': instance.totalCompletions,
      'currentStreak': instance.currentStreak,
    };

const _$RepeatUnitEnumMap = {
  RepeatUnit.DAYS: 'DAYS',
  RepeatUnit.WEEKS: 'WEEKS',
  RepeatUnit.MONTHS: 'MONTHS',
  RepeatUnit.YEARS: 'YEARS',
};

_$CreateTaskRequestImpl _$$CreateTaskRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateTaskRequestImpl(
      name: json['name'] as String,
      description: json['description'] as String?,
      taskListId: (json['taskListId'] as num).toInt(),
      repeatUnit: $enumDecode(_$RepeatUnitEnumMap, json['repeatUnit']),
      repeatDelta: (json['repeatDelta'] as num).toInt(),
      alarmAtTimeOfDay: json['alarmAtTimeOfDay'] == null
          ? null
          : LocalTime.fromJson(
              json['alarmAtTimeOfDay'] as Map<String, dynamic>),
      completionWindowHours: (json['completionWindowHours'] as num?)?.toInt(),
      firstRunDate: DateTime.parse(json['firstRunDate'] as String),
      sortOrder: (json['sortOrder'] as num?)?.toInt(),
      taskImageId: (json['taskImageId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$CreateTaskRequestImplToJson(
        _$CreateTaskRequestImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'taskListId': instance.taskListId,
      'repeatUnit': instance.repeatUnit,
      'repeatDelta': instance.repeatDelta,
      'alarmAtTimeOfDay': instance.alarmAtTimeOfDay,
      'completionWindowHours': instance.completionWindowHours,
      'firstRunDate': instance.firstRunDate.toIso8601String(),
      'sortOrder': instance.sortOrder,
      'taskImageId': instance.taskImageId,
    };

_$UpdateTaskRequestImpl _$$UpdateTaskRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$UpdateTaskRequestImpl(
      name: json['name'] as String?,
      description: json['description'] as String?,
      repeatUnit: $enumDecodeNullable(_$RepeatUnitEnumMap, json['repeatUnit']),
      repeatDelta: (json['repeatDelta'] as num?)?.toInt(),
      alarmAtTimeOfDay: json['alarmAtTimeOfDay'] == null
          ? null
          : LocalTime.fromJson(
              json['alarmAtTimeOfDay'] as Map<String, dynamic>),
      completionWindowHours: (json['completionWindowHours'] as num?)?.toInt(),
      sortOrder: (json['sortOrder'] as num?)?.toInt(),
      isActive: json['isActive'] as bool?,
      taskImageId: (json['taskImageId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$UpdateTaskRequestImplToJson(
        _$UpdateTaskRequestImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'repeatUnit': instance.repeatUnit,
      'repeatDelta': instance.repeatDelta,
      'alarmAtTimeOfDay': instance.alarmAtTimeOfDay,
      'completionWindowHours': instance.completionWindowHours,
      'sortOrder': instance.sortOrder,
      'isActive': instance.isActive,
      'taskImageId': instance.taskImageId,
    };
