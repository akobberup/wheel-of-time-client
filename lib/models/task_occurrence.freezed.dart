// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_occurrence.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UpcomingTaskOccurrenceResponse _$UpcomingTaskOccurrenceResponseFromJson(
    Map<String, dynamic> json) {
  return _UpcomingTaskOccurrenceResponse.fromJson(json);
}

/// @nodoc
mixin _$UpcomingTaskOccurrenceResponse {
  String get occurrenceId => throw _privateConstructorUsedError;
  int? get taskInstanceId => throw _privateConstructorUsedError;
  int get taskId => throw _privateConstructorUsedError;
  String get taskName => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int get taskListId => throw _privateConstructorUsedError;
  String get taskListName => throw _privateConstructorUsedError;
  DateTime get dueDate => throw _privateConstructorUsedError;
  @LocalTimeConverter()
  LocalTime? get alarmAtTimeOfDay => throw _privateConstructorUsedError;
  int? get completionWindowHours => throw _privateConstructorUsedError;
  String? get taskImagePath => throw _privateConstructorUsedError;
  int get totalCompletions => throw _privateConstructorUsedError;
  StreakResponse? get currentStreak => throw _privateConstructorUsedError;
  @TaskScheduleConverter()
  TaskSchedule get schedule => throw _privateConstructorUsedError;
  int get occurrenceNumber => throw _privateConstructorUsedError;
  bool get isNextOccurrence => throw _privateConstructorUsedError;
  String? get taskListPrimaryColor => throw _privateConstructorUsedError;
  String? get taskListSecondaryColor => throw _privateConstructorUsedError;

  /// Serializes this UpcomingTaskOccurrenceResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UpcomingTaskOccurrenceResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpcomingTaskOccurrenceResponseCopyWith<UpcomingTaskOccurrenceResponse>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpcomingTaskOccurrenceResponseCopyWith<$Res> {
  factory $UpcomingTaskOccurrenceResponseCopyWith(
          UpcomingTaskOccurrenceResponse value,
          $Res Function(UpcomingTaskOccurrenceResponse) then) =
      _$UpcomingTaskOccurrenceResponseCopyWithImpl<$Res,
          UpcomingTaskOccurrenceResponse>;
  @useResult
  $Res call(
      {String occurrenceId,
      int? taskInstanceId,
      int taskId,
      String taskName,
      String? description,
      int taskListId,
      String taskListName,
      DateTime dueDate,
      @LocalTimeConverter() LocalTime? alarmAtTimeOfDay,
      int? completionWindowHours,
      String? taskImagePath,
      int totalCompletions,
      StreakResponse? currentStreak,
      @TaskScheduleConverter() TaskSchedule schedule,
      int occurrenceNumber,
      bool isNextOccurrence,
      String? taskListPrimaryColor,
      String? taskListSecondaryColor});

  $LocalTimeCopyWith<$Res>? get alarmAtTimeOfDay;
  $StreakResponseCopyWith<$Res>? get currentStreak;
  $TaskScheduleCopyWith<$Res> get schedule;
}

/// @nodoc
class _$UpcomingTaskOccurrenceResponseCopyWithImpl<$Res,
        $Val extends UpcomingTaskOccurrenceResponse>
    implements $UpcomingTaskOccurrenceResponseCopyWith<$Res> {
  _$UpcomingTaskOccurrenceResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpcomingTaskOccurrenceResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? occurrenceId = null,
    Object? taskInstanceId = freezed,
    Object? taskId = null,
    Object? taskName = null,
    Object? description = freezed,
    Object? taskListId = null,
    Object? taskListName = null,
    Object? dueDate = null,
    Object? alarmAtTimeOfDay = freezed,
    Object? completionWindowHours = freezed,
    Object? taskImagePath = freezed,
    Object? totalCompletions = null,
    Object? currentStreak = freezed,
    Object? schedule = null,
    Object? occurrenceNumber = null,
    Object? isNextOccurrence = null,
    Object? taskListPrimaryColor = freezed,
    Object? taskListSecondaryColor = freezed,
  }) {
    return _then(_value.copyWith(
      occurrenceId: null == occurrenceId
          ? _value.occurrenceId
          : occurrenceId // ignore: cast_nullable_to_non_nullable
              as String,
      taskInstanceId: freezed == taskInstanceId
          ? _value.taskInstanceId
          : taskInstanceId // ignore: cast_nullable_to_non_nullable
              as int?,
      taskId: null == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as int,
      taskName: null == taskName
          ? _value.taskName
          : taskName // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      taskListId: null == taskListId
          ? _value.taskListId
          : taskListId // ignore: cast_nullable_to_non_nullable
              as int,
      taskListName: null == taskListName
          ? _value.taskListName
          : taskListName // ignore: cast_nullable_to_non_nullable
              as String,
      dueDate: null == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      alarmAtTimeOfDay: freezed == alarmAtTimeOfDay
          ? _value.alarmAtTimeOfDay
          : alarmAtTimeOfDay // ignore: cast_nullable_to_non_nullable
              as LocalTime?,
      completionWindowHours: freezed == completionWindowHours
          ? _value.completionWindowHours
          : completionWindowHours // ignore: cast_nullable_to_non_nullable
              as int?,
      taskImagePath: freezed == taskImagePath
          ? _value.taskImagePath
          : taskImagePath // ignore: cast_nullable_to_non_nullable
              as String?,
      totalCompletions: null == totalCompletions
          ? _value.totalCompletions
          : totalCompletions // ignore: cast_nullable_to_non_nullable
              as int,
      currentStreak: freezed == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as StreakResponse?,
      schedule: null == schedule
          ? _value.schedule
          : schedule // ignore: cast_nullable_to_non_nullable
              as TaskSchedule,
      occurrenceNumber: null == occurrenceNumber
          ? _value.occurrenceNumber
          : occurrenceNumber // ignore: cast_nullable_to_non_nullable
              as int,
      isNextOccurrence: null == isNextOccurrence
          ? _value.isNextOccurrence
          : isNextOccurrence // ignore: cast_nullable_to_non_nullable
              as bool,
      taskListPrimaryColor: freezed == taskListPrimaryColor
          ? _value.taskListPrimaryColor
          : taskListPrimaryColor // ignore: cast_nullable_to_non_nullable
              as String?,
      taskListSecondaryColor: freezed == taskListSecondaryColor
          ? _value.taskListSecondaryColor
          : taskListSecondaryColor // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of UpcomingTaskOccurrenceResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocalTimeCopyWith<$Res>? get alarmAtTimeOfDay {
    if (_value.alarmAtTimeOfDay == null) {
      return null;
    }

    return $LocalTimeCopyWith<$Res>(_value.alarmAtTimeOfDay!, (value) {
      return _then(_value.copyWith(alarmAtTimeOfDay: value) as $Val);
    });
  }

  /// Create a copy of UpcomingTaskOccurrenceResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StreakResponseCopyWith<$Res>? get currentStreak {
    if (_value.currentStreak == null) {
      return null;
    }

    return $StreakResponseCopyWith<$Res>(_value.currentStreak!, (value) {
      return _then(_value.copyWith(currentStreak: value) as $Val);
    });
  }

  /// Create a copy of UpcomingTaskOccurrenceResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TaskScheduleCopyWith<$Res> get schedule {
    return $TaskScheduleCopyWith<$Res>(_value.schedule, (value) {
      return _then(_value.copyWith(schedule: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UpcomingTaskOccurrenceResponseImplCopyWith<$Res>
    implements $UpcomingTaskOccurrenceResponseCopyWith<$Res> {
  factory _$$UpcomingTaskOccurrenceResponseImplCopyWith(
          _$UpcomingTaskOccurrenceResponseImpl value,
          $Res Function(_$UpcomingTaskOccurrenceResponseImpl) then) =
      __$$UpcomingTaskOccurrenceResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String occurrenceId,
      int? taskInstanceId,
      int taskId,
      String taskName,
      String? description,
      int taskListId,
      String taskListName,
      DateTime dueDate,
      @LocalTimeConverter() LocalTime? alarmAtTimeOfDay,
      int? completionWindowHours,
      String? taskImagePath,
      int totalCompletions,
      StreakResponse? currentStreak,
      @TaskScheduleConverter() TaskSchedule schedule,
      int occurrenceNumber,
      bool isNextOccurrence,
      String? taskListPrimaryColor,
      String? taskListSecondaryColor});

  @override
  $LocalTimeCopyWith<$Res>? get alarmAtTimeOfDay;
  @override
  $StreakResponseCopyWith<$Res>? get currentStreak;
  @override
  $TaskScheduleCopyWith<$Res> get schedule;
}

/// @nodoc
class __$$UpcomingTaskOccurrenceResponseImplCopyWithImpl<$Res>
    extends _$UpcomingTaskOccurrenceResponseCopyWithImpl<$Res,
        _$UpcomingTaskOccurrenceResponseImpl>
    implements _$$UpcomingTaskOccurrenceResponseImplCopyWith<$Res> {
  __$$UpcomingTaskOccurrenceResponseImplCopyWithImpl(
      _$UpcomingTaskOccurrenceResponseImpl _value,
      $Res Function(_$UpcomingTaskOccurrenceResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of UpcomingTaskOccurrenceResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? occurrenceId = null,
    Object? taskInstanceId = freezed,
    Object? taskId = null,
    Object? taskName = null,
    Object? description = freezed,
    Object? taskListId = null,
    Object? taskListName = null,
    Object? dueDate = null,
    Object? alarmAtTimeOfDay = freezed,
    Object? completionWindowHours = freezed,
    Object? taskImagePath = freezed,
    Object? totalCompletions = null,
    Object? currentStreak = freezed,
    Object? schedule = null,
    Object? occurrenceNumber = null,
    Object? isNextOccurrence = null,
    Object? taskListPrimaryColor = freezed,
    Object? taskListSecondaryColor = freezed,
  }) {
    return _then(_$UpcomingTaskOccurrenceResponseImpl(
      occurrenceId: null == occurrenceId
          ? _value.occurrenceId
          : occurrenceId // ignore: cast_nullable_to_non_nullable
              as String,
      taskInstanceId: freezed == taskInstanceId
          ? _value.taskInstanceId
          : taskInstanceId // ignore: cast_nullable_to_non_nullable
              as int?,
      taskId: null == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as int,
      taskName: null == taskName
          ? _value.taskName
          : taskName // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      taskListId: null == taskListId
          ? _value.taskListId
          : taskListId // ignore: cast_nullable_to_non_nullable
              as int,
      taskListName: null == taskListName
          ? _value.taskListName
          : taskListName // ignore: cast_nullable_to_non_nullable
              as String,
      dueDate: null == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      alarmAtTimeOfDay: freezed == alarmAtTimeOfDay
          ? _value.alarmAtTimeOfDay
          : alarmAtTimeOfDay // ignore: cast_nullable_to_non_nullable
              as LocalTime?,
      completionWindowHours: freezed == completionWindowHours
          ? _value.completionWindowHours
          : completionWindowHours // ignore: cast_nullable_to_non_nullable
              as int?,
      taskImagePath: freezed == taskImagePath
          ? _value.taskImagePath
          : taskImagePath // ignore: cast_nullable_to_non_nullable
              as String?,
      totalCompletions: null == totalCompletions
          ? _value.totalCompletions
          : totalCompletions // ignore: cast_nullable_to_non_nullable
              as int,
      currentStreak: freezed == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as StreakResponse?,
      schedule: null == schedule
          ? _value.schedule
          : schedule // ignore: cast_nullable_to_non_nullable
              as TaskSchedule,
      occurrenceNumber: null == occurrenceNumber
          ? _value.occurrenceNumber
          : occurrenceNumber // ignore: cast_nullable_to_non_nullable
              as int,
      isNextOccurrence: null == isNextOccurrence
          ? _value.isNextOccurrence
          : isNextOccurrence // ignore: cast_nullable_to_non_nullable
              as bool,
      taskListPrimaryColor: freezed == taskListPrimaryColor
          ? _value.taskListPrimaryColor
          : taskListPrimaryColor // ignore: cast_nullable_to_non_nullable
              as String?,
      taskListSecondaryColor: freezed == taskListSecondaryColor
          ? _value.taskListSecondaryColor
          : taskListSecondaryColor // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UpcomingTaskOccurrenceResponseImpl
    implements _UpcomingTaskOccurrenceResponse {
  const _$UpcomingTaskOccurrenceResponseImpl(
      {required this.occurrenceId,
      this.taskInstanceId,
      required this.taskId,
      required this.taskName,
      this.description,
      required this.taskListId,
      required this.taskListName,
      required this.dueDate,
      @LocalTimeConverter() this.alarmAtTimeOfDay,
      this.completionWindowHours,
      this.taskImagePath,
      this.totalCompletions = 0,
      this.currentStreak,
      @TaskScheduleConverter() required this.schedule,
      this.occurrenceNumber = 1,
      this.isNextOccurrence = false,
      this.taskListPrimaryColor,
      this.taskListSecondaryColor});

  factory _$UpcomingTaskOccurrenceResponseImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$UpcomingTaskOccurrenceResponseImplFromJson(json);

  @override
  final String occurrenceId;
  @override
  final int? taskInstanceId;
  @override
  final int taskId;
  @override
  final String taskName;
  @override
  final String? description;
  @override
  final int taskListId;
  @override
  final String taskListName;
  @override
  final DateTime dueDate;
  @override
  @LocalTimeConverter()
  final LocalTime? alarmAtTimeOfDay;
  @override
  final int? completionWindowHours;
  @override
  final String? taskImagePath;
  @override
  @JsonKey()
  final int totalCompletions;
  @override
  final StreakResponse? currentStreak;
  @override
  @TaskScheduleConverter()
  final TaskSchedule schedule;
  @override
  @JsonKey()
  final int occurrenceNumber;
  @override
  @JsonKey()
  final bool isNextOccurrence;
  @override
  final String? taskListPrimaryColor;
  @override
  final String? taskListSecondaryColor;

  @override
  String toString() {
    return 'UpcomingTaskOccurrenceResponse(occurrenceId: $occurrenceId, taskInstanceId: $taskInstanceId, taskId: $taskId, taskName: $taskName, description: $description, taskListId: $taskListId, taskListName: $taskListName, dueDate: $dueDate, alarmAtTimeOfDay: $alarmAtTimeOfDay, completionWindowHours: $completionWindowHours, taskImagePath: $taskImagePath, totalCompletions: $totalCompletions, currentStreak: $currentStreak, schedule: $schedule, occurrenceNumber: $occurrenceNumber, isNextOccurrence: $isNextOccurrence, taskListPrimaryColor: $taskListPrimaryColor, taskListSecondaryColor: $taskListSecondaryColor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpcomingTaskOccurrenceResponseImpl &&
            (identical(other.occurrenceId, occurrenceId) ||
                other.occurrenceId == occurrenceId) &&
            (identical(other.taskInstanceId, taskInstanceId) ||
                other.taskInstanceId == taskInstanceId) &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.taskName, taskName) ||
                other.taskName == taskName) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.taskListId, taskListId) ||
                other.taskListId == taskListId) &&
            (identical(other.taskListName, taskListName) ||
                other.taskListName == taskListName) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.alarmAtTimeOfDay, alarmAtTimeOfDay) ||
                other.alarmAtTimeOfDay == alarmAtTimeOfDay) &&
            (identical(other.completionWindowHours, completionWindowHours) ||
                other.completionWindowHours == completionWindowHours) &&
            (identical(other.taskImagePath, taskImagePath) ||
                other.taskImagePath == taskImagePath) &&
            (identical(other.totalCompletions, totalCompletions) ||
                other.totalCompletions == totalCompletions) &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.schedule, schedule) ||
                other.schedule == schedule) &&
            (identical(other.occurrenceNumber, occurrenceNumber) ||
                other.occurrenceNumber == occurrenceNumber) &&
            (identical(other.isNextOccurrence, isNextOccurrence) ||
                other.isNextOccurrence == isNextOccurrence) &&
            (identical(other.taskListPrimaryColor, taskListPrimaryColor) ||
                other.taskListPrimaryColor == taskListPrimaryColor) &&
            (identical(other.taskListSecondaryColor, taskListSecondaryColor) ||
                other.taskListSecondaryColor == taskListSecondaryColor));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      occurrenceId,
      taskInstanceId,
      taskId,
      taskName,
      description,
      taskListId,
      taskListName,
      dueDate,
      alarmAtTimeOfDay,
      completionWindowHours,
      taskImagePath,
      totalCompletions,
      currentStreak,
      schedule,
      occurrenceNumber,
      isNextOccurrence,
      taskListPrimaryColor,
      taskListSecondaryColor);

  /// Create a copy of UpcomingTaskOccurrenceResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpcomingTaskOccurrenceResponseImplCopyWith<
          _$UpcomingTaskOccurrenceResponseImpl>
      get copyWith => __$$UpcomingTaskOccurrenceResponseImplCopyWithImpl<
          _$UpcomingTaskOccurrenceResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpcomingTaskOccurrenceResponseImplToJson(
      this,
    );
  }
}

abstract class _UpcomingTaskOccurrenceResponse
    implements UpcomingTaskOccurrenceResponse {
  const factory _UpcomingTaskOccurrenceResponse(
          {required final String occurrenceId,
          final int? taskInstanceId,
          required final int taskId,
          required final String taskName,
          final String? description,
          required final int taskListId,
          required final String taskListName,
          required final DateTime dueDate,
          @LocalTimeConverter() final LocalTime? alarmAtTimeOfDay,
          final int? completionWindowHours,
          final String? taskImagePath,
          final int totalCompletions,
          final StreakResponse? currentStreak,
          @TaskScheduleConverter() required final TaskSchedule schedule,
          final int occurrenceNumber,
          final bool isNextOccurrence,
          final String? taskListPrimaryColor,
          final String? taskListSecondaryColor}) =
      _$UpcomingTaskOccurrenceResponseImpl;

  factory _UpcomingTaskOccurrenceResponse.fromJson(Map<String, dynamic> json) =
      _$UpcomingTaskOccurrenceResponseImpl.fromJson;

  @override
  String get occurrenceId;
  @override
  int? get taskInstanceId;
  @override
  int get taskId;
  @override
  String get taskName;
  @override
  String? get description;
  @override
  int get taskListId;
  @override
  String get taskListName;
  @override
  DateTime get dueDate;
  @override
  @LocalTimeConverter()
  LocalTime? get alarmAtTimeOfDay;
  @override
  int? get completionWindowHours;
  @override
  String? get taskImagePath;
  @override
  int get totalCompletions;
  @override
  StreakResponse? get currentStreak;
  @override
  @TaskScheduleConverter()
  TaskSchedule get schedule;
  @override
  int get occurrenceNumber;
  @override
  bool get isNextOccurrence;
  @override
  String? get taskListPrimaryColor;
  @override
  String? get taskListSecondaryColor;

  /// Create a copy of UpcomingTaskOccurrenceResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpcomingTaskOccurrenceResponseImplCopyWith<
          _$UpcomingTaskOccurrenceResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}
