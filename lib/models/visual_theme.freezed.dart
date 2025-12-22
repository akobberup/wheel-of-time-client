// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'visual_theme.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

VisualThemeResponse _$VisualThemeResponseFromJson(Map<String, dynamic> json) {
  return _VisualThemeResponse.fromJson(json);
}

/// @nodoc
mixin _$VisualThemeResponse {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  String get primaryColor => throw _privateConstructorUsedError;
  String get secondaryColor => throw _privateConstructorUsedError;

  /// Serializes this VisualThemeResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VisualThemeResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VisualThemeResponseCopyWith<VisualThemeResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VisualThemeResponseCopyWith<$Res> {
  factory $VisualThemeResponseCopyWith(
          VisualThemeResponse value, $Res Function(VisualThemeResponse) then) =
      _$VisualThemeResponseCopyWithImpl<$Res, VisualThemeResponse>;
  @useResult
  $Res call(
      {int id,
      String name,
      String displayName,
      String primaryColor,
      String secondaryColor});
}

/// @nodoc
class _$VisualThemeResponseCopyWithImpl<$Res, $Val extends VisualThemeResponse>
    implements $VisualThemeResponseCopyWith<$Res> {
  _$VisualThemeResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VisualThemeResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? displayName = null,
    Object? primaryColor = null,
    Object? secondaryColor = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      primaryColor: null == primaryColor
          ? _value.primaryColor
          : primaryColor // ignore: cast_nullable_to_non_nullable
              as String,
      secondaryColor: null == secondaryColor
          ? _value.secondaryColor
          : secondaryColor // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VisualThemeResponseImplCopyWith<$Res>
    implements $VisualThemeResponseCopyWith<$Res> {
  factory _$$VisualThemeResponseImplCopyWith(_$VisualThemeResponseImpl value,
          $Res Function(_$VisualThemeResponseImpl) then) =
      __$$VisualThemeResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      String displayName,
      String primaryColor,
      String secondaryColor});
}

/// @nodoc
class __$$VisualThemeResponseImplCopyWithImpl<$Res>
    extends _$VisualThemeResponseCopyWithImpl<$Res, _$VisualThemeResponseImpl>
    implements _$$VisualThemeResponseImplCopyWith<$Res> {
  __$$VisualThemeResponseImplCopyWithImpl(_$VisualThemeResponseImpl _value,
      $Res Function(_$VisualThemeResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of VisualThemeResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? displayName = null,
    Object? primaryColor = null,
    Object? secondaryColor = null,
  }) {
    return _then(_$VisualThemeResponseImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      primaryColor: null == primaryColor
          ? _value.primaryColor
          : primaryColor // ignore: cast_nullable_to_non_nullable
              as String,
      secondaryColor: null == secondaryColor
          ? _value.secondaryColor
          : secondaryColor // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VisualThemeResponseImpl implements _VisualThemeResponse {
  const _$VisualThemeResponseImpl(
      {required this.id,
      required this.name,
      required this.displayName,
      required this.primaryColor,
      required this.secondaryColor});

  factory _$VisualThemeResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$VisualThemeResponseImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String displayName;
  @override
  final String primaryColor;
  @override
  final String secondaryColor;

  @override
  String toString() {
    return 'VisualThemeResponse(id: $id, name: $name, displayName: $displayName, primaryColor: $primaryColor, secondaryColor: $secondaryColor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VisualThemeResponseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.primaryColor, primaryColor) ||
                other.primaryColor == primaryColor) &&
            (identical(other.secondaryColor, secondaryColor) ||
                other.secondaryColor == secondaryColor));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, displayName, primaryColor, secondaryColor);

  /// Create a copy of VisualThemeResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VisualThemeResponseImplCopyWith<_$VisualThemeResponseImpl> get copyWith =>
      __$$VisualThemeResponseImplCopyWithImpl<_$VisualThemeResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VisualThemeResponseImplToJson(
      this,
    );
  }
}

abstract class _VisualThemeResponse implements VisualThemeResponse {
  const factory _VisualThemeResponse(
      {required final int id,
      required final String name,
      required final String displayName,
      required final String primaryColor,
      required final String secondaryColor}) = _$VisualThemeResponseImpl;

  factory _VisualThemeResponse.fromJson(Map<String, dynamic> json) =
      _$VisualThemeResponseImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String get displayName;
  @override
  String get primaryColor;
  @override
  String get secondaryColor;

  /// Create a copy of VisualThemeResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VisualThemeResponseImplCopyWith<_$VisualThemeResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
