// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cheer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CheerResponse _$CheerResponseFromJson(Map<String, dynamic> json) {
  return _CheerResponse.fromJson(json);
}

/// @nodoc
mixin _$CheerResponse {
  int get id => throw _privateConstructorUsedError;
  int get taskInstanceId => throw _privateConstructorUsedError;
  int get userId => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  String get emoji => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this CheerResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CheerResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CheerResponseCopyWith<CheerResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CheerResponseCopyWith<$Res> {
  factory $CheerResponseCopyWith(
          CheerResponse value, $Res Function(CheerResponse) then) =
      _$CheerResponseCopyWithImpl<$Res, CheerResponse>;
  @useResult
  $Res call(
      {int id,
      int taskInstanceId,
      int userId,
      String userName,
      String emoji,
      String? message,
      DateTime createdAt});
}

/// @nodoc
class _$CheerResponseCopyWithImpl<$Res, $Val extends CheerResponse>
    implements $CheerResponseCopyWith<$Res> {
  _$CheerResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CheerResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? taskInstanceId = null,
    Object? userId = null,
    Object? userName = null,
    Object? emoji = null,
    Object? message = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      taskInstanceId: null == taskInstanceId
          ? _value.taskInstanceId
          : taskInstanceId // ignore: cast_nullable_to_non_nullable
              as int,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CheerResponseImplCopyWith<$Res>
    implements $CheerResponseCopyWith<$Res> {
  factory _$$CheerResponseImplCopyWith(
          _$CheerResponseImpl value, $Res Function(_$CheerResponseImpl) then) =
      __$$CheerResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int taskInstanceId,
      int userId,
      String userName,
      String emoji,
      String? message,
      DateTime createdAt});
}

/// @nodoc
class __$$CheerResponseImplCopyWithImpl<$Res>
    extends _$CheerResponseCopyWithImpl<$Res, _$CheerResponseImpl>
    implements _$$CheerResponseImplCopyWith<$Res> {
  __$$CheerResponseImplCopyWithImpl(
      _$CheerResponseImpl _value, $Res Function(_$CheerResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of CheerResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? taskInstanceId = null,
    Object? userId = null,
    Object? userName = null,
    Object? emoji = null,
    Object? message = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$CheerResponseImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      taskInstanceId: null == taskInstanceId
          ? _value.taskInstanceId
          : taskInstanceId // ignore: cast_nullable_to_non_nullable
              as int,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CheerResponseImpl implements _CheerResponse {
  const _$CheerResponseImpl(
      {required this.id,
      required this.taskInstanceId,
      required this.userId,
      required this.userName,
      required this.emoji,
      this.message,
      required this.createdAt});

  factory _$CheerResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$CheerResponseImplFromJson(json);

  @override
  final int id;
  @override
  final int taskInstanceId;
  @override
  final int userId;
  @override
  final String userName;
  @override
  final String emoji;
  @override
  final String? message;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'CheerResponse(id: $id, taskInstanceId: $taskInstanceId, userId: $userId, userName: $userName, emoji: $emoji, message: $message, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CheerResponseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.taskInstanceId, taskInstanceId) ||
                other.taskInstanceId == taskInstanceId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, taskInstanceId, userId,
      userName, emoji, message, createdAt);

  /// Create a copy of CheerResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CheerResponseImplCopyWith<_$CheerResponseImpl> get copyWith =>
      __$$CheerResponseImplCopyWithImpl<_$CheerResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CheerResponseImplToJson(
      this,
    );
  }
}

abstract class _CheerResponse implements CheerResponse {
  const factory _CheerResponse(
      {required final int id,
      required final int taskInstanceId,
      required final int userId,
      required final String userName,
      required final String emoji,
      final String? message,
      required final DateTime createdAt}) = _$CheerResponseImpl;

  factory _CheerResponse.fromJson(Map<String, dynamic> json) =
      _$CheerResponseImpl.fromJson;

  @override
  int get id;
  @override
  int get taskInstanceId;
  @override
  int get userId;
  @override
  String get userName;
  @override
  String get emoji;
  @override
  String? get message;
  @override
  DateTime get createdAt;

  /// Create a copy of CheerResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CheerResponseImplCopyWith<_$CheerResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
