import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';

part 'image.freezed.dart';
part 'image.g.dart';

@freezed
class ImageUploadResponse with _$ImageUploadResponse {
  const factory ImageUploadResponse({
    required int imageId,
    required String imagePath,
    required String thumbnailPath,
    required ImageSource imageSource,
  }) = _ImageUploadResponse;

  factory ImageUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$ImageUploadResponseFromJson(json);
}
