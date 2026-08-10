import 'package:flutter/material.dart';

import '../../../../core/services/storage_service.dart';

class ProfileViewScreen extends StatelessWidget {
  const ProfileViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Load user data from storage
    final user = StorageService.getUser();
    final fullName = user?['fullName'] ?? 'User';
    final email = user?['email'] ?? 'user@securevote.com';
    final phone = user?['phone'] ?? 'Not provided';
    final isKycVerified = StorageService.isKycCompleted();
    final voteCount = StorageService.getVotes().length;

    // Get initials from name
    final nameParts = fullName.split(' ');
    final initials = nameParts.length >= 2
        ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
        : fullName.length >= 2
        ? fullName.substring(0, 2).toUpperCase()
        : fullName[0].toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0E13),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0E13).withOpacity(0.8),
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
            onPressed: () {},
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
                color: Colors.white.withOpacity(0.05),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
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
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFB9C3FF), Color(0xFFD2BBFF)],
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Color(0xFF292A2F),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              'JD',
                              style: TextStyle(
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
                              color: Colors.white.withOpacity(0.1),
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
                    style: TextStyle(
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
                        color: const Color(0xFF2ADEC0).withOpacity(0.1),
                        border: Border.all(
                          color: const Color(0xFF2ADEC0).withOpacity(0.2),
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
                        color: const Color(0xFFFFB6C8).withOpacity(0.1),
                        border: Border.all(
                          color: const Color(0xFFFFB6C8).withOpacity(0.2),
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
                        top: BorderSide(color: Colors.white.withOpacity(0.05)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: const [
                              Text(
                                '3',
                                style: TextStyle(
                                  color: Color(0xFFE3E1E9),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
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
                          color: Colors.white.withOpacity(0.05),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '$voteCount',
                                style: TextStyle(
                                  color: Color(0xFFE3E1E9),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
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
                          color: Colors.white.withOpacity(0.05),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                isKycVerified ? '100%' : '0%',
                                style: TextStyle(
                                  color: Color(0xFFE3E1E9),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
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

            const SizedBox(height: 40),

            // Settings Sections
            _buildSection('ACCOUNT SETTINGS', [
              _buildSettingItem(
                'Personal Information',
                Icons.person,
                const Color(0xFFB9C3FF),
              ),
              _buildSettingItem(
                'Security & Privacy',
                Icons.shield,
                const Color(0xFFB9C3FF),
              ),
            ]),

            const SizedBox(height: 32),

            _buildSection('PREFERENCES', [
              _buildSettingItemWithToggle(
                'Notifications',
                Icons.notifications_active,
                const Color(0xFFB9C3FF),
                true,
              ),
              _buildSettingItemWithValue(
                'Language',
                Icons.language,
                const Color(0xFFB9C3FF),
                'English (US)',
              ),
            ]),

            const SizedBox(height: 32),

            _buildSection('SUPPORT', [
              _buildSettingItem(
                'Help Center',
                Icons.help,
                const Color(0xFFB9C3FF),
                trailing: Icons.open_in_new,
              ),
              _buildSettingItem(
                'Terms of Service',
                Icons.policy,
                const Color(0xFFB9C3FF),
              ),
            ]),

            const SizedBox(height: 32),

            // Sign Out Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF4757),
                  side: BorderSide(
                    color: const Color(0xFFFF4757).withOpacity(0.2),
                  ),
                  backgroundColor: const Color(0xFFFF4757).withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
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
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B21),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
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
          Icon(trailing ?? Icons.chevron_right, color: const Color(0xFF8E90A0)),
        ],
      ),
    );
  }

  Widget _buildSettingItemWithToggle(
    String title,
    IconData icon,
    Color iconColor,
    bool value,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B21),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
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
          Container(
            width: 40,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFFB9C3FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 16,
                height: 16,
                margin: const EdgeInsets.only(right: 2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItemWithValue(
    String title,
    IconData icon,
    Color iconColor,
    String value,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B21),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
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
    );
  }
}
