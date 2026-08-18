import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/providers/providers.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08090E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Security Settings',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSection('Authentication', [
            _buildComingSoonToggle(
              Icons.security,
              'Two-Factor Authentication',
              'Coming soon — not yet available',
            ),
            _buildComingSoonToggle(
              Icons.fingerprint,
              'Biometric Login',
              'Coming soon — not yet available',
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection('Password', [
            _buildActionItem(
              Icons.lock_outline,
              'Change Password',
              () => Navigator.pushNamed(context, AppRouter.changePassword),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection('Session Management', [
            _buildActionItem(Icons.devices, 'Active Sessions', () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Session management coming soon.'),
                  duration: Duration(seconds: 2),
                ),
              );
            }),
            _buildActionItem(Icons.logout, 'Sign Out All Devices', () async {
              await context.read<AuthProvider>().logout();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRouter.welcome,
                (route) => false,
              );
            }),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.4),
              letterSpacing: 1,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFF1A1D28),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildComingSoonToggle(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.4), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: false,
            onChanged: (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('This feature is coming soon.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            activeThumbColor: const Color(0xFFB9C3FF),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFB9C3FF), size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}
