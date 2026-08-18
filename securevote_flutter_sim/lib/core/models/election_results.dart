class CandidateResult {
  final String id;
  final String name;
  final String? party;
  final int votes;
  final double pct;

  CandidateResult({
    required this.id,
    required this.name,
    this.party,
    required this.votes,
    required this.pct,
  });

  factory CandidateResult.fromJson(Map<String, dynamic> json) {
    return CandidateResult(
      id: json['id'] as String,
      name: json['name'] as String,
      party: json['party'] as String?,
      votes: (json['votes'] as num).toInt(),
      pct: (json['pct'] as num).toDouble(),
    );
  }
}

class ElectionResults {
  final String electionId;
  final int totalVotes;
  final List<CandidateResult> results;

  ElectionResults({
    required this.electionId,
    required this.totalVotes,
    required this.results,
  });

  factory ElectionResults.fromJson(Map<String, dynamic> json) {
    final list = json['results'] as List<dynamic>? ?? [];
    return ElectionResults(
      electionId: json['electionId'] as String? ?? '',
      totalVotes: (json['totalVotes'] as num?)?.toInt() ?? 0,
      results: list
          .map((e) => CandidateResult.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
