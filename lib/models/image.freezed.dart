// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'image.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ImageUploadResponse _$ImageUploadResponseFromJson(Map<String, dynamic> json) {
  return _ImageUploadResponse.fromJson(json);
}

/// @nodoc
mixin _$ImageUploadResponse {
  int get imageId => throw _privateConstructorUsedError;
  String get imagePath => throw _privateConstructorUsedError;
  String get thumbnailPath => throw _privateConstructorUsedError;
  ImageSource get imageSource => throw _privateConstructorUsedError;

  /// Serializes this ImageUploadResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ImageUploadResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ImageUploadResponseCopyWith<ImageUploadResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ImageUploadResponseCopyWith<$Res> {
  factory $ImageUploadResponseCopyWith(
          ImageUploadResponse value, $Res Function(ImageUploadResponse) then) =
      _$ImageUploadResponseCopyWithImpl<$Res, ImageUploadResponse>;
  @useResult
  $Res call(
      {int imageId,
      String imagePath,
      String thumbnailPath,
      ImageSource imageSource});
}

/// @nodoc
class _$ImageUploadResponseCopyWithImpl<$Res, $Val extends ImageUploadResponse>
    implements $ImageUploadResponseCopyWith<$Res> {
  _$ImageUploadResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ImageUploadResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? imageId = null,
    Object? imagePath = null,
    Object? thumbnailPath = null,
    Object? imageSource = null,
  }) {
    return _then(_value.copyWith(
      imageId: null == imageId
          ? _value.imageId
          : imageId // ignore: cast_nullable_to_non_nullable
              as int,
      imagePath: null == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailPath: null == thumbnailPath
          ? _value.thumbnailPath
          : thumbnailPath // ignore: cast_nullable_to_non_nullable
              as String,
      imageSource: null == imageSource
          ? _value.imageSource
          : imageSource // ignore: cast_nullable_to_non_nullable
              as ImageSource,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ImageUploadResponseImplCopyWith<$Res>
    implements $ImageUploadResponseCopyWith<$Res> {
  factory _$$ImageUploadResponseImplCopyWith(_$ImageUploadResponseImpl value,
          $Res Function(_$ImageUploadResponseImpl) then) =
      __$$ImageUploadResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int imageId,
      String imagePath,
      String thumbnailPath,
      ImageSource imageSource});
}

/// @nodoc
class __$$ImageUploadResponseImplCopyWithImpl<$Res>
    extends _$ImageUploadResponseCopyWithImpl<$Res, _$ImageUploadResponseImpl>
    implements _$$ImageUploadResponseImplCopyWith<$Res> {
  __$$ImageUploadResponseImplCopyWithImpl(_$ImageUploadResponseImpl _value,
      $Res Function(_$ImageUploadResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of ImageUploadResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? imageId = null,
    Object? imagePath = null,
    Object? thumbnailPath = null,
    Object? imageSource = null,
  }) {
    return _then(_$ImageUploadResponseImpl(
      imageId: null == imageId
          ? _value.imageId
          : imageId // ignore: cast_nullable_to_non_nullable
              as int,
      imagePath: null == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailPath: null == thumbnailPath
          ? _value.thumbnailPath
          : thumbnailPath // ignore: cast_nullable_to_non_nullable
              as String,
      imageSource: null == imageSource
          ? _value.imageSource
          : imageSource // ignore: cast_nullable_to_non_nullable
              as ImageSource,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ImageUploadResponseImpl implements _ImageUploadResponse {
  const _$ImageUploadResponseImpl(
      {required this.imageId,
      required this.imagePath,
      required this.thumbnailPath,
      required this.imageSource});

  factory _$ImageUploadResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ImageUploadResponseImplFromJson(json);

  @override
  final int imageId;
  @override
  final String imagePath;
  @override
  final String thumbnailPath;
  @override
  final ImageSource imageSource;

  @override
  String toString() {
    return 'ImageUploadResponse(imageId: $imageId, imagePath: $imagePath, thumbnailPath: $thumbnailPath, imageSource: $imageSource)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImageUploadResponseImpl &&
            (identical(other.imageId, imageId) || other.imageId == imageId) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            (identical(other.thumbnailPath, thumbnailPath) ||
                other.thumbnailPath == thumbnailPath) &&
            (identical(other.imageSource, imageSource) ||
                other.imageSource == imageSource));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, imageId, imagePath, thumbnailPath, imageSource);

  /// Create a copy of ImageUploadResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ImageUploadResponseImplCopyWith<_$ImageUploadResponseImpl> get copyWith =>
      __$$ImageUploadResponseImplCopyWithImpl<_$ImageUploadResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ImageUploadResponseImplToJson(
      this,
    );
  }
}

abstract class _ImageUploadResponse implements ImageUploadResponse {
  const factory _ImageUploadResponse(
      {required final int imageId,
      required final String imagePath,
      required final String thumbnailPath,
      required final ImageSource imageSource}) = _$ImageUploadResponseImpl;

  factory _ImageUploadResponse.fromJson(Map<String, dynamic> json) =
      _$ImageUploadResponseImpl.fromJson;

  @override
  int get imageId;
  @override
  String get imagePath;
  @override
  String get thumbnailPath;
  @override
  ImageSource get imageSource;

  /// Create a copy of ImageUploadResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ImageUploadResponseImplCopyWith<_$ImageUploadResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
