// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vacation_period.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VacationPeriodResponseImpl _$$VacationPeriodResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$VacationPeriodResponseImpl(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      name: json['name'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
    );

Map<String, dynamic> _$$VacationPeriodResponseImplToJson(
        _$VacationPeriodResponseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
    };

_$CreateVacationPeriodRequestImpl _$$CreateVacationPeriodRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateVacationPeriodRequestImpl(
      name: json['name'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
    );

Map<String, dynamic> _$$CreateVacationPeriodRequestImplToJson(
        _$CreateVacationPeriodRequestImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
    };

_$UpdateVacationPeriodRequestImpl _$$UpdateVacationPeriodRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$UpdateVacationPeriodRequestImpl(
      name: json['name'] as String?,
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
    );

Map<String, dynamic> _$$UpdateVacationPeriodRequestImplToJson(
        _$UpdateVacationPeriodRequestImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
    };
