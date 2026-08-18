import 'package:freezed_annotation/freezed_annotation.dart';

// ignore_for_file: invalid_annotation_target

import '../utils/json_utils.dart';

part 'receipt.freezed.dart';
part 'receipt.g.dart';

/// A verifiable ballot receipt returned after a vote is committed.
@freezed
abstract class Receipt with _$Receipt {
  const factory Receipt({
    required String id,
    required String electionId,
    String? electionTitle,
    String? candidateName,
    required List<Map<String, String>> selections,
    @Default('confirmed') String status,
    String? txHash,
    @JsonKey(fromJson: epochMsToDateTime, toJson: dateTimeToEpochMs)
    required DateTime createdAt,
  }) = _Receipt;

  factory Receipt.fromJson(Map<String, dynamic> json) =>
      _$ReceiptFromJson(json);
}
