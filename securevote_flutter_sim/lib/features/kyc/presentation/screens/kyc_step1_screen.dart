import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/kyc_repository.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/obsidian_scaffold.dart';
import '../../../../shared/widgets/step_meter.dart';

class KycStep1Screen extends StatefulWidget {
  const KycStep1Screen({super.key});

  @override
  State<KycStep1Screen> createState() => _KycStep1ScreenState();
}

class _KycStep1ScreenState extends State<KycStep1Screen> {
  final KycRepository _repository = KycRepository();

  bool _submitting = false;
  String? _errorMessage;
  Uint8List? _previewBytes;
  String? _previewName;

  Future<void> _pickAndSubmit({required ImageSourceChoice source}) async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      final picked = await _repository.pickImage(docType: 'id');
      if (picked == null) {
        if (!mounted) return;
        setState(() => _submitting = false);
        return;
      }
      await _repository.submitDocument(
        bytes: picked.bytes,
        fileName: picked.fileName,
        docType: 'id',
      );
      if (!mounted) return;
      setState(() {
        _previewBytes = picked.bytes;
        _previewName = picked.fileName;
        _submitting = false;
      });
      // Small delay so the user sees the preview before the transition.
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      Navigator.pushNamed(context, AppRouter.kycLiveness);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _submitting = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Could not submit your ID document. Please check your connection and try again.';
        _submitting = false;
      });
    }
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
              child: _previewBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          Image.memory(
                            _previewBytes!,
                            fit: BoxFit.contain,
                            gaplessPlayback: true,
                          ),
                          Positioned(
                            left: 12,
                            bottom: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.55),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                _previewName ?? 'id',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Center(
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
                  onPressed: _submitting
                      ? null
                      : () => _pickAndSubmit(
                            source: ImageSourceChoice.gallery,
                          ),
                  icon: const Icon(Icons.upload_file_rounded),
                  label: const Text('Upload ID'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GradientButton(
                  label: _submitting ? 'Submitting...' : 'Take Photo',
                  icon: Icons.photo_camera_rounded,
                  onPressed: _submitting
                      ? () {}
                      : () {
                          _pickAndSubmit(source: ImageSourceChoice.camera);
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

/// Distinguishes which capture path the user picked (camera or gallery).
/// The repository handles the actual fallback logic; this is purely a UI
/// label to communicate intent.
enum ImageSourceChoice { camera, gallery }
