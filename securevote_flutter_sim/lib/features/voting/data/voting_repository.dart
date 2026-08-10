import '../../../core/errors/api_exception.dart';
import '../../../core/models/receipt.dart';
import '../../../core/models/vote.dart';
import '../../../core/network/api_client.dart';

/// Data access for ballot casting and vote history.
///
/// NOTE: The backend does not expose these endpoints yet. These methods are
/// stubs that issue the intended HTTP calls and return placeholders so the
/// wiring is in place for a later phase.
class VotingRepository {
  VotingRepository({ApiClient? api}) : _api = api ?? ApiClient.instance;

  final ApiClient _api;

  /// Casts a ballot for an election.
  ///
  /// TODO(backend): implement once `POST /api/votes` is available.
  Future<Vote> castVote({
    required String electionId,
    required List<Map<String, String>> selections,
  }) async {
    try {
      final data = await _api.postApi(
        '/api/votes',
        data: {'electionId': electionId, 'selections': selections},
      );
      return Vote.fromJson(data as Map<String, dynamic>);
    } on ApiException {
      // Placeholder until the endpoint exists.
      rethrow;
    }
  }

  /// Fetches the current user's past votes.
  ///
  /// TODO(backend): implement once `GET /api/votes/mine` is available.
  Future<List<Vote>> getMyVotes() async {
    try {
      final data = await _api.getApi('/api/votes/mine');
      if (data is List) {
        return data
            .map((v) => Vote.fromJson(v as Map<String, dynamic>))
            .toList();
      }
      return const [];
    } on ApiException {
      return const [];
    }
  }

  /// Fetches the current user's vote receipts.
  ///
  /// TODO(backend): implement once `GET /api/votes/mine` returns receipts.
  Future<List<Receipt>> getMyReceipts() async {
    try {
      final data = await _api.getApi('/api/votes/mine');
      if (data is List) {
        return data
            .map((v) => Receipt.fromJson(v as Map<String, dynamic>))
            .toList();
      }
      return const [];
    } on ApiException {
      return const [];
    }
  }
}