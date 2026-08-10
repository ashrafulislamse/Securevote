import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/obsidian_scaffold.dart';
import '../../../../shared/widgets/step_meter.dart';

class KycLivenessCheckScreen extends StatefulWidget {
  const KycLivenessCheckScreen({super.key});

  @override
  State<KycLivenessCheckScreen> createState() => _KycLivenessCheckScreenState();
}

class _KycLivenessCheckScreenState extends State<KycLivenessCheckScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ObsidianScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const StepMeter(total: 3, active: 2),
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: Colors.white.withValues(alpha: 0.06),
                border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
              ),
              child: const Icon(
                Icons.face_retouching_natural_rounded,
                color: AppColors.primary,
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Liveness Check',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Blink twice slowly to confirm you are live.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: const Color(0xFF10131C),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.28),
                ),
              ),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (BuildContext context, _) {
                  final double t = _controller.value;
                  final double y = 34 + math.sin(t * math.pi) * 140;
                  return Stack(
                    children: <Widget>[
                      Positioned(
                        left: 20,
                        right: 20,
                        top: y,
                        child: Container(
                          height: 2,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: <Color>[
                                Colors.transparent,
                                AppColors.primary,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 220,
                          height: 280,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.22),
                            ),
                          ),
                          child: const Icon(
                            Icons.face_rounded,
                            color: AppColors.primary,
                            size: 64,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                    backgroundColor: Colors.white.withValues(alpha: 0.04),
                  ),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Retake'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GradientButton(
                  label: 'Submit KYC',
                  icon: Icons.verified_rounded,
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRouter.kycStatusPending),
                ),
              ),
            ],
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
              icon: const Icon(Icons.schedule_rounded),
              label: const Text('Verify later from profile'),
            ),
          ),
        ],
      ),
    );
  }
}
