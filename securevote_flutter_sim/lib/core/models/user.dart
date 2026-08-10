import 'package:freezed_annotation/freezed_annotation.dart';

import 'kyc_status.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// An authenticated application user.
///
/// The active user is exposed by the auth layer (see `AuthProvider`). The API
/// returns slightly different shapes depending on the endpoint (e.g. the auth
/// responses omit `phone`, `profilePic`, and `createdAt`), so those fields are
/// nullable.
@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String fullName,
    String? phone,
    @Default('voter') String role,
    @Default(KycStatus.notSubmitted) KycStatus kycStatus,
    String? profilePic,
    DateTime? createdAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}