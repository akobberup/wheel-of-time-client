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
  RepeatUnit get repeatUnit => throw _privateConstructorUsedError;
  int get repeatDelta => throw _privateConstructorUsedError;
  LocalTime? get alarmAtTimeOfDay => throw _privateConstructorUsedError;
  int? get completionWindowHours => throw _privateConstructorUsedError;
  DateTime get firstRunDate => throw _privateConstructorUsedError;
  DateTime? get nextDueDate => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  String? get taskImagePath => throw _privateConstructorUsedError;
  int get totalCompletions => throw _privateConstructorUsedError;
  StreakResponse? get currentStreak => throw _privateConstructorUsedError;

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
      RepeatUnit repeatUnit,
      int repeatDelta,
      LocalTime? alarmAtTimeOfDay,
      int? completionWindowHours,
      DateTime firstRunDate,
      DateTime? nextDueDate,
      int sortOrder,
      bool isActive,
      String? taskImagePath,
      int totalCompletions,
      StreakResponse? currentStreak});

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
    Object? repeatUnit = null,
    Object? repeatDelta = null,
    Object? alarmAtTimeOfDay = freezed,
    Object? completionWindowHours = freezed,
    Object? firstRunDate = null,
    Object? nextDueDate = freezed,
    Object? sortOrder = null,
    Object? isActive = null,
    Object? taskImagePath = freezed,
    Object? totalCompletions = null,
    Object? currentStreak = freezed,
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
      repeatUnit: null == repeatUnit
          ? _value.repeatUnit
          : repeatUnit // ignore: cast_nullable_to_non_nullable
              as RepeatUnit,
      repeatDelta: null == repeatDelta
          ? _value.repeatDelta
          : repeatDelta // ignore: cast_nullable_to_non_nullable
              as int,
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
    ) as $Val);
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
      RepeatUnit repeatUnit,
      int repeatDelta,
      LocalTime? alarmAtTimeOfDay,
      int? completionWindowHours,
      DateTime firstRunDate,
      DateTime? nextDueDate,
      int sortOrder,
      bool isActive,
      String? taskImagePath,
      int totalCompletions,
      StreakResponse? currentStreak});

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
    Object? repeatUnit = null,
    Object? repeatDelta = null,
    Object? alarmAtTimeOfDay = freezed,
    Object? completionWindowHours = freezed,
    Object? firstRunDate = null,
    Object? nextDueDate = freezed,
    Object? sortOrder = null,
    Object? isActive = null,
    Object? taskImagePath = freezed,
    Object? totalCompletions = null,
    Object? currentStreak = freezed,
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
      repeatUnit: null == repeatUnit
          ? _value.repeatUnit
          : repeatUnit // ignore: cast_nullable_to_non_nullable
              as RepeatUnit,
      repeatDelta: null == repeatDelta
          ? _value.repeatDelta
          : repeatDelta // ignore: cast_nullable_to_non_nullable
              as int,
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
      required this.repeatUnit,
      required this.repeatDelta,
      this.alarmAtTimeOfDay,
      this.completionWindowHours,
      required this.firstRunDate,
      this.nextDueDate,
      this.sortOrder = 0,
      this.isActive = true,
      this.taskImagePath,
      this.totalCompletions = 0,
      this.currentStreak});

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
  final RepeatUnit repeatUnit;
  @override
  final int repeatDelta;
  @override
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
  String toString() {
    return 'TaskResponse(id: $id, name: $name, description: $description, taskListId: $taskListId, taskListName: $taskListName, repeatUnit: $repeatUnit, repeatDelta: $repeatDelta, alarmAtTimeOfDay: $alarmAtTimeOfDay, completionWindowHours: $completionWindowHours, firstRunDate: $firstRunDate, nextDueDate: $nextDueDate, sortOrder: $sortOrder, isActive: $isActive, taskImagePath: $taskImagePath, totalCompletions: $totalCompletions, currentStreak: $currentStreak)';
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
            (identical(other.repeatUnit, repeatUnit) ||
                other.repeatUnit == repeatUnit) &&
            (identical(other.repeatDelta, repeatDelta) ||
                other.repeatDelta == repeatDelta) &&
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
                other.currentStreak == currentStreak));
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
      repeatUnit,
      repeatDelta,
      alarmAtTimeOfDay,
      completionWindowHours,
      firstRunDate,
      nextDueDate,
      sortOrder,
      isActive,
      taskImagePath,
      totalCompletions,
      currentStreak);

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
      required final RepeatUnit repeatUnit,
      required final int repeatDelta,
      final LocalTime? alarmAtTimeOfDay,
      final int? completionWindowHours,
      required final DateTime firstRunDate,
      final DateTime? nextDueDate,
      final int sortOrder,
      final bool isActive,
      final String? taskImagePath,
      final int totalCompletions,
      final StreakResponse? currentStreak}) = _$TaskResponseImpl;

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
  RepeatUnit get repeatUnit;
  @override
  int get repeatDelta;
  @override
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
  RepeatUnit get repeatUnit => throw _privateConstructorUsedError;
  int get repeatDelta => throw _privateConstructorUsedError;
  LocalTime? get alarmAtTimeOfDay => throw _privateConstructorUsedError;
  int? get completionWindowHours => throw _privateConstructorUsedError;
  DateTime get firstRunDate => throw _privateConstructorUsedError;
  int? get sortOrder => throw _privateConstructorUsedError;
  int? get taskImageId => throw _privateConstructorUsedError;

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
      RepeatUnit repeatUnit,
      int repeatDelta,
      LocalTime? alarmAtTimeOfDay,
      int? completionWindowHours,
      DateTime firstRunDate,
      int? sortOrder,
      int? taskImageId});

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
    Object? repeatUnit = null,
    Object? repeatDelta = null,
    Object? alarmAtTimeOfDay = freezed,
    Object? completionWindowHours = freezed,
    Object? firstRunDate = null,
    Object? sortOrder = freezed,
    Object? taskImageId = freezed,
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
      repeatUnit: null == repeatUnit
          ? _value.repeatUnit
          : repeatUnit // ignore: cast_nullable_to_non_nullable
              as RepeatUnit,
      repeatDelta: null == repeatDelta
          ? _value.repeatDelta
          : repeatDelta // ignore: cast_nullable_to_non_nullable
              as int,
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
    ) as $Val);
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
      RepeatUnit repeatUnit,
      int repeatDelta,
      LocalTime? alarmAtTimeOfDay,
      int? completionWindowHours,
      DateTime firstRunDate,
      int? sortOrder,
      int? taskImageId});

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
    Object? repeatUnit = null,
    Object? repeatDelta = null,
    Object? alarmAtTimeOfDay = freezed,
    Object? completionWindowHours = freezed,
    Object? firstRunDate = null,
    Object? sortOrder = freezed,
    Object? taskImageId = freezed,
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
      repeatUnit: null == repeatUnit
          ? _value.repeatUnit
          : repeatUnit // ignore: cast_nullable_to_non_nullable
              as RepeatUnit,
      repeatDelta: null == repeatDelta
          ? _value.repeatDelta
          : repeatDelta // ignore: cast_nullable_to_non_nullable
              as int,
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
      required this.repeatUnit,
      required this.repeatDelta,
      this.alarmAtTimeOfDay,
      this.completionWindowHours,
      required this.firstRunDate,
      this.sortOrder,
      this.taskImageId});

  factory _$CreateTaskRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateTaskRequestImplFromJson(json);

  @override
  final String name;
  @override
  final String? description;
  @override
  final int taskListId;
  @override
  final RepeatUnit repeatUnit;
  @override
  final int repeatDelta;
  @override
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
  String toString() {
    return 'CreateTaskRequest(name: $name, description: $description, taskListId: $taskListId, repeatUnit: $repeatUnit, repeatDelta: $repeatDelta, alarmAtTimeOfDay: $alarmAtTimeOfDay, completionWindowHours: $completionWindowHours, firstRunDate: $firstRunDate, sortOrder: $sortOrder, taskImageId: $taskImageId)';
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
            (identical(other.repeatUnit, repeatUnit) ||
                other.repeatUnit == repeatUnit) &&
            (identical(other.repeatDelta, repeatDelta) ||
                other.repeatDelta == repeatDelta) &&
            (identical(other.alarmAtTimeOfDay, alarmAtTimeOfDay) ||
                other.alarmAtTimeOfDay == alarmAtTimeOfDay) &&
            (identical(other.completionWindowHours, completionWindowHours) ||
                other.completionWindowHours == completionWindowHours) &&
            (identical(other.firstRunDate, firstRunDate) ||
                other.firstRunDate == firstRunDate) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.taskImageId, taskImageId) ||
                other.taskImageId == taskImageId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      description,
      taskListId,
      repeatUnit,
      repeatDelta,
      alarmAtTimeOfDay,
      completionWindowHours,
      firstRunDate,
      sortOrder,
      taskImageId);

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
      required final RepeatUnit repeatUnit,
      required final int repeatDelta,
      final LocalTime? alarmAtTimeOfDay,
      final int? completionWindowHours,
      required final DateTime firstRunDate,
      final int? sortOrder,
      final int? taskImageId}) = _$CreateTaskRequestImpl;

  factory _CreateTaskRequest.fromJson(Map<String, dynamic> json) =
      _$CreateTaskRequestImpl.fromJson;

  @override
  String get name;
  @override
  String? get description;
  @override
  int get taskListId;
  @override
  RepeatUnit get repeatUnit;
  @override
  int get repeatDelta;
  @override
  LocalTime? get alarmAtTimeOfDay;
  @override
  int? get completionWindowHours;
  @override
  DateTime get firstRunDate;
  @override
  int? get sortOrder;
  @override
  int? get taskImageId;

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
  RepeatUnit? get repeatUnit => throw _privateConstructorUsedError;
  int? get repeatDelta => throw _privateConstructorUsedError;
  LocalTime? get alarmAtTimeOfDay => throw _privateConstructorUsedError;
  int? get completionWindowHours => throw _privateConstructorUsedError;
  int? get sortOrder => throw _privateConstructorUsedError;
  bool? get isActive => throw _privateConstructorUsedError;
  int? get taskImageId => throw _privateConstructorUsedError;

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
      RepeatUnit? repeatUnit,
      int? repeatDelta,
      LocalTime? alarmAtTimeOfDay,
      int? completionWindowHours,
      int? sortOrder,
      bool? isActive,
      int? taskImageId});

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
    Object? repeatUnit = freezed,
    Object? repeatDelta = freezed,
    Object? alarmAtTimeOfDay = freezed,
    Object? completionWindowHours = freezed,
    Object? sortOrder = freezed,
    Object? isActive = freezed,
    Object? taskImageId = freezed,
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
      repeatUnit: freezed == repeatUnit
          ? _value.repeatUnit
          : repeatUnit // ignore: cast_nullable_to_non_nullable
              as RepeatUnit?,
      repeatDelta: freezed == repeatDelta
          ? _value.repeatDelta
          : repeatDelta // ignore: cast_nullable_to_non_nullable
              as int?,
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
    ) as $Val);
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
      RepeatUnit? repeatUnit,
      int? repeatDelta,
      LocalTime? alarmAtTimeOfDay,
      int? completionWindowHours,
      int? sortOrder,
      bool? isActive,
      int? taskImageId});

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
    Object? repeatUnit = freezed,
    Object? repeatDelta = freezed,
    Object? alarmAtTimeOfDay = freezed,
    Object? completionWindowHours = freezed,
    Object? sortOrder = freezed,
    Object? isActive = freezed,
    Object? taskImageId = freezed,
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
      repeatUnit: freezed == repeatUnit
          ? _value.repeatUnit
          : repeatUnit // ignore: cast_nullable_to_non_nullable
              as RepeatUnit?,
      repeatDelta: freezed == repeatDelta
          ? _value.repeatDelta
          : repeatDelta // ignore: cast_nullable_to_non_nullable
              as int?,
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdateTaskRequestImpl implements _UpdateTaskRequest {
  const _$UpdateTaskRequestImpl(
      {this.name,
      this.description,
      this.repeatUnit,
      this.repeatDelta,
      this.alarmAtTimeOfDay,
      this.completionWindowHours,
      this.sortOrder,
      this.isActive,
      this.taskImageId});

  factory _$UpdateTaskRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpdateTaskRequestImplFromJson(json);

  @override
  final String? name;
  @override
  final String? description;
  @override
  final RepeatUnit? repeatUnit;
  @override
  final int? repeatDelta;
  @override
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
  String toString() {
    return 'UpdateTaskRequest(name: $name, description: $description, repeatUnit: $repeatUnit, repeatDelta: $repeatDelta, alarmAtTimeOfDay: $alarmAtTimeOfDay, completionWindowHours: $completionWindowHours, sortOrder: $sortOrder, isActive: $isActive, taskImageId: $taskImageId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateTaskRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.repeatUnit, repeatUnit) ||
                other.repeatUnit == repeatUnit) &&
            (identical(other.repeatDelta, repeatDelta) ||
                other.repeatDelta == repeatDelta) &&
            (identical(other.alarmAtTimeOfDay, alarmAtTimeOfDay) ||
                other.alarmAtTimeOfDay == alarmAtTimeOfDay) &&
            (identical(other.completionWindowHours, completionWindowHours) ||
                other.completionWindowHours == completionWindowHours) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.taskImageId, taskImageId) ||
                other.taskImageId == taskImageId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      description,
      repeatUnit,
      repeatDelta,
      alarmAtTimeOfDay,
      completionWindowHours,
      sortOrder,
      isActive,
      taskImageId);

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
      final RepeatUnit? repeatUnit,
      final int? repeatDelta,
      final LocalTime? alarmAtTimeOfDay,
      final int? completionWindowHours,
      final int? sortOrder,
      final bool? isActive,
      final int? taskImageId}) = _$UpdateTaskRequestImpl;

  factory _UpdateTaskRequest.fromJson(Map<String, dynamic> json) =
      _$UpdateTaskRequestImpl.fromJson;

  @override
  String? get name;
  @override
  String? get description;
  @override
  RepeatUnit? get repeatUnit;
  @override
  int? get repeatDelta;
  @override
  LocalTime? get alarmAtTimeOfDay;
  @override
  int? get completionWindowHours;
  @override
  int? get sortOrder;
  @override
  bool? get isActive;
  @override
  int? get taskImageId;

  /// Create a copy of UpdateTaskRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateTaskRequestImplCopyWith<_$UpdateTaskRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
