import 'package:flutter/material.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';

class AccountSuspendedScreen extends StatelessWidget {
  const AccountSuspendedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // The suspension reason may be passed via route args; otherwise a generic
    // message is shown.
    final reason = ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF6B6B).withValues(alpha: 0.1),
                  border: Border.all(
                    color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.gpp_bad,
                  size: 60,
                  color: Color(0xFFFF6B6B),
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'Account Suspended',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Message
              Text(
                reason != null && reason.isNotEmpty
                    ? 'Your account has been suspended: $reason. Please contact support to resolve this issue.'
                    : 'Your account has been temporarily suspended due to suspicious activity. Please contact support to resolve this issue.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textMuted,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Contact Support Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Email support@securevote.io for help'),
                        backgroundColor: Color(0xFF2ADEC0),
                      ),
                    );
                  },
                  icon: const Icon(Icons.support_agent, size: 20),
                  label: const Text(
                    'Contact Support',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: const Color(0xFF001257),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Appeal Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please email support@securevote.io to appeal',
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.gavel_rounded, size: 20),
                  label: const Text(
                    'Appeal Suspension',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Sign Out Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRouter.login,
                      (Route<dynamic> route) => false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textMuted,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
