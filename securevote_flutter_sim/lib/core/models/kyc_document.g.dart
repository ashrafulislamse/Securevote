// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kyc_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$KycDocumentImpl _$$KycDocumentImplFromJson(Map<String, dynamic> json) =>
    _$KycDocumentImpl(
      id: json['id'] as String,
      docType: json['docType'] as String? ?? 'id',
      status: json['status'] as String? ?? 'pending',
      createdAt: epochMsToDateTimeNullable(json['createdAt']),
    );

Map<String, dynamic> _$$KycDocumentImplToJson(_$KycDocumentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'docType': instance.docType,
      'status': instance.status,
      'createdAt': dateTimeToEpochMsNullable(instance.createdAt),
    };
