import 'package:flutter/material.dart';

import '../../../../core/models/candidate.dart';
import '../../../../core/models/election.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../features/elections/data/elections_repository.dart';
import '../../../../features/voting/data/voting_repository.dart';

class BallotCastingScreen extends StatefulWidget {
  const BallotCastingScreen({super.key});

  @override
  State<BallotCastingScreen> createState() => _BallotCastingScreenState();
}

class _BallotCastingScreenState extends State<BallotCastingScreen> {
  static const List<Color> _partyColors = <Color>[
    Color(0xFF6E88FF),
    Color(0xFF6001D1),
    Color(0xFF8E90A0),
    Color(0xFF2ADEC0),
    Color(0xFFFBBF24),
  ];

  String? _electionId;
  Election? _election;
  List<Candidate> _candidates = <Candidate>[];
  int? _selectedIndex = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _electionId = args['electionId'] as String?;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    await _loadElectionAndCandidates();
    if (!mounted || _error != null) return;
    await _checkAlreadyVoted();
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadElectionAndCandidates() async {
    final electionsRepo = ElectionsRepository();
    try {
      String id = _electionId ?? '';
      if (id.isEmpty) {
        final elections = await electionsRepo.getElections();
        if (!mounted) return;
        if (elections.isEmpty) {
          setState(() {
            _error = 'No elections are currently available.';
            _loading = false;
          });
          return;
        }
        id = elections.first.id;
      }
      _electionId = id;
      final (election, candidates) = await electionsRepo
          .getElectionWithCandidates(id);
      if (!mounted) return;
      setState(() {
        _election = election;
        _candidates = candidates;
      });
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _checkAlreadyVoted() async {
    try {
      final voted = await VotingRepository().hasVoted(_electionId!);
      if (voted && mounted) {
        _showAlreadyVotedDialog();
      }
    } on Exception {
      // Ignore failures here; the ballot screen still renders.
    }
  }

  void _showAlreadyVotedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1B21),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.info_outline, color: Color(0xFFFFB6C8)),
            SizedBox(width: 12),
            Text(
              'Already Voted',
              style: TextStyle(
                color: Color(0xFFE3E1E9),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'You have already cast your vote in this election. Each voter can only vote once per election.',
          style: TextStyle(color: Color(0xFFC4C5D7), fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, AppRouter.alreadyVoted);
            },
            child: const Text(
              'OK',
              style: TextStyle(
                color: Color(0xFFB9C3FF),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _continueToReview() {
    final selected = _candidates[_selectedIndex!];
    final selections = <Map<String, String>>[
      <String, String>{'blockId': _electionId!, 'candidateId': selected.id},
    ];
    Navigator.pushNamed(
      context,
      AppRouter.reviewVote,
      arguments: <String, dynamic>{
        'election': _election,
        'candidates': <Candidate>[selected],
        'selections': selections,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08090E),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Header with Progress
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              decoration: BoxDecoration(
                color: const Color(0xFF08090E).withValues(alpha: 0.8),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Row(
                          children: <Widget>[
                            const Icon(Icons.arrow_back, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Back',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'Cast Your Vote',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                        child: Text(
                          '1 OF 3',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.7),
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      height: 4,
                      color: const Color(0xFF34343A),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.33,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: <Color>[
                                Color(0xFFB9C3FF),
                                Color(0xFFD2BBFF),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(child: _buildContent()),
          ],
        ),
      ),
      // Bottom Action
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              const Color(0xFF08090E).withValues(alpha: 0),
              const Color(0xFF08090E).withValues(alpha: 0.9),
              const Color(0xFF08090E),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: <Color>[Color(0xFFB9C3FF), Color(0xFFD2BBFF)],
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: const Color(0xFFB9C3FF).withValues(alpha: 0.25),
                      blurRadius: 32,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: (_loading || _error != null)
                        ? null
                        : _continueToReview,
                    borderRadius: BorderRadius.circular(16),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Review & Continue',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF001257),
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            color: Color(0xFF001257),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select your candidate below. Your vote is encrypted and anonymous.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.4),
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFB9C3FF)),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.error_outline,
                color: Color(0xFFFF8A80),
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: <Widget>[
          // Context Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFFB9C3FF).withValues(alpha: 0.1),
              border: Border.all(
                color: const Color(0xFFB9C3FF).withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFB9C3FF),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  (_election?.type ?? 'ELECTION').toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFB9C3FF),
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            _election?.title ?? 'Election',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _election?.description ??
                'Select one candidate to represent your choice.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 40),

          // Candidates
          ...List.generate(_candidates.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildCandidateCard(index),
            );
          }),
          if (_candidates.isEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'No candidates are available for this election.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 15,
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Security Note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFF1A1B21).withValues(alpha: 0.5),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Row(
              children: <Widget>[
                const Icon(Icons.lock, color: Color(0xFF2ADEC0), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'End-to-end encrypted ballot. Your choice is private and anonymous.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildCandidateCard(int index) {
    final Candidate candidate = _candidates[index];
    final bool isSelected = _selectedIndex == index;
    final Color partyColor = _partyColors[index % _partyColors.length];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? const Color(0xFFB9C3FF).withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.03),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFB9C3FF).withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.05),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: <Widget>[
            // Avatar
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(
                        color: const Color(0xFFB9C3FF).withValues(alpha: 0.5),
                        width: 2,
                      )
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: isSelected
                      ? partyColor.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.05),
                  child:
                      candidate.photoUrl != null &&
                          candidate.photoUrl!.isNotEmpty
                      ? Image.network(
                          candidate.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.person,
                            size: 32,
                            color: isSelected
                                ? partyColor
                                : Colors.white.withValues(alpha: 0.3),
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 32,
                          color: isSelected
                              ? partyColor
                              : Colors.white.withValues(alpha: 0.3),
                        ),
                ),
              ),
            ),
            const SizedBox(width: 20),

            // Info
            Expanded(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isSelected ? 1.0 : 0.6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            candidate.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isSelected) ...<Widget>[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: const Color(
                                0xFF2ADEC0,
                              ).withValues(alpha: 0.2),
                              border: Border.all(
                                color: const Color(
                                  0xFF2ADEC0,
                                ).withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Text(
                              'SELECTED',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2ADEC0),
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: <Widget>[
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: partyColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            candidate.party ?? 'Independent',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Radio
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFB9C3FF)
                      : Colors.white.withValues(alpha: 0.1),
                  width: 2,
                ),
                color: isSelected
                    ? const Color(0xFFB9C3FF).withValues(alpha: 0.2)
                    : Colors.transparent,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFB9C3FF),
                          boxShadow: <BoxShadow>[
                            BoxShadow(color: Color(0xFFB9C3FF), blurRadius: 8),
                          ],
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
