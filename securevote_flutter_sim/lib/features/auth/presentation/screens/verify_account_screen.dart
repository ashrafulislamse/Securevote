import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/obsidian_scaffold.dart';
import '../../../../shared/widgets/step_meter.dart';

class VerifyAccountScreen extends StatefulWidget {
  const VerifyAccountScreen({super.key});

  @override
  State<VerifyAccountScreen> createState() => _VerifyAccountScreenState();
}

class _VerifyAccountScreenState extends State<VerifyAccountScreen> {
  int _secondsLeft = 30;
  Timer? _timer;
  final TextEditingController _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startCountdown();
    // Show demo OTP message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Demo OTP: ${StorageService.DEMO_OTP}'),
          duration: const Duration(seconds: 5),
          backgroundColor: const Color(0xFF2ADEC0),
        ),
      );
    });
  }

  void _startCountdown() {
    _timer?.cancel();
    _secondsLeft = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) return;
      if (_secondsLeft == 0) {
        timer.cancel();
      } else {
        setState(() {
          _secondsLeft -= 1;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ObsidianScaffold(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const StepMeter(total: 3, active: 1),
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: Colors.white.withValues(alpha: 0.06),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.14),
                  ),
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: AppColors.primary,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Verify your account',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 6),
            Text(
              'Enter the 6-digit OTP sent to your email/phone.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Text(
              'Verification Code',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                counterText: '',
                hintText: '000000',
                prefixIcon: Icon(Icons.pin_outlined),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: <Widget>[
                Text(
                  _secondsLeft > 0
                      ? 'Resend in ${_secondsLeft}s'
                      : 'Didn\'t get code?',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const Spacer(),
                TextButton(
                  onPressed: _secondsLeft > 0 ? null : _startCountdown,
                  child: const Text('Resend'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GradientButton(
              label: 'Verify & Continue',
              icon: Icons.arrow_forward_rounded,
              onPressed: () {
                final otp = _otpController.text.trim();

                if (otp.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter OTP')),
                  );
                  return;
                }

                if (StorageService.verifyOTP(otp)) {
                  // OTP verified, user is now logged in (already saved during registration)
                  // Proceed to KYC
                  Navigator.pushReplacementNamed(context, AppRouter.kycStep1);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Invalid OTP. Use demo OTP: ${StorageService.DEMO_OTP}',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                Expanded(
                  child: Divider(color: Colors.white.withValues(alpha: 0.10)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'OR',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                Expanded(
                  child: Divider(color: Colors.white.withValues(alpha: 0.10)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
                backgroundColor: Colors.white.withValues(alpha: 0.04),
              ),
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                AppRouter.homeScreen,
                (Route<dynamic> route) => route.isFirst,
              ),
              icon: const Icon(Icons.schedule_rounded),
              label: const Text('Verify later from profile'),
            ),
          ],
        ),
      ),
    );
  }
}
