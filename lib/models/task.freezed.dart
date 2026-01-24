// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TaskResponse _$TaskResponseFromJson(Map<String, dynamic> json) {
  return _TaskResponse.fromJson(json);
}

/// @nodoc
mixin _$TaskResponse {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int get taskListId => throw _privateConstructorUsedError;
  String get taskListName => throw _privateConstructorUsedError;
  @TaskScheduleConverter()
  TaskSchedule get schedule => throw _privateConstructorUsedError;
  @LocalTimeConverter()
  LocalTime? get alarmAtTimeOfDay => throw _privateConstructorUsedError;
  int? get completionWindowHours => throw _privateConstructorUsedError;
  DateTime get firstRunDate => throw _privateConstructorUsedError;
  DateTime? get nextDueDate => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  String? get taskImagePath => throw _privateConstructorUsedError;
  int get totalCompletions => throw _privateConstructorUsedError;
  StreakResponse? get currentStreak => throw _privateConstructorUsedError;
  bool get scheduleFromCompletion => throw _privateConstructorUsedError;

  /// Serializes this TaskResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TaskResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaskResponseCopyWith<TaskResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskResponseCopyWith<$Res> {
  factory $TaskResponseCopyWith(
          TaskResponse value, $Res Function(TaskResponse) then) =
      _$TaskResponseCopyWithImpl<$Res, TaskResponse>;
  @useResult
  $Res call(
      {int id,
      String name,
      String? description,
      int taskListId,
      String taskListName,
      @TaskScheduleConverter() TaskSchedule schedule,
      @LocalTimeConverter() LocalTime? alarmAtTimeOfDay,
      int? completionWindowHours,
      DateTime firstRunDate,
      DateTime? nextDueDate,
      int sortOrder,
      bool isActive,
      String? taskImagePath,
      int totalCompletions,
      StreakResponse? currentStreak,
      bool scheduleFromCompletion});

  $TaskScheduleCopyWith<$Res> get schedule;
  $LocalTimeCopyWith<$Res>? get alarmAtTimeOfDay;
  $StreakResponseCopyWith<$Res>? get currentStreak;
}

/// @nodoc
class _$TaskResponseCopyWithImpl<$Res, $Val extends TaskResponse>
    implements $TaskResponseCopyWith<$Res> {
  _$TaskResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaskResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? taskListId = null,
    Object? taskListName = null,
    Object? schedule = null,
    Object? alarmAtTimeOfDay = freezed,
    Object? completionWindowHours = freezed,
    Object? firstRunDate = null,
    Object? nextDueDate = freezed,
    Object? sortOrder = null,
    Object? isActive = null,
    Object? taskImagePath = freezed,
    Object? totalCompletions = null,
    Object? currentStreak = freezed,
    Object? scheduleFromCompletion = null,
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
      schedule: null == schedule
          ? _value.schedule
          : schedule // ignore: cast_nullable_to_non_nullable
              as TaskSchedule,
      alarmAtTimeOfDay: freezed == alarmAtTimeOfDay
          ? _value.alarmAtTimeOfDay
          : alarmAtTimeOfDay // ignore: cast_nullable_to_non_nullable
              as LocalTime?,
      completionWindowHours: freezed == completionWindowHours
          ? _value.completionWindowHours
          : completionWindowHours // ignore: cast_nullable_to_non_nullable
              as int?,
      firstRunDate: null == firstRunDate
          ? _value.firstRunDate
          : firstRunDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      nextDueDate: freezed == nextDueDate
          ? _value.nextDueDate
          : nextDueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
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
      scheduleFromCompletion: null == scheduleFromCompletion
          ? _value.scheduleFromCompletion
          : scheduleFromCompletion // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of TaskResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TaskScheduleCopyWith<$Res> get schedule {
    return $TaskScheduleCopyWith<$Res>(_value.schedule, (value) {
      return _then(_value.copyWith(schedule: value) as $Val);
    });
  }

  /// Create a copy of TaskResponse
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

  /// Create a copy of TaskResponse
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
}

/// @nodoc
abstract class _$$TaskResponseImplCopyWith<$Res>
    implements $TaskResponseCopyWith<$Res> {
  factory _$$TaskResponseImplCopyWith(
          _$TaskResponseImpl value, $Res Function(_$TaskResponseImpl) then) =
      __$$TaskResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      String? description,
      int taskListId,
      String taskListName,
      @TaskScheduleConverter() TaskSchedule schedule,
      @LocalTimeConverter() LocalTime? alarmAtTimeOfDay,
      int? completionWindowHours,
      DateTime firstRunDate,
      DateTime? nextDueDate,
      int sortOrder,
      bool isActive,
      String? taskImagePath,
      int totalCompletions,
      StreakResponse? currentStreak,
      bool scheduleFromCompletion});

  @override
  $TaskScheduleCopyWith<$Res> get schedule;
  @override
  $LocalTimeCopyWith<$Res>? get alarmAtTimeOfDay;
  @override
  $StreakResponseCopyWith<$Res>? get currentStreak;
}

/// @nodoc
class __$$TaskResponseImplCopyWithImpl<$Res>
    extends _$TaskResponseCopyWithImpl<$Res, _$TaskResponseImpl>
    implements _$$TaskResponseImplCopyWith<$Res> {
  __$$TaskResponseImplCopyWithImpl(
      _$TaskResponseImpl _value, $Res Function(_$TaskResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of TaskResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? taskListId = null,
    Object? taskListName = null,
    Object? schedule = null,
    Object? alarmAtTimeOfDay = freezed,
    Object? completionWindowHours = freezed,
    Object? firstRunDate = null,
    Object? nextDueDate = freezed,
    Object? sortOrder = null,
    Object? isActive = null,
    Object? taskImagePath = freezed,
    Object? totalCompletions = null,
    Object? currentStreak = freezed,
    Object? scheduleFromCompletion = null,
  }) {
    return _then(_$TaskResponseImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
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
      schedule: null == schedule
          ? _value.schedule
          : schedule // ignore: cast_nullable_to_non_nullable
              as TaskSchedule,
      alarmAtTimeOfDay: freezed == alarmAtTimeOfDay
          ? _value.alarmAtTimeOfDay
          : alarmAtTimeOfDay // ignore: cast_nullable_to_non_nullable
              as LocalTime?,
      completionWindowHours: freezed == completionWindowHours
          ? _value.completionWindowHours
          : completionWindowHours // ignore: cast_nullable_to_non_nullable
              as int?,
      firstRunDate: null == firstRunDate
          ? _value.firstRunDate
          : firstRunDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      nextDueDate: freezed == nextDueDate
          ? _value.nextDueDate
          : nextDueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
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
      scheduleFromCompletion: null == scheduleFromCompletion
          ? _value.scheduleFromCompletion
          : scheduleFromCompletion // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TaskResponseImpl implements _TaskResponse {
  const _$TaskResponseImpl(
      {required this.id,
      required this.name,
      this.description,
      required this.taskListId,
      required this.taskListName,
      @TaskScheduleConverter() required this.schedule,
      @LocalTimeConverter() this.alarmAtTimeOfDay,
      this.completionWindowHours,
      required this.firstRunDate,
      this.nextDueDate,
      this.sortOrder = 0,
      this.isActive = true,
      this.taskImagePath,
      this.totalCompletions = 0,
      this.currentStreak,
      this.scheduleFromCompletion = false});

  factory _$TaskResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaskResponseImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String? description;
  @override
  final int taskListId;
  @override
  final String taskListName;
  @override
  @TaskScheduleConverter()
  final TaskSchedule schedule;
  @override
  @LocalTimeConverter()
  final LocalTime? alarmAtTimeOfDay;
  @override
  final int? completionWindowHours;
  @override
  final DateTime firstRunDate;
  @override
  final DateTime? nextDueDate;
  @override
  @JsonKey()
  final int sortOrder;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final String? taskImagePath;
  @override
  @JsonKey()
  final int totalCompletions;
  @override
  final StreakResponse? currentStreak;
  @override
  @JsonKey()
  final bool scheduleFromCompletion;

  @override
  String toString() {
    return 'TaskResponse(id: $id, name: $name, description: $description, taskListId: $taskListId, taskListName: $taskListName, schedule: $schedule, alarmAtTimeOfDay: $alarmAtTimeOfDay, completionWindowHours: $completionWindowHours, firstRunDate: $firstRunDate, nextDueDate: $nextDueDate, sortOrder: $sortOrder, isActive: $isActive, taskImagePath: $taskImagePath, totalCompletions: $totalCompletions, currentStreak: $currentStreak, scheduleFromCompletion: $scheduleFromCompletion)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskResponseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.taskListId, taskListId) ||
                other.taskListId == taskListId) &&
            (identical(other.taskListName, taskListName) ||
                other.taskListName == taskListName) &&
            (identical(other.schedule, schedule) ||
                other.schedule == schedule) &&
            (identical(other.alarmAtTimeOfDay, alarmAtTimeOfDay) ||
                other.alarmAtTimeOfDay == alarmAtTimeOfDay) &&
            (identical(other.completionWindowHours, completionWindowHours) ||
                other.completionWindowHours == completionWindowHours) &&
            (identical(other.firstRunDate, firstRunDate) ||
                other.firstRunDate == firstRunDate) &&
            (identical(other.nextDueDate, nextDueDate) ||
                other.nextDueDate == nextDueDate) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.taskImagePath, taskImagePath) ||
                other.taskImagePath == taskImagePath) &&
            (identical(other.totalCompletions, totalCompletions) ||
                other.totalCompletions == totalCompletions) &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.scheduleFromCompletion, scheduleFromCompletion) ||
                other.scheduleFromCompletion == scheduleFromCompletion));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      taskListId,
      taskListName,
      schedule,
      alarmAtTimeOfDay,
      completionWindowHours,
      firstRunDate,
      nextDueDate,
      sortOrder,
      isActive,
      taskImagePath,
      totalCompletions,
      currentStreak,
      scheduleFromCompletion);

  /// Create a copy of TaskResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskResponseImplCopyWith<_$TaskResponseImpl> get copyWith =>
      __$$TaskResponseImplCopyWithImpl<_$TaskResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TaskResponseImplToJson(
      this,
    );
  }
}

abstract class _TaskResponse implements TaskResponse {
  const factory _TaskResponse(
      {required final int id,
      required final String name,
      final String? description,
      required final int taskListId,
      required final String taskListName,
      @TaskScheduleConverter() required final TaskSchedule schedule,
      @LocalTimeConverter() final LocalTime? alarmAtTimeOfDay,
      final int? completionWindowHours,
      required final DateTime firstRunDate,
      final DateTime? nextDueDate,
      final int sortOrder,
      final bool isActive,
      final String? taskImagePath,
      final int totalCompletions,
      final StreakResponse? currentStreak,
      final bool scheduleFromCompletion}) = _$TaskResponseImpl;

  factory _TaskResponse.fromJson(Map<String, dynamic> json) =
      _$TaskResponseImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  int get taskListId;
  @override
  String get taskListName;
  @override
  @TaskScheduleConverter()
  TaskSchedule get schedule;
  @override
  @LocalTimeConverter()
  LocalTime? get alarmAtTimeOfDay;
  @override
  int? get completionWindowHours;
  @override
  DateTime get firstRunDate;
  @override
  DateTime? get nextDueDate;
  @override
  int get sortOrder;
  @override
  bool get isActive;
  @override
  String? get taskImagePath;
  @override
  int get totalCompletions;
  @override
  StreakResponse? get currentStreak;
  @override
  bool get scheduleFromCompletion;

  /// Create a copy of TaskResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaskResponseImplCopyWith<_$TaskResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateTaskRequest _$CreateTaskRequestFromJson(Map<String, dynamic> json) {
  return _CreateTaskRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateTaskRequest {
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int get taskListId => throw _privateConstructorUsedError;
  @TaskScheduleConverter()
  TaskSchedule get schedule => throw _privateConstructorUsedError;
  @LocalTimeConverter()
  LocalTime? get alarmAtTimeOfDay => throw _privateConstructorUsedError;
  int? get completionWindowHours => throw _privateConstructorUsedError;
  DateTime get firstRunDate => throw _privateConstructorUsedError;
  int? get sortOrder => throw _privateConstructorUsedError;
  int? get taskImageId => throw _privateConstructorUsedError;
  bool? get scheduleFromCompletion => throw _privateConstructorUsedError;

  /// Serializes this CreateTaskRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateTaskRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateTaskRequestCopyWith<CreateTaskRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateTaskRequestCopyWith<$Res> {
  factory $CreateTaskRequestCopyWith(
          CreateTaskRequest value, $Res Function(CreateTaskRequest) then) =
      _$CreateTaskRequestCopyWithImpl<$Res, CreateTaskRequest>;
  @useResult
  $Res call(
      {String name,
      String? description,
      int taskListId,
      @TaskScheduleConverter() TaskSchedule schedule,
      @LocalTimeConverter() LocalTime? alarmAtTimeOfDay,
      int? completionWindowHours,
      DateTime firstRunDate,
      int? sortOrder,
      int? taskImageId,
      bool? scheduleFromCompletion});

  $TaskScheduleCopyWith<$Res> get schedule;
  $LocalTimeCopyWith<$Res>? get alarmAtTimeOfDay;
}

/// @nodoc
class _$CreateTaskRequestCopyWithImpl<$Res, $Val extends CreateTaskRequest>
    implements $CreateTaskRequestCopyWith<$Res> {
  _$CreateTaskRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateTaskRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = freezed,
    Object? taskListId = null,
    Object? schedule = null,
    Object? alarmAtTimeOfDay = freezed,
    Object? completionWindowHours = freezed,
    Object? firstRunDate = null,
    Object? sortOrder = freezed,
    Object? taskImageId = freezed,
    Object? scheduleFromCompletion = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      taskListId: null == taskListId
          ? _value.taskListId
          : taskListId // ignore: cast_nullable_to_non_nullable
              as int,
      schedule: null == schedule
          ? _value.schedule
          : schedule // ignore: cast_nullable_to_non_nullable
              as TaskSchedule,
      alarmAtTimeOfDay: freezed == alarmAtTimeOfDay
          ? _value.alarmAtTimeOfDay
          : alarmAtTimeOfDay // ignore: cast_nullable_to_non_nullable
              as LocalTime?,
      completionWindowHours: freezed == completionWindowHours
          ? _value.completionWindowHours
          : completionWindowHours // ignore: cast_nullable_to_non_nullable
              as int?,
      firstRunDate: null == firstRunDate
          ? _value.firstRunDate
          : firstRunDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sortOrder: freezed == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int?,
      taskImageId: freezed == taskImageId
          ? _value.taskImageId
          : taskImageId // ignore: cast_nullable_to_non_nullable
              as int?,
      scheduleFromCompletion: freezed == scheduleFromCompletion
          ? _value.scheduleFromCompletion
          : scheduleFromCompletion // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }

  /// Create a copy of CreateTaskRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TaskScheduleCopyWith<$Res> get schedule {
    return $TaskScheduleCopyWith<$Res>(_value.schedule, (value) {
      return _then(_value.copyWith(schedule: value) as $Val);
    });
  }

  /// Create a copy of CreateTaskRequest
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
}

/// @nodoc
abstract class _$$CreateTaskRequestImplCopyWith<$Res>
    implements $CreateTaskRequestCopyWith<$Res> {
  factory _$$CreateTaskRequestImplCopyWith(_$CreateTaskRequestImpl value,
          $Res Function(_$CreateTaskRequestImpl) then) =
      __$$CreateTaskRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String? description,
      int taskListId,
      @TaskScheduleConverter() TaskSchedule schedule,
      @LocalTimeConverter() LocalTime? alarmAtTimeOfDay,
      int? completionWindowHours,
      DateTime firstRunDate,
      int? sortOrder,
      int? taskImageId,
      bool? scheduleFromCompletion});

  @override
  $TaskScheduleCopyWith<$Res> get schedule;
  @override
  $LocalTimeCopyWith<$Res>? get alarmAtTimeOfDay;
}

/// @nodoc
class __$$CreateTaskRequestImplCopyWithImpl<$Res>
    extends _$CreateTaskRequestCopyWithImpl<$Res, _$CreateTaskRequestImpl>
    implements _$$CreateTaskRequestImplCopyWith<$Res> {
  __$$CreateTaskRequestImplCopyWithImpl(_$CreateTaskRequestImpl _value,
      $Res Function(_$CreateTaskRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreateTaskRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = freezed,
    Object? taskListId = null,
    Object? schedule = null,
    Object? alarmAtTimeOfDay = freezed,
    Object? completionWindowHours = freezed,
    Object? firstRunDate = null,
    Object? sortOrder = freezed,
    Object? taskImageId = freezed,
    Object? scheduleFromCompletion = freezed,
  }) {
    return _then(_$CreateTaskRequestImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      taskListId: null == taskListId
          ? _value.taskListId
          : taskListId // ignore: cast_nullable_to_non_nullable
              as int,
      schedule: null == schedule
          ? _value.schedule
          : schedule // ignore: cast_nullable_to_non_nullable
              as TaskSchedule,
      alarmAtTimeOfDay: freezed == alarmAtTimeOfDay
          ? _value.alarmAtTimeOfDay
          : alarmAtTimeOfDay // ignore: cast_nullable_to_non_nullable
              as LocalTime?,
      completionWindowHours: freezed == completionWindowHours
          ? _value.completionWindowHours
          : completionWindowHours // ignore: cast_nullable_to_non_nullable
              as int?,
      firstRunDate: null == firstRunDate
          ? _value.firstRunDate
          : firstRunDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sortOrder: freezed == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int?,
      taskImageId: freezed == taskImageId
          ? _value.taskImageId
          : taskImageId // ignore: cast_nullable_to_non_nullable
              as int?,
      scheduleFromCompletion: freezed == scheduleFromCompletion
          ? _value.scheduleFromCompletion
          : scheduleFromCompletion // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateTaskRequestImpl implements _CreateTaskRequest {
  const _$CreateTaskRequestImpl(
      {required this.name,
      this.description,
      required this.taskListId,
      @TaskScheduleConverter() required this.schedule,
      @LocalTimeConverter() this.alarmAtTimeOfDay,
      this.completionWindowHours,
      required this.firstRunDate,
      this.sortOrder,
      this.taskImageId,
      this.scheduleFromCompletion});

  factory _$CreateTaskRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateTaskRequestImplFromJson(json);

  @override
  final String name;
  @override
  final String? description;
  @override
  final int taskListId;
  @override
  @TaskScheduleConverter()
  final TaskSchedule schedule;
  @override
  @LocalTimeConverter()
  final LocalTime? alarmAtTimeOfDay;
  @override
  final int? completionWindowHours;
  @override
  final DateTime firstRunDate;
  @override
  final int? sortOrder;
  @override
  final int? taskImageId;
  @override
  final bool? scheduleFromCompletion;

  @override
  String toString() {
    return 'CreateTaskRequest(name: $name, description: $description, taskListId: $taskListId, schedule: $schedule, alarmAtTimeOfDay: $alarmAtTimeOfDay, completionWindowHours: $completionWindowHours, firstRunDate: $firstRunDate, sortOrder: $sortOrder, taskImageId: $taskImageId, scheduleFromCompletion: $scheduleFromCompletion)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateTaskRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.taskListId, taskListId) ||
                other.taskListId == taskListId) &&
            (identical(other.schedule, schedule) ||
                other.schedule == schedule) &&
            (identical(other.alarmAtTimeOfDay, alarmAtTimeOfDay) ||
                other.alarmAtTimeOfDay == alarmAtTimeOfDay) &&
            (identical(other.completionWindowHours, completionWindowHours) ||
                other.completionWindowHours == completionWindowHours) &&
            (identical(other.firstRunDate, firstRunDate) ||
                other.firstRunDate == firstRunDate) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.taskImageId, taskImageId) ||
                other.taskImageId == taskImageId) &&
            (identical(other.scheduleFromCompletion, scheduleFromCompletion) ||
                other.scheduleFromCompletion == scheduleFromCompletion));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      description,
      taskListId,
      schedule,
      alarmAtTimeOfDay,
      completionWindowHours,
      firstRunDate,
      sortOrder,
      taskImageId,
      scheduleFromCompletion);

  /// Create a copy of CreateTaskRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateTaskRequestImplCopyWith<_$CreateTaskRequestImpl> get copyWith =>
      __$$CreateTaskRequestImplCopyWithImpl<_$CreateTaskRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateTaskRequestImplToJson(
      this,
    );
  }
}

abstract class _CreateTaskRequest implements CreateTaskRequest {
  const factory _CreateTaskRequest(
      {required final String name,
      final String? description,
      required final int taskListId,
      @TaskScheduleConverter() required final TaskSchedule schedule,
      @LocalTimeConverter() final LocalTime? alarmAtTimeOfDay,
      final int? completionWindowHours,
      required final DateTime firstRunDate,
      final int? sortOrder,
      final int? taskImageId,
      final bool? scheduleFromCompletion}) = _$CreateTaskRequestImpl;

  factory _CreateTaskRequest.fromJson(Map<String, dynamic> json) =
      _$CreateTaskRequestImpl.fromJson;

  @override
  String get name;
  @override
  String? get description;
  @override
  int get taskListId;
  @override
  @TaskScheduleConverter()
  TaskSchedule get schedule;
  @override
  @LocalTimeConverter()
  LocalTime? get alarmAtTimeOfDay;
  @override
  int? get completionWindowHours;
  @override
  DateTime get firstRunDate;
  @override
  int? get sortOrder;
  @override
  int? get taskImageId;
  @override
  bool? get scheduleFromCompletion;

  /// Create a copy of CreateTaskRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateTaskRequestImplCopyWith<_$CreateTaskRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UpdateTaskRequest _$UpdateTaskRequestFromJson(Map<String, dynamic> json) {
  return _UpdateTaskRequest.fromJson(json);
}

/// @nodoc
mixin _$UpdateTaskRequest {
  String? get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @TaskScheduleConverter()
  TaskSchedule? get schedule => throw _privateConstructorUsedError;
  @LocalTimeConverter()
  LocalTime? get alarmAtTimeOfDay => throw _privateConstructorUsedError;
  int? get completionWindowHours => throw _privateConstructorUsedError;
  int? get sortOrder => throw _privateConstructorUsedError;
  bool? get isActive => throw _privateConstructorUsedError;
  int? get taskImageId => throw _privateConstructorUsedError;
  bool? get scheduleFromCompletion => throw _privateConstructorUsedError;

  /// Serializes this UpdateTaskRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UpdateTaskRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpdateTaskRequestCopyWith<UpdateTaskRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateTaskRequestCopyWith<$Res> {
  factory $UpdateTaskRequestCopyWith(
          UpdateTaskRequest value, $Res Function(UpdateTaskRequest) then) =
      _$UpdateTaskRequestCopyWithImpl<$Res, UpdateTaskRequest>;
  @useResult
  $Res call(
      {String? name,
      String? description,
      @TaskScheduleConverter() TaskSchedule? schedule,
      @LocalTimeConverter() LocalTime? alarmAtTimeOfDay,
      int? completionWindowHours,
      int? sortOrder,
      bool? isActive,
      int? taskImageId,
      bool? scheduleFromCompletion});

  $TaskScheduleCopyWith<$Res>? get schedule;
  $LocalTimeCopyWith<$Res>? get alarmAtTimeOfDay;
}

/// @nodoc
class _$UpdateTaskRequestCopyWithImpl<$Res, $Val extends UpdateTaskRequest>
    implements $UpdateTaskRequestCopyWith<$Res> {
  _$UpdateTaskRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpdateTaskRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? description = freezed,
    Object? schedule = freezed,
    Object? alarmAtTimeOfDay = freezed,
    Object? completionWindowHours = freezed,
    Object? sortOrder = freezed,
    Object? isActive = freezed,
    Object? taskImageId = freezed,
    Object? scheduleFromCompletion = freezed,
  }) {
    return _then(_value.copyWith(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      schedule: freezed == schedule
          ? _value.schedule
          : schedule // ignore: cast_nullable_to_non_nullable
              as TaskSchedule?,
      alarmAtTimeOfDay: freezed == alarmAtTimeOfDay
          ? _value.alarmAtTimeOfDay
          : alarmAtTimeOfDay // ignore: cast_nullable_to_non_nullable
              as LocalTime?,
      completionWindowHours: freezed == completionWindowHours
          ? _value.completionWindowHours
          : completionWindowHours // ignore: cast_nullable_to_non_nullable
              as int?,
      sortOrder: freezed == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int?,
      isActive: freezed == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool?,
      taskImageId: freezed == taskImageId
          ? _value.taskImageId
          : taskImageId // ignore: cast_nullable_to_non_nullable
              as int?,
      scheduleFromCompletion: freezed == scheduleFromCompletion
          ? _value.scheduleFromCompletion
          : scheduleFromCompletion // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }

  /// Create a copy of UpdateTaskRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TaskScheduleCopyWith<$Res>? get schedule {
    if (_value.schedule == null) {
      return null;
    }

    return $TaskScheduleCopyWith<$Res>(_value.schedule!, (value) {
      return _then(_value.copyWith(schedule: value) as $Val);
    });
  }

  /// Create a copy of UpdateTaskRequest
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
}

/// @nodoc
abstract class _$$UpdateTaskRequestImplCopyWith<$Res>
    implements $UpdateTaskRequestCopyWith<$Res> {
  factory _$$UpdateTaskRequestImplCopyWith(_$UpdateTaskRequestImpl value,
          $Res Function(_$UpdateTaskRequestImpl) then) =
      __$$UpdateTaskRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? name,
      String? description,
      @TaskScheduleConverter() TaskSchedule? schedule,
      @LocalTimeConverter() LocalTime? alarmAtTimeOfDay,
      int? completionWindowHours,
      int? sortOrder,
      bool? isActive,
      int? taskImageId,
      bool? scheduleFromCompletion});

  @override
  $TaskScheduleCopyWith<$Res>? get schedule;
  @override
  $LocalTimeCopyWith<$Res>? get alarmAtTimeOfDay;
}

/// @nodoc
class __$$UpdateTaskRequestImplCopyWithImpl<$Res>
    extends _$UpdateTaskRequestCopyWithImpl<$Res, _$UpdateTaskRequestImpl>
    implements _$$UpdateTaskRequestImplCopyWith<$Res> {
  __$$UpdateTaskRequestImplCopyWithImpl(_$UpdateTaskRequestImpl _value,
      $Res Function(_$UpdateTaskRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of UpdateTaskRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? description = freezed,
    Object? schedule = freezed,
    Object? alarmAtTimeOfDay = freezed,
    Object? completionWindowHours = freezed,
    Object? sortOrder = freezed,
    Object? isActive = freezed,
    Object? taskImageId = freezed,
    Object? scheduleFromCompletion = freezed,
  }) {
    return _then(_$UpdateTaskRequestImpl(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      schedule: freezed == schedule
          ? _value.schedule
          : schedule // ignore: cast_nullable_to_non_nullable
              as TaskSchedule?,
      alarmAtTimeOfDay: freezed == alarmAtTimeOfDay
          ? _value.alarmAtTimeOfDay
          : alarmAtTimeOfDay // ignore: cast_nullable_to_non_nullable
              as LocalTime?,
      completionWindowHours: freezed == completionWindowHours
          ? _value.completionWindowHours
          : completionWindowHours // ignore: cast_nullable_to_non_nullable
              as int?,
      sortOrder: freezed == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int?,
      isActive: freezed == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool?,
      taskImageId: freezed == taskImageId
          ? _value.taskImageId
          : taskImageId // ignore: cast_nullable_to_non_nullable
              as int?,
      scheduleFromCompletion: freezed == scheduleFromCompletion
          ? _value.scheduleFromCompletion
          : scheduleFromCompletion // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdateTaskRequestImpl implements _UpdateTaskRequest {
  const _$UpdateTaskRequestImpl(
      {this.name,
      this.description,
      @TaskScheduleConverter() this.schedule,
      @LocalTimeConverter() this.alarmAtTimeOfDay,
      this.completionWindowHours,
      this.sortOrder,
      this.isActive,
      this.taskImageId,
      this.scheduleFromCompletion});

  factory _$UpdateTaskRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpdateTaskRequestImplFromJson(json);

  @override
  final String? name;
  @override
  final String? description;
  @override
  @TaskScheduleConverter()
  final TaskSchedule? schedule;
  @override
  @LocalTimeConverter()
  final LocalTime? alarmAtTimeOfDay;
  @override
  final int? completionWindowHours;
  @override
  final int? sortOrder;
  @override
  final bool? isActive;
  @override
  final int? taskImageId;
  @override
  final bool? scheduleFromCompletion;

  @override
  String toString() {
    return 'UpdateTaskRequest(name: $name, description: $description, schedule: $schedule, alarmAtTimeOfDay: $alarmAtTimeOfDay, completionWindowHours: $completionWindowHours, sortOrder: $sortOrder, isActive: $isActive, taskImageId: $taskImageId, scheduleFromCompletion: $scheduleFromCompletion)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateTaskRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.schedule, schedule) ||
                other.schedule == schedule) &&
            (identical(other.alarmAtTimeOfDay, alarmAtTimeOfDay) ||
                other.alarmAtTimeOfDay == alarmAtTimeOfDay) &&
            (identical(other.completionWindowHours, completionWindowHours) ||
                other.completionWindowHours == completionWindowHours) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.taskImageId, taskImageId) ||
                other.taskImageId == taskImageId) &&
            (identical(other.scheduleFromCompletion, scheduleFromCompletion) ||
                other.scheduleFromCompletion == scheduleFromCompletion));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      description,
      schedule,
      alarmAtTimeOfDay,
      completionWindowHours,
      sortOrder,
      isActive,
      taskImageId,
      scheduleFromCompletion);

  /// Create a copy of UpdateTaskRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateTaskRequestImplCopyWith<_$UpdateTaskRequestImpl> get copyWith =>
      __$$UpdateTaskRequestImplCopyWithImpl<_$UpdateTaskRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateTaskRequestImplToJson(
      this,
    );
  }
}

abstract class _UpdateTaskRequest implements UpdateTaskRequest {
  const factory _UpdateTaskRequest(
      {final String? name,
      final String? description,
      @TaskScheduleConverter() final TaskSchedule? schedule,
      @LocalTimeConverter() final LocalTime? alarmAtTimeOfDay,
      final int? completionWindowHours,
      final int? sortOrder,
      final bool? isActive,
      final int? taskImageId,
      final bool? scheduleFromCompletion}) = _$UpdateTaskRequestImpl;

  factory _UpdateTaskRequest.fromJson(Map<String, dynamic> json) =
      _$UpdateTaskRequestImpl.fromJson;

  @override
  String? get name;
  @override
  String? get description;
  @override
  @TaskScheduleConverter()
  TaskSchedule? get schedule;
  @override
  @LocalTimeConverter()
  LocalTime? get alarmAtTimeOfDay;
  @override
  int? get completionWindowHours;
  @override
  int? get sortOrder;
  @override
  bool? get isActive;
  @override
  int? get taskImageId;
  @override
  bool? get scheduleFromCompletion;

  /// Create a copy of UpdateTaskRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateTaskRequestImplCopyWith<_$UpdateTaskRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
