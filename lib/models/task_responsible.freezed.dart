// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_responsible.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TaskResponsibleResponse _$TaskResponsibleResponseFromJson(
    Map<String, dynamic> json) {
  return _TaskResponsibleResponse.fromJson(json);
}

/// @nodoc
mixin _$TaskResponsibleResponse {
  /// TaskResponsible entitetens unikke ID.
  int get id => throw _privateConstructorUsedError;

  /// Brugerens unikke ID.
  int get userId => throw _privateConstructorUsedError;

  /// Brugerens visningsnavn.
  String get userName => throw _privateConstructorUsedError;

  /// Brugerens email-adresse.
  String get userEmail => throw _privateConstructorUsedError;

  /// Placering i rotationsrækkefølgen (0-baseret).
  int get sortOrder => throw _privateConstructorUsedError;

  /// Serializes this TaskResponsibleResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TaskResponsibleResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaskResponsibleResponseCopyWith<TaskResponsibleResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskResponsibleResponseCopyWith<$Res> {
  factory $TaskResponsibleResponseCopyWith(TaskResponsibleResponse value,
          $Res Function(TaskResponsibleResponse) then) =
      _$TaskResponsibleResponseCopyWithImpl<$Res, TaskResponsibleResponse>;
  @useResult
  $Res call(
      {int id, int userId, String userName, String userEmail, int sortOrder});
}

/// @nodoc
class _$TaskResponsibleResponseCopyWithImpl<$Res,
        $Val extends TaskResponsibleResponse>
    implements $TaskResponsibleResponseCopyWith<$Res> {
  _$TaskResponsibleResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaskResponsibleResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? userName = null,
    Object? userEmail = null,
    Object? sortOrder = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      userEmail: null == userEmail
          ? _value.userEmail
          : userEmail // ignore: cast_nullable_to_non_nullable
              as String,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TaskResponsibleResponseImplCopyWith<$Res>
    implements $TaskResponsibleResponseCopyWith<$Res> {
  factory _$$TaskResponsibleResponseImplCopyWith(
          _$TaskResponsibleResponseImpl value,
          $Res Function(_$TaskResponsibleResponseImpl) then) =
      __$$TaskResponsibleResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id, int userId, String userName, String userEmail, int sortOrder});
}

/// @nodoc
class __$$TaskResponsibleResponseImplCopyWithImpl<$Res>
    extends _$TaskResponsibleResponseCopyWithImpl<$Res,
        _$TaskResponsibleResponseImpl>
    implements _$$TaskResponsibleResponseImplCopyWith<$Res> {
  __$$TaskResponsibleResponseImplCopyWithImpl(
      _$TaskResponsibleResponseImpl _value,
      $Res Function(_$TaskResponsibleResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of TaskResponsibleResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? userName = null,
    Object? userEmail = null,
    Object? sortOrder = null,
  }) {
    return _then(_$TaskResponsibleResponseImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      userEmail: null == userEmail
          ? _value.userEmail
          : userEmail // ignore: cast_nullable_to_non_nullable
              as String,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TaskResponsibleResponseImpl implements _TaskResponsibleResponse {
  const _$TaskResponsibleResponseImpl(
      {required this.id,
      required this.userId,
      required this.userName,
      required this.userEmail,
      required this.sortOrder});

  factory _$TaskResponsibleResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaskResponsibleResponseImplFromJson(json);

  /// TaskResponsible entitetens unikke ID.
  @override
  final int id;

  /// Brugerens unikke ID.
  @override
  final int userId;

  /// Brugerens visningsnavn.
  @override
  final String userName;

  /// Brugerens email-adresse.
  @override
  final String userEmail;

  /// Placering i rotationsrækkefølgen (0-baseret).
  @override
  final int sortOrder;

  @override
  String toString() {
    return 'TaskResponsibleResponse(id: $id, userId: $userId, userName: $userName, userEmail: $userEmail, sortOrder: $sortOrder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskResponsibleResponseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.userEmail, userEmail) ||
                other.userEmail == userEmail) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, userId, userName, userEmail, sortOrder);

  /// Create a copy of TaskResponsibleResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskResponsibleResponseImplCopyWith<_$TaskResponsibleResponseImpl>
      get copyWith => __$$TaskResponsibleResponseImplCopyWithImpl<
          _$TaskResponsibleResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TaskResponsibleResponseImplToJson(
      this,
    );
  }
}

abstract class _TaskResponsibleResponse implements TaskResponsibleResponse {
  const factory _TaskResponsibleResponse(
      {required final int id,
      required final int userId,
      required final String userName,
      required final String userEmail,
      required final int sortOrder}) = _$TaskResponsibleResponseImpl;

  factory _TaskResponsibleResponse.fromJson(Map<String, dynamic> json) =
      _$TaskResponsibleResponseImpl.fromJson;

  /// TaskResponsible entitetens unikke ID.
  @override
  int get id;

  /// Brugerens unikke ID.
  @override
  int get userId;

  /// Brugerens visningsnavn.
  @override
  String get userName;

  /// Brugerens email-adresse.
  @override
  String get userEmail;

  /// Placering i rotationsrækkefølgen (0-baseret).
  @override
  int get sortOrder;

  /// Create a copy of TaskResponsibleResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaskResponsibleResponseImplCopyWith<_$TaskResponsibleResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

TaskResponsibleConfigResponse _$TaskResponsibleConfigResponseFromJson(
    Map<String, dynamic> json) {
  return _TaskResponsibleConfigResponse.fromJson(json);
}

/// @nodoc
mixin _$TaskResponsibleConfigResponse {
  /// Konfigurationens unikke ID.
  int get id => throw _privateConstructorUsedError;

  /// ID på den tilknyttede task.
  int get taskId => throw _privateConstructorUsedError;

  /// Strategi for tildeling af ansvarlige.
  ResponsibleStrategy get strategy => throw _privateConstructorUsedError;

  /// Nuværende rotationsindex ved ROUND_ROBIN strategi.
  int? get currentRotationIndex => throw _privateConstructorUsedError;

  /// Liste af ansvarlige brugere i rotationsrækkefølge.
  List<TaskResponsibleResponse> get responsibles =>
      throw _privateConstructorUsedError;

  /// Serializes this TaskResponsibleConfigResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TaskResponsibleConfigResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaskResponsibleConfigResponseCopyWith<TaskResponsibleConfigResponse>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskResponsibleConfigResponseCopyWith<$Res> {
  factory $TaskResponsibleConfigResponseCopyWith(
          TaskResponsibleConfigResponse value,
          $Res Function(TaskResponsibleConfigResponse) then) =
      _$TaskResponsibleConfigResponseCopyWithImpl<$Res,
          TaskResponsibleConfigResponse>;
  @useResult
  $Res call(
      {int id,
      int taskId,
      ResponsibleStrategy strategy,
      int? currentRotationIndex,
      List<TaskResponsibleResponse> responsibles});
}

/// @nodoc
class _$TaskResponsibleConfigResponseCopyWithImpl<$Res,
        $Val extends TaskResponsibleConfigResponse>
    implements $TaskResponsibleConfigResponseCopyWith<$Res> {
  _$TaskResponsibleConfigResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaskResponsibleConfigResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? taskId = null,
    Object? strategy = null,
    Object? currentRotationIndex = freezed,
    Object? responsibles = null,
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
      strategy: null == strategy
          ? _value.strategy
          : strategy // ignore: cast_nullable_to_non_nullable
              as ResponsibleStrategy,
      currentRotationIndex: freezed == currentRotationIndex
          ? _value.currentRotationIndex
          : currentRotationIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      responsibles: null == responsibles
          ? _value.responsibles
          : responsibles // ignore: cast_nullable_to_non_nullable
              as List<TaskResponsibleResponse>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TaskResponsibleConfigResponseImplCopyWith<$Res>
    implements $TaskResponsibleConfigResponseCopyWith<$Res> {
  factory _$$TaskResponsibleConfigResponseImplCopyWith(
          _$TaskResponsibleConfigResponseImpl value,
          $Res Function(_$TaskResponsibleConfigResponseImpl) then) =
      __$$TaskResponsibleConfigResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int taskId,
      ResponsibleStrategy strategy,
      int? currentRotationIndex,
      List<TaskResponsibleResponse> responsibles});
}

/// @nodoc
class __$$TaskResponsibleConfigResponseImplCopyWithImpl<$Res>
    extends _$TaskResponsibleConfigResponseCopyWithImpl<$Res,
        _$TaskResponsibleConfigResponseImpl>
    implements _$$TaskResponsibleConfigResponseImplCopyWith<$Res> {
  __$$TaskResponsibleConfigResponseImplCopyWithImpl(
      _$TaskResponsibleConfigResponseImpl _value,
      $Res Function(_$TaskResponsibleConfigResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of TaskResponsibleConfigResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? taskId = null,
    Object? strategy = null,
    Object? currentRotationIndex = freezed,
    Object? responsibles = null,
  }) {
    return _then(_$TaskResponsibleConfigResponseImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      taskId: null == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as int,
      strategy: null == strategy
          ? _value.strategy
          : strategy // ignore: cast_nullable_to_non_nullable
              as ResponsibleStrategy,
      currentRotationIndex: freezed == currentRotationIndex
          ? _value.currentRotationIndex
          : currentRotationIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      responsibles: null == responsibles
          ? _value._responsibles
          : responsibles // ignore: cast_nullable_to_non_nullable
              as List<TaskResponsibleResponse>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TaskResponsibleConfigResponseImpl
    implements _TaskResponsibleConfigResponse {
  const _$TaskResponsibleConfigResponseImpl(
      {required this.id,
      required this.taskId,
      required this.strategy,
      this.currentRotationIndex,
      final List<TaskResponsibleResponse> responsibles = const []})
      : _responsibles = responsibles;

  factory _$TaskResponsibleConfigResponseImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$TaskResponsibleConfigResponseImplFromJson(json);

  /// Konfigurationens unikke ID.
  @override
  final int id;

  /// ID på den tilknyttede task.
  @override
  final int taskId;

  /// Strategi for tildeling af ansvarlige.
  @override
  final ResponsibleStrategy strategy;

  /// Nuværende rotationsindex ved ROUND_ROBIN strategi.
  @override
  final int? currentRotationIndex;

  /// Liste af ansvarlige brugere i rotationsrækkefølge.
  final List<TaskResponsibleResponse> _responsibles;

  /// Liste af ansvarlige brugere i rotationsrækkefølge.
  @override
  @JsonKey()
  List<TaskResponsibleResponse> get responsibles {
    if (_responsibles is EqualUnmodifiableListView) return _responsibles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_responsibles);
  }

  @override
  String toString() {
    return 'TaskResponsibleConfigResponse(id: $id, taskId: $taskId, strategy: $strategy, currentRotationIndex: $currentRotationIndex, responsibles: $responsibles)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskResponsibleConfigResponseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.strategy, strategy) ||
                other.strategy == strategy) &&
            (identical(other.currentRotationIndex, currentRotationIndex) ||
                other.currentRotationIndex == currentRotationIndex) &&
            const DeepCollectionEquality()
                .equals(other._responsibles, _responsibles));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, taskId, strategy,
      currentRotationIndex, const DeepCollectionEquality().hash(_responsibles));

  /// Create a copy of TaskResponsibleConfigResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskResponsibleConfigResponseImplCopyWith<
          _$TaskResponsibleConfigResponseImpl>
      get copyWith => __$$TaskResponsibleConfigResponseImplCopyWithImpl<
          _$TaskResponsibleConfigResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TaskResponsibleConfigResponseImplToJson(
      this,
    );
  }
}

abstract class _TaskResponsibleConfigResponse
    implements TaskResponsibleConfigResponse {
  const factory _TaskResponsibleConfigResponse(
          {required final int id,
          required final int taskId,
          required final ResponsibleStrategy strategy,
          final int? currentRotationIndex,
          final List<TaskResponsibleResponse> responsibles}) =
      _$TaskResponsibleConfigResponseImpl;

  factory _TaskResponsibleConfigResponse.fromJson(Map<String, dynamic> json) =
      _$TaskResponsibleConfigResponseImpl.fromJson;

  /// Konfigurationens unikke ID.
  @override
  int get id;

  /// ID på den tilknyttede task.
  @override
  int get taskId;

  /// Strategi for tildeling af ansvarlige.
  @override
  ResponsibleStrategy get strategy;

  /// Nuværende rotationsindex ved ROUND_ROBIN strategi.
  @override
  int? get currentRotationIndex;

  /// Liste af ansvarlige brugere i rotationsrækkefølge.
  @override
  List<TaskResponsibleResponse> get responsibles;

  /// Create a copy of TaskResponsibleConfigResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaskResponsibleConfigResponseImplCopyWith<
          _$TaskResponsibleConfigResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

TaskResponsibleConfigRequest _$TaskResponsibleConfigRequestFromJson(
    Map<String, dynamic> json) {
  return _TaskResponsibleConfigRequest.fromJson(json);
}

/// @nodoc
mixin _$TaskResponsibleConfigRequest {
  /// Strategi for tildeling af ansvarlige.
  ResponsibleStrategy get strategy => throw _privateConstructorUsedError;

  /// Liste af bruger-IDs der er ansvarlige for opgaven.
  /// Rækkefølgen afgør rotationsordenen ved ROUND_ROBIN strategi.
  List<int> get responsibleUserIds => throw _privateConstructorUsedError;

  /// Serializes this TaskResponsibleConfigRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TaskResponsibleConfigRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaskResponsibleConfigRequestCopyWith<TaskResponsibleConfigRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskResponsibleConfigRequestCopyWith<$Res> {
  factory $TaskResponsibleConfigRequestCopyWith(
          TaskResponsibleConfigRequest value,
          $Res Function(TaskResponsibleConfigRequest) then) =
      _$TaskResponsibleConfigRequestCopyWithImpl<$Res,
          TaskResponsibleConfigRequest>;
  @useResult
  $Res call({ResponsibleStrategy strategy, List<int> responsibleUserIds});
}

/// @nodoc
class _$TaskResponsibleConfigRequestCopyWithImpl<$Res,
        $Val extends TaskResponsibleConfigRequest>
    implements $TaskResponsibleConfigRequestCopyWith<$Res> {
  _$TaskResponsibleConfigRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaskResponsibleConfigRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? strategy = null,
    Object? responsibleUserIds = null,
  }) {
    return _then(_value.copyWith(
      strategy: null == strategy
          ? _value.strategy
          : strategy // ignore: cast_nullable_to_non_nullable
              as ResponsibleStrategy,
      responsibleUserIds: null == responsibleUserIds
          ? _value.responsibleUserIds
          : responsibleUserIds // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TaskResponsibleConfigRequestImplCopyWith<$Res>
    implements $TaskResponsibleConfigRequestCopyWith<$Res> {
  factory _$$TaskResponsibleConfigRequestImplCopyWith(
          _$TaskResponsibleConfigRequestImpl value,
          $Res Function(_$TaskResponsibleConfigRequestImpl) then) =
      __$$TaskResponsibleConfigRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({ResponsibleStrategy strategy, List<int> responsibleUserIds});
}

/// @nodoc
class __$$TaskResponsibleConfigRequestImplCopyWithImpl<$Res>
    extends _$TaskResponsibleConfigRequestCopyWithImpl<$Res,
        _$TaskResponsibleConfigRequestImpl>
    implements _$$TaskResponsibleConfigRequestImplCopyWith<$Res> {
  __$$TaskResponsibleConfigRequestImplCopyWithImpl(
      _$TaskResponsibleConfigRequestImpl _value,
      $Res Function(_$TaskResponsibleConfigRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of TaskResponsibleConfigRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? strategy = null,
    Object? responsibleUserIds = null,
  }) {
    return _then(_$TaskResponsibleConfigRequestImpl(
      strategy: null == strategy
          ? _value.strategy
          : strategy // ignore: cast_nullable_to_non_nullable
              as ResponsibleStrategy,
      responsibleUserIds: null == responsibleUserIds
          ? _value._responsibleUserIds
          : responsibleUserIds // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TaskResponsibleConfigRequestImpl
    implements _TaskResponsibleConfigRequest {
  const _$TaskResponsibleConfigRequestImpl(
      {required this.strategy, final List<int> responsibleUserIds = const []})
      : _responsibleUserIds = responsibleUserIds;

  factory _$TaskResponsibleConfigRequestImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$TaskResponsibleConfigRequestImplFromJson(json);

  /// Strategi for tildeling af ansvarlige.
  @override
  final ResponsibleStrategy strategy;

  /// Liste af bruger-IDs der er ansvarlige for opgaven.
  /// Rækkefølgen afgør rotationsordenen ved ROUND_ROBIN strategi.
  final List<int> _responsibleUserIds;

  /// Liste af bruger-IDs der er ansvarlige for opgaven.
  /// Rækkefølgen afgør rotationsordenen ved ROUND_ROBIN strategi.
  @override
  @JsonKey()
  List<int> get responsibleUserIds {
    if (_responsibleUserIds is EqualUnmodifiableListView)
      return _responsibleUserIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_responsibleUserIds);
  }

  @override
  String toString() {
    return 'TaskResponsibleConfigRequest(strategy: $strategy, responsibleUserIds: $responsibleUserIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskResponsibleConfigRequestImpl &&
            (identical(other.strategy, strategy) ||
                other.strategy == strategy) &&
            const DeepCollectionEquality()
                .equals(other._responsibleUserIds, _responsibleUserIds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, strategy,
      const DeepCollectionEquality().hash(_responsibleUserIds));

  /// Create a copy of TaskResponsibleConfigRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskResponsibleConfigRequestImplCopyWith<
          _$TaskResponsibleConfigRequestImpl>
      get copyWith => __$$TaskResponsibleConfigRequestImplCopyWithImpl<
          _$TaskResponsibleConfigRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TaskResponsibleConfigRequestImplToJson(
      this,
    );
  }
}

abstract class _TaskResponsibleConfigRequest
    implements TaskResponsibleConfigRequest {
  const factory _TaskResponsibleConfigRequest(
      {required final ResponsibleStrategy strategy,
      final List<int> responsibleUserIds}) = _$TaskResponsibleConfigRequestImpl;

  factory _TaskResponsibleConfigRequest.fromJson(Map<String, dynamic> json) =
      _$TaskResponsibleConfigRequestImpl.fromJson;

  /// Strategi for tildeling af ansvarlige.
  @override
  ResponsibleStrategy get strategy;

  /// Liste af bruger-IDs der er ansvarlige for opgaven.
  /// Rækkefølgen afgør rotationsordenen ved ROUND_ROBIN strategi.
  @override
  List<int> get responsibleUserIds;

  /// Create a copy of TaskResponsibleConfigRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaskResponsibleConfigRequestImplCopyWith<
          _$TaskResponsibleConfigRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}
