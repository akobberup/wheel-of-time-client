// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'streak.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StreakResponse _$StreakResponseFromJson(Map<String, dynamic> json) {
  return _StreakResponse.fromJson(json);
}

/// @nodoc
mixin _$StreakResponse {
  int get id => throw _privateConstructorUsedError;
  int get taskId => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  int get streakCount => throw _privateConstructorUsedError;
  int get instanceCount => throw _privateConstructorUsedError;

  /// Serializes this StreakResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StreakResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StreakResponseCopyWith<StreakResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StreakResponseCopyWith<$Res> {
  factory $StreakResponseCopyWith(
          StreakResponse value, $Res Function(StreakResponse) then) =
      _$StreakResponseCopyWithImpl<$Res, StreakResponse>;
  @useResult
  $Res call(
      {int id,
      int taskId,
      DateTime startDate,
      DateTime? endDate,
      bool isActive,
      int streakCount,
      int instanceCount});
}

/// @nodoc
class _$StreakResponseCopyWithImpl<$Res, $Val extends StreakResponse>
    implements $StreakResponseCopyWith<$Res> {
  _$StreakResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StreakResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? taskId = null,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? isActive = null,
    Object? streakCount = null,
    Object? instanceCount = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      taskId: null == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as int,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      streakCount: null == streakCount
          ? _value.streakCount
          : streakCount // ignore: cast_nullable_to_non_nullable
              as int,
      instanceCount: null == instanceCount
          ? _value.instanceCount
          : instanceCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StreakResponseImplCopyWith<$Res>
    implements $StreakResponseCopyWith<$Res> {
  factory _$$StreakResponseImplCopyWith(_$StreakResponseImpl value,
          $Res Function(_$StreakResponseImpl) then) =
      __$$StreakResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int taskId,
      DateTime startDate,
      DateTime? endDate,
      bool isActive,
      int streakCount,
      int instanceCount});
}

/// @nodoc
class __$$StreakResponseImplCopyWithImpl<$Res>
    extends _$StreakResponseCopyWithImpl<$Res, _$StreakResponseImpl>
    implements _$$StreakResponseImplCopyWith<$Res> {
  __$$StreakResponseImplCopyWithImpl(
      _$StreakResponseImpl _value, $Res Function(_$StreakResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of StreakResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? taskId = null,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? isActive = null,
    Object? streakCount = null,
    Object? instanceCount = null,
  }) {
    return _then(_$StreakResponseImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      taskId: null == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as int,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      streakCount: null == streakCount
          ? _value.streakCount
          : streakCount // ignore: cast_nullable_to_non_nullable
              as int,
      instanceCount: null == instanceCount
          ? _value.instanceCount
          : instanceCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StreakResponseImpl implements _StreakResponse {
  const _$StreakResponseImpl(
      {required this.id,
      required this.taskId,
      required this.startDate,
      this.endDate,
      this.isActive = true,
      this.streakCount = 0,
      this.instanceCount = 0});

  factory _$StreakResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$StreakResponseImplFromJson(json);

  @override
  final int id;
  @override
  final int taskId;
  @override
  final DateTime startDate;
  @override
  final DateTime? endDate;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final int streakCount;
  @override
  @JsonKey()
  final int instanceCount;

  @override
  String toString() {
    return 'StreakResponse(id: $id, taskId: $taskId, startDate: $startDate, endDate: $endDate, isActive: $isActive, streakCount: $streakCount, instanceCount: $instanceCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StreakResponseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.streakCount, streakCount) ||
                other.streakCount == streakCount) &&
            (identical(other.instanceCount, instanceCount) ||
                other.instanceCount == instanceCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, taskId, startDate, endDate,
      isActive, streakCount, instanceCount);

  /// Create a copy of StreakResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StreakResponseImplCopyWith<_$StreakResponseImpl> get copyWith =>
      __$$StreakResponseImplCopyWithImpl<_$StreakResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StreakResponseImplToJson(
      this,
    );
  }
}

abstract class _StreakResponse implements StreakResponse {
  const factory _StreakResponse(
      {required final int id,
      required final int taskId,
      required final DateTime startDate,
      final DateTime? endDate,
      final bool isActive,
      final int streakCount,
      final int instanceCount}) = _$StreakResponseImpl;

  factory _StreakResponse.fromJson(Map<String, dynamic> json) =
      _$StreakResponseImpl.fromJson;

  @override
  int get id;
  @override
  int get taskId;
  @override
  DateTime get startDate;
  @override
  DateTime? get endDate;
  @override
  bool get isActive;
  @override
  int get streakCount;
  @override
  int get instanceCount;

  /// Create a copy of StreakResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StreakResponseImplCopyWith<_$StreakResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
