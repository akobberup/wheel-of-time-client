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
      schedule: const TaskScheduleConverter()
          .fromJson(json['schedule'] as Map<String, dynamic>),
      alarmAtTimeOfDay: const LocalTimeConverter()
          .fromJson(json['alarmAtTimeOfDay'] as String?),
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
      scheduleFromCompletion: json['scheduleFromCompletion'] as bool? ?? false,
    );

Map<String, dynamic> _$$TaskResponseImplToJson(_$TaskResponseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'taskListId': instance.taskListId,
      'taskListName': instance.taskListName,
      'schedule': const TaskScheduleConverter().toJson(instance.schedule),
      'alarmAtTimeOfDay':
          const LocalTimeConverter().toJson(instance.alarmAtTimeOfDay),
      'completionWindowHours': instance.completionWindowHours,
      'firstRunDate': instance.firstRunDate.toIso8601String(),
      'nextDueDate': instance.nextDueDate?.toIso8601String(),
      'sortOrder': instance.sortOrder,
      'isActive': instance.isActive,
      'taskImagePath': instance.taskImagePath,
      'totalCompletions': instance.totalCompletions,
      'currentStreak': instance.currentStreak,
      'scheduleFromCompletion': instance.scheduleFromCompletion,
    };

_$CreateTaskRequestImpl _$$CreateTaskRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateTaskRequestImpl(
      name: json['name'] as String,
      description: json['description'] as String?,
      taskListId: (json['taskListId'] as num).toInt(),
      schedule: const TaskScheduleConverter()
          .fromJson(json['schedule'] as Map<String, dynamic>),
      alarmAtTimeOfDay: const LocalTimeConverter()
          .fromJson(json['alarmAtTimeOfDay'] as String?),
      completionWindowHours: (json['completionWindowHours'] as num?)?.toInt(),
      firstRunDate: DateTime.parse(json['firstRunDate'] as String),
      sortOrder: (json['sortOrder'] as num?)?.toInt(),
      taskImageId: (json['taskImageId'] as num?)?.toInt(),
      scheduleFromCompletion: json['scheduleFromCompletion'] as bool?,
    );

Map<String, dynamic> _$$CreateTaskRequestImplToJson(
        _$CreateTaskRequestImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'taskListId': instance.taskListId,
      'schedule': const TaskScheduleConverter().toJson(instance.schedule),
      'alarmAtTimeOfDay':
          const LocalTimeConverter().toJson(instance.alarmAtTimeOfDay),
      'completionWindowHours': instance.completionWindowHours,
      'firstRunDate': instance.firstRunDate.toIso8601String(),
      'sortOrder': instance.sortOrder,
      'taskImageId': instance.taskImageId,
      'scheduleFromCompletion': instance.scheduleFromCompletion,
    };

_$UpdateTaskRequestImpl _$$UpdateTaskRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$UpdateTaskRequestImpl(
      name: json['name'] as String?,
      description: json['description'] as String?,
      schedule: _$JsonConverterFromJson<Map<String, dynamic>, TaskSchedule>(
          json['schedule'], const TaskScheduleConverter().fromJson),
      alarmAtTimeOfDay: const LocalTimeConverter()
          .fromJson(json['alarmAtTimeOfDay'] as String?),
      completionWindowHours: (json['completionWindowHours'] as num?)?.toInt(),
      sortOrder: (json['sortOrder'] as num?)?.toInt(),
      isActive: json['isActive'] as bool?,
      taskImageId: (json['taskImageId'] as num?)?.toInt(),
      scheduleFromCompletion: json['scheduleFromCompletion'] as bool?,
    );

Map<String, dynamic> _$$UpdateTaskRequestImplToJson(
        _$UpdateTaskRequestImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'schedule': _$JsonConverterToJson<Map<String, dynamic>, TaskSchedule>(
          instance.schedule, const TaskScheduleConverter().toJson),
      'alarmAtTimeOfDay':
          const LocalTimeConverter().toJson(instance.alarmAtTimeOfDay),
      'completionWindowHours': instance.completionWindowHours,
      'sortOrder': instance.sortOrder,
      'isActive': instance.isActive,
      'taskImageId': instance.taskImageId,
      'scheduleFromCompletion': instance.scheduleFromCompletion,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
