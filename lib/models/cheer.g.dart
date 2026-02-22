// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cheer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CheerResponseImpl _$$CheerResponseImplFromJson(Map<String, dynamic> json) =>
    _$CheerResponseImpl(
      id: (json['id'] as num).toInt(),
      taskInstanceId: (json['taskInstanceId'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      userName: json['userName'] as String,
      emoji: json['emoji'] as String,
      message: json['message'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$CheerResponseImplToJson(_$CheerResponseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'taskInstanceId': instance.taskInstanceId,
      'userId': instance.userId,
      'userName': instance.userName,
      'emoji': instance.emoji,
      'message': instance.message,
      'createdAt': instance.createdAt.toIso8601String(),
    };
