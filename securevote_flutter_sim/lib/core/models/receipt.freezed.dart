// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'receipt.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Receipt _$ReceiptFromJson(Map<String, dynamic> json) {
  return _Receipt.fromJson(json);
}

/// @nodoc
mixin _$Receipt {
  String get id => throw _privateConstructorUsedError;
  String get electionId => throw _privateConstructorUsedError;
  String? get electionTitle => throw _privateConstructorUsedError;
  String? get candidateName => throw _privateConstructorUsedError;
  List<Map<String, String>> get selections =>
      throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get txHash => throw _privateConstructorUsedError;
  @JsonKey(fromJson: epochMsToDateTime, toJson: dateTimeToEpochMs)
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Receipt to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Receipt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReceiptCopyWith<Receipt> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReceiptCopyWith<$Res> {
  factory $ReceiptCopyWith(Receipt value, $Res Function(Receipt) then) =
      _$ReceiptCopyWithImpl<$Res, Receipt>;
  @useResult
  $Res call({
    String id,
    String electionId,
    String? electionTitle,
    String? candidateName,
    List<Map<String, String>> selections,
    String status,
    String? txHash,
    @JsonKey(fromJson: epochMsToDateTime, toJson: dateTimeToEpochMs)
    DateTime createdAt,
  });
}

/// @nodoc
class _$ReceiptCopyWithImpl<$Res, $Val extends Receipt>
    implements $ReceiptCopyWith<$Res> {
  _$ReceiptCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Receipt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? electionId = null,
    Object? electionTitle = freezed,
    Object? candidateName = freezed,
    Object? selections = null,
    Object? status = null,
    Object? txHash = freezed,
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
            electionTitle: freezed == electionTitle
                ? _value.electionTitle
                : electionTitle // ignore: cast_nullable_to_non_nullable
                      as String?,
            candidateName: freezed == candidateName
                ? _value.candidateName
                : candidateName // ignore: cast_nullable_to_non_nullable
                      as String?,
            selections: null == selections
                ? _value.selections
                : selections // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, String>>,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            txHash: freezed == txHash
                ? _value.txHash
                : txHash // ignore: cast_nullable_to_non_nullable
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
abstract class _$$ReceiptImplCopyWith<$Res> implements $ReceiptCopyWith<$Res> {
  factory _$$ReceiptImplCopyWith(
    _$ReceiptImpl value,
    $Res Function(_$ReceiptImpl) then,
  ) = __$$ReceiptImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String electionId,
    String? electionTitle,
    String? candidateName,
    List<Map<String, String>> selections,
    String status,
    String? txHash,
    @JsonKey(fromJson: epochMsToDateTime, toJson: dateTimeToEpochMs)
    DateTime createdAt,
  });
}

/// @nodoc
class __$$ReceiptImplCopyWithImpl<$Res>
    extends _$ReceiptCopyWithImpl<$Res, _$ReceiptImpl>
    implements _$$ReceiptImplCopyWith<$Res> {
  __$$ReceiptImplCopyWithImpl(
    _$ReceiptImpl _value,
    $Res Function(_$ReceiptImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Receipt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? electionId = null,
    Object? electionTitle = freezed,
    Object? candidateName = freezed,
    Object? selections = null,
    Object? status = null,
    Object? txHash = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$ReceiptImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        electionId: null == electionId
            ? _value.electionId
            : electionId // ignore: cast_nullable_to_non_nullable
                  as String,
        electionTitle: freezed == electionTitle
            ? _value.electionTitle
            : electionTitle // ignore: cast_nullable_to_non_nullable
                  as String?,
        candidateName: freezed == candidateName
            ? _value.candidateName
            : candidateName // ignore: cast_nullable_to_non_nullable
                  as String?,
        selections: null == selections
            ? _value._selections
            : selections // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, String>>,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        txHash: freezed == txHash
            ? _value.txHash
            : txHash // ignore: cast_nullable_to_non_nullable
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
class _$ReceiptImpl implements _Receipt {
  const _$ReceiptImpl({
    required this.id,
    required this.electionId,
    this.electionTitle,
    this.candidateName,
    required final List<Map<String, String>> selections,
    this.status = 'confirmed',
    this.txHash,
    @JsonKey(fromJson: epochMsToDateTime, toJson: dateTimeToEpochMs)
    required this.createdAt,
  }) : _selections = selections;

  factory _$ReceiptImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReceiptImplFromJson(json);

  @override
  final String id;
  @override
  final String electionId;
  @override
  final String? electionTitle;
  @override
  final String? candidateName;
  final List<Map<String, String>> _selections;
  @override
  List<Map<String, String>> get selections {
    if (_selections is EqualUnmodifiableListView) return _selections;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selections);
  }

  @override
  @JsonKey()
  final String status;
  @override
  final String? txHash;
  @override
  @JsonKey(fromJson: epochMsToDateTime, toJson: dateTimeToEpochMs)
  final DateTime createdAt;

  @override
  String toString() {
    return 'Receipt(id: $id, electionId: $electionId, electionTitle: $electionTitle, candidateName: $candidateName, selections: $selections, status: $status, txHash: $txHash, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReceiptImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.electionId, electionId) ||
                other.electionId == electionId) &&
            (identical(other.electionTitle, electionTitle) ||
                other.electionTitle == electionTitle) &&
            (identical(other.candidateName, candidateName) ||
                other.candidateName == candidateName) &&
            const DeepCollectionEquality().equals(
              other._selections,
              _selections,
            ) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.txHash, txHash) || other.txHash == txHash) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    electionId,
    electionTitle,
    candidateName,
    const DeepCollectionEquality().hash(_selections),
    status,
    txHash,
    createdAt,
  );

  /// Create a copy of Receipt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReceiptImplCopyWith<_$ReceiptImpl> get copyWith =>
      __$$ReceiptImplCopyWithImpl<_$ReceiptImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReceiptImplToJson(this);
  }
}

abstract class _Receipt implements Receipt {
  const factory _Receipt({
    required final String id,
    required final String electionId,
    final String? electionTitle,
    final String? candidateName,
    required final List<Map<String, String>> selections,
    final String status,
    final String? txHash,
    @JsonKey(fromJson: epochMsToDateTime, toJson: dateTimeToEpochMs)
    required final DateTime createdAt,
  }) = _$ReceiptImpl;

  factory _Receipt.fromJson(Map<String, dynamic> json) = _$ReceiptImpl.fromJson;

  @override
  String get id;
  @override
  String get electionId;
  @override
  String? get electionTitle;
  @override
  String? get candidateName;
  @override
  List<Map<String, String>> get selections;
  @override
  String get status;
  @override
  String? get txHash;
  @override
  @JsonKey(fromJson: epochMsToDateTime, toJson: dateTimeToEpochMs)
  DateTime get createdAt;

  /// Create a copy of Receipt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReceiptImplCopyWith<_$ReceiptImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
