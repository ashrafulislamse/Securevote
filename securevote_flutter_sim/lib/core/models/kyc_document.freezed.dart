// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'kyc_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

KycDocument _$KycDocumentFromJson(Map<String, dynamic> json) {
  return _KycDocument.fromJson(json);
}

/// @nodoc
mixin _$KycDocument {
  String get id => throw _privateConstructorUsedError;
  String get docType => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(
    fromJson: epochMsToDateTimeNullable,
    toJson: dateTimeToEpochMsNullable,
  )
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this KycDocument to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of KycDocument
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $KycDocumentCopyWith<KycDocument> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KycDocumentCopyWith<$Res> {
  factory $KycDocumentCopyWith(
    KycDocument value,
    $Res Function(KycDocument) then,
  ) = _$KycDocumentCopyWithImpl<$Res, KycDocument>;
  @useResult
  $Res call({
    String id,
    String docType,
    String status,
    @JsonKey(
      fromJson: epochMsToDateTimeNullable,
      toJson: dateTimeToEpochMsNullable,
    )
    DateTime? createdAt,
  });
}

/// @nodoc
class _$KycDocumentCopyWithImpl<$Res, $Val extends KycDocument>
    implements $KycDocumentCopyWith<$Res> {
  _$KycDocumentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of KycDocument
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? docType = null,
    Object? status = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            docType: null == docType
                ? _value.docType
                : docType // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$KycDocumentImplCopyWith<$Res>
    implements $KycDocumentCopyWith<$Res> {
  factory _$$KycDocumentImplCopyWith(
    _$KycDocumentImpl value,
    $Res Function(_$KycDocumentImpl) then,
  ) = __$$KycDocumentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String docType,
    String status,
    @JsonKey(
      fromJson: epochMsToDateTimeNullable,
      toJson: dateTimeToEpochMsNullable,
    )
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$KycDocumentImplCopyWithImpl<$Res>
    extends _$KycDocumentCopyWithImpl<$Res, _$KycDocumentImpl>
    implements _$$KycDocumentImplCopyWith<$Res> {
  __$$KycDocumentImplCopyWithImpl(
    _$KycDocumentImpl _value,
    $Res Function(_$KycDocumentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of KycDocument
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? docType = null,
    Object? status = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$KycDocumentImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        docType: null == docType
            ? _value.docType
            : docType // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$KycDocumentImpl implements _KycDocument {
  const _$KycDocumentImpl({
    required this.id,
    this.docType = 'id',
    this.status = 'pending',
    @JsonKey(
      fromJson: epochMsToDateTimeNullable,
      toJson: dateTimeToEpochMsNullable,
    )
    this.createdAt,
  });

  factory _$KycDocumentImpl.fromJson(Map<String, dynamic> json) =>
      _$$KycDocumentImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey()
  final String docType;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(
    fromJson: epochMsToDateTimeNullable,
    toJson: dateTimeToEpochMsNullable,
  )
  final DateTime? createdAt;

  @override
  String toString() {
    return 'KycDocument(id: $id, docType: $docType, status: $status, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KycDocumentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.docType, docType) || other.docType == docType) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, docType, status, createdAt);

  /// Create a copy of KycDocument
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$KycDocumentImplCopyWith<_$KycDocumentImpl> get copyWith =>
      __$$KycDocumentImplCopyWithImpl<_$KycDocumentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$KycDocumentImplToJson(this);
  }
}

abstract class _KycDocument implements KycDocument {
  const factory _KycDocument({
    required final String id,
    final String docType,
    final String status,
    @JsonKey(
      fromJson: epochMsToDateTimeNullable,
      toJson: dateTimeToEpochMsNullable,
    )
    final DateTime? createdAt,
  }) = _$KycDocumentImpl;

  factory _KycDocument.fromJson(Map<String, dynamic> json) =
      _$KycDocumentImpl.fromJson;

  @override
  String get id;
  @override
  String get docType;
  @override
  String get status;
  @override
  @JsonKey(
    fromJson: epochMsToDateTimeNullable,
    toJson: dateTimeToEpochMsNullable,
  )
  DateTime? get createdAt;

  /// Create a copy of KycDocument
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$KycDocumentImplCopyWith<_$KycDocumentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
