// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'candidate.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Candidate _$CandidateFromJson(Map<String, dynamic> json) {
  return _Candidate.fromJson(json);
}

/// @nodoc
mixin _$Candidate {
  String get id => throw _privateConstructorUsedError;
  String get electionId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get party => throw _privateConstructorUsedError;
  String? get bio => throw _privateConstructorUsedError;
  String? get manifesto => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  int get ballotOrder => throw _privateConstructorUsedError;

  /// Serializes this Candidate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Candidate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CandidateCopyWith<Candidate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CandidateCopyWith<$Res> {
  factory $CandidateCopyWith(Candidate value, $Res Function(Candidate) then) =
      _$CandidateCopyWithImpl<$Res, Candidate>;
  @useResult
  $Res call({
    String id,
    String electionId,
    String name,
    String? party,
    String? bio,
    String? manifesto,
    String? photoUrl,
    int ballotOrder,
  });
}

/// @nodoc
class _$CandidateCopyWithImpl<$Res, $Val extends Candidate>
    implements $CandidateCopyWith<$Res> {
  _$CandidateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Candidate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? electionId = null,
    Object? name = null,
    Object? party = freezed,
    Object? bio = freezed,
    Object? manifesto = freezed,
    Object? photoUrl = freezed,
    Object? ballotOrder = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            electionId: null == electionId
                ? _value.electionId
                : electionId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            party: freezed == party
                ? _value.party
                : party // ignore: cast_nullable_to_non_nullable
                      as String?,
            bio: freezed == bio
                ? _value.bio
                : bio // ignore: cast_nullable_to_non_nullable
                      as String?,
            manifesto: freezed == manifesto
                ? _value.manifesto
                : manifesto // ignore: cast_nullable_to_non_nullable
                      as String?,
            photoUrl: freezed == photoUrl
                ? _value.photoUrl
                : photoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            ballotOrder: null == ballotOrder
                ? _value.ballotOrder
                : ballotOrder // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CandidateImplCopyWith<$Res>
    implements $CandidateCopyWith<$Res> {
  factory _$$CandidateImplCopyWith(
    _$CandidateImpl value,
    $Res Function(_$CandidateImpl) then,
  ) = __$$CandidateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String electionId,
    String name,
    String? party,
    String? bio,
    String? manifesto,
    String? photoUrl,
    int ballotOrder,
  });
}

/// @nodoc
class __$$CandidateImplCopyWithImpl<$Res>
    extends _$CandidateCopyWithImpl<$Res, _$CandidateImpl>
    implements _$$CandidateImplCopyWith<$Res> {
  __$$CandidateImplCopyWithImpl(
    _$CandidateImpl _value,
    $Res Function(_$CandidateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Candidate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? electionId = null,
    Object? name = null,
    Object? party = freezed,
    Object? bio = freezed,
    Object? manifesto = freezed,
    Object? photoUrl = freezed,
    Object? ballotOrder = null,
  }) {
    return _then(
      _$CandidateImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        electionId: null == electionId
            ? _value.electionId
            : electionId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        party: freezed == party
            ? _value.party
            : party // ignore: cast_nullable_to_non_nullable
                  as String?,
        bio: freezed == bio
            ? _value.bio
            : bio // ignore: cast_nullable_to_non_nullable
                  as String?,
        manifesto: freezed == manifesto
            ? _value.manifesto
            : manifesto // ignore: cast_nullable_to_non_nullable
                  as String?,
        photoUrl: freezed == photoUrl
            ? _value.photoUrl
            : photoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        ballotOrder: null == ballotOrder
            ? _value.ballotOrder
            : ballotOrder // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CandidateImpl implements _Candidate {
  const _$CandidateImpl({
    required this.id,
    required this.electionId,
    required this.name,
    this.party,
    this.bio,
    this.manifesto,
    this.photoUrl,
    this.ballotOrder = 0,
  });

  factory _$CandidateImpl.fromJson(Map<String, dynamic> json) =>
      _$$CandidateImplFromJson(json);

  @override
  final String id;
  @override
  final String electionId;
  @override
  final String name;
  @override
  final String? party;
  @override
  final String? bio;
  @override
  final String? manifesto;
  @override
  final String? photoUrl;
  @override
  @JsonKey()
  final int ballotOrder;

  @override
  String toString() {
    return 'Candidate(id: $id, electionId: $electionId, name: $name, party: $party, bio: $bio, manifesto: $manifesto, photoUrl: $photoUrl, ballotOrder: $ballotOrder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CandidateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.electionId, electionId) ||
                other.electionId == electionId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.party, party) || other.party == party) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.manifesto, manifesto) ||
                other.manifesto == manifesto) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.ballotOrder, ballotOrder) ||
                other.ballotOrder == ballotOrder));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    electionId,
    name,
    party,
    bio,
    manifesto,
    photoUrl,
    ballotOrder,
  );

  /// Create a copy of Candidate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CandidateImplCopyWith<_$CandidateImpl> get copyWith =>
      __$$CandidateImplCopyWithImpl<_$CandidateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CandidateImplToJson(this);
  }
}

abstract class _Candidate implements Candidate {
  const factory _Candidate({
    required final String id,
    required final String electionId,
    required final String name,
    final String? party,
    final String? bio,
    final String? manifesto,
    final String? photoUrl,
    final int ballotOrder,
  }) = _$CandidateImpl;

  factory _Candidate.fromJson(Map<String, dynamic> json) =
      _$CandidateImpl.fromJson;

  @override
  String get id;
  @override
  String get electionId;
  @override
  String get name;
  @override
  String? get party;
  @override
  String? get bio;
  @override
  String? get manifesto;
  @override
  String? get photoUrl;
  @override
  int get ballotOrder;

  /// Create a copy of Candidate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CandidateImplCopyWith<_$CandidateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
