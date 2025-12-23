// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_occurrence.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UpcomingTaskOccurrenceResponseImpl
    _$$UpcomingTaskOccurrenceResponseImplFromJson(Map<String, dynamic> json) =>
        _$UpcomingTaskOccurrenceResponseImpl(
          occurrenceId: json['occurrenceId'] as String,
          taskId: (json['taskId'] as num).toInt(),
          taskName: json['taskName'] as String,
          description: json['description'] as String?,
          taskListId: (json['taskListId'] as num).toInt(),
          taskListName: json['taskListName'] as String,
          dueDate: DateTime.parse(json['dueDate'] as String),
          alarmAtTimeOfDay: const LocalTimeConverter()
              .fromJson(json['alarmAtTimeOfDay'] as String?),
          completionWindowHours:
              (json['completionWindowHours'] as num?)?.toInt(),
          taskImagePath: json['taskImagePath'] as String?,
          totalCompletions: (json['totalCompletions'] as num?)?.toInt() ?? 0,
          currentStreak: json['currentStreak'] == null
              ? null
              : StreakResponse.fromJson(
                  json['currentStreak'] as Map<String, dynamic>),
          schedule: const TaskScheduleConverter()
              .fromJson(json['schedule'] as Map<String, dynamic>),
          occurrenceNumber: (json['occurrenceNumber'] as num?)?.toInt() ?? 1,
          isNextOccurrence: json['isNextOccurrence'] as bool? ?? false,
          taskListPrimaryColor: json['taskListPrimaryColor'] as String?,
          taskListSecondaryColor: json['taskListSecondaryColor'] as String?,
        );

Map<String, dynamic> _$$UpcomingTaskOccurrenceResponseImplToJson(
        _$UpcomingTaskOccurrenceResponseImpl instance) =>
    <String, dynamic>{
      'occurrenceId': instance.occurrenceId,
      'taskId': instance.taskId,
      'taskName': instance.taskName,
      'description': instance.description,
      'taskListId': instance.taskListId,
      'taskListName': instance.taskListName,
      'dueDate': instance.dueDate.toIso8601String(),
      'alarmAtTimeOfDay':
          const LocalTimeConverter().toJson(instance.alarmAtTimeOfDay),
      'completionWindowHours': instance.completionWindowHours,
      'taskImagePath': instance.taskImagePath,
      'totalCompletions': instance.totalCompletions,
      'currentStreak': instance.currentStreak,
      'schedule': const TaskScheduleConverter().toJson(instance.schedule),
      'occurrenceNumber': instance.occurrenceNumber,
      'isNextOccurrence': instance.isNextOccurrence,
      'taskListPrimaryColor': instance.taskListPrimaryColor,
      'taskListSecondaryColor': instance.taskListSecondaryColor,
    };
