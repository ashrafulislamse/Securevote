import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/kyc_status.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/providers/providers.dart';
import '../../../elections/data/elections_repository.dart';
import '../../../voting/data/voting_repository.dart';

class ProfileViewScreen extends StatefulWidget {
  const ProfileViewScreen({super.key});

  @override
  State<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen> {
  final VotingRepository _votingRepository = VotingRepository();
  final ElectionsRepository _electionsRepository = ElectionsRepository();

  bool _statsLoading = true;
  int _voteCount = 0;
  int _electionCount = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadStats();
  }

  Future<void> _loadStats() async {
    int votes = 0;
    int elections = 0;
    try {
      final myVotes = await _votingRepository.getMyVotes();
      votes = myVotes.length;
    } catch (_) {
      // Best-effort: keep 0 on failure.
    }
    try {
      final all = await _electionsRepository.getElections();
      elections = all.length;
    } catch (_) {
      // Best-effort: keep 0 on failure.
    }
    if (!mounted) return;
    setState(() {
      _voteCount = votes;
      _electionCount = elections;
      _statsLoading = false;
    });
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'U';
  }

  Future<void> _handleSignOut() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouter.welcome,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Load the real user from the auth provider.
    final user = context.watch<AuthProvider>().user;
    final fullName = user?.fullName ?? 'User';
    final email = user?.email ?? 'user@securevote.com';
    final phone = user?.phone ?? 'Not provided';
    final role = user?.role ?? 'voter';
    final kycStatus = user?.kycStatus ?? KycStatus.notSubmitted;
    final isKycVerified = kycStatus == KycStatus.approved;
    final initials = _getInitials(fullName);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0E13),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0E13).withValues(alpha: 0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFB9C3FF)),
          onPressed: () => Navigator.pop(context),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFB9C3FF), Color(0xFFD2BBFF)],
          ).createShader(bounds),
          child: const Text(
            'SecureVote',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Color(0xFFB9C3FF)),
            onPressed: () =>
                Navigator.pushNamed(context, AppRouter.notificationSettings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Hero Card
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 1, color: Color(0xFFB9C3FF)),
                      ),
                    ),
                  ),
                  Stack(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFFB9C3FF), Color(0xFFD2BBFF)],
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Color(0xFF292A2F),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: Color(0xFFB9C3FF),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF34343A),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: const Icon(
                            Icons.verified,
                            color: Color(0xFF2ADEC0),
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    fullName,
                    style: const TextStyle(
                      color: Color(0xFFE3E1E9),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (isKycVerified)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2ADEC0).withValues(alpha: 0.1),
                        border: Border.all(
                          color: const Color(0xFF2ADEC0).withValues(alpha: 0.2),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2ADEC0),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'IDENTITY VERIFIED',
                            style: TextStyle(
                              color: Color(0xFF2ADEC0),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB6C8).withValues(alpha: 0.1),
                        border: Border.all(
                          color: const Color(0xFFFFB6C8).withValues(alpha: 0.2),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFB6C8),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'VERIFICATION PENDING',
                            style: TextStyle(
                              color: Color(0xFFFFB6C8),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.only(top: 24),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                _statsLoading ? '-' : _electionCount.toString(),
                                style: const TextStyle(
                                  color: Color(0xFFE3E1E9),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'ELECTIONS',
                                style: TextStyle(
                                  color: Color(0xFFC4C5D7),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                _statsLoading ? '-' : _voteCount.toString(),
                                style: const TextStyle(
                                  color: Color(0xFFE3E1E9),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'VOTES CAST',
                                style: TextStyle(
                                  color: Color(0xFFC4C5D7),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                isKycVerified ? '100%' : '0%',
                                style: const TextStyle(
                                  color: Color(0xFFE3E1E9),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'VERIFIED',
                                style: TextStyle(
                                  color: Color(0xFFC4C5D7),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Contact & Role Details
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1B21),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Column(
                children: [
                  _buildDetailRow(Icons.mail_outline, 'Email', email),
                  Divider(
                    height: 24,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                  _buildDetailRow(Icons.phone_outlined, 'Phone', phone),
                  Divider(
                    height: 24,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                  _buildDetailRow(
                    Icons.verified_user,
                    'KYC Status',
                    _kycLabel(kycStatus),
                  ),
                  Divider(
                    height: 24,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                  _buildDetailRow(Icons.person_outline, 'Role', role),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Settings Sections
            _buildSection('ACCOUNT SETTINGS', [
              _buildSettingItem(
                'Personal Information',
                Icons.person,
                const Color(0xFFB9C3FF),
                onTap: () =>
                    Navigator.pushNamed(context, AppRouter.editProfile),
              ),
              _buildSettingItem(
                'Security & Privacy',
                Icons.shield,
                const Color(0xFFB9C3FF),
                onTap: () =>
                    Navigator.pushNamed(context, AppRouter.securitySettings),
              ),
              _buildSettingItem(
                'Notification Settings',
                Icons.notifications_active,
                const Color(0xFFB9C3FF),
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRouter.notificationSettings,
                ),
              ),
              _buildSettingItem(
                'Privacy Settings',
                Icons.lock,
                const Color(0xFFB9C3FF),
                onTap: () =>
                    Navigator.pushNamed(context, AppRouter.privacySettings),
              ),
            ]),

            const SizedBox(height: 32),

            _buildSection('PREFERENCES', [
              _buildSettingItem(
                'Appearance',
                Icons.palette,
                const Color(0xFFB9C3FF),
                onTap: () =>
                    Navigator.pushNamed(context, AppRouter.appearanceSettings),
              ),
              _buildSettingItemWithValue(
                'Language',
                Icons.language,
                const Color(0xFFB9C3FF),
                'English (US)',
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Language is not customizable in this version.',
                    ),
                    duration: Duration(seconds: 2),
                  ),
                ),
              ),
            ]),

            const SizedBox(height: 32),

            _buildSection('SUPPORT', [
              _buildSettingItem(
                'Help Center',
                Icons.help,
                const Color(0xFFB9C3FF),
                trailing: Icons.open_in_new,
                onTap: () =>
                    Navigator.pushNamed(context, AppRouter.helpSupport),
              ),
              _buildSettingItem(
                'About SecureVote',
                Icons.info,
                const Color(0xFFB9C3FF),
                onTap: () => Navigator.pushNamed(context, AppRouter.about),
              ),
            ]),

            const SizedBox(height: 32),

            // Sign Out Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: _handleSignOut,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF4757),
                  side: BorderSide(
                    color: const Color(0xFFFF4757).withValues(alpha: 0.2),
                  ),
                  backgroundColor: const Color(
                    0xFFFF4757,
                  ).withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'SIGN OUT',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFB9C3FF), size: 20),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  String _kycLabel(KycStatus status) {
    switch (status) {
      case KycStatus.approved:
        return 'Verified';
      case KycStatus.pending:
        return 'Pending';
      case KycStatus.rejected:
        return 'Rejected';
      case KycStatus.notSubmitted:
        return 'Not Submitted';
    }
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 16),
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFFC4C5D7),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildSettingItem(
    String title,
    IconData icon,
    Color iconColor, {
    IconData? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B21),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFE3E1E9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              trailing ?? Icons.chevron_right,
              color: const Color(0xFF8E90A0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItemWithValue(
    String title,
    IconData icon,
    Color iconColor,
    String value, {
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B21),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFE3E1E9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(color: Color(0xFFC4C5D7), fontSize: 14),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Color(0xFF8E90A0)),
          ],
        ),
      ),
    );
  }
}
