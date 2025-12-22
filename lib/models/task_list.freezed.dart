// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_list.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TaskListResponse _$TaskListResponseFromJson(Map<String, dynamic> json) {
  return _TaskListResponse.fromJson(json);
}

/// @nodoc
mixin _$TaskListResponse {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int get ownerId => throw _privateConstructorUsedError;
  String get ownerName => throw _privateConstructorUsedError;
  VisualThemeResponse get visualTheme => throw _privateConstructorUsedError;
  int get taskCount => throw _privateConstructorUsedError;
  int get activeTaskCount => throw _privateConstructorUsedError;
  int get memberCount => throw _privateConstructorUsedError;

  /// Serializes this TaskListResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TaskListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaskListResponseCopyWith<TaskListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskListResponseCopyWith<$Res> {
  factory $TaskListResponseCopyWith(
          TaskListResponse value, $Res Function(TaskListResponse) then) =
      _$TaskListResponseCopyWithImpl<$Res, TaskListResponse>;
  @useResult
  $Res call(
      {int id,
      String name,
      String? description,
      int ownerId,
      String ownerName,
      VisualThemeResponse visualTheme,
      int taskCount,
      int activeTaskCount,
      int memberCount});

  $VisualThemeResponseCopyWith<$Res> get visualTheme;
}

/// @nodoc
class _$TaskListResponseCopyWithImpl<$Res, $Val extends TaskListResponse>
    implements $TaskListResponseCopyWith<$Res> {
  _$TaskListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaskListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? ownerId = null,
    Object? ownerName = null,
    Object? visualTheme = null,
    Object? taskCount = null,
    Object? activeTaskCount = null,
    Object? memberCount = null,
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
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as int,
      ownerName: null == ownerName
          ? _value.ownerName
          : ownerName // ignore: cast_nullable_to_non_nullable
              as String,
      visualTheme: null == visualTheme
          ? _value.visualTheme
          : visualTheme // ignore: cast_nullable_to_non_nullable
              as VisualThemeResponse,
      taskCount: null == taskCount
          ? _value.taskCount
          : taskCount // ignore: cast_nullable_to_non_nullable
              as int,
      activeTaskCount: null == activeTaskCount
          ? _value.activeTaskCount
          : activeTaskCount // ignore: cast_nullable_to_non_nullable
              as int,
      memberCount: null == memberCount
          ? _value.memberCount
          : memberCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }

  /// Create a copy of TaskListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VisualThemeResponseCopyWith<$Res> get visualTheme {
    return $VisualThemeResponseCopyWith<$Res>(_value.visualTheme, (value) {
      return _then(_value.copyWith(visualTheme: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TaskListResponseImplCopyWith<$Res>
    implements $TaskListResponseCopyWith<$Res> {
  factory _$$TaskListResponseImplCopyWith(_$TaskListResponseImpl value,
          $Res Function(_$TaskListResponseImpl) then) =
      __$$TaskListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      String? description,
      int ownerId,
      String ownerName,
      VisualThemeResponse visualTheme,
      int taskCount,
      int activeTaskCount,
      int memberCount});

  @override
  $VisualThemeResponseCopyWith<$Res> get visualTheme;
}

/// @nodoc
class __$$TaskListResponseImplCopyWithImpl<$Res>
    extends _$TaskListResponseCopyWithImpl<$Res, _$TaskListResponseImpl>
    implements _$$TaskListResponseImplCopyWith<$Res> {
  __$$TaskListResponseImplCopyWithImpl(_$TaskListResponseImpl _value,
      $Res Function(_$TaskListResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of TaskListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? ownerId = null,
    Object? ownerName = null,
    Object? visualTheme = null,
    Object? taskCount = null,
    Object? activeTaskCount = null,
    Object? memberCount = null,
  }) {
    return _then(_$TaskListResponseImpl(
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
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as int,
      ownerName: null == ownerName
          ? _value.ownerName
          : ownerName // ignore: cast_nullable_to_non_nullable
              as String,
      visualTheme: null == visualTheme
          ? _value.visualTheme
          : visualTheme // ignore: cast_nullable_to_non_nullable
              as VisualThemeResponse,
      taskCount: null == taskCount
          ? _value.taskCount
          : taskCount // ignore: cast_nullable_to_non_nullable
              as int,
      activeTaskCount: null == activeTaskCount
          ? _value.activeTaskCount
          : activeTaskCount // ignore: cast_nullable_to_non_nullable
              as int,
      memberCount: null == memberCount
          ? _value.memberCount
          : memberCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TaskListResponseImpl implements _TaskListResponse {
  const _$TaskListResponseImpl(
      {required this.id,
      required this.name,
      this.description,
      required this.ownerId,
      required this.ownerName,
      required this.visualTheme,
      this.taskCount = 0,
      this.activeTaskCount = 0,
      this.memberCount = 0});

  factory _$TaskListResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaskListResponseImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String? description;
  @override
  final int ownerId;
  @override
  final String ownerName;
  @override
  final VisualThemeResponse visualTheme;
  @override
  @JsonKey()
  final int taskCount;
  @override
  @JsonKey()
  final int activeTaskCount;
  @override
  @JsonKey()
  final int memberCount;

  @override
  String toString() {
    return 'TaskListResponse(id: $id, name: $name, description: $description, ownerId: $ownerId, ownerName: $ownerName, visualTheme: $visualTheme, taskCount: $taskCount, activeTaskCount: $activeTaskCount, memberCount: $memberCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskListResponseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId) &&
            (identical(other.ownerName, ownerName) ||
                other.ownerName == ownerName) &&
            (identical(other.visualTheme, visualTheme) ||
                other.visualTheme == visualTheme) &&
            (identical(other.taskCount, taskCount) ||
                other.taskCount == taskCount) &&
            (identical(other.activeTaskCount, activeTaskCount) ||
                other.activeTaskCount == activeTaskCount) &&
            (identical(other.memberCount, memberCount) ||
                other.memberCount == memberCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, description, ownerId,
      ownerName, visualTheme, taskCount, activeTaskCount, memberCount);

  /// Create a copy of TaskListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskListResponseImplCopyWith<_$TaskListResponseImpl> get copyWith =>
      __$$TaskListResponseImplCopyWithImpl<_$TaskListResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TaskListResponseImplToJson(
      this,
    );
  }
}

abstract class _TaskListResponse implements TaskListResponse {
  const factory _TaskListResponse(
      {required final int id,
      required final String name,
      final String? description,
      required final int ownerId,
      required final String ownerName,
      required final VisualThemeResponse visualTheme,
      final int taskCount,
      final int activeTaskCount,
      final int memberCount}) = _$TaskListResponseImpl;

  factory _TaskListResponse.fromJson(Map<String, dynamic> json) =
      _$TaskListResponseImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  int get ownerId;
  @override
  String get ownerName;
  @override
  VisualThemeResponse get visualTheme;
  @override
  int get taskCount;
  @override
  int get activeTaskCount;
  @override
  int get memberCount;

  /// Create a copy of TaskListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaskListResponseImplCopyWith<_$TaskListResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateTaskListRequest _$CreateTaskListRequestFromJson(
    Map<String, dynamic> json) {
  return _CreateTaskListRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateTaskListRequest {
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int? get visualThemeId => throw _privateConstructorUsedError;

  /// Serializes this CreateTaskListRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateTaskListRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateTaskListRequestCopyWith<CreateTaskListRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateTaskListRequestCopyWith<$Res> {
  factory $CreateTaskListRequestCopyWith(CreateTaskListRequest value,
          $Res Function(CreateTaskListRequest) then) =
      _$CreateTaskListRequestCopyWithImpl<$Res, CreateTaskListRequest>;
  @useResult
  $Res call({String name, String? description, int? visualThemeId});
}

/// @nodoc
class _$CreateTaskListRequestCopyWithImpl<$Res,
        $Val extends CreateTaskListRequest>
    implements $CreateTaskListRequestCopyWith<$Res> {
  _$CreateTaskListRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateTaskListRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = freezed,
    Object? visualThemeId = freezed,
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
      visualThemeId: freezed == visualThemeId
          ? _value.visualThemeId
          : visualThemeId // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateTaskListRequestImplCopyWith<$Res>
    implements $CreateTaskListRequestCopyWith<$Res> {
  factory _$$CreateTaskListRequestImplCopyWith(
          _$CreateTaskListRequestImpl value,
          $Res Function(_$CreateTaskListRequestImpl) then) =
      __$$CreateTaskListRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String? description, int? visualThemeId});
}

/// @nodoc
class __$$CreateTaskListRequestImplCopyWithImpl<$Res>
    extends _$CreateTaskListRequestCopyWithImpl<$Res,
        _$CreateTaskListRequestImpl>
    implements _$$CreateTaskListRequestImplCopyWith<$Res> {
  __$$CreateTaskListRequestImplCopyWithImpl(_$CreateTaskListRequestImpl _value,
      $Res Function(_$CreateTaskListRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreateTaskListRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = freezed,
    Object? visualThemeId = freezed,
  }) {
    return _then(_$CreateTaskListRequestImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      visualThemeId: freezed == visualThemeId
          ? _value.visualThemeId
          : visualThemeId // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateTaskListRequestImpl implements _CreateTaskListRequest {
  const _$CreateTaskListRequestImpl(
      {required this.name, this.description, this.visualThemeId});

  factory _$CreateTaskListRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateTaskListRequestImplFromJson(json);

  @override
  final String name;
  @override
  final String? description;
  @override
  final int? visualThemeId;

  @override
  String toString() {
    return 'CreateTaskListRequest(name: $name, description: $description, visualThemeId: $visualThemeId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateTaskListRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.visualThemeId, visualThemeId) ||
                other.visualThemeId == visualThemeId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, description, visualThemeId);

  /// Create a copy of CreateTaskListRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateTaskListRequestImplCopyWith<_$CreateTaskListRequestImpl>
      get copyWith => __$$CreateTaskListRequestImplCopyWithImpl<
          _$CreateTaskListRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateTaskListRequestImplToJson(
      this,
    );
  }
}

abstract class _CreateTaskListRequest implements CreateTaskListRequest {
  const factory _CreateTaskListRequest(
      {required final String name,
      final String? description,
      final int? visualThemeId}) = _$CreateTaskListRequestImpl;

  factory _CreateTaskListRequest.fromJson(Map<String, dynamic> json) =
      _$CreateTaskListRequestImpl.fromJson;

  @override
  String get name;
  @override
  String? get description;
  @override
  int? get visualThemeId;

  /// Create a copy of CreateTaskListRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateTaskListRequestImplCopyWith<_$CreateTaskListRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

UpdateTaskListRequest _$UpdateTaskListRequestFromJson(
    Map<String, dynamic> json) {
  return _UpdateTaskListRequest.fromJson(json);
}

/// @nodoc
mixin _$UpdateTaskListRequest {
  String? get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int? get visualThemeId => throw _privateConstructorUsedError;

  /// Serializes this UpdateTaskListRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UpdateTaskListRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpdateTaskListRequestCopyWith<UpdateTaskListRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateTaskListRequestCopyWith<$Res> {
  factory $UpdateTaskListRequestCopyWith(UpdateTaskListRequest value,
          $Res Function(UpdateTaskListRequest) then) =
      _$UpdateTaskListRequestCopyWithImpl<$Res, UpdateTaskListRequest>;
  @useResult
  $Res call({String? name, String? description, int? visualThemeId});
}

/// @nodoc
class _$UpdateTaskListRequestCopyWithImpl<$Res,
        $Val extends UpdateTaskListRequest>
    implements $UpdateTaskListRequestCopyWith<$Res> {
  _$UpdateTaskListRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpdateTaskListRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? description = freezed,
    Object? visualThemeId = freezed,
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
      visualThemeId: freezed == visualThemeId
          ? _value.visualThemeId
          : visualThemeId // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UpdateTaskListRequestImplCopyWith<$Res>
    implements $UpdateTaskListRequestCopyWith<$Res> {
  factory _$$UpdateTaskListRequestImplCopyWith(
          _$UpdateTaskListRequestImpl value,
          $Res Function(_$UpdateTaskListRequestImpl) then) =
      __$$UpdateTaskListRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? name, String? description, int? visualThemeId});
}

/// @nodoc
class __$$UpdateTaskListRequestImplCopyWithImpl<$Res>
    extends _$UpdateTaskListRequestCopyWithImpl<$Res,
        _$UpdateTaskListRequestImpl>
    implements _$$UpdateTaskListRequestImplCopyWith<$Res> {
  __$$UpdateTaskListRequestImplCopyWithImpl(_$UpdateTaskListRequestImpl _value,
      $Res Function(_$UpdateTaskListRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of UpdateTaskListRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? description = freezed,
    Object? visualThemeId = freezed,
  }) {
    return _then(_$UpdateTaskListRequestImpl(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      visualThemeId: freezed == visualThemeId
          ? _value.visualThemeId
          : visualThemeId // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdateTaskListRequestImpl implements _UpdateTaskListRequest {
  const _$UpdateTaskListRequestImpl(
      {this.name, this.description, this.visualThemeId});

  factory _$UpdateTaskListRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpdateTaskListRequestImplFromJson(json);

  @override
  final String? name;
  @override
  final String? description;
  @override
  final int? visualThemeId;

  @override
  String toString() {
    return 'UpdateTaskListRequest(name: $name, description: $description, visualThemeId: $visualThemeId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateTaskListRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.visualThemeId, visualThemeId) ||
                other.visualThemeId == visualThemeId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, description, visualThemeId);

  /// Create a copy of UpdateTaskListRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateTaskListRequestImplCopyWith<_$UpdateTaskListRequestImpl>
      get copyWith => __$$UpdateTaskListRequestImplCopyWithImpl<
          _$UpdateTaskListRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateTaskListRequestImplToJson(
      this,
    );
  }
}

abstract class _UpdateTaskListRequest implements UpdateTaskListRequest {
  const factory _UpdateTaskListRequest(
      {final String? name,
      final String? description,
      final int? visualThemeId}) = _$UpdateTaskListRequestImpl;

  factory _UpdateTaskListRequest.fromJson(Map<String, dynamic> json) =
      _$UpdateTaskListRequestImpl.fromJson;

  @override
  String? get name;
  @override
  String? get description;
  @override
  int? get visualThemeId;

  /// Create a copy of UpdateTaskListRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateTaskListRequestImplCopyWith<_$UpdateTaskListRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}
