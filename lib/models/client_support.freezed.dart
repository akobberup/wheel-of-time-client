// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_support.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ClientSupportResponse _$ClientSupportResponseFromJson(
    Map<String, dynamic> json) {
  return _ClientSupportResponse.fromJson(json);
}

/// @nodoc
mixin _$ClientSupportResponse {
  ClientSupportStatus get status => throw _privateConstructorUsedError;
  String get currentVersion => throw _privateConstructorUsedError;
  String get minimumSupportedVersion => throw _privateConstructorUsedError;
  String get latestVersion => throw _privateConstructorUsedError;

  /// Serializes this ClientSupportResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClientSupportResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClientSupportResponseCopyWith<ClientSupportResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClientSupportResponseCopyWith<$Res> {
  factory $ClientSupportResponseCopyWith(ClientSupportResponse value,
          $Res Function(ClientSupportResponse) then) =
      _$ClientSupportResponseCopyWithImpl<$Res, ClientSupportResponse>;
  @useResult
  $Res call(
      {ClientSupportStatus status,
      String currentVersion,
      String minimumSupportedVersion,
      String latestVersion});
}

/// @nodoc
class _$ClientSupportResponseCopyWithImpl<$Res,
        $Val extends ClientSupportResponse>
    implements $ClientSupportResponseCopyWith<$Res> {
  _$ClientSupportResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClientSupportResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? currentVersion = null,
    Object? minimumSupportedVersion = null,
    Object? latestVersion = null,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ClientSupportStatus,
      currentVersion: null == currentVersion
          ? _value.currentVersion
          : currentVersion // ignore: cast_nullable_to_non_nullable
              as String,
      minimumSupportedVersion: null == minimumSupportedVersion
          ? _value.minimumSupportedVersion
          : minimumSupportedVersion // ignore: cast_nullable_to_non_nullable
              as String,
      latestVersion: null == latestVersion
          ? _value.latestVersion
          : latestVersion // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ClientSupportResponseImplCopyWith<$Res>
    implements $ClientSupportResponseCopyWith<$Res> {
  factory _$$ClientSupportResponseImplCopyWith(
          _$ClientSupportResponseImpl value,
          $Res Function(_$ClientSupportResponseImpl) then) =
      __$$ClientSupportResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ClientSupportStatus status,
      String currentVersion,
      String minimumSupportedVersion,
      String latestVersion});
}

/// @nodoc
class __$$ClientSupportResponseImplCopyWithImpl<$Res>
    extends _$ClientSupportResponseCopyWithImpl<$Res,
        _$ClientSupportResponseImpl>
    implements _$$ClientSupportResponseImplCopyWith<$Res> {
  __$$ClientSupportResponseImplCopyWithImpl(_$ClientSupportResponseImpl _value,
      $Res Function(_$ClientSupportResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of ClientSupportResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? currentVersion = null,
    Object? minimumSupportedVersion = null,
    Object? latestVersion = null,
  }) {
    return _then(_$ClientSupportResponseImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ClientSupportStatus,
      currentVersion: null == currentVersion
          ? _value.currentVersion
          : currentVersion // ignore: cast_nullable_to_non_nullable
              as String,
      minimumSupportedVersion: null == minimumSupportedVersion
          ? _value.minimumSupportedVersion
          : minimumSupportedVersion // ignore: cast_nullable_to_non_nullable
              as String,
      latestVersion: null == latestVersion
          ? _value.latestVersion
          : latestVersion // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ClientSupportResponseImpl implements _ClientSupportResponse {
  const _$ClientSupportResponseImpl(
      {required this.status,
      required this.currentVersion,
      required this.minimumSupportedVersion,
      required this.latestVersion});

  factory _$ClientSupportResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClientSupportResponseImplFromJson(json);

  @override
  final ClientSupportStatus status;
  @override
  final String currentVersion;
  @override
  final String minimumSupportedVersion;
  @override
  final String latestVersion;

  @override
  String toString() {
    return 'ClientSupportResponse(status: $status, currentVersion: $currentVersion, minimumSupportedVersion: $minimumSupportedVersion, latestVersion: $latestVersion)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClientSupportResponseImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.currentVersion, currentVersion) ||
                other.currentVersion == currentVersion) &&
            (identical(
                    other.minimumSupportedVersion, minimumSupportedVersion) ||
                other.minimumSupportedVersion == minimumSupportedVersion) &&
            (identical(other.latestVersion, latestVersion) ||
                other.latestVersion == latestVersion));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, status, currentVersion,
      minimumSupportedVersion, latestVersion);

  /// Create a copy of ClientSupportResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClientSupportResponseImplCopyWith<_$ClientSupportResponseImpl>
      get copyWith => __$$ClientSupportResponseImplCopyWithImpl<
          _$ClientSupportResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClientSupportResponseImplToJson(
      this,
    );
  }
}

abstract class _ClientSupportResponse implements ClientSupportResponse {
  const factory _ClientSupportResponse(
      {required final ClientSupportStatus status,
      required final String currentVersion,
      required final String minimumSupportedVersion,
      required final String latestVersion}) = _$ClientSupportResponseImpl;

  factory _ClientSupportResponse.fromJson(Map<String, dynamic> json) =
      _$ClientSupportResponseImpl.fromJson;

  @override
  ClientSupportStatus get status;
  @override
  String get currentVersion;
  @override
  String get minimumSupportedVersion;
  @override
  String get latestVersion;

  /// Create a copy of ClientSupportResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClientSupportResponseImplCopyWith<_$ClientSupportResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}
