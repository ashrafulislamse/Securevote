import 'package:freezed_annotation/freezed_annotation.dart';

part 'vote.freezed.dart';
part 'vote.g.dart';

/// A cast ballot.
///
/// `selections` maps a race/position to the chosen candidate id. Its JSON
/// representation is a list of `{race: candidateId}` maps.
@freezed
abstract class Vote with _$Vote {
  const factory Vote({
    required String id,
    required String electionId,
    required List<Map<String, String>> selections,
    required String receiptId,
    String? txHash,
    String? blockNumber,
    required DateTime createdAt,
  }) = _Vote;

  factory Vote.fromJson(Map<String, dynamic> json) => _$VoteFromJson(json);
}