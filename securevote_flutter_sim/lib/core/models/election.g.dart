// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'election.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ElectionImpl _$$ElectionImplFromJson(Map<String, dynamic> json) =>
    _$ElectionImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      organization: json['organization'] as String?,
      type: json['type'] as String? ?? 'general',
      status: json['status'] as String? ?? 'upcoming',
      startsAt: DateTime.parse(json['startsAt'] as String),
      endsAt: DateTime.parse(json['endsAt'] as String),
      candidateCount: (json['candidateCount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$ElectionImplToJson(_$ElectionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'organization': instance.organization,
      'type': instance.type,
      'status': instance.status,
      'startsAt': instance.startsAt.toIso8601String(),
      'endsAt': instance.endsAt.toIso8601String(),
      'candidateCount': instance.candidateCount,
    };
