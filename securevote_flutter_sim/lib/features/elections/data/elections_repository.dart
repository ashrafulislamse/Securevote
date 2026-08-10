import '../../../core/errors/api_exception.dart';
import '../../../core/models/candidate.dart';
import '../../../core/models/election.dart';
import '../../../core/network/api_client.dart';

/// Data access for election listing and detail endpoints.
///
/// NOTE: The backend does not expose these endpoints yet. The methods below
/// are stubs that issue the intended HTTP calls and return empty placeholders
/// so the app compiles and the wiring is in place. They will be fully
/// implemented once the `/api/elections` endpoints ship.
class ElectionsRepository {
  ElectionsRepository({ApiClient? api}) : _api = api ?? ApiClient.instance;

  final ApiClient _api;

  /// Fetches the list of elections.
  ///
  /// TODO(backend): implement once `GET /api/elections` is available.
  Future<List<Election>> getElections() async {
    try {
      final data = await _api.getApi('/api/elections');
      if (data is List) {
        return data
            .map((e) => Election.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return const [];
    } on ApiException {
      // Return an empty list until the endpoint exists.
      return const [];
    }
  }

  /// Fetches a single election by id.
  ///
  /// TODO(backend): implement once `GET /api/elections/:id` is available.
  Future<Election?> getElection(String id) async {
    try {
      final data = await _api.getApi('/api/elections/$id');
      return Election.fromJson(data as Map<String, dynamic>);
    } on ApiException {
      return null;
    }
  }

  /// Fetches the candidates for a given election.
  ///
  /// TODO(backend): implement once
  /// `GET /api/elections/:id/candidates` is available.
  Future<List<Candidate>> getCandidates(String electionId) async {
    try {
      final data = await _api.getApi('/api/elections/$electionId/candidates');
      if (data is List) {
        return data
            .map((c) => Candidate.fromJson(c as Map<String, dynamic>))
            .toList();
      }
      return const [];
    } on ApiException {
      return const [];
    }
  }
}