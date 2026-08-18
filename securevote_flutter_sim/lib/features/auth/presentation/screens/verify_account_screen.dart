import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/kyc_status.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/providers/providers.dart';
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
  int _totalSeconds = 600;
  int _secondsLeft = 600;
  Timer? _timer;
  bool _resending = false;
  final TextEditingController _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final expiresInSeconds =
        context.read<AuthProvider>().lastRegister?.expiresInSeconds ?? 600;
    _totalSeconds = expiresInSeconds;
    _secondsLeft = expiresInSeconds;
    _startCountdown();
    // Show the dev OTP if the API returned one (dev mode). In production the
    // user receives the OTP via email, so we don't show anything then.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final devOtp = context.read<AuthProvider>().lastRegister?.devOtp;
      if (devOtp != null && devOtp.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Your verification code: $devOtp'),
            duration: const Duration(seconds: 5),
            backgroundColor: const Color(0xFF2ADEC0),
          ),
        );
      }
    });
  }

  /// The email being verified, passed from the register screen.
  String? get _email {
    final args = ModalRoute.of(context)?.settings.arguments;
    return args is String ? args : null;
  }

  void _startCountdown() {
    _timer?.cancel();
    _secondsLeft = _totalSeconds;
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

  String get _countdownText {
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _resendOtp() async {
    final email = _email;
    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Registration email is missing. Please register again.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _resending = true;
    });

    final auth = context.read<AuthProvider>();
    final result = await auth.resendOtp(email);

    if (!mounted) return;
    setState(() {
      _resending = false;
    });

    if (result.ok) {
      _startCountdown();
      if (result.devOtp != null && result.devOtp!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Your new verification code: ${result.devOtp}'),
            duration: const Duration(seconds: 5),
            backgroundColor: const Color(0xFF2ADEC0),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'A new verification code has been sent to your email.',
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            auth.error ?? 'Could not resend OTP. Please try again.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
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
                      ? 'Code expires in $_countdownText'
                      : 'Code expired',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const Spacer(),
                TextButton(
                  onPressed: (_secondsLeft > 0 || _resending)
                      ? null
                      : _resendOtp,
                  child: _resending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Resend OTP'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (auth.isLoading)
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: <Color>[AppColors.primary, AppColors.secondary],
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Color(0xFF0D0E13),
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),
              )
            else
              GradientButton(
                label: 'Verify & Continue',
                icon: Icons.arrow_forward_rounded,
                onPressed: () async {
                  final otp = _otpController.text.trim();
                  final email = _email;

                  if (email == null || email.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Registration email is missing. Please register again.',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (otp.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter OTP')),
                    );
                    return;
                  }

                  final navigator = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    await auth.verifyOtp(email: email, otp: otp);
                    if (!mounted) return;

                    // Route by KYC status
                    if (auth.user?.kycStatus != KycStatus.approved) {
                      navigator.pushNamedAndRemoveUntil(
                        AppRouter.kycStep1,
                        (Route<dynamic> route) => false,
                      );
                    } else {
                      navigator.pushNamedAndRemoveUntil(
                        AppRouter.homeScreen,
                        (Route<dynamic> route) => false,
                      );
                    }
                  } catch (_) {
                    if (!mounted) return;
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          auth.error ??
                              'Verification failed. Please try again.',
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
