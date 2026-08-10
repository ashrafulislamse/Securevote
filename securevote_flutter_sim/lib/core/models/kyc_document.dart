import 'package:freezed_annotation/freezed_annotation.dart';

// ignore_for_file: invalid_annotation_target

import '../utils/json_utils.dart';

part 'kyc_document.freezed.dart';
part 'kyc_document.g.dart';

/// A KYC document submitted by the user for review.
///
/// Mirrors the row returned by `GET /api/kyc/status` and
/// `GET /api/kyc/queue` (admin queue).
@freezed
abstract class KycDocument with _$KycDocument {
  const factory KycDocument({
    required String id,
    @Default('id') String docType,
    @Default('pending') String status,
    @JsonKey(
      fromJson: epochMsToDateTimeNullable,
      toJson: dateTimeToEpochMsNullable,
    )
    DateTime? createdAt,
  }) = _KycDocument;

  factory KycDocument.fromJson(Map<String, dynamic> json) =>
      _$KycDocumentFromJson(json);
}
