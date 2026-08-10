// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReceiptImpl _$$ReceiptImplFromJson(Map<String, dynamic> json) =>
    _$ReceiptImpl(
      id: json['id'] as String,
      electionId: json['electionId'] as String,
      electionTitle: json['electionTitle'] as String?,
      candidateName: json['candidateName'] as String?,
      selections: (json['selections'] as List<dynamic>)
          .map((e) => Map<String, String>.from(e as Map))
          .toList(),
      status: json['status'] as String? ?? 'confirmed',
      txHash: json['txHash'] as String?,
      createdAt: epochMsToDateTime(json['createdAt']),
    );

Map<String, dynamic> _$$ReceiptImplToJson(_$ReceiptImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'electionId': instance.electionId,
      'electionTitle': instance.electionTitle,
      'candidateName': instance.candidateName,
      'selections': instance.selections,
      'status': instance.status,
      'txHash': instance.txHash,
      'createdAt': dateTimeToEpochMs(instance.createdAt),
    };
