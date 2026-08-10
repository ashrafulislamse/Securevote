import 'package:flutter/material.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/obsidian_scaffold.dart';
import '../../../../shared/widgets/trust_pill.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ObsidianScaffold(
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 60,
            left: -60,
            child: Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            bottom: 180,
            right: -70,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: 0.10),
              ),
            ),
          ),
          Column(
            children: <Widget>[
              const Spacer(),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.9, end: 1),
                duration: const Duration(milliseconds: 420),
                curve: Curves.easeOutCubic,
                builder: (BuildContext context, double value, Widget? child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Container(
                  height: 94,
                  width: 94,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: <Color>[AppColors.primary, AppColors.secondary],
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.how_to_vote_rounded,
                    size: 48,
                    color: Color(0xFF0D0E13),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'SecureVote',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 6),
              Text(
                'Digital elections you can trust.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: <Widget>[
                  TrustPill(
                    label: 'Encrypted',
                    icon: Icons.lock_rounded,
                    color: AppColors.tertiary,
                  ),
                  TrustPill(
                    label: 'Verified',
                    icon: Icons.check_circle_rounded,
                    color: AppColors.primary,
                  ),
                  TrustPill(
                    label: 'Anonymous',
                    icon: Icons.visibility_off_rounded,
                    color: AppColors.secondary,
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  color: Colors.white.withValues(alpha: 0.06),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x66000000),
                      blurRadius: 30,
                      offset: Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  children: <Widget>[
                    GradientButton(
                      label: 'Create Account',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRouter.register),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(54),
                          backgroundColor: const Color(0xFF1E2230),
                          foregroundColor: AppColors.textPrimary,
                          side: BorderSide(
                            color: AppColors.primary.withValues(alpha: 0.38),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRouter.login),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.login_rounded, size: 18),
                            SizedBox(width: 8),
                            Text('Sign In'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'By continuing, you accept Terms and Privacy Policy.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
