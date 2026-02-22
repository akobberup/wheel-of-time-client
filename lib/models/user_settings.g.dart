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
      pushInvitations: json['pushInvitations'] as bool? ?? true,
      pushInvitationResponses: json['pushInvitationResponses'] as bool? ?? true,
      pushTaskReminders: json['pushTaskReminders'] as bool? ?? true,
      pushCheers: json['pushCheers'] as bool? ?? true,
      gender: $enumDecodeNullable(_$GenderEnumMap, json['gender']),
      birthYear: (json['birthYear'] as num?)?.toInt(),
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
      'pushInvitations': instance.pushInvitations,
      'pushInvitationResponses': instance.pushInvitationResponses,
      'pushTaskReminders': instance.pushTaskReminders,
      'pushCheers': instance.pushCheers,
      'gender': instance.gender,
      'birthYear': instance.birthYear,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$GenderEnumMap = {
  Gender.MALE: 'MALE',
  Gender.FEMALE: 'FEMALE',
  Gender.OTHER: 'OTHER',
};

_$UpdateUserSettingsRequestImpl _$$UpdateUserSettingsRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$UpdateUserSettingsRequestImpl(
      mainThemeColor: json['mainThemeColor'] as String?,
      darkModeEnabled: json['darkModeEnabled'] as bool?,
      pushInvitations: json['pushInvitations'] as bool?,
      pushInvitationResponses: json['pushInvitationResponses'] as bool?,
      pushTaskReminders: json['pushTaskReminders'] as bool?,
      pushCheers: json['pushCheers'] as bool?,
      gender: $enumDecodeNullable(_$GenderEnumMap, json['gender']),
      birthYear: (json['birthYear'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$UpdateUserSettingsRequestImplToJson(
        _$UpdateUserSettingsRequestImpl instance) =>
    <String, dynamic>{
      'mainThemeColor': instance.mainThemeColor,
      'darkModeEnabled': instance.darkModeEnabled,
      'pushInvitations': instance.pushInvitations,
      'pushInvitationResponses': instance.pushInvitationResponses,
      'pushTaskReminders': instance.pushTaskReminders,
      'pushCheers': instance.pushCheers,
      'gender': instance.gender,
      'birthYear': instance.birthYear,
    };
