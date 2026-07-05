// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vacation_period.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

VacationPeriodResponse _$VacationPeriodResponseFromJson(
    Map<String, dynamic> json) {
  return _VacationPeriodResponse.fromJson(json);
}

/// @nodoc
mixin _$VacationPeriodResponse {
  int get id => throw _privateConstructorUsedError;
  int get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get endDate => throw _privateConstructorUsedError;

  /// Serializes this VacationPeriodResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VacationPeriodResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VacationPeriodResponseCopyWith<VacationPeriodResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VacationPeriodResponseCopyWith<$Res> {
  factory $VacationPeriodResponseCopyWith(VacationPeriodResponse value,
          $Res Function(VacationPeriodResponse) then) =
      _$VacationPeriodResponseCopyWithImpl<$Res, VacationPeriodResponse>;
  @useResult
  $Res call(
      {int id, int userId, String name, DateTime startDate, DateTime endDate});
}

/// @nodoc
class _$VacationPeriodResponseCopyWithImpl<$Res,
        $Val extends VacationPeriodResponse>
    implements $VacationPeriodResponseCopyWith<$Res> {
  _$VacationPeriodResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VacationPeriodResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? startDate = null,
    Object? endDate = null,
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
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VacationPeriodResponseImplCopyWith<$Res>
    implements $VacationPeriodResponseCopyWith<$Res> {
  factory _$$VacationPeriodResponseImplCopyWith(
          _$VacationPeriodResponseImpl value,
          $Res Function(_$VacationPeriodResponseImpl) then) =
      __$$VacationPeriodResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id, int userId, String name, DateTime startDate, DateTime endDate});
}

/// @nodoc
class __$$VacationPeriodResponseImplCopyWithImpl<$Res>
    extends _$VacationPeriodResponseCopyWithImpl<$Res,
        _$VacationPeriodResponseImpl>
    implements _$$VacationPeriodResponseImplCopyWith<$Res> {
  __$$VacationPeriodResponseImplCopyWithImpl(
      _$VacationPeriodResponseImpl _value,
      $Res Function(_$VacationPeriodResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of VacationPeriodResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? startDate = null,
    Object? endDate = null,
  }) {
    return _then(_$VacationPeriodResponseImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VacationPeriodResponseImpl implements _VacationPeriodResponse {
  const _$VacationPeriodResponseImpl(
      {required this.id,
      required this.userId,
      required this.name,
      required this.startDate,
      required this.endDate});

  factory _$VacationPeriodResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$VacationPeriodResponseImplFromJson(json);

  @override
  final int id;
  @override
  final int userId;
  @override
  final String name;
  @override
  final DateTime startDate;
  @override
  final DateTime endDate;

  @override
  String toString() {
    return 'VacationPeriodResponse(id: $id, userId: $userId, name: $name, startDate: $startDate, endDate: $endDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VacationPeriodResponseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, userId, name, startDate, endDate);

  /// Create a copy of VacationPeriodResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VacationPeriodResponseImplCopyWith<_$VacationPeriodResponseImpl>
      get copyWith => __$$VacationPeriodResponseImplCopyWithImpl<
          _$VacationPeriodResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VacationPeriodResponseImplToJson(
      this,
    );
  }
}

abstract class _VacationPeriodResponse implements VacationPeriodResponse {
  const factory _VacationPeriodResponse(
      {required final int id,
      required final int userId,
      required final String name,
      required final DateTime startDate,
      required final DateTime endDate}) = _$VacationPeriodResponseImpl;

  factory _VacationPeriodResponse.fromJson(Map<String, dynamic> json) =
      _$VacationPeriodResponseImpl.fromJson;

  @override
  int get id;
  @override
  int get userId;
  @override
  String get name;
  @override
  DateTime get startDate;
  @override
  DateTime get endDate;

  /// Create a copy of VacationPeriodResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VacationPeriodResponseImplCopyWith<_$VacationPeriodResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

CreateVacationPeriodRequest _$CreateVacationPeriodRequestFromJson(
    Map<String, dynamic> json) {
  return _CreateVacationPeriodRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateVacationPeriodRequest {
  String get name => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get endDate => throw _privateConstructorUsedError;

  /// Serializes this CreateVacationPeriodRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateVacationPeriodRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateVacationPeriodRequestCopyWith<CreateVacationPeriodRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateVacationPeriodRequestCopyWith<$Res> {
  factory $CreateVacationPeriodRequestCopyWith(
          CreateVacationPeriodRequest value,
          $Res Function(CreateVacationPeriodRequest) then) =
      _$CreateVacationPeriodRequestCopyWithImpl<$Res,
          CreateVacationPeriodRequest>;
  @useResult
  $Res call({String name, DateTime startDate, DateTime endDate});
}

/// @nodoc
class _$CreateVacationPeriodRequestCopyWithImpl<$Res,
        $Val extends CreateVacationPeriodRequest>
    implements $CreateVacationPeriodRequestCopyWith<$Res> {
  _$CreateVacationPeriodRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateVacationPeriodRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? startDate = null,
    Object? endDate = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateVacationPeriodRequestImplCopyWith<$Res>
    implements $CreateVacationPeriodRequestCopyWith<$Res> {
  factory _$$CreateVacationPeriodRequestImplCopyWith(
          _$CreateVacationPeriodRequestImpl value,
          $Res Function(_$CreateVacationPeriodRequestImpl) then) =
      __$$CreateVacationPeriodRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, DateTime startDate, DateTime endDate});
}

/// @nodoc
class __$$CreateVacationPeriodRequestImplCopyWithImpl<$Res>
    extends _$CreateVacationPeriodRequestCopyWithImpl<$Res,
        _$CreateVacationPeriodRequestImpl>
    implements _$$CreateVacationPeriodRequestImplCopyWith<$Res> {
  __$$CreateVacationPeriodRequestImplCopyWithImpl(
      _$CreateVacationPeriodRequestImpl _value,
      $Res Function(_$CreateVacationPeriodRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreateVacationPeriodRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? startDate = null,
    Object? endDate = null,
  }) {
    return _then(_$CreateVacationPeriodRequestImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateVacationPeriodRequestImpl
    implements _CreateVacationPeriodRequest {
  const _$CreateVacationPeriodRequestImpl(
      {required this.name, required this.startDate, required this.endDate});

  factory _$CreateVacationPeriodRequestImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$CreateVacationPeriodRequestImplFromJson(json);

  @override
  final String name;
  @override
  final DateTime startDate;
  @override
  final DateTime endDate;

  @override
  String toString() {
    return 'CreateVacationPeriodRequest(name: $name, startDate: $startDate, endDate: $endDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateVacationPeriodRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, startDate, endDate);

  /// Create a copy of CreateVacationPeriodRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateVacationPeriodRequestImplCopyWith<_$CreateVacationPeriodRequestImpl>
      get copyWith => __$$CreateVacationPeriodRequestImplCopyWithImpl<
          _$CreateVacationPeriodRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateVacationPeriodRequestImplToJson(
      this,
    );
  }
}

abstract class _CreateVacationPeriodRequest
    implements CreateVacationPeriodRequest {
  const factory _CreateVacationPeriodRequest(
      {required final String name,
      required final DateTime startDate,
      required final DateTime endDate}) = _$CreateVacationPeriodRequestImpl;

  factory _CreateVacationPeriodRequest.fromJson(Map<String, dynamic> json) =
      _$CreateVacationPeriodRequestImpl.fromJson;

  @override
  String get name;
  @override
  DateTime get startDate;
  @override
  DateTime get endDate;

  /// Create a copy of CreateVacationPeriodRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateVacationPeriodRequestImplCopyWith<_$CreateVacationPeriodRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

UpdateVacationPeriodRequest _$UpdateVacationPeriodRequestFromJson(
    Map<String, dynamic> json) {
  return _UpdateVacationPeriodRequest.fromJson(json);
}

/// @nodoc
mixin _$UpdateVacationPeriodRequest {
  String? get name => throw _privateConstructorUsedError;
  DateTime? get startDate => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;

  /// Serializes this UpdateVacationPeriodRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UpdateVacationPeriodRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpdateVacationPeriodRequestCopyWith<UpdateVacationPeriodRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateVacationPeriodRequestCopyWith<$Res> {
  factory $UpdateVacationPeriodRequestCopyWith(
          UpdateVacationPeriodRequest value,
          $Res Function(UpdateVacationPeriodRequest) then) =
      _$UpdateVacationPeriodRequestCopyWithImpl<$Res,
          UpdateVacationPeriodRequest>;
  @useResult
  $Res call({String? name, DateTime? startDate, DateTime? endDate});
}

/// @nodoc
class _$UpdateVacationPeriodRequestCopyWithImpl<$Res,
        $Val extends UpdateVacationPeriodRequest>
    implements $UpdateVacationPeriodRequestCopyWith<$Res> {
  _$UpdateVacationPeriodRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpdateVacationPeriodRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
  }) {
    return _then(_value.copyWith(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UpdateVacationPeriodRequestImplCopyWith<$Res>
    implements $UpdateVacationPeriodRequestCopyWith<$Res> {
  factory _$$UpdateVacationPeriodRequestImplCopyWith(
          _$UpdateVacationPeriodRequestImpl value,
          $Res Function(_$UpdateVacationPeriodRequestImpl) then) =
      __$$UpdateVacationPeriodRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? name, DateTime? startDate, DateTime? endDate});
}

/// @nodoc
class __$$UpdateVacationPeriodRequestImplCopyWithImpl<$Res>
    extends _$UpdateVacationPeriodRequestCopyWithImpl<$Res,
        _$UpdateVacationPeriodRequestImpl>
    implements _$$UpdateVacationPeriodRequestImplCopyWith<$Res> {
  __$$UpdateVacationPeriodRequestImplCopyWithImpl(
      _$UpdateVacationPeriodRequestImpl _value,
      $Res Function(_$UpdateVacationPeriodRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of UpdateVacationPeriodRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
  }) {
    return _then(_$UpdateVacationPeriodRequestImpl(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdateVacationPeriodRequestImpl
    implements _UpdateVacationPeriodRequest {
  const _$UpdateVacationPeriodRequestImpl(
      {this.name, this.startDate, this.endDate});

  factory _$UpdateVacationPeriodRequestImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$UpdateVacationPeriodRequestImplFromJson(json);

  @override
  final String? name;
  @override
  final DateTime? startDate;
  @override
  final DateTime? endDate;

  @override
  String toString() {
    return 'UpdateVacationPeriodRequest(name: $name, startDate: $startDate, endDate: $endDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateVacationPeriodRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, startDate, endDate);

  /// Create a copy of UpdateVacationPeriodRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateVacationPeriodRequestImplCopyWith<_$UpdateVacationPeriodRequestImpl>
      get copyWith => __$$UpdateVacationPeriodRequestImplCopyWithImpl<
          _$UpdateVacationPeriodRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateVacationPeriodRequestImplToJson(
      this,
    );
  }
}

abstract class _UpdateVacationPeriodRequest
    implements UpdateVacationPeriodRequest {
  const factory _UpdateVacationPeriodRequest(
      {final String? name,
      final DateTime? startDate,
      final DateTime? endDate}) = _$UpdateVacationPeriodRequestImpl;

  factory _UpdateVacationPeriodRequest.fromJson(Map<String, dynamic> json) =
      _$UpdateVacationPeriodRequestImpl.fromJson;

  @override
  String? get name;
  @override
  DateTime? get startDate;
  @override
  DateTime? get endDate;

  /// Create a copy of UpdateVacationPeriodRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateVacationPeriodRequestImplCopyWith<_$UpdateVacationPeriodRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}
