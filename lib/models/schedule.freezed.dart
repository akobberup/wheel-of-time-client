// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TaskSchedule {
  String get description => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            RepeatUnit repeatUnit, int repeatDelta, String description)
        interval,
    required TResult Function(
            int repeatWeeks, Set<DayOfWeek> daysOfWeek, String description)
        weeklyPattern,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            RepeatUnit repeatUnit, int repeatDelta, String description)?
        interval,
    TResult? Function(
            int repeatWeeks, Set<DayOfWeek> daysOfWeek, String description)?
        weeklyPattern,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            RepeatUnit repeatUnit, int repeatDelta, String description)?
        interval,
    TResult Function(
            int repeatWeeks, Set<DayOfWeek> daysOfWeek, String description)?
        weeklyPattern,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(IntervalSchedule value) interval,
    required TResult Function(WeeklyPatternSchedule value) weeklyPattern,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(IntervalSchedule value)? interval,
    TResult? Function(WeeklyPatternSchedule value)? weeklyPattern,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(IntervalSchedule value)? interval,
    TResult Function(WeeklyPatternSchedule value)? weeklyPattern,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Create a copy of TaskSchedule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaskScheduleCopyWith<TaskSchedule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskScheduleCopyWith<$Res> {
  factory $TaskScheduleCopyWith(
          TaskSchedule value, $Res Function(TaskSchedule) then) =
      _$TaskScheduleCopyWithImpl<$Res, TaskSchedule>;
  @useResult
  $Res call({String description});
}

/// @nodoc
class _$TaskScheduleCopyWithImpl<$Res, $Val extends TaskSchedule>
    implements $TaskScheduleCopyWith<$Res> {
  _$TaskScheduleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaskSchedule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? description = null,
  }) {
    return _then(_value.copyWith(
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IntervalScheduleImplCopyWith<$Res>
    implements $TaskScheduleCopyWith<$Res> {
  factory _$$IntervalScheduleImplCopyWith(_$IntervalScheduleImpl value,
          $Res Function(_$IntervalScheduleImpl) then) =
      __$$IntervalScheduleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({RepeatUnit repeatUnit, int repeatDelta, String description});
}

/// @nodoc
class __$$IntervalScheduleImplCopyWithImpl<$Res>
    extends _$TaskScheduleCopyWithImpl<$Res, _$IntervalScheduleImpl>
    implements _$$IntervalScheduleImplCopyWith<$Res> {
  __$$IntervalScheduleImplCopyWithImpl(_$IntervalScheduleImpl _value,
      $Res Function(_$IntervalScheduleImpl) _then)
      : super(_value, _then);

  /// Create a copy of TaskSchedule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? repeatUnit = null,
    Object? repeatDelta = null,
    Object? description = null,
  }) {
    return _then(_$IntervalScheduleImpl(
      repeatUnit: null == repeatUnit
          ? _value.repeatUnit
          : repeatUnit // ignore: cast_nullable_to_non_nullable
              as RepeatUnit,
      repeatDelta: null == repeatDelta
          ? _value.repeatDelta
          : repeatDelta // ignore: cast_nullable_to_non_nullable
              as int,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$IntervalScheduleImpl implements IntervalSchedule {
  const _$IntervalScheduleImpl(
      {required this.repeatUnit,
      required this.repeatDelta,
      required this.description});

  @override
  final RepeatUnit repeatUnit;
  @override
  final int repeatDelta;
  @override
  final String description;

  @override
  String toString() {
    return 'TaskSchedule.interval(repeatUnit: $repeatUnit, repeatDelta: $repeatDelta, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IntervalScheduleImpl &&
            (identical(other.repeatUnit, repeatUnit) ||
                other.repeatUnit == repeatUnit) &&
            (identical(other.repeatDelta, repeatDelta) ||
                other.repeatDelta == repeatDelta) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, repeatUnit, repeatDelta, description);

  /// Create a copy of TaskSchedule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IntervalScheduleImplCopyWith<_$IntervalScheduleImpl> get copyWith =>
      __$$IntervalScheduleImplCopyWithImpl<_$IntervalScheduleImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            RepeatUnit repeatUnit, int repeatDelta, String description)
        interval,
    required TResult Function(
            int repeatWeeks, Set<DayOfWeek> daysOfWeek, String description)
        weeklyPattern,
  }) {
    return interval(repeatUnit, repeatDelta, description);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            RepeatUnit repeatUnit, int repeatDelta, String description)?
        interval,
    TResult? Function(
            int repeatWeeks, Set<DayOfWeek> daysOfWeek, String description)?
        weeklyPattern,
  }) {
    return interval?.call(repeatUnit, repeatDelta, description);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            RepeatUnit repeatUnit, int repeatDelta, String description)?
        interval,
    TResult Function(
            int repeatWeeks, Set<DayOfWeek> daysOfWeek, String description)?
        weeklyPattern,
    required TResult orElse(),
  }) {
    if (interval != null) {
      return interval(repeatUnit, repeatDelta, description);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(IntervalSchedule value) interval,
    required TResult Function(WeeklyPatternSchedule value) weeklyPattern,
  }) {
    return interval(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(IntervalSchedule value)? interval,
    TResult? Function(WeeklyPatternSchedule value)? weeklyPattern,
  }) {
    return interval?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(IntervalSchedule value)? interval,
    TResult Function(WeeklyPatternSchedule value)? weeklyPattern,
    required TResult orElse(),
  }) {
    if (interval != null) {
      return interval(this);
    }
    return orElse();
  }
}

abstract class IntervalSchedule implements TaskSchedule {
  const factory IntervalSchedule(
      {required final RepeatUnit repeatUnit,
      required final int repeatDelta,
      required final String description}) = _$IntervalScheduleImpl;

  RepeatUnit get repeatUnit;
  int get repeatDelta;
  @override
  String get description;

  /// Create a copy of TaskSchedule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IntervalScheduleImplCopyWith<_$IntervalScheduleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$WeeklyPatternScheduleImplCopyWith<$Res>
    implements $TaskScheduleCopyWith<$Res> {
  factory _$$WeeklyPatternScheduleImplCopyWith(
          _$WeeklyPatternScheduleImpl value,
          $Res Function(_$WeeklyPatternScheduleImpl) then) =
      __$$WeeklyPatternScheduleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int repeatWeeks, Set<DayOfWeek> daysOfWeek, String description});
}

/// @nodoc
class __$$WeeklyPatternScheduleImplCopyWithImpl<$Res>
    extends _$TaskScheduleCopyWithImpl<$Res, _$WeeklyPatternScheduleImpl>
    implements _$$WeeklyPatternScheduleImplCopyWith<$Res> {
  __$$WeeklyPatternScheduleImplCopyWithImpl(_$WeeklyPatternScheduleImpl _value,
      $Res Function(_$WeeklyPatternScheduleImpl) _then)
      : super(_value, _then);

  /// Create a copy of TaskSchedule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? repeatWeeks = null,
    Object? daysOfWeek = null,
    Object? description = null,
  }) {
    return _then(_$WeeklyPatternScheduleImpl(
      repeatWeeks: null == repeatWeeks
          ? _value.repeatWeeks
          : repeatWeeks // ignore: cast_nullable_to_non_nullable
              as int,
      daysOfWeek: null == daysOfWeek
          ? _value._daysOfWeek
          : daysOfWeek // ignore: cast_nullable_to_non_nullable
              as Set<DayOfWeek>,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$WeeklyPatternScheduleImpl implements WeeklyPatternSchedule {
  const _$WeeklyPatternScheduleImpl(
      {required this.repeatWeeks,
      required final Set<DayOfWeek> daysOfWeek,
      required this.description})
      : _daysOfWeek = daysOfWeek;

  @override
  final int repeatWeeks;
  final Set<DayOfWeek> _daysOfWeek;
  @override
  Set<DayOfWeek> get daysOfWeek {
    if (_daysOfWeek is EqualUnmodifiableSetView) return _daysOfWeek;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_daysOfWeek);
  }

  @override
  final String description;

  @override
  String toString() {
    return 'TaskSchedule.weeklyPattern(repeatWeeks: $repeatWeeks, daysOfWeek: $daysOfWeek, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeeklyPatternScheduleImpl &&
            (identical(other.repeatWeeks, repeatWeeks) ||
                other.repeatWeeks == repeatWeeks) &&
            const DeepCollectionEquality()
                .equals(other._daysOfWeek, _daysOfWeek) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @override
  int get hashCode => Object.hash(runtimeType, repeatWeeks,
      const DeepCollectionEquality().hash(_daysOfWeek), description);

  /// Create a copy of TaskSchedule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeeklyPatternScheduleImplCopyWith<_$WeeklyPatternScheduleImpl>
      get copyWith => __$$WeeklyPatternScheduleImplCopyWithImpl<
          _$WeeklyPatternScheduleImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            RepeatUnit repeatUnit, int repeatDelta, String description)
        interval,
    required TResult Function(
            int repeatWeeks, Set<DayOfWeek> daysOfWeek, String description)
        weeklyPattern,
  }) {
    return weeklyPattern(repeatWeeks, daysOfWeek, description);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            RepeatUnit repeatUnit, int repeatDelta, String description)?
        interval,
    TResult? Function(
            int repeatWeeks, Set<DayOfWeek> daysOfWeek, String description)?
        weeklyPattern,
  }) {
    return weeklyPattern?.call(repeatWeeks, daysOfWeek, description);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            RepeatUnit repeatUnit, int repeatDelta, String description)?
        interval,
    TResult Function(
            int repeatWeeks, Set<DayOfWeek> daysOfWeek, String description)?
        weeklyPattern,
    required TResult orElse(),
  }) {
    if (weeklyPattern != null) {
      return weeklyPattern(repeatWeeks, daysOfWeek, description);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(IntervalSchedule value) interval,
    required TResult Function(WeeklyPatternSchedule value) weeklyPattern,
  }) {
    return weeklyPattern(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(IntervalSchedule value)? interval,
    TResult? Function(WeeklyPatternSchedule value)? weeklyPattern,
  }) {
    return weeklyPattern?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(IntervalSchedule value)? interval,
    TResult Function(WeeklyPatternSchedule value)? weeklyPattern,
    required TResult orElse(),
  }) {
    if (weeklyPattern != null) {
      return weeklyPattern(this);
    }
    return orElse();
  }
}

abstract class WeeklyPatternSchedule implements TaskSchedule {
  const factory WeeklyPatternSchedule(
      {required final int repeatWeeks,
      required final Set<DayOfWeek> daysOfWeek,
      required final String description}) = _$WeeklyPatternScheduleImpl;

  int get repeatWeeks;
  Set<DayOfWeek> get daysOfWeek;
  @override
  String get description;

  /// Create a copy of TaskSchedule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeeklyPatternScheduleImplCopyWith<_$WeeklyPatternScheduleImpl>
      get copyWith => throw _privateConstructorUsedError;
}
