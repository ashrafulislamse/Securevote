import '../../../core/models/vote.dart';
import '../../../core/network/api_client.dart';

/// Data access for ballot casting and vote history.
class VotingRepository {
  VotingRepository({ApiClient? api}) : _api = api ?? ApiClient.instance;

  final ApiClient _api;

  /// Casts a ballot for an election.
  ///
  /// Backend: `POST /api/voting/cast` with
  /// `{ electionId, selections: [{blockId, candidateId}] }` returns
  /// `{ ok, vote: { id, electionId, receiptId, voteHash, selections, createdAt } }`.
  ///
  /// Throws [ApiException] (e.g. 409 already voted, 403 KYC required).
  Future<Vote> castVote({
    required String electionId,
    required List<Map<String, String>> selections,
  }) async {
    final data = await _api.postApi(
      '/api/voting/cast',
      data: {'electionId': electionId, 'selections': selections},
    ) as Map<String, dynamic>;
    return Vote.fromJson(data['vote'] as Map<String, dynamic>);
  }

  /// Fetches the current user's past votes.
  ///
  /// Backend: `GET /api/voting/mine` returns `{ votes: [...] }`.
  Future<List<Vote>> getMyVotes() async {
    final data = await _api.getApi('/api/voting/mine') as Map<String, dynamic>;
    final list = data['votes'] as List<dynamic>? ?? const [];
    return list
        .map((v) => Vote.fromJson(v as Map<String, dynamic>))
        .toList();
  }

  /// Checks whether the current user has already voted in an election.
  ///
  /// Backend: `GET /api/voting/voted/:electionId` returns `{ voted: bool }`.
  Future<bool> hasVoted(String electionId) async {
    final data = await _api.getApi('/api/voting/voted/$electionId')
        as Map<String, dynamic>;
    return data['voted'] as bool? ?? false;
  }
}