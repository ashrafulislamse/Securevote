import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/obsidian_scaffold.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  String _method = 'email';
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = _emailController.text.trim();

    if (_method != 'email') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('SMS reset is not yet available. Please use email.'),
        ),
      );
      return;
    }

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address')),
      );
      return;
    }

    if (!RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final result = await auth.forgotPassword(email);

    if (!mounted) return;

    if (result != null && result.ok) {
      if (result.devResetToken != null && result.devResetToken!.isNotEmpty) {
        // Dev mode: the backend returned a reset token directly.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dev reset token: ${result.devResetToken}'),
            duration: const Duration(seconds: 8),
            backgroundColor: const Color(0xFF2ADEC0),
          ),
        );
        Navigator.pushNamed(
          context,
          AppRouter.resetPassword,
          arguments: result.devResetToken,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.message.isNotEmpty
                  ? result.message
                  : 'If the email exists, a reset link has been sent.',
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            auth.error ?? 'Could not send reset code. Please try again.',
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
            'Forgot Password',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Choose how to receive your reset code.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: _MethodChip(
                  label: 'Email',
                  icon: Icons.mail_outline_rounded,
                  selected: _method == 'email',
                  onTap: () => setState(() {
                    _method = 'email';
                  }),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MethodChip(
                  label: 'SMS',
                  icon: Icons.sms_outlined,
                  selected: _method == 'sms',
                  onTap: () => setState(() {
                    _method = 'sms';
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              controller: _emailController,
              keyboardType: _method == 'email'
                  ? TextInputType.emailAddress
                  : TextInputType.phone,
              decoration: InputDecoration(
                hintText: _method == 'email'
                    ? 'you@example.com'
                    : '+1 202 555 0125',
                prefixIcon: Icon(
                  _method == 'email'
                      ? Icons.mail_outline_rounded
                      : Icons.call_outlined,
                ),
              ),
            ),
          ),
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
              label: 'Send Reset Code',
              icon: Icons.send_rounded,
              onPressed: _send,
            ),
        ],
      ),
    );
  }
}

class _MethodChip extends StatelessWidget {
  const _MethodChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: selected
              ? AppColors.primary.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.06),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 18,
              color: selected ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(width: 8),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
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
          color: AppColors.secondary.withValues(alpha: 0.16),
        ),
        child: Text(label, style: Theme.of(context).textTheme.labelMedium),
      ),
    );
  }
}
