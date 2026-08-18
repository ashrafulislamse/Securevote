import '../../../core/models/candidate.dart';
import '../../../core/models/election.dart';
import '../../../core/models/election_results.dart';
import '../../../core/network/api_client.dart';

/// Data access for election listing and detail endpoints.
class ElectionsRepository {
  ElectionsRepository({ApiClient? api}) : _api = api ?? ApiClient.instance;

  final ApiClient _api;

  /// Fetches the list of elections.
  ///
  /// Backend: `GET /api/elections` returns `{ elections: [...] }`.
  Future<List<Election>> getElections() async {
    final data = await _api.getApi('/api/elections') as Map<String, dynamic>;
    final list = data['elections'] as List<dynamic>? ?? const [];
    return list
        .map((e) => Election.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetches a single election (with its candidates) by id.
  ///
  /// Backend: `GET /api/elections/:id` returns
  /// `{ election: {...}, candidates: [...] }`.
  Future<(Election, List<Candidate>)> getElectionWithCandidates(
    String id,
  ) async {
    final data =
        await _api.getApi('/api/elections/$id') as Map<String, dynamic>;
    final election = Election.fromJson(
      data['election'] as Map<String, dynamic>,
    );
    final candidates = (data['candidates'] as List<dynamic>? ?? const [])
        .map((c) => Candidate.fromJson(c as Map<String, dynamic>))
        .toList();
    return (election, candidates);
  }

  /// Fetches the tallied results for an election.
  ///
  /// Backend: `GET /api/elections/:id/results` returns
  /// `{ electionId, totalVotes, results: [...] }`.
  Future<ElectionResults> getResults(String electionId) async {
    final dynamic data = await _api.getApi(
      '/api/elections/$electionId/results',
    );
    return ElectionResults.fromJson(data as Map<String, dynamic>);
  }
}
