import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/models/candidate.dart';
import '../../../../core/models/election.dart';
import '../../../../core/models/election_results.dart';
import '../../../../features/elections/data/elections_repository.dart';

class ElectionResultsScreen extends StatefulWidget {
  const ElectionResultsScreen({super.key});

  @override
  State<ElectionResultsScreen> createState() => _ElectionResultsScreenState();
}

class _ElectionResultsScreenState extends State<ElectionResultsScreen> {
  static const List<Color> _candidateColors = <Color>[
    Color(0xFFB9C3FF),
    Color(0xFFD2BBFF),
    Color(0xFF2ADEC0),
    Color(0xFFFF7B5A),
    Color(0xFF46F1A0),
    Color(0xFFFFB547),
  ];

  Election? _election;
  ElectionResults? _results;
  bool _loading = true;
  String? _error;
  // True when the results endpoint explicitly indicated results are not
  // available yet (e.g. 403 from the API).
  bool _resultsPending = false;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      _load();
    }
  }

  Future<void> _load() async {
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    final Election? passedElection = _extractElection(args);
    final String? id = _extractId(args) ?? passedElection?.id;
    if (id == null) {
      setState(() {
        _loading = false;
        _error = 'No election specified.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _resultsPending = false;
      if (passedElection != null) {
        _election = passedElection;
      }
    });
    final ElectionsRepository repo = context.read<ElectionsRepository>();

    // Fetch election metadata when it was not passed via route args.
    if (_election == null) {
      try {
        final (Election election, List<Candidate> _) = await repo
            .getElectionWithCandidates(id);
        if (!mounted) return;
        setState(() => _election = election);
      } on Exception {
        // Metadata is optional for the results view; keep going.
      }
    }

    try {
      final ElectionResults results = await repo.getResults(id);
      if (!mounted) return;
      setState(() {
        _results = results;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 403) {
        setState(() {
          _resultsPending = true;
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
          _error = e.message.isNotEmpty
              ? e.message
              : 'Could not load results. Please try again.';
        });
      }
    } on Exception catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error =
            'Could not load results. Please check your connection and try again.';
      });
    }
  }

  Election? _extractElection(Object? args) {
    if (args is Election) return args;
    if (args is Map) {
      final Object? v = args['election'];
      if (v is Election) return v;
    }
    return null;
  }

  String? _extractId(Object? args) {
    if (args is String) return args;
    if (args is Map) {
      final Object? v = args['electionId'] ?? args['id'];
      if (v is String) return v;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08090E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF08090E).withValues(alpha: 0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFC4C5D7)),
          onPressed: () => Navigator.pop(context),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: <Color>[Color(0xFFB9C3FF), Color(0xFFD2BBFF)],
          ).createShader(bounds),
          child: const Text(
            'SecureVote',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFC4C5D7)),
            onPressed: _load,
            tooltip: 'Refresh results',
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFB9C3FF)),
      );
    }
    if (_resultsPending) {
      return _buildPending(context);
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.cloud_off_rounded,
                size: 48,
                color: Color(0xFF8E90A0),
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFC4C5D7)),
              ),
              const SizedBox(height: 20),
              OutlinedButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final ElectionResults results = _results!;
    final Election? election = _election;
    final List<CandidateResult> sorted = List<CandidateResult>.from(
      results.results,
    )..sort((a, b) => b.votes.compareTo(a.votes));
    final CandidateResult? winner = sorted.isNotEmpty ? sorted.first : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Election Meta
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFB9C3FF).withValues(alpha: 0.2),
                  border: Border.all(
                    color: const Color(0xFFB9C3FF).withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'ELECTION RESULTS',
                  style: TextStyle(
                    color: Color(0xFFB9C3FF),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '• Final Tabulation',
                style: TextStyle(color: Color(0xFFC4C5D7), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            election?.title ?? 'Election Results',
            style: const TextStyle(
              color: Color(0xFFE3E1E9),
              fontSize: 30,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${election?.organization ?? 'SecureVote Election'} • Blockchain Verified',
            style: const TextStyle(
              color: Color(0xFFC4C5D7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 24),

          // Total votes banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  const Color(0xFFB9C3FF).withValues(alpha: 0.1),
                  const Color(0xFFD2BBFF).withValues(alpha: 0.1),
                ],
              ),
              border: Border.all(
                color: const Color(0xFFFFB547).withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.how_to_vote_rounded,
                  color: Color(0xFFFFB547),
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'TOTAL VOTES CAST',
                        style: TextStyle(
                          color: Color(0xFFFFB547),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatCount(results.totalVotes),
                        style: const TextStyle(
                          color: Color(0xFFE3E1E9),
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Section Header
          const Text(
            'CANDIDATE BREAKDOWN',
            style: TextStyle(
              color: Color(0xFFC4C5D7),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          if (sorted.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No results have been recorded for this election yet.',
                style: TextStyle(color: Color(0xFFC4C5D7)),
              ),
            ),

          for (int i = 0; i < sorted.length; i++) ...<Widget>[
            _buildResultCard(
              (i + 1).toString().padLeft(2, '0'),
              sorted[i],
              sorted[i].id == winner?.id,
            ),
            if (i != sorted.length - 1) const SizedBox(height: 12),
          ],

          const SizedBox(height: 32),

          // Note about verification
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1B21),
              border: Border.all(
                color: const Color(0xFFB9C3FF).withValues(alpha: 0.4),
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Row(
                  children: <Widget>[
                    Icon(Icons.verified, color: Color(0xFFB9C3FF), size: 14),
                    SizedBox(width: 8),
                    Text(
                      'BLOCKCHAIN VERIFICATION',
                      style: TextStyle(
                        color: Color(0xFFB9C3FF),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'Every ballot cast in this election is recorded on an immutable, auditable ledger. Any registered voter can verify their vote was counted without revealing their choice.',
                  style: TextStyle(
                    color: Color(0xFFC4C5D7),
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPending(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.hourglass_top_rounded,
              size: 56,
              color: Color(0xFFC4C5D7),
            ),
            const SizedBox(height: 20),
            Text(
              _election?.title ?? 'Election',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFE3E1E9),
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Results not available yet. Results are published after the voting period closes.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFFC4C5D7), height: 1.5),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(
    String rank,
    CandidateResult candidate,
    bool isWinner,
  ) {
    final int colorIndex =
        candidate.id.hashCode.abs() % _candidateColors.length;
    final Color color = _candidateColors[colorIndex];
    final double pct = candidate.pct.clamp(0.0, 100.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161A24),
        border: Border.all(
          color: isWinner
              ? const Color(0xFFFFB547).withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.07),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                rank,
                style: TextStyle(
                  color: isWinner ? const Color(0xFFFFB547) : color,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF292A2F),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.person, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      candidate.name,
                      style: const TextStyle(
                        color: Color(0xFFE3E1E9),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      candidate.party ?? 'Independent',
                      style: const TextStyle(
                        color: Color(0xFFC4C5D7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isWinner)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB547).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'WINNER',
                    style: TextStyle(
                      color: Color(0xFFFFB547),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Vote bar
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 10,
              color: const Color(0xFF34343A),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: pct / 100,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[color, color.withValues(alpha: 0.7)],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '${_formatCount(candidate.votes)} votes',
                style: const TextStyle(
                  color: Color(0xFFE3E1E9),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${pct.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCount(int value) {
    if (value >= 1000) {
      final double k = value / 1000;
      return k >= 1000
          ? '${(k / 1000).toStringAsFixed(1)}M'
          : '${k.toStringAsFixed(1)}K';
    }
    return value.toString();
  }
}
