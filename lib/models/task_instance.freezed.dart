// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_instance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TaskInstanceResponse _$TaskInstanceResponseFromJson(Map<String, dynamic> json) {
  return _TaskInstanceResponse.fromJson(json);
}

/// @nodoc
mixin _$TaskInstanceResponse {
  int get id => throw _privateConstructorUsedError;
  int get taskId => throw _privateConstructorUsedError;
  String get taskName => throw _privateConstructorUsedError;
  int get userId => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  DateTime get completedDateTime => throw _privateConstructorUsedError;
  String? get optionalImagePath => throw _privateConstructorUsedError;
  String? get optionalComment => throw _privateConstructorUsedError;
  bool get contributedToStreak =>
      throw _privateConstructorUsedError; // Timeline view fields
  TaskInstanceStatus get status => throw _privateConstructorUsedError;
  DateTime? get dueDate => throw _privateConstructorUsedError;

  /// Serializes this TaskInstanceResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TaskInstanceResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaskInstanceResponseCopyWith<TaskInstanceResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskInstanceResponseCopyWith<$Res> {
  factory $TaskInstanceResponseCopyWith(TaskInstanceResponse value,
          $Res Function(TaskInstanceResponse) then) =
      _$TaskInstanceResponseCopyWithImpl<$Res, TaskInstanceResponse>;
  @useResult
  $Res call(
      {int id,
      int taskId,
      String taskName,
      int userId,
      String userName,
      DateTime completedDateTime,
      String? optionalImagePath,
      String? optionalComment,
      bool contributedToStreak,
      TaskInstanceStatus status,
      DateTime? dueDate});
}

/// @nodoc
class _$TaskInstanceResponseCopyWithImpl<$Res,
        $Val extends TaskInstanceResponse>
    implements $TaskInstanceResponseCopyWith<$Res> {
  _$TaskInstanceResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaskInstanceResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? taskId = null,
    Object? taskName = null,
    Object? userId = null,
    Object? userName = null,
    Object? completedDateTime = null,
    Object? optionalImagePath = freezed,
    Object? optionalComment = freezed,
    Object? contributedToStreak = null,
    Object? status = null,
    Object? dueDate = freezed,
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
      taskName: null == taskName
          ? _value.taskName
          : taskName // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      completedDateTime: null == completedDateTime
          ? _value.completedDateTime
          : completedDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      optionalImagePath: freezed == optionalImagePath
          ? _value.optionalImagePath
          : optionalImagePath // ignore: cast_nullable_to_non_nullable
              as String?,
      optionalComment: freezed == optionalComment
          ? _value.optionalComment
          : optionalComment // ignore: cast_nullable_to_non_nullable
              as String?,
      contributedToStreak: null == contributedToStreak
          ? _value.contributedToStreak
          : contributedToStreak // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TaskInstanceStatus,
      dueDate: freezed == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TaskInstanceResponseImplCopyWith<$Res>
    implements $TaskInstanceResponseCopyWith<$Res> {
  factory _$$TaskInstanceResponseImplCopyWith(_$TaskInstanceResponseImpl value,
          $Res Function(_$TaskInstanceResponseImpl) then) =
      __$$TaskInstanceResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int taskId,
      String taskName,
      int userId,
      String userName,
      DateTime completedDateTime,
      String? optionalImagePath,
      String? optionalComment,
      bool contributedToStreak,
      TaskInstanceStatus status,
      DateTime? dueDate});
}

/// @nodoc
class __$$TaskInstanceResponseImplCopyWithImpl<$Res>
    extends _$TaskInstanceResponseCopyWithImpl<$Res, _$TaskInstanceResponseImpl>
    implements _$$TaskInstanceResponseImplCopyWith<$Res> {
  __$$TaskInstanceResponseImplCopyWithImpl(_$TaskInstanceResponseImpl _value,
      $Res Function(_$TaskInstanceResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of TaskInstanceResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? taskId = null,
    Object? taskName = null,
    Object? userId = null,
    Object? userName = null,
    Object? completedDateTime = null,
    Object? optionalImagePath = freezed,
    Object? optionalComment = freezed,
    Object? contributedToStreak = null,
    Object? status = null,
    Object? dueDate = freezed,
  }) {
    return _then(_$TaskInstanceResponseImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      taskId: null == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as int,
      taskName: null == taskName
          ? _value.taskName
          : taskName // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      completedDateTime: null == completedDateTime
          ? _value.completedDateTime
          : completedDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      optionalImagePath: freezed == optionalImagePath
          ? _value.optionalImagePath
          : optionalImagePath // ignore: cast_nullable_to_non_nullable
              as String?,
      optionalComment: freezed == optionalComment
          ? _value.optionalComment
          : optionalComment // ignore: cast_nullable_to_non_nullable
              as String?,
      contributedToStreak: null == contributedToStreak
          ? _value.contributedToStreak
          : contributedToStreak // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TaskInstanceStatus,
      dueDate: freezed == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TaskInstanceResponseImpl implements _TaskInstanceResponse {
  const _$TaskInstanceResponseImpl(
      {required this.id,
      required this.taskId,
      required this.taskName,
      required this.userId,
      required this.userName,
      required this.completedDateTime,
      this.optionalImagePath,
      this.optionalComment,
      this.contributedToStreak = false,
      this.status = TaskInstanceStatus.completed,
      this.dueDate});

  factory _$TaskInstanceResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaskInstanceResponseImplFromJson(json);

  @override
  final int id;
  @override
  final int taskId;
  @override
  final String taskName;
  @override
  final int userId;
  @override
  final String userName;
  @override
  final DateTime completedDateTime;
  @override
  final String? optionalImagePath;
  @override
  final String? optionalComment;
  @override
  @JsonKey()
  final bool contributedToStreak;
// Timeline view fields
  @override
  @JsonKey()
  final TaskInstanceStatus status;
  @override
  final DateTime? dueDate;

  @override
  String toString() {
    return 'TaskInstanceResponse(id: $id, taskId: $taskId, taskName: $taskName, userId: $userId, userName: $userName, completedDateTime: $completedDateTime, optionalImagePath: $optionalImagePath, optionalComment: $optionalComment, contributedToStreak: $contributedToStreak, status: $status, dueDate: $dueDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskInstanceResponseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.taskName, taskName) ||
                other.taskName == taskName) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.completedDateTime, completedDateTime) ||
                other.completedDateTime == completedDateTime) &&
            (identical(other.optionalImagePath, optionalImagePath) ||
                other.optionalImagePath == optionalImagePath) &&
            (identical(other.optionalComment, optionalComment) ||
                other.optionalComment == optionalComment) &&
            (identical(other.contributedToStreak, contributedToStreak) ||
                other.contributedToStreak == contributedToStreak) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      taskId,
      taskName,
      userId,
      userName,
      completedDateTime,
      optionalImagePath,
      optionalComment,
      contributedToStreak,
      status,
      dueDate);

  /// Create a copy of TaskInstanceResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskInstanceResponseImplCopyWith<_$TaskInstanceResponseImpl>
      get copyWith =>
          __$$TaskInstanceResponseImplCopyWithImpl<_$TaskInstanceResponseImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TaskInstanceResponseImplToJson(
      this,
    );
  }
}

abstract class _TaskInstanceResponse implements TaskInstanceResponse {
  const factory _TaskInstanceResponse(
      {required final int id,
      required final int taskId,
      required final String taskName,
      required final int userId,
      required final String userName,
      required final DateTime completedDateTime,
      final String? optionalImagePath,
      final String? optionalComment,
      final bool contributedToStreak,
      final TaskInstanceStatus status,
      final DateTime? dueDate}) = _$TaskInstanceResponseImpl;

  factory _TaskInstanceResponse.fromJson(Map<String, dynamic> json) =
      _$TaskInstanceResponseImpl.fromJson;

  @override
  int get id;
  @override
  int get taskId;
  @override
  String get taskName;
  @override
  int get userId;
  @override
  String get userName;
  @override
  DateTime get completedDateTime;
  @override
  String? get optionalImagePath;
  @override
  String? get optionalComment;
  @override
  bool get contributedToStreak; // Timeline view fields
  @override
  TaskInstanceStatus get status;
  @override
  DateTime? get dueDate;

  /// Create a copy of TaskInstanceResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaskInstanceResponseImplCopyWith<_$TaskInstanceResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

CreateTaskInstanceRequest _$CreateTaskInstanceRequestFromJson(
    Map<String, dynamic> json) {
  return _CreateTaskInstanceRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateTaskInstanceRequest {
  int get taskId => throw _privateConstructorUsedError;
  DateTime? get completedDateTime => throw _privateConstructorUsedError;
  int? get optionalImageId => throw _privateConstructorUsedError;
  String? get optionalComment => throw _privateConstructorUsedError;

  /// Serializes this CreateTaskInstanceRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateTaskInstanceRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateTaskInstanceRequestCopyWith<CreateTaskInstanceRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateTaskInstanceRequestCopyWith<$Res> {
  factory $CreateTaskInstanceRequestCopyWith(CreateTaskInstanceRequest value,
          $Res Function(CreateTaskInstanceRequest) then) =
      _$CreateTaskInstanceRequestCopyWithImpl<$Res, CreateTaskInstanceRequest>;
  @useResult
  $Res call(
      {int taskId,
      DateTime? completedDateTime,
      int? optionalImageId,
      String? optionalComment});
}

/// @nodoc
class _$CreateTaskInstanceRequestCopyWithImpl<$Res,
        $Val extends CreateTaskInstanceRequest>
    implements $CreateTaskInstanceRequestCopyWith<$Res> {
  _$CreateTaskInstanceRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateTaskInstanceRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? taskId = null,
    Object? completedDateTime = freezed,
    Object? optionalImageId = freezed,
    Object? optionalComment = freezed,
  }) {
    return _then(_value.copyWith(
      taskId: null == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as int,
      completedDateTime: freezed == completedDateTime
          ? _value.completedDateTime
          : completedDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      optionalImageId: freezed == optionalImageId
          ? _value.optionalImageId
          : optionalImageId // ignore: cast_nullable_to_non_nullable
              as int?,
      optionalComment: freezed == optionalComment
          ? _value.optionalComment
          : optionalComment // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateTaskInstanceRequestImplCopyWith<$Res>
    implements $CreateTaskInstanceRequestCopyWith<$Res> {
  factory _$$CreateTaskInstanceRequestImplCopyWith(
          _$CreateTaskInstanceRequestImpl value,
          $Res Function(_$CreateTaskInstanceRequestImpl) then) =
      __$$CreateTaskInstanceRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int taskId,
      DateTime? completedDateTime,
      int? optionalImageId,
      String? optionalComment});
}

/// @nodoc
class __$$CreateTaskInstanceRequestImplCopyWithImpl<$Res>
    extends _$CreateTaskInstanceRequestCopyWithImpl<$Res,
        _$CreateTaskInstanceRequestImpl>
    implements _$$CreateTaskInstanceRequestImplCopyWith<$Res> {
  __$$CreateTaskInstanceRequestImplCopyWithImpl(
      _$CreateTaskInstanceRequestImpl _value,
      $Res Function(_$CreateTaskInstanceRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreateTaskInstanceRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? taskId = null,
    Object? completedDateTime = freezed,
    Object? optionalImageId = freezed,
    Object? optionalComment = freezed,
  }) {
    return _then(_$CreateTaskInstanceRequestImpl(
      taskId: null == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as int,
      completedDateTime: freezed == completedDateTime
          ? _value.completedDateTime
          : completedDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      optionalImageId: freezed == optionalImageId
          ? _value.optionalImageId
          : optionalImageId // ignore: cast_nullable_to_non_nullable
              as int?,
      optionalComment: freezed == optionalComment
          ? _value.optionalComment
          : optionalComment // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateTaskInstanceRequestImpl implements _CreateTaskInstanceRequest {
  const _$CreateTaskInstanceRequestImpl(
      {required this.taskId,
      this.completedDateTime,
      this.optionalImageId,
      this.optionalComment});

  factory _$CreateTaskInstanceRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateTaskInstanceRequestImplFromJson(json);

  @override
  final int taskId;
  @override
  final DateTime? completedDateTime;
  @override
  final int? optionalImageId;
  @override
  final String? optionalComment;

  @override
  String toString() {
    return 'CreateTaskInstanceRequest(taskId: $taskId, completedDateTime: $completedDateTime, optionalImageId: $optionalImageId, optionalComment: $optionalComment)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateTaskInstanceRequestImpl &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.completedDateTime, completedDateTime) ||
                other.completedDateTime == completedDateTime) &&
            (identical(other.optionalImageId, optionalImageId) ||
                other.optionalImageId == optionalImageId) &&
            (identical(other.optionalComment, optionalComment) ||
                other.optionalComment == optionalComment));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, taskId, completedDateTime, optionalImageId, optionalComment);

  /// Create a copy of CreateTaskInstanceRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateTaskInstanceRequestImplCopyWith<_$CreateTaskInstanceRequestImpl>
      get copyWith => __$$CreateTaskInstanceRequestImplCopyWithImpl<
          _$CreateTaskInstanceRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateTaskInstanceRequestImplToJson(
      this,
    );
  }
}

abstract class _CreateTaskInstanceRequest implements CreateTaskInstanceRequest {
  const factory _CreateTaskInstanceRequest(
      {required final int taskId,
      final DateTime? completedDateTime,
      final int? optionalImageId,
      final String? optionalComment}) = _$CreateTaskInstanceRequestImpl;

  factory _CreateTaskInstanceRequest.fromJson(Map<String, dynamic> json) =
      _$CreateTaskInstanceRequestImpl.fromJson;

  @override
  int get taskId;
  @override
  DateTime? get completedDateTime;
  @override
  int? get optionalImageId;
  @override
  String? get optionalComment;

  /// Create a copy of CreateTaskInstanceRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateTaskInstanceRequestImplCopyWith<_$CreateTaskInstanceRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}
