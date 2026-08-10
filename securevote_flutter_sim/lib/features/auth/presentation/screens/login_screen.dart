import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/obsidian_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _rememberMe = true;
  bool _obscurePassword = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  label: 'Sign Up',
                  onTap: () => Navigator.pushNamed(context, AppRouter.register),
                ),
              ],
            ),
            const SizedBox(height: 18),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.92, end: 1),
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              builder: (BuildContext context, double value, Widget? child) {
                return Transform.translate(
                  offset: Offset(0, (1 - value) * 20),
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'Sign In',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Welcome back. Vote securely in seconds.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 18),
                  _MobileSurface(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _FieldLabel('Email'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'you@example.com',
                            prefixIcon: Icon(Icons.mail_outline_rounded),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _FieldLabel('Password'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'Enter password',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
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
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _rememberMe = !_rememberMe;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  color: _rememberMe
                                      ? AppColors.primary.withValues(
                                          alpha: 0.18,
                                        )
                                      : Colors.white.withValues(alpha: 0.06),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      _rememberMe
                                          ? Icons.check_circle_rounded
                                          : Icons
                                                .radio_button_unchecked_rounded,
                                      size: 16,
                                      color: _rememberMe
                                          ? AppColors.primary
                                          : AppColors.textMuted,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Remember me',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                AppRouter.forgotPassword,
                              ),
                              child: const Text('Forgot?'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GradientButton(
              label: 'Sign In Securely',
              icon: Icons.arrow_forward_rounded,
              onPressed: () async {
                final email = _emailController.text.trim();
                final password = _passwordController.text;

                // Validate fields
                if (email.isEmpty || password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter email and password'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Check if user exists in storage
                final storedUser = StorageService.getUser();

                if (storedUser != null) {
                  // User exists - validate credentials
                  if (storedUser['email'] == email &&
                      storedUser['password'] == password) {
                    // Correct credentials - login
                    await StorageService.saveUser(storedUser); // Re-login

                    if (!mounted) return;

                    // Check KYC status and navigate
                    if (StorageService.isKycCompleted()) {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRouter.homeScreen,
                      );
                    } else {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRouter.kycStep1,
                      );
                    }
                  } else {
                    // Wrong credentials
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invalid email or password'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  // No user registered - Demo mode
                  // Create a demo user and login
                  final demoUser = {
                    'fullName': 'Demo User',
                    'email': email,
                    'phone': '+1234567890',
                    'password': password,
                    'registeredAt': DateTime.now().toIso8601String(),
                  };

                  await StorageService.saveUser(demoUser);

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Demo login successful! Complete KYC to continue.',
                      ),
                      backgroundColor: Color(0xFF2ADEC0),
                      duration: Duration(seconds: 2),
                    ),
                  );

                  // Go to KYC
                  Navigator.pushReplacementNamed(context, AppRouter.kycStep1);
                }
              },
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                side: BorderSide(
                  color: const Color(0xFF2ADEC0).withValues(alpha: 0.3),
                ),
                backgroundColor: const Color(0xFF2ADEC0).withValues(alpha: 0.1),
              ),
              onPressed: () async {
                // Demo login with pre-filled credentials
                final demoUser = {
                  'fullName': 'Demo User',
                  'email': 'demo@securevote.com',
                  'phone': '+1234567890',
                  'password': 'demo123',
                  'registeredAt': DateTime.now().toIso8601String(),
                };

                await StorageService.saveUser(demoUser);
                await StorageService.setKycCompleted(true); // Skip KYC for demo

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🎮 Demo Mode: Logged in as Demo User'),
                    backgroundColor: Color(0xFF2ADEC0),
                    duration: Duration(seconds: 2),
                  ),
                );

                Navigator.pushReplacementNamed(context, AppRouter.homeScreen);
              },
              icon: const Icon(
                Icons.play_circle_outline,
                color: Color(0xFF2ADEC0),
              ),
              label: Text(
                'Quick Demo Login',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF2ADEC0),
                ),
              ),
            ),
            const SizedBox(height: 14),
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
                'Continue with Google',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRouter.kycStep1),
              icon: const Icon(Icons.fingerprint_rounded),
              label: const Text('Use biometric login'),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'New to SecureVote?',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRouter.register),
                  child: const Text('Create account'),
                ),
              ],
            ),
          ],
        ),
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

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: AppColors.textPrimary.withValues(alpha: 0.86),
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
