// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ImageUploadResponseImpl _$$ImageUploadResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$ImageUploadResponseImpl(
      imageId: (json['imageId'] as num).toInt(),
      imagePath: json['imagePath'] as String,
      thumbnailPath: json['thumbnailPath'] as String,
      imageSource: $enumDecode(_$ImageSourceEnumMap, json['imageSource']),
    );

Map<String, dynamic> _$$ImageUploadResponseImplToJson(
        _$ImageUploadResponseImpl instance) =>
    <String, dynamic>{
      'imageId': instance.imageId,
      'imagePath': instance.imagePath,
      'thumbnailPath': instance.thumbnailPath,
      'imageSource': instance.imageSource,
    };

const _$ImageSourceEnumMap = {
  ImageSource.USER: 'USER',
  ImageSource.TASK_LIST: 'TASK_LIST',
  ImageSource.TASK: 'TASK',
  ImageSource.TASK_INSTANCE: 'TASK_INSTANCE',
};
