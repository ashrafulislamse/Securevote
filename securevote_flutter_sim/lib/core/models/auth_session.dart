import 'package:freezed_annotation/freezed_annotation.dart';

// ignore_for_file: invalid_annotation_target

import '../utils/json_utils.dart';
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
    @JsonKey(fromJson: epochMsToDateTime, toJson: dateTimeToEpochMs)
    required DateTime expiresAt,
  }) = _AuthSession;

  factory AuthSession.fromJson(Map<String, dynamic> json) =>
      _$AuthSessionFromJson(json);
}
