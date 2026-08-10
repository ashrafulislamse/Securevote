// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vote.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Vote _$VoteFromJson(Map<String, dynamic> json) {
  return _Vote.fromJson(json);
}

/// @nodoc
mixin _$Vote {
  String get id => throw _privateConstructorUsedError;
  String get electionId => throw _privateConstructorUsedError;
  List<Map<String, String>> get selections =>
      throw _privateConstructorUsedError;
  String get receiptId => throw _privateConstructorUsedError;
  String? get txHash => throw _privateConstructorUsedError;
  String? get blockNumber => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Vote to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Vote
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VoteCopyWith<Vote> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VoteCopyWith<$Res> {
  factory $VoteCopyWith(Vote value, $Res Function(Vote) then) =
      _$VoteCopyWithImpl<$Res, Vote>;
  @useResult
  $Res call({
    String id,
    String electionId,
    List<Map<String, String>> selections,
    String receiptId,
    String? txHash,
    String? blockNumber,
    DateTime createdAt,
  });
}

/// @nodoc
class _$VoteCopyWithImpl<$Res, $Val extends Vote>
    implements $VoteCopyWith<$Res> {
  _$VoteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Vote
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? electionId = null,
    Object? selections = null,
    Object? receiptId = null,
    Object? txHash = freezed,
    Object? blockNumber = freezed,
    Object? createdAt = null,
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
            selections: null == selections
                ? _value.selections
                : selections // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, String>>,
            receiptId: null == receiptId
                ? _value.receiptId
                : receiptId // ignore: cast_nullable_to_non_nullable
                      as String,
            txHash: freezed == txHash
                ? _value.txHash
                : txHash // ignore: cast_nullable_to_non_nullable
                      as String?,
            blockNumber: freezed == blockNumber
                ? _value.blockNumber
                : blockNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VoteImplCopyWith<$Res> implements $VoteCopyWith<$Res> {
  factory _$$VoteImplCopyWith(
    _$VoteImpl value,
    $Res Function(_$VoteImpl) then,
  ) = __$$VoteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String electionId,
    List<Map<String, String>> selections,
    String receiptId,
    String? txHash,
    String? blockNumber,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$VoteImplCopyWithImpl<$Res>
    extends _$VoteCopyWithImpl<$Res, _$VoteImpl>
    implements _$$VoteImplCopyWith<$Res> {
  __$$VoteImplCopyWithImpl(_$VoteImpl _value, $Res Function(_$VoteImpl) _then)
    : super(_value, _then);

  /// Create a copy of Vote
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? electionId = null,
    Object? selections = null,
    Object? receiptId = null,
    Object? txHash = freezed,
    Object? blockNumber = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$VoteImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        electionId: null == electionId
            ? _value.electionId
            : electionId // ignore: cast_nullable_to_non_nullable
                  as String,
        selections: null == selections
            ? _value._selections
            : selections // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, String>>,
        receiptId: null == receiptId
            ? _value.receiptId
            : receiptId // ignore: cast_nullable_to_non_nullable
                  as String,
        txHash: freezed == txHash
            ? _value.txHash
            : txHash // ignore: cast_nullable_to_non_nullable
                  as String?,
        blockNumber: freezed == blockNumber
            ? _value.blockNumber
            : blockNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VoteImpl implements _Vote {
  const _$VoteImpl({
    required this.id,
    required this.electionId,
    required final List<Map<String, String>> selections,
    required this.receiptId,
    this.txHash,
    this.blockNumber,
    required this.createdAt,
  }) : _selections = selections;

  factory _$VoteImpl.fromJson(Map<String, dynamic> json) =>
      _$$VoteImplFromJson(json);

  @override
  final String id;
  @override
  final String electionId;
  final List<Map<String, String>> _selections;
  @override
  List<Map<String, String>> get selections {
    if (_selections is EqualUnmodifiableListView) return _selections;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selections);
  }

  @override
  final String receiptId;
  @override
  final String? txHash;
  @override
  final String? blockNumber;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'Vote(id: $id, electionId: $electionId, selections: $selections, receiptId: $receiptId, txHash: $txHash, blockNumber: $blockNumber, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VoteImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.electionId, electionId) ||
                other.electionId == electionId) &&
            const DeepCollectionEquality().equals(
              other._selections,
              _selections,
            ) &&
            (identical(other.receiptId, receiptId) ||
                other.receiptId == receiptId) &&
            (identical(other.txHash, txHash) || other.txHash == txHash) &&
            (identical(other.blockNumber, blockNumber) ||
                other.blockNumber == blockNumber) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    electionId,
    const DeepCollectionEquality().hash(_selections),
    receiptId,
    txHash,
    blockNumber,
    createdAt,
  );

  /// Create a copy of Vote
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VoteImplCopyWith<_$VoteImpl> get copyWith =>
      __$$VoteImplCopyWithImpl<_$VoteImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VoteImplToJson(this);
  }
}

abstract class _Vote implements Vote {
  const factory _Vote({
    required final String id,
    required final String electionId,
    required final List<Map<String, String>> selections,
    required final String receiptId,
    final String? txHash,
    final String? blockNumber,
    required final DateTime createdAt,
  }) = _$VoteImpl;

  factory _Vote.fromJson(Map<String, dynamic> json) = _$VoteImpl.fromJson;

  @override
  String get id;
  @override
  String get electionId;
  @override
  List<Map<String, String>> get selections;
  @override
  String get receiptId;
  @override
  String? get txHash;
  @override
  String? get blockNumber;
  @override
  DateTime get createdAt;

  /// Create a copy of Vote
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VoteImplCopyWith<_$VoteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
