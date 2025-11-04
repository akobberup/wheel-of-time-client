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
          alarmAtTimeOfDay: json['alarmAtTimeOfDay'] == null
              ? null
              : LocalTime.fromJson(
                  json['alarmAtTimeOfDay'] as Map<String, dynamic>),
          completionWindowHours:
              (json['completionWindowHours'] as num?)?.toInt(),
          taskImagePath: json['taskImagePath'] as String?,
          totalCompletions: (json['totalCompletions'] as num?)?.toInt() ?? 0,
          currentStreak: json['currentStreak'] == null
              ? null
              : StreakResponse.fromJson(
                  json['currentStreak'] as Map<String, dynamic>),
          repeatUnit: $enumDecode(_$RepeatUnitEnumMap, json['repeatUnit']),
          repeatDelta: (json['repeatDelta'] as num).toInt(),
          occurrenceNumber: (json['occurrenceNumber'] as num?)?.toInt() ?? 1,
          isNextOccurrence: json['isNextOccurrence'] as bool? ?? false,
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
      'alarmAtTimeOfDay': instance.alarmAtTimeOfDay,
      'completionWindowHours': instance.completionWindowHours,
      'taskImagePath': instance.taskImagePath,
      'totalCompletions': instance.totalCompletions,
      'currentStreak': instance.currentStreak,
      'repeatUnit': instance.repeatUnit,
      'repeatDelta': instance.repeatDelta,
      'occurrenceNumber': instance.occurrenceNumber,
      'isNextOccurrence': instance.isNextOccurrence,
    };

const _$RepeatUnitEnumMap = {
  RepeatUnit.DAYS: 'DAYS',
  RepeatUnit.WEEKS: 'WEEKS',
  RepeatUnit.MONTHS: 'MONTHS',
  RepeatUnit.YEARS: 'YEARS',
};
