/// JSON parsing helpers shared by Freezed/json_serializable models.
///
/// The SecureVote backend returns all timestamps as Unix millisecond integers
/// (e.g. `1786341710733`), while json_serializable's default `DateTime`
/// handling expects ISO-8601 strings. These helpers bridge that gap so models
/// can deserialize epoch-ms values safely (and still accept ISO strings).

/// Parse a timestamp that may be an epoch-ms `num` or an ISO-8601 `String`.
DateTime epochMsToDateTime(Object? value) {
  if (value is num) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  }
  if (value is String) {
    return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }
  return DateTime.fromMillisecondsSinceEpoch(0);
}

/// Serialize a [DateTime] to an epoch-ms integer for the backend.
num dateTimeToEpochMs(DateTime value) => value.millisecondsSinceEpoch;

/// Parse a nullable epoch-ms / ISO timestamp.
DateTime? epochMsToDateTimeNullable(Object? value) {
  if (value == null) return null;
  if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  if (value is String) return DateTime.tryParse(value);
  return null;
}

/// Serialize a nullable [DateTime] to epoch-ms (or null).
num? dateTimeToEpochMsNullable(DateTime? value) =>
    value?.millisecondsSinceEpoch;