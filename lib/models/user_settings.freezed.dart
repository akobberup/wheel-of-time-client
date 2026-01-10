// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserSettingsResponse _$UserSettingsResponseFromJson(Map<String, dynamic> json) {
  return _UserSettingsResponse.fromJson(json);
}

/// @nodoc
mixin _$UserSettingsResponse {
  int get id => throw _privateConstructorUsedError;
  int get userId => throw _privateConstructorUsedError;
  String get mainThemeColor => throw _privateConstructorUsedError;
  bool get darkModeEnabled =>
      throw _privateConstructorUsedError; // Push notification preferences
  bool get pushInvitations => throw _privateConstructorUsedError;
  bool get pushInvitationResponses => throw _privateConstructorUsedError;
  bool get pushTaskReminders => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this UserSettingsResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserSettingsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserSettingsResponseCopyWith<UserSettingsResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserSettingsResponseCopyWith<$Res> {
  factory $UserSettingsResponseCopyWith(UserSettingsResponse value,
          $Res Function(UserSettingsResponse) then) =
      _$UserSettingsResponseCopyWithImpl<$Res, UserSettingsResponse>;
  @useResult
  $Res call(
      {int id,
      int userId,
      String mainThemeColor,
      bool darkModeEnabled,
      bool pushInvitations,
      bool pushInvitationResponses,
      bool pushTaskReminders,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$UserSettingsResponseCopyWithImpl<$Res,
        $Val extends UserSettingsResponse>
    implements $UserSettingsResponseCopyWith<$Res> {
  _$UserSettingsResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserSettingsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? mainThemeColor = null,
    Object? darkModeEnabled = null,
    Object? pushInvitations = null,
    Object? pushInvitationResponses = null,
    Object? pushTaskReminders = null,
    Object? createdAt = null,
    Object? updatedAt = null,
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
      mainThemeColor: null == mainThemeColor
          ? _value.mainThemeColor
          : mainThemeColor // ignore: cast_nullable_to_non_nullable
              as String,
      darkModeEnabled: null == darkModeEnabled
          ? _value.darkModeEnabled
          : darkModeEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      pushInvitations: null == pushInvitations
          ? _value.pushInvitations
          : pushInvitations // ignore: cast_nullable_to_non_nullable
              as bool,
      pushInvitationResponses: null == pushInvitationResponses
          ? _value.pushInvitationResponses
          : pushInvitationResponses // ignore: cast_nullable_to_non_nullable
              as bool,
      pushTaskReminders: null == pushTaskReminders
          ? _value.pushTaskReminders
          : pushTaskReminders // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserSettingsResponseImplCopyWith<$Res>
    implements $UserSettingsResponseCopyWith<$Res> {
  factory _$$UserSettingsResponseImplCopyWith(_$UserSettingsResponseImpl value,
          $Res Function(_$UserSettingsResponseImpl) then) =
      __$$UserSettingsResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int userId,
      String mainThemeColor,
      bool darkModeEnabled,
      bool pushInvitations,
      bool pushInvitationResponses,
      bool pushTaskReminders,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$UserSettingsResponseImplCopyWithImpl<$Res>
    extends _$UserSettingsResponseCopyWithImpl<$Res, _$UserSettingsResponseImpl>
    implements _$$UserSettingsResponseImplCopyWith<$Res> {
  __$$UserSettingsResponseImplCopyWithImpl(_$UserSettingsResponseImpl _value,
      $Res Function(_$UserSettingsResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserSettingsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? mainThemeColor = null,
    Object? darkModeEnabled = null,
    Object? pushInvitations = null,
    Object? pushInvitationResponses = null,
    Object? pushTaskReminders = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$UserSettingsResponseImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      mainThemeColor: null == mainThemeColor
          ? _value.mainThemeColor
          : mainThemeColor // ignore: cast_nullable_to_non_nullable
              as String,
      darkModeEnabled: null == darkModeEnabled
          ? _value.darkModeEnabled
          : darkModeEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      pushInvitations: null == pushInvitations
          ? _value.pushInvitations
          : pushInvitations // ignore: cast_nullable_to_non_nullable
              as bool,
      pushInvitationResponses: null == pushInvitationResponses
          ? _value.pushInvitationResponses
          : pushInvitationResponses // ignore: cast_nullable_to_non_nullable
              as bool,
      pushTaskReminders: null == pushTaskReminders
          ? _value.pushTaskReminders
          : pushTaskReminders // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserSettingsResponseImpl implements _UserSettingsResponse {
  const _$UserSettingsResponseImpl(
      {required this.id,
      required this.userId,
      required this.mainThemeColor,
      required this.darkModeEnabled,
      this.pushInvitations = true,
      this.pushInvitationResponses = true,
      this.pushTaskReminders = true,
      required this.createdAt,
      required this.updatedAt});

  factory _$UserSettingsResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserSettingsResponseImplFromJson(json);

  @override
  final int id;
  @override
  final int userId;
  @override
  final String mainThemeColor;
  @override
  final bool darkModeEnabled;
// Push notification preferences
  @override
  @JsonKey()
  final bool pushInvitations;
  @override
  @JsonKey()
  final bool pushInvitationResponses;
  @override
  @JsonKey()
  final bool pushTaskReminders;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'UserSettingsResponse(id: $id, userId: $userId, mainThemeColor: $mainThemeColor, darkModeEnabled: $darkModeEnabled, pushInvitations: $pushInvitations, pushInvitationResponses: $pushInvitationResponses, pushTaskReminders: $pushTaskReminders, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserSettingsResponseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.mainThemeColor, mainThemeColor) ||
                other.mainThemeColor == mainThemeColor) &&
            (identical(other.darkModeEnabled, darkModeEnabled) ||
                other.darkModeEnabled == darkModeEnabled) &&
            (identical(other.pushInvitations, pushInvitations) ||
                other.pushInvitations == pushInvitations) &&
            (identical(
                    other.pushInvitationResponses, pushInvitationResponses) ||
                other.pushInvitationResponses == pushInvitationResponses) &&
            (identical(other.pushTaskReminders, pushTaskReminders) ||
                other.pushTaskReminders == pushTaskReminders) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      mainThemeColor,
      darkModeEnabled,
      pushInvitations,
      pushInvitationResponses,
      pushTaskReminders,
      createdAt,
      updatedAt);

  /// Create a copy of UserSettingsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserSettingsResponseImplCopyWith<_$UserSettingsResponseImpl>
      get copyWith =>
          __$$UserSettingsResponseImplCopyWithImpl<_$UserSettingsResponseImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserSettingsResponseImplToJson(
      this,
    );
  }
}

abstract class _UserSettingsResponse implements UserSettingsResponse {
  const factory _UserSettingsResponse(
      {required final int id,
      required final int userId,
      required final String mainThemeColor,
      required final bool darkModeEnabled,
      final bool pushInvitations,
      final bool pushInvitationResponses,
      final bool pushTaskReminders,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$UserSettingsResponseImpl;

  factory _UserSettingsResponse.fromJson(Map<String, dynamic> json) =
      _$UserSettingsResponseImpl.fromJson;

  @override
  int get id;
  @override
  int get userId;
  @override
  String get mainThemeColor;
  @override
  bool get darkModeEnabled; // Push notification preferences
  @override
  bool get pushInvitations;
  @override
  bool get pushInvitationResponses;
  @override
  bool get pushTaskReminders;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of UserSettingsResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserSettingsResponseImplCopyWith<_$UserSettingsResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

UpdateUserSettingsRequest _$UpdateUserSettingsRequestFromJson(
    Map<String, dynamic> json) {
  return _UpdateUserSettingsRequest.fromJson(json);
}

/// @nodoc
mixin _$UpdateUserSettingsRequest {
  String? get mainThemeColor => throw _privateConstructorUsedError;
  bool? get darkModeEnabled =>
      throw _privateConstructorUsedError; // Push notification preferences
  bool? get pushInvitations => throw _privateConstructorUsedError;
  bool? get pushInvitationResponses => throw _privateConstructorUsedError;
  bool? get pushTaskReminders => throw _privateConstructorUsedError;

  /// Serializes this UpdateUserSettingsRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UpdateUserSettingsRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpdateUserSettingsRequestCopyWith<UpdateUserSettingsRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateUserSettingsRequestCopyWith<$Res> {
  factory $UpdateUserSettingsRequestCopyWith(UpdateUserSettingsRequest value,
          $Res Function(UpdateUserSettingsRequest) then) =
      _$UpdateUserSettingsRequestCopyWithImpl<$Res, UpdateUserSettingsRequest>;
  @useResult
  $Res call(
      {String? mainThemeColor,
      bool? darkModeEnabled,
      bool? pushInvitations,
      bool? pushInvitationResponses,
      bool? pushTaskReminders});
}

/// @nodoc
class _$UpdateUserSettingsRequestCopyWithImpl<$Res,
        $Val extends UpdateUserSettingsRequest>
    implements $UpdateUserSettingsRequestCopyWith<$Res> {
  _$UpdateUserSettingsRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpdateUserSettingsRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mainThemeColor = freezed,
    Object? darkModeEnabled = freezed,
    Object? pushInvitations = freezed,
    Object? pushInvitationResponses = freezed,
    Object? pushTaskReminders = freezed,
  }) {
    return _then(_value.copyWith(
      mainThemeColor: freezed == mainThemeColor
          ? _value.mainThemeColor
          : mainThemeColor // ignore: cast_nullable_to_non_nullable
              as String?,
      darkModeEnabled: freezed == darkModeEnabled
          ? _value.darkModeEnabled
          : darkModeEnabled // ignore: cast_nullable_to_non_nullable
              as bool?,
      pushInvitations: freezed == pushInvitations
          ? _value.pushInvitations
          : pushInvitations // ignore: cast_nullable_to_non_nullable
              as bool?,
      pushInvitationResponses: freezed == pushInvitationResponses
          ? _value.pushInvitationResponses
          : pushInvitationResponses // ignore: cast_nullable_to_non_nullable
              as bool?,
      pushTaskReminders: freezed == pushTaskReminders
          ? _value.pushTaskReminders
          : pushTaskReminders // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UpdateUserSettingsRequestImplCopyWith<$Res>
    implements $UpdateUserSettingsRequestCopyWith<$Res> {
  factory _$$UpdateUserSettingsRequestImplCopyWith(
          _$UpdateUserSettingsRequestImpl value,
          $Res Function(_$UpdateUserSettingsRequestImpl) then) =
      __$$UpdateUserSettingsRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? mainThemeColor,
      bool? darkModeEnabled,
      bool? pushInvitations,
      bool? pushInvitationResponses,
      bool? pushTaskReminders});
}

/// @nodoc
class __$$UpdateUserSettingsRequestImplCopyWithImpl<$Res>
    extends _$UpdateUserSettingsRequestCopyWithImpl<$Res,
        _$UpdateUserSettingsRequestImpl>
    implements _$$UpdateUserSettingsRequestImplCopyWith<$Res> {
  __$$UpdateUserSettingsRequestImplCopyWithImpl(
      _$UpdateUserSettingsRequestImpl _value,
      $Res Function(_$UpdateUserSettingsRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of UpdateUserSettingsRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mainThemeColor = freezed,
    Object? darkModeEnabled = freezed,
    Object? pushInvitations = freezed,
    Object? pushInvitationResponses = freezed,
    Object? pushTaskReminders = freezed,
  }) {
    return _then(_$UpdateUserSettingsRequestImpl(
      mainThemeColor: freezed == mainThemeColor
          ? _value.mainThemeColor
          : mainThemeColor // ignore: cast_nullable_to_non_nullable
              as String?,
      darkModeEnabled: freezed == darkModeEnabled
          ? _value.darkModeEnabled
          : darkModeEnabled // ignore: cast_nullable_to_non_nullable
              as bool?,
      pushInvitations: freezed == pushInvitations
          ? _value.pushInvitations
          : pushInvitations // ignore: cast_nullable_to_non_nullable
              as bool?,
      pushInvitationResponses: freezed == pushInvitationResponses
          ? _value.pushInvitationResponses
          : pushInvitationResponses // ignore: cast_nullable_to_non_nullable
              as bool?,
      pushTaskReminders: freezed == pushTaskReminders
          ? _value.pushTaskReminders
          : pushTaskReminders // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdateUserSettingsRequestImpl implements _UpdateUserSettingsRequest {
  const _$UpdateUserSettingsRequestImpl(
      {this.mainThemeColor,
      this.darkModeEnabled,
      this.pushInvitations,
      this.pushInvitationResponses,
      this.pushTaskReminders});

  factory _$UpdateUserSettingsRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpdateUserSettingsRequestImplFromJson(json);

  @override
  final String? mainThemeColor;
  @override
  final bool? darkModeEnabled;
// Push notification preferences
  @override
  final bool? pushInvitations;
  @override
  final bool? pushInvitationResponses;
  @override
  final bool? pushTaskReminders;

  @override
  String toString() {
    return 'UpdateUserSettingsRequest(mainThemeColor: $mainThemeColor, darkModeEnabled: $darkModeEnabled, pushInvitations: $pushInvitations, pushInvitationResponses: $pushInvitationResponses, pushTaskReminders: $pushTaskReminders)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateUserSettingsRequestImpl &&
            (identical(other.mainThemeColor, mainThemeColor) ||
                other.mainThemeColor == mainThemeColor) &&
            (identical(other.darkModeEnabled, darkModeEnabled) ||
                other.darkModeEnabled == darkModeEnabled) &&
            (identical(other.pushInvitations, pushInvitations) ||
                other.pushInvitations == pushInvitations) &&
            (identical(
                    other.pushInvitationResponses, pushInvitationResponses) ||
                other.pushInvitationResponses == pushInvitationResponses) &&
            (identical(other.pushTaskReminders, pushTaskReminders) ||
                other.pushTaskReminders == pushTaskReminders));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, mainThemeColor, darkModeEnabled,
      pushInvitations, pushInvitationResponses, pushTaskReminders);

  /// Create a copy of UpdateUserSettingsRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateUserSettingsRequestImplCopyWith<_$UpdateUserSettingsRequestImpl>
      get copyWith => __$$UpdateUserSettingsRequestImplCopyWithImpl<
          _$UpdateUserSettingsRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateUserSettingsRequestImplToJson(
      this,
    );
  }
}

abstract class _UpdateUserSettingsRequest implements UpdateUserSettingsRequest {
  const factory _UpdateUserSettingsRequest(
      {final String? mainThemeColor,
      final bool? darkModeEnabled,
      final bool? pushInvitations,
      final bool? pushInvitationResponses,
      final bool? pushTaskReminders}) = _$UpdateUserSettingsRequestImpl;

  factory _UpdateUserSettingsRequest.fromJson(Map<String, dynamic> json) =
      _$UpdateUserSettingsRequestImpl.fromJson;

  @override
  String? get mainThemeColor;
  @override
  bool? get darkModeEnabled; // Push notification preferences
  @override
  bool? get pushInvitations;
  @override
  bool? get pushInvitationResponses;
  @override
  bool? get pushTaskReminders;

  /// Create a copy of UpdateUserSettingsRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateUserSettingsRequestImplCopyWith<_$UpdateUserSettingsRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}
