import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/candidate.dart';
import '../../../../core/models/election.dart';
import '../../../../core/models/kyc_status.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../features/elections/data/elections_repository.dart';
import '../../../../features/kyc/data/kyc_repository.dart';
import '../../../../features/voting/data/voting_repository.dart';
import '../../../../shared/widgets/gradient_button.dart';

class ElectionDetailsScreen extends StatefulWidget {
  const ElectionDetailsScreen({super.key});

  @override
  State<ElectionDetailsScreen> createState() => _ElectionDetailsScreenState();
}

class _ElectionDetailsScreenState extends State<ElectionDetailsScreen> {
  static const List<Color> _candidateColors = <Color>[
    Color(0xFF6E88FF),
    Color(0xFFD2BBFF),
    Color(0xFF2ADEC0),
    Color(0xFFFF7B5A),
    Color(0xFF46F1A0),
    Color(0xFFFFB547),
  ];

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

  int _selectedTab = 0;
  Election? _election;
  List<Candidate> _candidates = const <Candidate>[];
  bool _loading = true;
  String? _error;
  bool _started = false;

  // Eligibility state derived from real auth + vote checks.
  bool _kycApproved = false;
  bool _hasVoted = false;
  bool _eligibilityChecked = false;

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
      final (Election election, List<Candidate> candidates) = await repo
          .getElectionWithCandidates(id);
      if (!mounted) {
        return;
      }
      setState(() {
        _election = election;
        _candidates = candidates;
        _loading = false;
      });
      await _checkEligibility(election.id);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error =
            'Could not load election details. Please check your connection and try again.';
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

  Future<void> _checkEligibility(String electionId) async {
    // Fetch fresh KYC status from the API rather than relying on the
    // in-memory auth.user, which may be stale if KYC was approved after
    // login (e.g. dev auto-approve or admin approval while the app was open).
    final AuthProvider auth = context.read<AuthProvider>();
    bool kycApproved = false;
    try {
      final snapshot = await KycRepository().getStatus();
      kycApproved = snapshot.status == KycStatus.approved;
    } on Exception {
      // Fall back to the in-memory user if the API call fails.
      kycApproved = auth.user?.kycStatus == KycStatus.approved;
    }
    bool voted = false;
    try {
      voted = await VotingRepository().hasVoted(electionId);
    } on Exception {
      // Treat lookup failures as "not voted" so the ballot still opens.
      voted = false;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _kycApproved = kycApproved;
      _hasVoted = voted;
      _eligibilityChecked = true;
    });
  }

  void _shareElection() {
    final Election? election = _election;
    if (election == null) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${election.title} — ${election.organization ?? 'SecureVote Election'}',
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static String _formatDate(DateTime d) {
    final List<String> months = _months;
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  static String _formatShort(DateTime d) {
    final List<String> months = _months;
    final String hour = d.hour.toString().padLeft(2, '0');
    final String min = d.minute.toString().padLeft(2, '0');
    return '${months[d.month - 1]} ${d.day}, $hour:$min';
  }

  static String _formatTimeRange(DateTime startsAt, DateTime endsAt) {
    return '${_formatShort(startsAt)} — ${_formatShort(endsAt)}';
  }

  static String _statusLabel(Election e) {
    switch (e.status) {
      case 'active':
        return 'Active — Voting Open';
      case 'scheduled':
      case 'upcoming':
      case 'draft':
        return 'Upcoming — Not Open';
      case 'closed':
      case 'published':
        return 'Closed — Results';
      default:
        return e.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> tabs = <String>[
      'Overview',
      'Candidates (${_candidates.length})',
      'Rules & Info',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF08090E),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Custom AppBar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: const Color(0xFF1E1F25),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(24),
                        child: const Icon(Icons.arrow_back, size: 20),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: const Color(0xFF1E1F25),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _shareElection,
                        borderRadius: BorderRadius.circular(24),
                        child: const Icon(Icons.share, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tabs
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF08090E).withValues(alpha: 0.8),
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFF444654).withValues(alpha: 0.15),
                  ),
                ),
              ),
              child: Row(
                children: List.generate(tabs.length, (index) {
                  final bool isSelected = _selectedTab == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTab = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 32),
                      padding: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isSelected
                                ? const Color(0xFFB9C3FF)
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        tabs[index],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFFB9C3FF)
                              : Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Content
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      // Fixed Bottom Button — context-aware:
      //   • already voted   → "View Receipt"
      //   • KYC not approved → disabled "KYC Required"
      //   • election closed → disabled "Voting Closed"
      //   • otherwise       → "Vote Now"
      bottomNavigationBar: _election == null
          ? const SizedBox.shrink()
          : _buildBottomButton(),
    );
  }

  Widget _buildBottomButton() {
    final Election election = _election!;

    // Already voted — offer to view the receipt instead.
    if (_hasVoted) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF08090E).withValues(alpha: 0.8),
          border: Border(
            top: BorderSide(
              color: const Color(0xFF444654).withValues(alpha: 0.15),
            ),
          ),
        ),
        child: SafeArea(
          child: GradientButton(
            label: 'View Your Receipt',
            icon: Icons.receipt_long_rounded,
            onPressed: () => Navigator.pushNamed(
              context,
              AppRouter.myVotes,
            ),
          ),
        ),
      );
    }

    // KYC not approved — disabled.
    if (_eligibilityChecked && !_kycApproved) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF08090E).withValues(alpha: 0.8),
          border: Border(
            top: BorderSide(
              color: const Color(0xFF444654).withValues(alpha: 0.15),
            ),
          ),
        ),
        child: SafeArea(
          child: GradientButton(
            label: 'KYC Required to Vote',
            icon: Icons.gpp_bad_outlined,
            onPressed: null,
          ),
        ),
      );
    }

    // Election not active — disabled.
    if (election.status != 'active') {
      final String label = election.status == 'closed' ||
          election.status == 'published'
          ? 'Voting Closed'
          : 'Voting Not Open Yet';
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF08090E).withValues(alpha: 0.8),
          border: Border(
            top: BorderSide(
              color: const Color(0xFF444654).withValues(alpha: 0.15),
            ),
          ),
        ),
        child: SafeArea(
          child: GradientButton(
            label: label,
            icon: Icons.lock_clock,
            onPressed: null,
          ),
        ),
      );
    }

    // Eligible and election is active — vote.
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF08090E).withValues(alpha: 0.8),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF444654).withValues(alpha: 0.15),
          ),
        ),
      ),
      child: SafeArea(
        child: GradientButton(
          label: 'Vote Now',
          icon: Icons.how_to_vote_rounded,
          onPressed: () => Navigator.pushNamed(
            context,
            AppRouter.ballotCasting,
            arguments: <String, dynamic>{
              'electionId': election.id,
              'election': election,
              'candidates': _candidates,
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (_selectedTab == 0) ...[
            // Overview Tab
            _headerBlock(context, election),
            const SizedBox(height: 16),
            _statsRow(election),
            const SizedBox(height: 16),
            _progressBlock(context, election),
            const SizedBox(height: 16),
            _timeCard(context, election),
            const SizedBox(height: 16),
            _eligibilityCard(context),
            const SizedBox(height: 24),
            const Text(
              'About this Election',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              election.description ??
                  'This election is managed securely through the SecureVote platform. Review the candidates carefully before casting your ballot. Voting is anonymous and secured via cryptographic proofs.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withValues(alpha: 0.7),
                height: 1.6,
              ),
            ),
          ] else if (_selectedTab == 1) ...[
            // Candidates Tab
            _buildCandidatesList(context),
          ] else ...[
            // Rules & Info Tab
            _buildRulesInfo(context, election),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _headerBlock(BuildContext context, Election election) {
    final bool isActive = election.status == 'active';
    final Color statusColor = isActive
        ? const Color(0xFF2ADEC0)
        : const Color(0xFFB9C3FF);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFF1E1F25),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.1),
                blurRadius: 0,
                offset: const Offset(0, 1),
                blurStyle: BlurStyle.inner,
              ),
            ],
          ),
          child: Icon(
            isActive ? Icons.how_to_vote_rounded : Icons.school_rounded,
            size: 48,
            color: statusColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                election.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                election.organization ?? 'SecureVote Election',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: statusColor.withValues(alpha: 0.2),
                  border: Border.all(
                    color: const Color(0xFF444654).withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: statusColor,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: statusColor.withValues(alpha: 0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _statusLabel(election),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statsRow(Election election) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _StatCard(label: 'Candidates', value: '${_candidates.length}'),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            label: 'Starts',
            value: _formatDate(election.startsAt),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(label: 'Ends', value: _formatDate(election.endsAt)),
        ),
      ],
    );
  }

  Widget _progressBlock(BuildContext context, Election election) {
    final DateTime now = DateTime.now();
    final double total = election.endsAt
        .difference(election.startsAt)
        .inMilliseconds
        .toDouble();
    final double elapsed = now
        .difference(election.startsAt)
        .inMilliseconds
        .toDouble();
    final double progress = total <= 0
        ? 0.0
        : (elapsed / total).clamp(0.0, 1.0);
    final int percent = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1A1B21),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.1),
            blurRadius: 0,
            offset: const Offset(0, 1),
            blurStyle: BlurStyle.inner,
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                'Voting Window',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '$percent%',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF34343A),
                borderRadius: BorderRadius.circular(999),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[Color(0xFFB9C3FF), Color(0xFFD2BBFF)],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(999)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeCard(BuildContext context, Election election) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1E1F25),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.1),
            blurRadius: 0,
            offset: const Offset(0, 1),
            blurStyle: BlurStyle.inner,
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFF34343A),
            ),
            child: const Icon(
              Icons.schedule_rounded,
              color: Color(0xFFB9C3FF),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Voting Period',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTimeRange(election.startsAt, election.endsAt),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _statusLabel(election),
                  style: const TextStyle(
                    color: Color(0xFFB9C3FF),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _eligibilityCard(BuildContext context) {
    final bool eligible = _kycApproved && !_hasVoted;
    final Color statusColor = _hasVoted
        ? const Color(0xFFFFB547)
        : eligible
        ? const Color(0xFF2ADEC0)
        : const Color(0xFFFF6B6B);
    final IconData statusIcon = _hasVoted
        ? Icons.how_to_vote_rounded
        : eligible
        ? Icons.check_circle
        : Icons.gpp_bad_outlined;
    final String title = _hasVoted
        ? 'You have already voted'
        : eligible
        ? 'You are eligible to vote'
        : 'KYC verification required';
    final String subtitle = !_eligibilityChecked
        ? 'Checking your eligibility...'
        : _hasVoted
        ? 'Your ballot for this election has been recorded.'
        : eligible
        ? 'Your KYC profile is verified. You can cast your ballot.'
        : 'Complete KYC verification to become eligible to vote.';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1E1F25),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor.withValues(alpha: 0.2),
            ),
            child: Icon(statusIcon, color: statusColor, size: 16),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                if (!_eligibilityChecked && !_kycApproved && !_hasVoted)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFB9C3FF),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidatesList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Running Candidates',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.5,
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
          _buildCandidateCard(context, _candidates[i], i),
          if (i != _candidates.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildCandidateCard(
    BuildContext context,
    Candidate candidate,
    int index,
  ) {
    final Color color = _candidateColors[index % _candidateColors.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRouter.candidateDetails,
            arguments: <String, dynamic>{
              'candidate': candidate,
              'election': _election,
            },
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
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
                  color: color.withValues(alpha: 0.2),
                ),
                child: Icon(Icons.person, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      candidate.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: <Widget>[
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            candidate.party ?? 'Independent',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF8E90A0)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRulesInfo(BuildContext context, Election election) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Election Rules & Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        if (election.description != null && election.description!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFF1A1B21),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Text(
                election.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.75),
                  height: 1.6,
                ),
              ),
            ),
          ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFF1A1B21),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildRuleItem(
                Icons.how_to_vote,
                'Voting Method',
                'One vote per person. Anonymous ballot with cryptographic verification.',
              ),
              const SizedBox(height: 16),
              _buildRuleItem(
                Icons.schedule,
                'Voting Period',
                '${_formatTimeRange(election.startsAt, election.endsAt)}.',
              ),
              const SizedBox(height: 16),
              _buildRuleItem(
                Icons.verified_user,
                'Eligibility',
                'Participants with verified KYC status are eligible to vote.',
              ),
              const SizedBox(height: 16),
              _buildRuleItem(
                Icons.security,
                'Security',
                'Votes are encrypted end-to-end and stored on an immutable blockchain ledger.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRouter.electionRules,
                arguments: election,
              );
            },
            icon: const Icon(Icons.article_outlined, size: 20),
            label: const Text('View Complete Rules'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFB9C3FF),
              side: BorderSide(
                color: const Color(0xFFB9C3FF).withValues(alpha: 0.3),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRuleItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color(0xFFB9C3FF).withValues(alpha: 0.1),
          ),
          child: Icon(icon, color: const Color(0xFFB9C3FF), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.7),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1A1B21),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.1),
            blurRadius: 0,
            offset: const Offset(0, 1),
            blurStyle: BlurStyle.inner,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
