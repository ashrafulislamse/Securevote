// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'candidate.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CandidateImpl _$$CandidateImplFromJson(Map<String, dynamic> json) =>
    _$CandidateImpl(
      id: json['id'] as String,
      electionId: json['electionId'] as String,
      name: json['name'] as String,
      party: json['party'] as String?,
      bio: json['bio'] as String?,
      manifesto: json['manifesto'] as String?,
      photoUrl: json['photoUrl'] as String?,
      ballotOrder: (json['ballotOrder'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$CandidateImplToJson(_$CandidateImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'electionId': instance.electionId,
      'name': instance.name,
      'party': instance.party,
      'bio': instance.bio,
      'manifesto': instance.manifesto,
      'photoUrl': instance.photoUrl,
      'ballotOrder': instance.ballotOrder,
    };
