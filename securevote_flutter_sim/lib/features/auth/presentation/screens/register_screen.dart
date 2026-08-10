import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/obsidian_scaffold.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _acceptTerms = true;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  int _passwordScore(String value) {
    int score = 0;
    if (value.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(value) && RegExp(r'[a-z]').hasMatch(value)) {
      score++;
    }
    if (RegExp(r'\d').hasMatch(value)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(value)) score++;
    return score;
  }

  @override
  Widget build(BuildContext context) {
    final int score = _passwordScore(_passwordController.text);

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
            const SizedBox(height: 14),
            Text(
              'Create Account',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 6),
            Text(
              'Step 1 of 3: Personal info',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            _SignupProgress(active: 0),
            const SizedBox(height: 14),
            _MobileSurface(
              child: Column(
                children: <Widget>[
                  _AuthField(
                    hint: 'Full name',
                    icon: Icons.person_outline_rounded,
                    controller: _fullNameController,
                  ),
                  const SizedBox(height: 10),
                  _AuthField(
                    hint: 'Email address',
                    icon: Icons.mail_outline_rounded,
                    controller: _emailController,
                  ),
                  const SizedBox(height: 10),
                  _AuthField(
                    hint: 'Phone number',
                    icon: Icons.call_outlined,
                    controller: _phoneController,
                  ),
                  const SizedBox(height: 10),
                  _AuthField(
                    hint: 'Password',
                    icon: Icons.lock_outline_rounded,
                    controller: _passwordController,
                    onChanged: (_) => setState(() {}),
                    obscureText: _obscurePassword,
                    trailing: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _AuthField(
                    hint: 'Confirm password',
                    icon: Icons.lock_person_outlined,
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirm,
                    trailing: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureConfirm = !_obscureConfirm;
                        });
                      },
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _StrengthMeter(score: score),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Checkbox(
                        value: _acceptTerms,
                        onChanged: (bool? value) {
                          setState(() {
                            _acceptTerms = value ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            'I accept Terms and Privacy Policy.',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GradientButton(
              label: 'Continue to Verify',
              icon: Icons.arrow_forward_rounded,
              onPressed: () async {
                if (!_acceptTerms) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please accept terms first.')),
                  );
                  return;
                }

                // Validate fields (phone is optional)
                if (_fullNameController.text.trim().isEmpty ||
                    _emailController.text.trim().isEmpty ||
                    _passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                if (_passwordController.text !=
                    _confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Passwords do not match')),
                  );
                  return;
                }

                final auth = context.read<AuthProvider>();
                if (auth.isLoading) return;

                final email = _emailController.text.trim();
                final phone = _phoneController.text.trim();

                try {
                  await auth.register(
                    email: email,
                    password: _passwordController.text,
                    fullName: _fullNameController.text.trim(),
                    phone: phone.isEmpty ? null : phone,
                  );
                  if (!mounted) return;

                  // In dev the code is returned by the API; show it to the user.
                  final devOtp = auth.lastRegister?.devOtp;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        devOtp != null && devOtp.isNotEmpty
                            ? 'Your verification code: $devOtp'
                            : 'Verification code sent. Check your email.',
                      ),
                      backgroundColor: const Color(0xFF2ADEC0),
                      duration: const Duration(seconds: 5),
                    ),
                  );

                  Navigator.pushNamed(
                    context,
                    AppRouter.verifyAccount,
                    arguments: email,
                  );
                } catch (_) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        auth.error ?? 'Registration failed. Please try again.',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                backgroundColor: Colors.white.withValues(alpha: 0.06),
              ),
              onPressed: () {},
              icon: const FaIcon(
                FontAwesomeIcons.google,
                size: 16,
                color: Color(0xFFDB4437),
              ),
              label: Text(
                'Sign up with Google',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignupProgress extends StatelessWidget {
  const _SignupProgress({required this.active});

  final int active;

  @override
  Widget build(BuildContext context) {
    final List<String> labels = <String>['Account', 'Verify', 'KYC'];
    return Column(
      children: <Widget>[
        Row(
          children: List<Widget>.generate(labels.length, (int index) {
            final bool isActive = index == active;
            final bool isPast = index < active;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index == labels.length - 1 ? 0 : 6,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  height: 7,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    color: isActive || isPast
                        ? AppColors.primary
                        : Colors.white.withValues(alpha: 0.16),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          children: List<Widget>.generate(labels.length, (int index) {
            final bool isActive = index == active;
            return Expanded(
              child: Text(
                labels[index],
                textAlign: index == 1
                    ? TextAlign.center
                    : (index == 2 ? TextAlign.right : TextAlign.left),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: isActive ? AppColors.primary : AppColors.textMuted,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _StrengthMeter extends StatelessWidget {
  const _StrengthMeter({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final String label = switch (score) {
      0 || 1 => 'Weak',
      2 => 'Medium',
      3 => 'Good',
      _ => 'Strong',
    };

    return Column(
      children: <Widget>[
        Row(
          children: List<Widget>.generate(4, (int index) {
            final bool active = index < score;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index == 3 ? 0 : 4),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    color: active
                        ? AppColors.tertiary
                        : Colors.white.withValues(alpha: 0.14),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Row(
          children: <Widget>[
            Text(
              '$label security',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: AppColors.tertiary),
            ),
            const Spacer(),
            Text(
              'Encrypted vault',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ],
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.trailing,
    this.controller,
    this.onChanged,
  });

  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? trailing;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: trailing,
      ),
    );
  }
}

class _MobileSurface extends StatelessWidget {
  const _MobileSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x32000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
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
