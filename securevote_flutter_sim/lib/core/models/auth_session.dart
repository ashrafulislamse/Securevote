import 'package:freezed_annotation/freezed_annotation.dart';

import 'user.dart';

part 'auth_session.freezed.dart';
part 'auth_session.g.dart';

/// The result of a successful authentication (login / OTP verification).
@freezed
abstract class AuthSession with _$AuthSession {
  const factory AuthSession({
    required User user,
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
  }) = _AuthSession;

  factory AuthSession.fromJson(Map<String, dynamic> json) =>
      _$AuthSessionFromJson(json);
}