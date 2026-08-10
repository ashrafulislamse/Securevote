import 'package:flutter/material.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
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

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                          color: const Color(
                            0xFFFFBF00,
                          ).withValues(alpha: 0.66),
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 92,
                          height: 92,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(
                              0xFFFFBF00,
                            ).withValues(alpha: 0.10),
                            boxShadow: const <BoxShadow>[
                              BoxShadow(
                                color: Color(0x33FFBF00),
                                blurRadius: 28,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.schedule_rounded,
                            size: 36,
                            color: Color(0xFFFFBF00),
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
              'Under Review',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 6),
            Text(
              'Our security team is validating your biometric credentials.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
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
                    subtitle: 'Passport & Liveness verified successfully.',
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
            GradientButton(
              label: 'Simulate Approval (Demo)',
              icon: Icons.verified_rounded,
              onPressed: () {
                // For simulation: Go directly to success screen
                Navigator.pushReplacementNamed(context, AppRouter.kycSuccess);
              },
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                backgroundColor: Colors.white.withValues(alpha: 0.04),
              ),
              onPressed: () {},
              icon: const Icon(Icons.notifications_active_rounded),
              label: const Text('Notify Me When Approved'),
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
