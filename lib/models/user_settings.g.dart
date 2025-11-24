// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserSettingsResponseImpl _$$UserSettingsResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$UserSettingsResponseImpl(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      mainThemeColor: json['mainThemeColor'] as String,
      darkModeEnabled: json['darkModeEnabled'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$UserSettingsResponseImplToJson(
        _$UserSettingsResponseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'mainThemeColor': instance.mainThemeColor,
      'darkModeEnabled': instance.darkModeEnabled,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$UpdateUserSettingsRequestImpl _$$UpdateUserSettingsRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$UpdateUserSettingsRequestImpl(
      mainThemeColor: json['mainThemeColor'] as String?,
      darkModeEnabled: json['darkModeEnabled'] as bool?,
    );

Map<String, dynamic> _$$UpdateUserSettingsRequestImplToJson(
        _$UpdateUserSettingsRequestImpl instance) =>
    <String, dynamic>{
      'mainThemeColor': instance.mainThemeColor,
      'darkModeEnabled': instance.darkModeEnabled,
    };
