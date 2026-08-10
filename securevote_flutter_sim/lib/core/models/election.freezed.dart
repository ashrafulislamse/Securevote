// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'election.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Election _$ElectionFromJson(Map<String, dynamic> json) {
  return _Election.fromJson(json);
}

/// @nodoc
mixin _$Election {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get organization => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(fromJson: epochMsToDateTime, toJson: dateTimeToEpochMs)
  DateTime get startsAt => throw _privateConstructorUsedError;
  @JsonKey(fromJson: epochMsToDateTime, toJson: dateTimeToEpochMs)
  DateTime get endsAt => throw _privateConstructorUsedError;
  int? get candidateCount => throw _privateConstructorUsedError;

  /// Serializes this Election to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Election
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ElectionCopyWith<Election> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ElectionCopyWith<$Res> {
  factory $ElectionCopyWith(Election value, $Res Function(Election) then) =
      _$ElectionCopyWithImpl<$Res, Election>;
  @useResult
  $Res call({
    String id,
    String title,
    String? description,
    String? organization,
    String type,
    String status,
    @JsonKey(fromJson: epochMsToDateTime, toJson: dateTimeToEpochMs)
    DateTime startsAt,
    @JsonKey(fromJson: epochMsToDateTime, toJson: dateTimeToEpochMs)
    DateTime endsAt,
    int? candidateCount,
  });
}

/// @nodoc
class _$ElectionCopyWithImpl<$Res, $Val extends Election>
    implements $ElectionCopyWith<$Res> {
  _$ElectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Election
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? organization = freezed,
    Object? type = null,
    Object? status = null,
    Object? startsAt = null,
    Object? endsAt = null,
    Object? candidateCount = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            organization: freezed == organization
                ? _value.organization
                : organization // ignore: cast_nullable_to_non_nullable
                      as String?,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            startsAt: null == startsAt
                ? _value.startsAt
                : startsAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endsAt: null == endsAt
                ? _value.endsAt
                : endsAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            candidateCount: freezed == candidateCount
                ? _value.candidateCount
                : candidateCount // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ElectionImplCopyWith<$Res>
    implements $ElectionCopyWith<$Res> {
  factory _$$ElectionImplCopyWith(
    _$ElectionImpl value,
    $Res Function(_$ElectionImpl) then,
  ) = __$$ElectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String? description,
    String? organization,
    String type,
    String status,
    @JsonKey(fromJson: epochMsToDateTime, toJson: dateTimeToEpochMs)
    DateTime startsAt,
    @JsonKey(fromJson: epochMsToDateTime, toJson: dateTimeToEpochMs)
    DateTime endsAt,
    int? candidateCount,
  });
}

/// @nodoc
class __$$ElectionImplCopyWithImpl<$Res>
    extends _$ElectionCopyWithImpl<$Res, _$ElectionImpl>
    implements _$$ElectionImplCopyWith<$Res> {
  __$$ElectionImplCopyWithImpl(
    _$ElectionImpl _value,
    $Res Function(_$ElectionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Election
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? organization = freezed,
    Object? type = null,
    Object? status = null,
    Object? startsAt = null,
    Object? endsAt = null,
    Object? candidateCount = freezed,
  }) {
    return _then(
      _$ElectionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        organization: freezed == organization
            ? _value.organization
            : organization // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        startsAt: null == startsAt
            ? _value.startsAt
            : startsAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endsAt: null == endsAt
            ? _value.endsAt
            : endsAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        candidateCount: freezed == candidateCount
            ? _value.candidateCount
            : candidateCount // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ElectionImpl implements _Election {
  const _$ElectionImpl({
    required this.id,
    required this.title,
    this.description,
    this.organization,
    this.type = 'general',
    this.status = 'upcoming',
    @JsonKey(fromJson: epochMsToDateTime, toJson: dateTimeToEpochMs)
    required this.startsAt,
    @JsonKey(fromJson: epochMsToDateTime, toJson: dateTimeToEpochMs)
    required this.endsAt,
    this.candidateCount,
  });

  factory _$ElectionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ElectionImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String? description;
  @override
  final String? organization;
  @override
  @JsonKey()
  final String type;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(fromJson: epochMsToDateTime, toJson: dateTimeToEpochMs)
  final DateTime startsAt;
  @override
  @JsonKey(fromJson: epochMsToDateTime, toJson: dateTimeToEpochMs)
  final DateTime endsAt;
  @override
  final int? candidateCount;

  @override
  String toString() {
    return 'Election(id: $id, title: $title, description: $description, organization: $organization, type: $type, status: $status, startsAt: $startsAt, endsAt: $endsAt, candidateCount: $candidateCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ElectionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.organization, organization) ||
                other.organization == organization) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.startsAt, startsAt) ||
                other.startsAt == startsAt) &&
            (identical(other.endsAt, endsAt) || other.endsAt == endsAt) &&
            (identical(other.candidateCount, candidateCount) ||
                other.candidateCount == candidateCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    description,
    organization,
    type,
    status,
    startsAt,
    endsAt,
    candidateCount,
  );

  /// Create a copy of Election
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ElectionImplCopyWith<_$ElectionImpl> get copyWith =>
      __$$ElectionImplCopyWithImpl<_$ElectionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ElectionImplToJson(this);
  }
}

abstract class _Election implements Election {
  const factory _Election({
    required final String id,
    required final String title,
    final String? description,
    final String? organization,
    final String type,
    final String status,
    @JsonKey(fromJson: epochMsToDateTime, toJson: dateTimeToEpochMs)
    required final DateTime startsAt,
    @JsonKey(fromJson: epochMsToDateTime, toJson: dateTimeToEpochMs)
    required final DateTime endsAt,
    final int? candidateCount,
  }) = _$ElectionImpl;

  factory _Election.fromJson(Map<String, dynamic> json) =
      _$ElectionImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String? get description;
  @override
  String? get organization;
  @override
  String get type;
  @override
  String get status;
  @override
  @JsonKey(fromJson: epochMsToDateTime, toJson: dateTimeToEpochMs)
  DateTime get startsAt;
  @override
  @JsonKey(fromJson: epochMsToDateTime, toJson: dateTimeToEpochMs)
  DateTime get endsAt;
  @override
  int? get candidateCount;

  /// Create a copy of Election
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ElectionImplCopyWith<_$ElectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
