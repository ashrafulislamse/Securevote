import 'package:freezed_annotation/freezed_annotation.dart';

// ignore_for_file: invalid_annotation_target

import '../utils/json_utils.dart';

part 'vote.freezed.dart';
part 'vote.g.dart';

/// A cast ballot.
///
/// `selections` is a list of `{blockId: candidateId}` maps (one per race).
@freezed
abstract class Vote with _$Vote {
  const factory Vote({
    required String id,
    required String electionId,
    String? electionTitle,
    required List<Map<String, String>> selections,
    required String receiptId,
    String? voteHash,
    String? txHash,
    int? blockNumber,
    @JsonKey(fromJson: epochMsToDateTime, toJson: dateTimeToEpochMs)
    required DateTime createdAt,
  }) = _Vote;

  factory Vote.fromJson(Map<String, dynamic> json) => _$VoteFromJson(json);
}
