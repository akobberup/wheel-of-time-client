// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_time.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LocalTimeImpl _$$LocalTimeImplFromJson(Map<String, dynamic> json) =>
    _$LocalTimeImpl(
      hour: (json['hour'] as num).toInt(),
      minute: (json['minute'] as num).toInt(),
      second: (json['second'] as num?)?.toInt() ?? 0,
      nano: (json['nano'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$LocalTimeImplToJson(_$LocalTimeImpl instance) =>
    <String, dynamic>{
      'hour': instance.hour,
      'minute': instance.minute,
      'second': instance.second,
      'nano': instance.nano,
    };
