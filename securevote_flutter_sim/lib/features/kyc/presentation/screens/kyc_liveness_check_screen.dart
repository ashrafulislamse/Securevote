import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/kyc_repository.dart';
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
  final KycRepository _repository = KycRepository();

  bool _submitting = false;
  String? _errorMessage;
  Uint8List? _previewBytes;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  Future<void> _pickAndSubmitSelfie() async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      final picked = await _repository.pickImage(docType: 'selfie');
      if (picked == null) {
        if (!mounted) return;
        setState(() => _submitting = false);
        return;
      }
      await _repository.submitDocument(
        bytes: picked.bytes,
        fileName: picked.fileName,
        docType: 'selfie',
      );
      if (!mounted) return;
      setState(() {
        _previewBytes = picked.bytes;
        _submitting = false;
      });
      Navigator.pushNamed(context, AppRouter.kycStatusPending);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _submitting = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Could not submit your selfie. Please check your connection and try again.';
        _submitting = false;
      });
    }
  }

  void _retake() {
    setState(() {
      _previewBytes = null;
      _errorMessage = null;
    });
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
              child: _previewBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          Image.memory(
                            _previewBytes!,
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                          ),
                        ],
                      ),
                    )
                  : AnimatedBuilder(
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
          if (_errorMessage != null) ...<Widget>[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0x33FF5252),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0x55FF5252)),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Color(0xFFFF8A80),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Color(0xFFFFCDD2),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
                  onPressed: _submitting ? null : _retake,
                  icon: const Icon(Icons.replay_rounded),
                  label: Text(_previewBytes != null ? 'Retake' : 'Skip'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GradientButton(
                  label: _submitting ? 'Submitting...' : 'Submit KYC',
                  icon: Icons.verified_rounded,
                  onPressed: _submitting
                      ? () {}
                      : () {
                          _pickAndSubmitSelfie();
                        },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.center,
            child: TextButton.icon(
              onPressed: _submitting
                  ? null
                  : () => Navigator.pushNamedAndRemoveUntil(
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
