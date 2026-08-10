// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vote.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VoteImpl _$$VoteImplFromJson(Map<String, dynamic> json) => _$VoteImpl(
  id: json['id'] as String,
  electionId: json['electionId'] as String,
  electionTitle: json['electionTitle'] as String?,
  selections: (json['selections'] as List<dynamic>)
      .map((e) => Map<String, String>.from(e as Map))
      .toList(),
  receiptId: json['receiptId'] as String,
  voteHash: json['voteHash'] as String?,
  txHash: json['txHash'] as String?,
  blockNumber: (json['blockNumber'] as num?)?.toInt(),
  createdAt: epochMsToDateTime(json['createdAt']),
);

Map<String, dynamic> _$$VoteImplToJson(_$VoteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'electionId': instance.electionId,
      'electionTitle': instance.electionTitle,
      'selections': instance.selections,
      'receiptId': instance.receiptId,
      'voteHash': instance.voteHash,
      'txHash': instance.txHash,
      'blockNumber': instance.blockNumber,
      'createdAt': dateTimeToEpochMs(instance.createdAt),
    };
