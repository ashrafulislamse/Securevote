import 'package:provider/provider.dart';

import '../../features/elections/data/elections_repository.dart';
import '../models/election.dart';

/// Fetches the list of elections for a [FutureProvider].
///
/// NOTE: The backend endpoint does not exist yet; the repository currently
/// returns an empty list. This provider is wired now so the UI can consume it
/// once the endpoint ships.
Future<List<Election>> fetchElections() async {
  return ElectionsRepository().getElections();
}

/// Async provider for the elections list.
final electionsProvider = FutureProvider<List<Election>>(
  create: (_) => fetchElections(),
  initialData: const <Election>[],
);

/// Provider exposing the elections repository.
final electionsRepositoryProvider = Provider<ElectionsRepository>(
  create: (_) => ElectionsRepository(),
);