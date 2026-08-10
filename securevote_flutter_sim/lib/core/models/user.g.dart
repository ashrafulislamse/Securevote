// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
  id: json['id'] as String,
  email: json['email'] as String,
  fullName: json['fullName'] as String,
  phone: json['phone'] as String?,
  role: json['role'] as String? ?? 'voter',
  kycStatus:
      $enumDecodeNullable(_$KycStatusEnumMap, json['kycStatus']) ??
      KycStatus.notSubmitted,
  profilePic: json['profilePic'] as String?,
  createdAt: epochMsToDateTimeNullable(json['createdAt']),
);

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'fullName': instance.fullName,
      'phone': instance.phone,
      'role': instance.role,
      'kycStatus': _$KycStatusEnumMap[instance.kycStatus]!,
      'profilePic': instance.profilePic,
      'createdAt': dateTimeToEpochMsNullable(instance.createdAt),
    };

const _$KycStatusEnumMap = {
  KycStatus.notSubmitted: 'notSubmitted',
  KycStatus.pending: 'pending',
  KycStatus.approved: 'approved',
  KycStatus.rejected: 'rejected',
};
