import 'package:flutter/material.dart';

import '../../../../core/navigation/app_router.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

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
          'About',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // App Logo
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFFB9C3FF), Color(0xFFD2BBFF)],
                ),
              ),
              child: const Icon(
                Icons.how_to_vote,
                size: 50,
                color: Color(0xFF001257),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // App Name & Version
          const Center(
            child: Column(
              children: [
                Text(
                  'SecureVote',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'SecureVote v2.0.0',
                  style: TextStyle(fontSize: 14, color: Color(0xFF8E90A0)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Info Section
          _buildSection('Information', [
            _buildItem(
              'Terms of Service',
              () => _showSnackBar(
                context,
                'Terms of Service are not available offline in this version.',
              ),
            ),
            _buildItem(
              'Privacy Policy',
              () => _showSnackBar(
                context,
                'Privacy Policy is not available offline in this version.',
              ),
            ),
            _buildItem(
              'Open Source Licenses',
              () => _showSnackBar(
                context,
                'This app uses Flutter, Provider, Dio, and Freezed among other open-source packages.',
              ),
            ),
          ]),
          const SizedBox(height: 24),

          _buildSection('Support', [
            _buildItem(
              'Help Center',
              () => Navigator.pushNamed(context, AppRouter.helpSupport),
            ),
            _buildItem(
              'Contact Us',
              () =>
                  _showSnackBar(context, 'Email us at support@securevote.io.'),
            ),
            _buildItem(
              'Report a Bug',
              () => _showSnackBar(
                context,
                'To report a bug, email support@securevote.io with details.',
              ),
            ),
            _buildItem(
              'Rate SecureVote',
              () => _showSnackBar(
                context,
                'Thank you! Rating is not available in this version.',
              ),
            ),
          ]),
          const SizedBox(height: 40),

          // Copyright
          Center(
            child: Text(
              '© 2026 SecureVote. All rights reserved.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
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

  Widget _buildItem(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
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
