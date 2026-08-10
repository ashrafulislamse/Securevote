// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthSessionImpl _$$AuthSessionImplFromJson(Map<String, dynamic> json) =>
    _$AuthSessionImpl(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresAt: epochMsToDateTime(json['expiresAt']),
    );

Map<String, dynamic> _$$AuthSessionImplToJson(_$AuthSessionImpl instance) =>
    <String, dynamic>{
      'user': instance.user,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'expiresAt': dateTimeToEpochMs(instance.expiresAt),
    };
