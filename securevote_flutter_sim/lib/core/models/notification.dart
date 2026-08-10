import 'package:freezed_annotation/freezed_annotation.dart';

// ignore_for_file: invalid_annotation_target

import '../utils/json_utils.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

/// An in-app notification surfaced in the Alerts inbox.
///
/// Mirrors a row from the backend `notifications` table (see
/// `GET /api/notifications`). `type` is intentionally a free-form string so
/// new notification kinds (e.g. `election_published`) can be added by the
/// backend without breaking the client.
@freezed
abstract class Notification with _$Notification {
  const factory Notification({
    required String id,
    @Default('') String userId,
    required String title,
    @Default('') String body,
    @Default('info') String type,
    @Default(false) bool read,
    @JsonKey(fromJson: epochMsToDateTime, toJson: dateTimeToEpochMs)
    required DateTime createdAt,
  }) = _Notification;

  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);
}
