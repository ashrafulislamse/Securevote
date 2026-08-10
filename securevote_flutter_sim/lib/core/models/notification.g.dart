// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppNotificationImpl _$$AppNotificationImplFromJson(
  Map<String, dynamic> json,
) => _$AppNotificationImpl(
  id: json['id'] as String,
  userId: json['userId'] as String? ?? '',
  title: json['title'] as String,
  body: json['body'] as String? ?? '',
  type: json['type'] as String? ?? 'info',
  read: json['read'] as bool? ?? false,
  createdAt: epochMsToDateTime(json['createdAt']),
);

Map<String, dynamic> _$$AppNotificationImplToJson(
  _$AppNotificationImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'title': instance.title,
  'body': instance.body,
  'type': instance.type,
  'read': instance.read,
  'createdAt': dateTimeToEpochMs(instance.createdAt),
};
