// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vote.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VoteImpl _$$VoteImplFromJson(Map<String, dynamic> json) => _$VoteImpl(
  id: json['id'] as String,
  electionId: json['electionId'] as String,
  selections: (json['selections'] as List<dynamic>)
      .map((e) => Map<String, String>.from(e as Map))
      .toList(),
  receiptId: json['receiptId'] as String,
  txHash: json['txHash'] as String?,
  blockNumber: json['blockNumber'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$VoteImplToJson(_$VoteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'electionId': instance.electionId,
      'selections': instance.selections,
      'receiptId': instance.receiptId,
      'txHash': instance.txHash,
      'blockNumber': instance.blockNumber,
      'createdAt': instance.createdAt.toIso8601String(),
    };
