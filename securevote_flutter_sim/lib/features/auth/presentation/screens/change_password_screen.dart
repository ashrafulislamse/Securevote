import 'package:flutter/material.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/obsidian_scaffold.dart';
import '../../data/auth_repository.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  double _passwordStrength = 0;
  bool _submitting = false;

  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool get _lengthOk => _newController.text.length >= 8;
  bool get _hasCase =>
      RegExp(r'[A-Z]').hasMatch(_newController.text) &&
      RegExp(r'[a-z]').hasMatch(_newController.text);
  bool get _hasDigit => RegExp(r'\d').hasMatch(_newController.text);
  bool get _hasSymbol => RegExp(r'[^A-Za-z0-9]').hasMatch(_newController.text);

  Future<void> _updatePassword() async {
    final current = _currentController.text;
    final newPassword = _newController.text;
    final confirm = _confirmController.text;

    if (current.isEmpty || newPassword.isEmpty || confirm.isEmpty) {
      _showSnack('Please fill in all password fields', isError: true);
      return;
    }
    if (newPassword != confirm) {
      _showSnack('New passwords do not match', isError: true);
      return;
    }
    if (!_lengthOk || !_hasCase || !_hasDigit) {
      _showSnack(
        'New password must be at least 8 characters with uppercase, '
        'lowercase, and a digit',
        isError: true,
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      await AuthRepository().changePassword(
        currentPassword: current,
        newPassword: newPassword,
      );
      if (!mounted) return;
      _showSnack('Password updated successfully.');
      _currentController.clear();
      _newController.clear();
      _confirmController.clear();
      setState(() {
        _passwordStrength = 0;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      _showSnack(e.message, isError: true);
    } catch (_) {
      if (!mounted) return;
      _showSnack('Could not update password. Please try again.', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF2ADEC0),
      ),
    );
  }

  String get _strengthLabel => switch (_passwordStrength) {
    0.0 => 'WEAK',
    0.25 => 'WEAK',
    0.5 => 'MEDIUM',
    0.75 => 'GOOD',
    _ => 'STRONG',
  };

  @override
  Widget build(BuildContext context) {
    return ObsidianScaffold(
      title: 'Security',
      showBack: true,
      onBack: () => Navigator.pop(context),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Security Shield Icon
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBase.withValues(alpha: 0.5),
                  border: Border.all(color: AppColors.primary, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.shield_outlined,
                      color: AppColors.primary,
                      size: 40,
                    ),
                    Icon(Icons.lock, color: AppColors.primary, size: 20),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Heading
            Text(
              'Change Password',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Update your credentials to maintain vault integrity.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 32),

            // Current Password
            _buildPasswordField(
              'Current Password',
              _obscureCurrent,
              () => setState(() => _obscureCurrent = !_obscureCurrent),
              controller: _currentController,
            ),

            const SizedBox(height: 24),

            // New Password with Strength
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildPasswordField(
                  'New Password',
                  _obscureNew,
                  () => setState(() => _obscureNew = !_obscureNew),
                  controller: _newController,
                  onChanged: (_) => setState(() {
                    final len = _newController.text.length;
                    _passwordStrength = len >= 12
                        ? 1.0
                        : len >= 8
                        ? 0.75
                        : len >= 4
                        ? 0.5
                        : 0.25;
                  }),
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: _passwordStrength >= 0.25
                                    ? AppColors.tertiary
                                    : AppColors.tertiary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: _passwordStrength >= 0.5
                                    ? AppColors.tertiary
                                    : AppColors.tertiary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: _passwordStrength >= 0.75
                                    ? AppColors.tertiary
                                    : AppColors.tertiary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: _passwordStrength >= 1.0
                                    ? AppColors.tertiary
                                    : AppColors.tertiary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.tertiary.withValues(alpha: 0.1),
                        border: Border.all(
                          color: AppColors.tertiary.withValues(alpha: 0.2),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.tertiary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _strengthLabel,
                            style: const TextStyle(
                              color: AppColors.tertiary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Confirm Password
            _buildPasswordField(
              'Confirm New Password',
              _obscureConfirm,
              () => setState(() => _obscureConfirm = !_obscureConfirm),
              hasCheck: true,
              controller: _confirmController,
            ),

            const SizedBox(height: 24),

            // Security Checklist (dynamic — checks off as the user types)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'SECURITY CHECKLIST',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textMuted.withValues(alpha: 0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildChecklistItem('At least 8 characters long', _lengthOk),
                  const SizedBox(height: 12),
                  _buildChecklistItem(
                    'Includes uppercase and lowercase',
                    _hasCase,
                  ),
                  const SizedBox(height: 12),
                  _buildChecklistItem('Includes a digit', _hasDigit),
                  const SizedBox(height: 12),
                  _buildChecklistItem('Includes a symbol', _hasSymbol),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // Update Button
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: _submitting ? null : _updatePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: const Color(0xFF001D79),
                  elevation: 10,
                  shadowColor: AppColors.primary.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Color(0xFF001D79),
                          strokeWidth: 2,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Update Password',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    bool obscure,
    VoidCallback onToggle, {
    bool hasCheck = false,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            obscureText: obscure,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: '••••••••••••',
              hintStyle: TextStyle(
                color: AppColors.textMuted.withValues(alpha: 0.4),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              suffixIcon: hasCheck
                  ? const Icon(
                      Icons.check_circle,
                      color: AppColors.tertiary,
                      size: 20,
                    )
                  : IconButton(
                      icon: Icon(
                        obscure ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textMuted.withValues(alpha: 0.6),
                      ),
                      onPressed: onToggle,
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistItem(String text, bool isChecked) {
    return Row(
      children: <Widget>[
        Icon(
          isChecked ? Icons.check_circle : Icons.schedule,
          color: isChecked
              ? AppColors.tertiary
              : AppColors.textMuted.withValues(alpha: 0.4),
          size: 18,
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            color: isChecked ? AppColors.textPrimary : AppColors.textMuted,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
