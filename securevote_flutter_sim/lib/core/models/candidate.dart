import 'package:freezed_annotation/freezed_annotation.dart';

part 'candidate.freezed.dart';
part 'candidate.g.dart';

/// A candidate standing in a specific election.
@freezed
abstract class Candidate with _$Candidate {
  const factory Candidate({
    required String id,
    required String electionId,
    required String name,
    String? party,
    String? bio,
    String? manifesto,
    String? photoUrl,
    @Default(0) int ballotOrder,
  }) = _Candidate;

  factory Candidate.fromJson(Map<String, dynamic> json) =>
      _$CandidateFromJson(json);
}