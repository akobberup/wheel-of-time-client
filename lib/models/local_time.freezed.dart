// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'local_time.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LocalTime _$LocalTimeFromJson(Map<String, dynamic> json) {
  return _LocalTime.fromJson(json);
}

/// @nodoc
mixin _$LocalTime {
  int get hour => throw _privateConstructorUsedError;
  int get minute => throw _privateConstructorUsedError;
  int get second => throw _privateConstructorUsedError;
  int get nano => throw _privateConstructorUsedError;

  /// Serializes this LocalTime to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LocalTime
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LocalTimeCopyWith<LocalTime> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocalTimeCopyWith<$Res> {
  factory $LocalTimeCopyWith(LocalTime value, $Res Function(LocalTime) then) =
      _$LocalTimeCopyWithImpl<$Res, LocalTime>;
  @useResult
  $Res call({int hour, int minute, int second, int nano});
}

/// @nodoc
class _$LocalTimeCopyWithImpl<$Res, $Val extends LocalTime>
    implements $LocalTimeCopyWith<$Res> {
  _$LocalTimeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LocalTime
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hour = null,
    Object? minute = null,
    Object? second = null,
    Object? nano = null,
  }) {
    return _then(_value.copyWith(
      hour: null == hour
          ? _value.hour
          : hour // ignore: cast_nullable_to_non_nullable
              as int,
      minute: null == minute
          ? _value.minute
          : minute // ignore: cast_nullable_to_non_nullable
              as int,
      second: null == second
          ? _value.second
          : second // ignore: cast_nullable_to_non_nullable
              as int,
      nano: null == nano
          ? _value.nano
          : nano // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LocalTimeImplCopyWith<$Res>
    implements $LocalTimeCopyWith<$Res> {
  factory _$$LocalTimeImplCopyWith(
          _$LocalTimeImpl value, $Res Function(_$LocalTimeImpl) then) =
      __$$LocalTimeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int hour, int minute, int second, int nano});
}

/// @nodoc
class __$$LocalTimeImplCopyWithImpl<$Res>
    extends _$LocalTimeCopyWithImpl<$Res, _$LocalTimeImpl>
    implements _$$LocalTimeImplCopyWith<$Res> {
  __$$LocalTimeImplCopyWithImpl(
      _$LocalTimeImpl _value, $Res Function(_$LocalTimeImpl) _then)
      : super(_value, _then);

  /// Create a copy of LocalTime
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hour = null,
    Object? minute = null,
    Object? second = null,
    Object? nano = null,
  }) {
    return _then(_$LocalTimeImpl(
      hour: null == hour
          ? _value.hour
          : hour // ignore: cast_nullable_to_non_nullable
              as int,
      minute: null == minute
          ? _value.minute
          : minute // ignore: cast_nullable_to_non_nullable
              as int,
      second: null == second
          ? _value.second
          : second // ignore: cast_nullable_to_non_nullable
              as int,
      nano: null == nano
          ? _value.nano
          : nano // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LocalTimeImpl implements _LocalTime {
  const _$LocalTimeImpl(
      {required this.hour,
      required this.minute,
      this.second = 0,
      this.nano = 0});

  factory _$LocalTimeImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocalTimeImplFromJson(json);

  @override
  final int hour;
  @override
  final int minute;
  @override
  @JsonKey()
  final int second;
  @override
  @JsonKey()
  final int nano;

  @override
  String toString() {
    return 'LocalTime(hour: $hour, minute: $minute, second: $second, nano: $nano)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocalTimeImpl &&
            (identical(other.hour, hour) || other.hour == hour) &&
            (identical(other.minute, minute) || other.minute == minute) &&
            (identical(other.second, second) || other.second == second) &&
            (identical(other.nano, nano) || other.nano == nano));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, hour, minute, second, nano);

  /// Create a copy of LocalTime
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocalTimeImplCopyWith<_$LocalTimeImpl> get copyWith =>
      __$$LocalTimeImplCopyWithImpl<_$LocalTimeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LocalTimeImplToJson(
      this,
    );
  }
}

abstract class _LocalTime implements LocalTime {
  const factory _LocalTime(
      {required final int hour,
      required final int minute,
      final int second,
      final int nano}) = _$LocalTimeImpl;

  factory _LocalTime.fromJson(Map<String, dynamic> json) =
      _$LocalTimeImpl.fromJson;

  @override
  int get hour;
  @override
  int get minute;
  @override
  int get second;
  @override
  int get nano;

  /// Create a copy of LocalTime
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocalTimeImplCopyWith<_$LocalTimeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
