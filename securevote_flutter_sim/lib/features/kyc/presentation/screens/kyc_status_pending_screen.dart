import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/models/kyc_document.dart';
import '../../../../core/models/kyc_status.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/kyc_repository.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/obsidian_scaffold.dart';

class KycStatusPendingScreen extends StatefulWidget {
  const KycStatusPendingScreen({super.key});

  @override
  State<KycStatusPendingScreen> createState() => _KycStatusPendingScreenState();
}

class _KycStatusPendingScreenState extends State<KycStatusPendingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  final KycRepository _repository = KycRepository();
  Timer? _pollTimer;
  KycStatus _status = KycStatus.pending;
  List<KycDocument> _documents = const <KycDocument>[];
  KycDocument? _latest;
  bool _loading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // Poll the real KYC status every few seconds so the UI reflects when an
    // admin approves the submission in the web portal.
    _checkStatus();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkStatus(),
    );
  }

  Future<void> _checkStatus() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final snapshot = await _repository.getStatus();
      if (!mounted) return;
      if (snapshot.status == KycStatus.approved) {
        _pollTimer?.cancel();
        setState(() => _loading = false);
        Navigator.pushReplacementNamed(context, AppRouter.kycSuccess);
        return;
      }
      setState(() {
        _status = snapshot.status;
        _documents = snapshot.documents;
        _latest = snapshot.documents.isNotEmpty
            ? snapshot.documents.first
            : null;
        _loading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = 'Could not reach the server. Retrying...';
      });
      // Keep the current view on transient failures.
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  String _formatTimestamp(DateTime? ts) {
    if (ts == null) return '—';
    return ts.toLocal().toString();
  }

  @override
  Widget build(BuildContext context) {
    final DateTime? submittedAt = _latest?.createdAt;
    return ObsidianScaffold(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'SecureVote',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                const Icon(
                  Icons.notifications_rounded,
                  color: AppColors.textPrimary,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
            const SizedBox(height: 26),
            Center(
              child: AnimatedBuilder(
                animation: _pulse,
                builder: (BuildContext context, _) {
                  final double scale = 1 + (_pulse.value * 0.05);
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 124,
                      height: 124,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _status == KycStatus.rejected
                              ? const Color(0xFFFF5252)
                                  .withValues(alpha: 0.66)
                              : const Color(0xFFFFBF00)
                                  .withValues(alpha: 0.66),
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 92,
                          height: 92,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _status == KycStatus.rejected
                                ? const Color(0xFFFF5252)
                                    .withValues(alpha: 0.10)
                                : const Color(0xFFFFBF00)
                                    .withValues(alpha: 0.10),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: _status == KycStatus.rejected
                                    ? const Color(0x33FF5252)
                                    : const Color(0x33FFBF00),
                                blurRadius: 28,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            _status == KycStatus.rejected
                                ? Icons.cancel_rounded
                                : Icons.schedule_rounded,
                            size: 36,
                            color: _status == KycStatus.rejected
                                ? const Color(0xFFFF8A80)
                                : const Color(0xFFFFBF00),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _status == KycStatus.rejected
                  ? 'Verification Rejected'
                  : _status == KycStatus.notSubmitted
                      ? 'Verification Required'
                      : 'Under Review',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 6),
            Text(
              _status == KycStatus.rejected
                  ? 'Your identity documents could not be verified. Please review and resubmit.'
                  : _status == KycStatus.notSubmitted
                      ? 'Submit your identity documents to unlock voting access.'
                      : 'Our security team is validating your biometric credentials.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (submittedAt != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                'Submitted at: ${_formatTimestamp(submittedAt)}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
            if (_documents.isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: _documents
                    .map(
                      (doc) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: Colors.white.withValues(alpha: 0.07),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.10),
                          ),
                        ),
                        child: Text(
                          '${doc.docType} · ${doc.status}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
            if (_errorMessage != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: const Color(0xFFFF8A80),
                    ),
              ),
            ],
            const SizedBox(height: 20),
            if (_status == KycStatus.rejected)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'What went wrong?',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your submission did not pass our security review. This can happen if the document was blurry, out of date, or did not match your account details.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'You can retry verification with a clearer document.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(color: Color(0x32000000), blurRadius: 16),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Identity Roadmap',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 18),
                    const _TimelineRow(
                      icon: Icons.check_circle_rounded,
                      color: AppColors.tertiary,
                      title: 'Document Uploaded',
                      subtitle: 'ID & selfie submitted to review queue.',
                    ),
                    const SizedBox(height: 12),
                    const _TimelineRow(
                      icon: Icons.hourglass_bottom_rounded,
                      color: Color(0xFFFFBF00),
                      title: 'Security Review',
                      subtitle:
                          'Manual cross-reference in progress. Est. 2-4 hours.',
                      highlight: true,
                    ),
                    const SizedBox(height: 12),
                    const _TimelineRow(
                      icon: Icons.lock_outline_rounded,
                      color: AppColors.textMuted,
                      title: 'Vote Access Granted',
                      subtitle: 'Unlock your digital ballot after approval.',
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            if (_status != KycStatus.rejected)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: Colors.white.withValues(alpha: 0.05),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.primary.withValues(alpha: 0.13),
                      ),
                      child: const Icon(
                        Icons.lightbulb_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You can close this screen. We will notify you the moment your identity is approved.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            if (_status == KycStatus.rejected)
              GradientButton(
                label: 'Retry Verification',
                icon: Icons.refresh_rounded,
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRouter.kycStep1,
                    (Route<dynamic> route) => route.isFirst,
                  );
                },
              )
            else
              GradientButton(
                label: _loading ? 'Checking...' : 'Check Status',
                icon: Icons.verified_rounded,
                onPressed: _loading
                    ? () {}
                    : () {
                        _checkStatus();
                      },
              ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'An admin must approve your documents in the web portal. '
                'This screen refreshes automatically every few seconds.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.center,
              child: TextButton.icon(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRouter.homeScreen,
                  (Route<dynamic> route) => route.isFirst,
                ),
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Continue to Home'),
              ),
            ),
            const SizedBox(height: 26),
          ],
        ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.highlight = false,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: color.withValues(alpha: 0.18),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: highlight ? const Color(0xFFFFBF00) : null,
                    ),
              ),
              const SizedBox(height: 2),
              Text(subtitle, style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
        ),
      ],
    );
  }
}
