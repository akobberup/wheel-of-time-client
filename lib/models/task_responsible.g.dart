// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_responsible.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TaskResponsibleResponseImpl _$$TaskResponsibleResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$TaskResponsibleResponseImpl(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      userName: json['userName'] as String,
      userEmail: json['userEmail'] as String,
      sortOrder: (json['sortOrder'] as num).toInt(),
    );

Map<String, dynamic> _$$TaskResponsibleResponseImplToJson(
        _$TaskResponsibleResponseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userName': instance.userName,
      'userEmail': instance.userEmail,
      'sortOrder': instance.sortOrder,
    };

_$TaskResponsibleConfigResponseImpl
    _$$TaskResponsibleConfigResponseImplFromJson(Map<String, dynamic> json) =>
        _$TaskResponsibleConfigResponseImpl(
          id: (json['id'] as num).toInt(),
          taskId: (json['taskId'] as num).toInt(),
          strategy: $enumDecode(_$ResponsibleStrategyEnumMap, json['strategy']),
          currentRotationIndex: (json['currentRotationIndex'] as num?)?.toInt(),
          responsibles: (json['responsibles'] as List<dynamic>?)
                  ?.map((e) => TaskResponsibleResponse.fromJson(
                      e as Map<String, dynamic>))
                  .toList() ??
              const [],
        );

Map<String, dynamic> _$$TaskResponsibleConfigResponseImplToJson(
        _$TaskResponsibleConfigResponseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'taskId': instance.taskId,
      'strategy': _$ResponsibleStrategyEnumMap[instance.strategy]!,
      'currentRotationIndex': instance.currentRotationIndex,
      'responsibles': instance.responsibles,
    };

const _$ResponsibleStrategyEnumMap = {
  ResponsibleStrategy.all: 'ALL',
  ResponsibleStrategy.fixedPerson: 'FIXED_PERSON',
  ResponsibleStrategy.roundRobin: 'ROUND_ROBIN',
};

_$TaskResponsibleConfigRequestImpl _$$TaskResponsibleConfigRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$TaskResponsibleConfigRequestImpl(
      strategy: $enumDecode(_$ResponsibleStrategyEnumMap, json['strategy']),
      responsibleUserIds: (json['responsibleUserIds'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$TaskResponsibleConfigRequestImplToJson(
        _$TaskResponsibleConfigRequestImpl instance) =>
    <String, dynamic>{
      'strategy': _$ResponsibleStrategyEnumMap[instance.strategy]!,
      'responsibleUserIds': instance.responsibleUserIds,
    };
