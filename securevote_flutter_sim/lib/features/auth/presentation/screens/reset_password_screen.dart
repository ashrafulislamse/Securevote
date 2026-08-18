import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/obsidian_scaffold.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  @override
  void dispose() {
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  /// The reset token passed from the forgot-password screen (dev mode).
  String? get _token => ModalRoute.of(context)?.settings.arguments as String?;

  bool get _lengthOk => _newController.text.length >= 8;
  bool get _hasSymbol => RegExp(r'[^A-Za-z0-9]').hasMatch(_newController.text);
  bool get _hasCase =>
      RegExp(r'[A-Z]').hasMatch(_newController.text) &&
      RegExp(r'[a-z]').hasMatch(_newController.text);
  bool get _hasDigit => RegExp(r'\d').hasMatch(_newController.text);

  Future<void> _resetPassword() async {
    final token = _token;
    final newPassword = _newController.text;
    final confirmPassword = _confirmController.text;

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reset token is missing. Please request a new link.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all password fields')),
      );
      return;
    }

    if (!_lengthOk || !_hasCase || !_hasDigit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password must be at least 8 characters with uppercase, '
            'lowercase, and a digit',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final ok = await auth.resetPassword(token, newPassword);

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset successfully. Please sign in.'),
          backgroundColor: Color(0xFF2ADEC0),
        ),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.login,
        (Route<dynamic> route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            auth.error ?? 'Could not reset password. Please try again.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return ObsidianScaffold(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                _CircleIconButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                const Spacer(),
                _TinyActionChip(
                  label: 'Sign In',
                  onTap: () => Navigator.pushNamed(context, AppRouter.login),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Reset Password',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 6),
            Text(
              'Use your verification code and set a new password.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: <Widget>[
                  if (_token != null && _token!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.tertiary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: <Widget>[
                            const Icon(
                              Icons.vpn_key_rounded,
                              size: 18,
                              color: AppColors.tertiary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Reset token: $_token',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        'No reset token received. Please request a new reset link.',
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _newController,
                    onChanged: (_) => setState(() {}),
                    obscureText: _obscureNewPassword,
                    decoration: InputDecoration(
                      hintText: 'New password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureNewPassword = !_obscureNewPassword;
                          });
                        },
                        icon: Icon(
                          _obscureNewPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _confirmController,
                    onChanged: (_) => setState(() {}),
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      hintText: 'Confirm password',
                      prefixIcon: const Icon(Icons.lock_person_outlined),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _ChecklistTile(label: 'At least 8 characters', ok: _lengthOk),
            _ChecklistTile(label: 'Uppercase and lowercase', ok: _hasCase),
            _ChecklistTile(label: 'Contains a digit', ok: _hasDigit),
            _ChecklistTile(label: 'Contains a symbol', ok: _hasSymbol),
            const SizedBox(height: 16),
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
                label: 'Reset Password',
                icon: Icons.restart_alt_rounded,
                onPressed: _resetPassword,
              ),
          ],
        ),
      ),
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  const _ChecklistTile({required this.label, required this.ok});

  final String label;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: ok
            ? AppColors.tertiary.withValues(alpha: 0.14)
            : Colors.white.withValues(alpha: 0.05),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            ok ? Icons.check_circle_rounded : Icons.schedule_rounded,
            size: 18,
            color: ok ? AppColors.tertiary : AppColors.textMuted,
          ),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.08),
        ),
        child: Icon(icon, color: AppColors.textPrimary),
      ),
    );
  }
}

class _TinyActionChip extends StatelessWidget {
  const _TinyActionChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: AppColors.primary.withValues(alpha: 0.16),
        ),
        child: Text(label, style: Theme.of(context).textTheme.labelMedium),
      ),
    );
  }
}
