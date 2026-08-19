import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/kyc_status.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  Timer? _navTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();

    _scale = Tween<double>(
      begin: 0.86,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _scheduleNavigation();
  }

  void _scheduleNavigation() {
    _navTimer?.cancel();
    _navTimer = Timer(const Duration(milliseconds: 1600), () {
      if (!mounted || _hasNavigated) return;
      _navigateToNextScreen();
    });
  }

  void _navigateToNextScreen() {
    final auth = context.read<AuthProvider>();

    // If the session is still being restored, wait for it to finish.
    if (auth.isLoading) {
      _scheduleNavigation();
      return;
    }

    // Onboarding is a non-auth preference, keep it in StorageService.
    if (!StorageService.isOnboardingCompleted()) {
      _go(AppRouter.onboarding);
      return;
    }

    if (!auth.isAuthenticated) {
      _go(AppRouter.welcome);
      return;
    }

    final kyc = auth.user?.kycStatus ?? KycStatus.notSubmitted;
    switch (kyc) {
      case KycStatus.approved:
        _go(AppRouter.homeScreen);
      case KycStatus.notSubmitted:
        // Never submitted documents — go straight to the upload form.
        _go(AppRouter.kycStep1);
      case KycStatus.pending:
      case KycStatus.rejected:
        // Submitted before — show the status/rejection screen with a
        // re-verify path so the user sees why they were rejected.
        _go(AppRouter.kycStatusPending);
    }
  }

  void _go(String route) {
    _hasNavigated = true;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.7, -0.9),
            radius: 1.8,
            colors: <Color>[
              Color(0xFF262D49),
              Color(0xFF121318),
              AppColors.surfaceBase,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, _) {
                return Opacity(
                  opacity: _fade.value,
                  child: Transform.scale(
                    scale: _scale.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          width: 98,
                          height: 98,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: const LinearGradient(
                              colors: <Color>[
                                AppColors.primary,
                                AppColors.secondary,
                              ],
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: 0.35,
                                ),
                                blurRadius: 34,
                                offset: const Offset(0, 14),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.how_to_vote_rounded,
                            size: 52,
                            color: Color(0xFF0D0E13),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'SecureVote',
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Obsidian Mobile Experience',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
