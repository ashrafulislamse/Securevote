import 'package:provider/provider.dart';

import '../../features/voting/data/voting_repository.dart';
import '../models/vote.dart';

/// Fetches the current user's votes for a [FutureProvider].
///
/// NOTE: The backend endpoint does not exist yet; the repository currently
/// returns an empty list. This provider is wired now so the UI can consume it
/// once the endpoint ships.
Future<List<Vote>> fetchMyVotes() async {
  return VotingRepository().getMyVotes();
}

/// Async provider for the current user's vote history.
final myVotesProvider = FutureProvider<List<Vote>>(
  create: (_) => fetchMyVotes(),
  initialData: const <Vote>[],
);

/// Provider exposing the voting repository.
final votingRepositoryProvider = Provider<VotingRepository>(
  create: (_) => VotingRepository(),
);