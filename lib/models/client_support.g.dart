// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_support.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ClientSupportResponseImpl _$$ClientSupportResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$ClientSupportResponseImpl(
      status: $enumDecode(_$ClientSupportStatusEnumMap, json['status']),
      currentVersion: json['currentVersion'] as String,
      minimumSupportedVersion: json['minimumSupportedVersion'] as String,
      latestVersion: json['latestVersion'] as String,
    );

Map<String, dynamic> _$$ClientSupportResponseImplToJson(
        _$ClientSupportResponseImpl instance) =>
    <String, dynamic>{
      'status': _$ClientSupportStatusEnumMap[instance.status]!,
      'currentVersion': instance.currentVersion,
      'minimumSupportedVersion': instance.minimumSupportedVersion,
      'latestVersion': instance.latestVersion,
    };

const _$ClientSupportStatusEnumMap = {
  ClientSupportStatus.ok: 'OK',
  ClientSupportStatus.updateRecommended: 'UPDATE_RECOMMENDED',
  ClientSupportStatus.updateRequired: 'UPDATE_REQUIRED',
};
