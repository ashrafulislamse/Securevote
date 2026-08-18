import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/election.dart';
import '../../../../core/models/kyc_status.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../features/voting/data/voting_repository.dart';

class ElectionParticipationScreen extends StatefulWidget {
  const ElectionParticipationScreen({super.key});

  @override
  State<ElectionParticipationScreen> createState() =>
      _ElectionParticipationScreenState();
}

class _ElectionParticipationScreenState
    extends State<ElectionParticipationScreen> {
  static const List<String> _months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  Election? _election;
  bool _kycApproved = false;
  bool _hasVoted = false;
  bool _eligibilityChecked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    if (args is Election) {
      _election = args;
    } else if (args is Map) {
      final Object? e = args['election'];
      if (e is Election) {
        _election = e;
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkEligibility());
  }

  Future<void> _checkEligibility() async {
    final Election? election = _election;
    if (election == null) {
      if (mounted) setState(() => _eligibilityChecked = true);
      return;
    }
    final AuthProvider auth = context.read<AuthProvider>();
    final bool kycApproved = auth.user?.kycStatus == KycStatus.approved;
    bool voted = false;
    try {
      voted = await VotingRepository().hasVoted(election.id);
    } on Exception {
      voted = false;
    }
    if (!mounted) return;
    setState(() {
      _kycApproved = kycApproved;
      _hasVoted = voted;
      _eligibilityChecked = true;
    });
  }

  static String _formatDate(DateTime d) {
    final List<String> months = _months;
    final String hour = d.hour.toString().padLeft(2, '0');
    final String min = d.minute.toString().padLeft(2, '0');
    return '${months[d.month - 1]} ${d.day}, ${d.year} $hour:$min';
  }

  String _timeRemaining() {
    final Election? election = _election;
    if (election == null) return '—';
    final DateTime now = DateTime.now();
    final Duration remaining = election.endsAt.difference(now);
    if (remaining.isNegative) return 'Voting has ended';
    final int days = remaining.inDays;
    final int hours = remaining.inHours.remainder(24);
    if (days > 0) return '$days days $hours hours';
    final int minutes = remaining.inMinutes.remainder(60);
    if (hours > 0) return '$hours hours $minutes minutes';
    return '$minutes minutes';
  }

  bool get _eligible => _kycApproved && !_hasVoted;

  void _startVoting() {
    final Election? election = _election;
    if (election == null) return;
    Navigator.pushNamed(
      context,
      AppRouter.ballotCasting,
      arguments: <String, dynamic>{'electionId': election.id},
    );
  }

  @override
  Widget build(BuildContext context) {
    final Election? election = _election;

    return Scaffold(
      backgroundColor: const Color(0xFF08090E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Eligibility Check',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: election == null
          ? _buildNoElection(context)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Status Banner
                  _buildStatusBanner(),
                  const SizedBox(height: 32),

                  const Text(
                    'Election Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildInfoCard(
                    election.title,
                    election.organization ?? 'SecureVote Election',
                    Icons.how_to_vote,
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Voting Period',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildTimeCard(),
                  const SizedBox(height: 24),

                  const Text(
                    'Requirements',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildRequirement(
                    'KYC Verified',
                    _eligibilityChecked ? _kycApproved : null,
                    _eligibilityChecked
                        ? (_kycApproved ? 'Verified' : 'Verification required')
                        : 'Checking...',
                  ),
                  _buildRequirement(
                    'No Previous Vote',
                    _eligibilityChecked ? !_hasVoted : null,
                    _eligibilityChecked
                        ? (_hasVoted ? 'Already voted' : 'Not yet voted')
                        : 'Checking...',
                  ),
                  const SizedBox(height: 32),

                  // Start Voting Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _eligible ? _startVoting : null,
                      icon: const Icon(Icons.how_to_vote, size: 20),
                      label: const Text(
                        'Start Voting',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB9C3FF),
                        foregroundColor: const Color(0xFF001257),
                        disabledBackgroundColor: const Color(
                          0xFFB9C3FF,
                        ).withValues(alpha: 0.3),
                        disabledForegroundColor: const Color(0xFF001257),
                        elevation: 8,
                        shadowColor: const Color(
                          0xFFB9C3FF,
                        ).withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildNoElection(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.event_busy_rounded,
              size: 48,
              color: Color(0xFF8E90A0),
            ),
            const SizedBox(height: 16),
            const Text(
              'No election details available.',
              style: TextStyle(color: Color(0xFFC4C5D7)),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    if (!_eligibilityChecked) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF1A1B21),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: <Widget>[
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFB9C3FF),
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Checking your eligibility...',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }
    if (_eligible) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: <Color>[Color(0xFF2ADEC0), Color(0xFF1AB89F)],
          ),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              child: const Icon(
                Icons.verified_user,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "You're Eligible!",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'All requirements met',
                    style: TextStyle(fontSize: 13, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    // Not eligible
    final String reason = _hasVoted
        ? 'You have already voted in this election.'
        : 'Complete KYC verification to become eligible.';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFFFF8A80), Color(0xFFE57373)],
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            child: const Icon(
              Icons.gpp_bad_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Not Eligible Yet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reason,
                  style: const TextStyle(fontSize: 13, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1A1B21),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFB9C3FF).withValues(alpha: 0.1),
            ),
            child: Icon(icon, color: const Color(0xFFB9C3FF), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard() {
    final Election? election = _election;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1A1B21),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                'Starts',
                style: TextStyle(fontSize: 14, color: Color(0xFF8E90A0)),
              ),
              Text(
                election != null ? _formatDate(election.startsAt) : '—',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                'Ends',
                style: TextStyle(fontSize: 14, color: Color(0xFF8E90A0)),
              ),
              Text(
                election != null ? _formatDate(election.endsAt) : '—',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                'Time Remaining',
                style: TextStyle(fontSize: 14, color: Color(0xFF8E90A0)),
              ),
              Text(
                _timeRemaining(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2ADEC0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequirement(String title, bool? met, String subtitle) {
    final IconData icon = met == null
        ? Icons.hourglass_top_rounded
        : met
        ? Icons.check_circle
        : Icons.cancel;
    final Color color = met == null
        ? const Color(0xFFC4C5D7)
        : met
        ? const Color(0xFF2ADEC0)
        : const Color(0xFFFF6B6B);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: <Widget>[
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.6),
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
