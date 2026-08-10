import 'package:flutter/material.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/obsidian_scaffold.dart';
import '../../../../shared/widgets/step_meter.dart';

class KycStep1Screen extends StatelessWidget {
  const KycStep1Screen({super.key});

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
                Icons.badge_rounded,
                color: AppColors.primary,
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Upload your ID',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Step 3 of 3: KYC document capture.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: const Color(0xFF111420),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.28),
                ),
              ),
              child: Center(
                child: Container(
                  width: 250,
                  height: 155,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.crop_free_rounded,
                        color: AppColors.primary.withValues(alpha: 0.9),
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Align all corners in frame',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
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
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRouter.kycLiveness),
                  icon: const Icon(Icons.upload_file_rounded),
                  label: const Text('Upload ID'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GradientButton(
                  label: 'Take Photo',
                  icon: Icons.photo_camera_rounded,
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRouter.kycLiveness),
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
