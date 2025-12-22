// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visual_theme.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VisualThemeResponseImpl _$$VisualThemeResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$VisualThemeResponseImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      primaryColor: json['primaryColor'] as String,
      secondaryColor: json['secondaryColor'] as String,
    );

Map<String, dynamic> _$$VisualThemeResponseImplToJson(
        _$VisualThemeResponseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'displayName': instance.displayName,
      'primaryColor': instance.primaryColor,
      'secondaryColor': instance.secondaryColor,
    };
