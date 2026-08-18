import 'package:flutter/material.dart';

import '../../../../core/models/candidate.dart';
import '../../../../core/models/election.dart';
import '../../../../core/navigation/app_router.dart';
import '../widgets/vote_confirmation_dialog.dart';

class ReviewVoteScreen extends StatefulWidget {
  const ReviewVoteScreen({super.key});

  @override
  State<ReviewVoteScreen> createState() => _ReviewVoteScreenState();
}

class _ReviewVoteScreenState extends State<ReviewVoteScreen> {
  bool _isConfirmed = false;
  Election? _election;
  List<Candidate> _candidates = <Candidate>[];
  List<Map<String, String>> _selections = <Map<String, String>>[];

  @override
  void initState() {
    super.initState();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _election = args['election'] as Election?;
      final candidates = args['candidates'];
      if (candidates is List<Candidate>) {
        _candidates = candidates;
      }
      final selections = args['selections'];
      if (selections is List<Map<String, String>>) {
        _selections = selections;
      }
    }
  }

  void _submitVote() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const VoteConfirmationDialog(),
    );

    if (confirmed == true && mounted) {
      Navigator.pushNamed(
        context,
        AppRouter.voteSuccess,
        arguments: <String, dynamic>{
          'election': _election,
          'selections': _selections,
          'candidateNames': _candidates.map((c) => c.name).toList(),
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08090E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFE3E1E9)),
          onPressed: () => Navigator.pop(context),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFB9C3FF), Color(0xFFD2BBFF)],
          ).createShader(bounds),
          child: const Text(
            'Review Your Vote',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(Icons.shield, color: Color(0xFFB9C3FF), size: 24),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFBBF24).withValues(alpha: 0.08),
                border: Border.all(
                  color: const Color(0xFFFBBF24).withValues(alpha: 0.2),
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBBF24).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFFBBF24),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Action Irreversible',
                          style: TextStyle(
                            color: Color(0xFFFCD34D),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Once submitted, your vote is cryptographically sealed and cannot be altered or deleted. Please double-check your selections below.',
                          style: TextStyle(
                            color: Color(0xFFFCD34D),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Selections',
                  style: TextStyle(
                    color: Color(0xFFE3E1E9),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: const [
                    Icon(
                      Icons.verified_user,
                      color: Color(0xFF2ADEC0),
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'IDENTITY VERIFIED',
                      style: TextStyle(
                        color: Color(0xFF2ADEC0),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Selection Cards
            ..._candidates.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildSelectionCard(
                  _election ??
                      Election(
                        id: '',
                        title: 'Election',
                        startsAt: DateTime.fromMillisecondsSinceEpoch(0),
                        endsAt: DateTime.fromMillisecondsSinceEpoch(0),
                      ),
                  entry.value,
                ),
              );
            }),
            if (_candidates.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No selections to review.',
                    style: TextStyle(color: Color(0xFFC4C5D7), fontSize: 15),
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Encryption Note
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.lock, color: Color(0xFF8E90A0), size: 14),
                SizedBox(width: 8),
                Text(
                  'Your selection is encrypted and private',
                  style: TextStyle(
                    color: Color(0xFF8E90A0),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Confirmation Checkbox
            InkWell(
              onTap: () {
                setState(() {
                  _isConfirmed = !_isConfirmed;
                });
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: _isConfirmed
                          ? const Color(0xFFB9C3FF)
                          : Colors.transparent,
                      border: Border.all(
                        color: _isConfirmed
                            ? const Color(0xFFB9C3FF)
                            : const Color(0xFF444654),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _isConfirmed
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          color: Color(0xFFC4C5D7),
                          fontSize: 14,
                          height: 1.5,
                        ),
                        children: [
                          TextSpan(text: 'I understand that this vote is '),
                          TextSpan(
                            text: 'final',
                            style: TextStyle(
                              color: Color(0xFFFFB4AB),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text:
                                ' and cannot be withdrawn or modified once I press submit. My identity remains anonymous to the tally system.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        decoration: BoxDecoration(
          color: const Color(0xFF0D0E13).withValues(alpha: 0.8),
          border: const Border(
            top: BorderSide(color: Color(0xFF1A1B21), width: 1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (_isConfirmed && _candidates.isNotEmpty)
                    ? _submitVote
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isConfirmed
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF444654),
                  foregroundColor: Colors.white,
                  elevation: _isConfirmed ? 8 : 0,
                  shadowColor: _isConfirmed
                      ? const Color(0xFFDC2626).withValues(alpha: 0.25)
                      : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.how_to_vote, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Submit Vote',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.visibility_off, color: Color(0xFF8E90A0), size: 12),
                SizedBox(width: 6),
                Text(
                  'YOUR VOTE REMAINS ANONYMOUS',
                  style: TextStyle(
                    color: Color(0xFF8E90A0),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Your identity is stored separately from your choice to ensure total privacy.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF8E90A0),
                fontSize: 10,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCard(Election election, Candidate candidate) {
    final String category = election.type.toUpperCase();
    final String position = election.title;
    final String imageUrl = candidate.photoUrl ?? '';
    final String party = candidate.party ?? 'Independent';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B21),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFB9C3FF).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: const TextStyle(
                      color: Color(0xFFC4C5D7),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    position,
                    style: const TextStyle(
                      color: Color(0xFFE3E1E9),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB9C3FF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Edit',
                    style: TextStyle(
                      color: Color(0xFFB9C3FF),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF34343A).withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF292A2F),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.person,
                                color: Color(0xFF8E90A0),
                              );
                            },
                          )
                        : const Icon(Icons.person, color: Color(0xFF8E90A0)),
                  ),
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        party,
                        style: const TextStyle(
                          color: Color(0xFFC4C5D7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2ADEC0).withValues(alpha: 0.2),
                    border: Border.all(
                      color: const Color(0xFF2ADEC0).withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Color(0xFF2ADEC0),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
