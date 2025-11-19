// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LogEntryImpl _$$LogEntryImplFromJson(Map<String, dynamic> json) =>
    _$LogEntryImpl(
      level: $enumDecode(_$LogLevelEnumMap, json['level']),
      message: json['message'] as String,
      timestamp: json['timestamp'] as String,
      clientVersion: json['clientVersion'] as String,
      userId: json['userId'] as String?,
      category: json['category'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      stackTrace: json['stackTrace'] as String?,
      errorType: json['errorType'] as String?,
    );

Map<String, dynamic> _$$LogEntryImplToJson(_$LogEntryImpl instance) =>
    <String, dynamic>{
      'level': _$LogLevelEnumMap[instance.level]!,
      'message': instance.message,
      'timestamp': instance.timestamp,
      'clientVersion': instance.clientVersion,
      'userId': instance.userId,
      'category': instance.category,
      'metadata': instance.metadata,
      'stackTrace': instance.stackTrace,
      'errorType': instance.errorType,
    };

const _$LogLevelEnumMap = {
  LogLevel.debug: 'DEBUG',
  LogLevel.info: 'INFO',
  LogLevel.warning: 'WARNING',
  LogLevel.error: 'ERROR',
};
