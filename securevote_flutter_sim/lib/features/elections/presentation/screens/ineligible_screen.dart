import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/election.dart';
import '../../../../core/models/kyc_status.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../features/voting/data/voting_repository.dart';

class IneligibleScreen extends StatefulWidget {
  const IneligibleScreen({super.key});

  @override
  State<IneligibleScreen> createState() => _IneligibleScreenState();
}

class _IneligibleScreenState extends State<IneligibleScreen> {
  Election? _election;
  bool _kycApproved = false;
  bool _hasVoted = false;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    bool? hasVotedArg;
    bool? kycApprovedArg;

    final Object? args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      final Object? e = args['election'];
      if (e is Election) {
        _election = e;
      }
      final Object? hv = args['hasVoted'];
      if (hv is bool) {
        hasVotedArg = hv;
      }
      final Object? kyc = args['kycStatus'];
      if (kyc is KycStatus) {
        kycApprovedArg = kyc == KycStatus.approved;
      }
      final Object? kycApproved = args['kycApproved'];
      if (kycApproved is bool) {
        kycApprovedArg = kycApproved;
      }
    } else if (args is Election) {
      _election = args;
    }

    final AuthProvider auth = context.read<AuthProvider>();
    kycApprovedArg ??= auth.user?.kycStatus == KycStatus.approved;

    _kycApproved = kycApprovedArg;

    if (hasVotedArg != null) {
      _hasVoted = hasVotedArg;
      return;
    }

    // Fall back to an async check when hasVoted was not passed.
    final Election? election = _election;
    if (election == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final bool voted = await VotingRepository().hasVoted(election.id);
        if (!mounted) return;
        setState(() => _hasVoted = voted);
      } on Exception {
        // Ignore; keep the KYC reason as the primary cause.
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool kycIssue = !_kycApproved;
    final bool votedIssue = _hasVoted;

    return Scaffold(
      backgroundColor: const Color(0xFF08090E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 40),
                // Icon
                Container(
                  width: 120,
                  height: 120,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFF6B6B).withValues(alpha: 0.1),
                    border: Border.all(
                      color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.block,
                    size: 60,
                    color: Color(0xFFFF6B6B),
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                const Text(
                  'Not Eligible to Vote',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_election != null) ...<Widget>[
                  const SizedBox(height: 12),
                  Text(
                    _election!.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFFB9C3FF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // Message
                Text(
                  _ineligibilityMessage(kycIssue, votedIssue),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.7),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Requirements Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xFF1A1B21),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Requirements',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildRequirement(
                        'KYC Verification',
                        _kycApproved,
                        _kycApproved ? 'Verified' : 'KYC verification required',
                      ),
                      const SizedBox(height: 12),
                      _buildRequirement(
                        'Single Vote',
                        !_hasVoted,
                        _hasVoted
                            ? 'You have already voted in this election'
                            : 'No previous vote recorded',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Complete KYC Button (only when KYC is the issue)
                if (kycIssue)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRouter.kycStep1);
                      },
                      icon: const Icon(Icons.verified_user, size: 20),
                      label: const Text(
                        'Complete KYC Verification',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB9C3FF),
                        foregroundColor: const Color(0xFF001257),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                if (kycIssue) const SizedBox(height: 12),

                // Contact Support
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRouter.helpSupport);
                  },
                  icon: const Icon(Icons.help_outline, size: 18),
                  label: const Text(
                    'Contact Support',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF8E90A0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _ineligibilityMessage(bool kycIssue, bool votedIssue) {
    if (kycIssue && votedIssue) {
      return 'You do not meet the eligibility requirements for this election. KYC verification is required and a vote has already been recorded for your account.';
    }
    if (votedIssue) {
      return 'You have already voted in this election. Each voter can only vote once per election.';
    }
    if (kycIssue) {
      return 'You do not meet the eligibility requirements for this election. Complete KYC verification to become eligible to vote.';
    }
    return 'You do not meet the eligibility requirements for this election. Please review the requirements below.';
  }

  Widget _buildRequirement(String title, bool met, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(
          met ? Icons.check_circle : Icons.cancel,
          color: met ? const Color(0xFF2ADEC0) : const Color(0xFFFF6B6B),
          size: 24,
        ),
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
    );
  }
}
