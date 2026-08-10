import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/candidate.dart';
import '../../../../core/models/election.dart';
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
  List<Candidate> _candidates = const <Candidate>[];
  bool _loading = true;
  String? _error;
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
    final String? id = _extractId(args);
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
    });
    try {
      final repo = context.read<ElectionsRepository>();
      final (Election election, List<Candidate> candidates) =
          await repo.getElectionWithCandidates(id);
      if (!mounted) {
        return;
      }
      setState(() {
        _election = election;
        _candidates = candidates;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error =
            'Could not load results. Please check your connection and try again.';
      });
    }
  }

  String? _extractId(Object? args) {
    if (args == null) {
      return null;
    }
    if (args is String) {
      return args;
    }
    if (args is Election) {
      return args.id;
    }
    if (args is Map) {
      final Object? v = args['electionId'] ?? args['id'];
      if (v is String) {
        return v;
      }
      if (v is Election) {
        return v.id;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08090E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF08090E).withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFC4C5D7)),
          onPressed: () => Navigator.pop(context),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFB9C3FF), Color(0xFFD2BBFF)],
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
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Color(0xFFC4C5D7)),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: const Icon(
                Icons.person,
                color: Color(0xFFC4C5D7),
                size: 20,
              ),
            ),
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

    final Election election = _election!;
    final bool resultsAvailable =
        election.status == 'closed' || election.status == 'published';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Election Meta
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFB9C3FF).withOpacity(0.2),
                  border: Border.all(
                    color: const Color(0xFFB9C3FF).withOpacity(0.3),
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
              Text(
                resultsAvailable ? '• Final Tabulation' : '• Pending',
                style: const TextStyle(color: Color(0xFFC4C5D7), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            election.title,
            style: const TextStyle(
              color: Color(0xFFE3E1E9),
              fontSize: 30,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${election.organization ?? 'SecureVote Election'} • Blockchain Verified',
            style: const TextStyle(
              color: Color(0xFFC4C5D7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 32),

          // Status Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFB9C3FF).withOpacity(0.1),
                  const Color(0xFFD2BBFF).withOpacity(0.1),
                ],
              ),
              border: Border.all(
                color: resultsAvailable
                    ? const Color(0xFFFFB547).withOpacity(0.3)
                    : Colors.white.withOpacity(0.1),
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Icon(
                  resultsAvailable
                      ? Icons.verified_rounded
                      : Icons.schedule_rounded,
                  color: resultsAvailable
                      ? const Color(0xFFFFB547)
                      : const Color(0xFFC4C5D7),
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resultsAvailable
                            ? 'RESULTS AVAILABLE'
                            : 'RESULTS PENDING',
                        style: TextStyle(
                          color: resultsAvailable
                              ? const Color(0xFFFFB547)
                              : const Color(0xFFC4C5D7),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        resultsAvailable
                            ? 'This election has closed and the final tally is available below.'
                            : 'This election is not yet closed. Results will be published after the voting period ends.',
                        style: const TextStyle(
                          color: Color(0xFFC4C5D7),
                          fontSize: 14,
                          height: 1.5,
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
          const SizedBox(height: 8),
          const Text(
            'Ordered by ballot position. Precise tallies are published by election officials.',
            style: TextStyle(
              color: Color(0xFF8E90A0),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),

          if (_candidates.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No candidates have been registered for this election yet.',
                style: TextStyle(color: Color(0xFFC4C5D7)),
              ),
            ),

          for (int i = 0; i < _candidates.length; i++) ...<Widget>[
            _buildResultCard(
              (i + 1).toString().padLeft(2, '0'),
              _candidates[i],
              i == 0,
            ),
            if (i != _candidates.length - 1) const SizedBox(height: 12),
          ],

          const SizedBox(height: 32),

          // Note about verification
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1B21),
              border: Border.all(
                color: const Color(0xFFB9C3FF).withOpacity(0.4),
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
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
                const SizedBox(height: 16),
                const Text(
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

  Widget _buildResultCard(String rank, Candidate candidate, bool isTop) {
    final Color color = _candidateColors[candidate.ballotOrder %
        _candidateColors.length];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161A24),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(
            rank,
            style: TextStyle(
              color: isTop ? const Color(0xFFFFB547) : color,
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
              border: Border.all(color: Colors.white.withOpacity(0.05)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.person, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
          if (isTop)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB547).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'TOP',
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
    );
  }
}