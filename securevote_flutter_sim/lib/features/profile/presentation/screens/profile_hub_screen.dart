import 'package:flutter/material.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../shared/widgets/premium_bottom_nav.dart';

class ProfileHubScreen extends StatelessWidget {
  const ProfileHubScreen({super.key});

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'U';
  }

  @override
  Widget build(BuildContext context) {
    // Get user data from storage
    final user = StorageService.getUser();
    final userName = user?['fullName'] ?? 'User';
    final userInitials = _getInitials(userName);
    final isKycCompleted = StorageService.isKycCompleted();
    final votes = StorageService.getVotes();
    final voteCount = votes.length;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D12),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // AppBar
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              color: const Color(0xFF0B0D12),
              child: Row(
                children: <Widget>[
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, size: 24),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  // Profile Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color(0xFF1A1D28),
                    ),
                    child: Column(
                      children: <Widget>[
                        // Avatar
                        Stack(
                          clipBehavior: Clip.none,
                          children: <Widget>[
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF2D3748),
                              ),
                              child: Center(
                                child: Text(
                                  userInitials,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF2ADEC0),
                                  border: Border.all(
                                    color: const Color(0xFF1A1D28),
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 12,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: isKycCompleted
                                ? const Color(
                                    0xFF2ADEC0,
                                  ).withValues(alpha: 0.15)
                                : const Color(
                                    0xFFFFB4AB,
                                  ).withValues(alpha: 0.15),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                Icons.circle,
                                size: 8,
                                color: isKycCompleted
                                    ? const Color(0xFF2ADEC0)
                                    : const Color(0xFFFFB4AB),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isKycCompleted
                                    ? 'IDENTITY VERIFIED'
                                    : 'VERIFICATION PENDING',
                                style: TextStyle(
                                  color: isKycCompleted
                                      ? const Color(0xFF2ADEC0)
                                      : const Color(0xFFFFB4AB),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Stats
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            _buildStat(voteCount.toString(), 'Elections'),
                            Container(
                              width: 1,
                              height: 40,
                              color: const Color(0xFF2A2E3A),
                            ),
                            _buildStat(voteCount.toString(), 'Votes Cast'),
                            Container(
                              width: 1,
                              height: 40,
                              color: const Color(0xFF2A2E3A),
                            ),
                            _buildStat(
                              isKycCompleted ? '100%' : '0%',
                              'Verified',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ACCOUNT SETTINGS
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'ACCOUNT SETTINGS',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: const Color(0xFF1A1D28),
                    ),
                    child: Column(
                      children: <Widget>[
                        _buildMenuItem(
                          icon: Icons.account_circle_outlined,
                          title: 'View Public Profile',
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRouter.profileView,
                          ),
                        ),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.white.withValues(alpha: 0.05),
                          indent: 60,
                        ),
                        _buildMenuItem(
                          icon: Icons.person_outline,
                          title: 'Personal Information',
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRouter.editProfile,
                          ),
                        ),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.white.withValues(alpha: 0.05),
                          indent: 60,
                        ),
                        _buildMenuItem(
                          icon: Icons.shield_outlined,
                          title: 'Security & Privacy',
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRouter.securitySettings,
                          ),
                        ),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.white.withValues(alpha: 0.05),
                          indent: 60,
                        ),
                        _buildMenuItem(
                          icon: Icons.lock_outline,
                          title: 'Privacy Settings',
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRouter.privacySettings,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // PREFERENCES
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'PREFERENCES',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: const Color(0xFF1A1D28),
                    ),
                    child: Column(
                      children: <Widget>[
                        _buildMenuItem(
                          icon: Icons.notifications_outlined,
                          title: 'Notifications',
                          trailing: _buildToggle(true),
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRouter.notificationSettings,
                          ),
                        ),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.white.withValues(alpha: 0.05),
                          indent: 60,
                        ),
                        _buildMenuItem(
                          icon: Icons.language,
                          title: 'Appearance',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                'Dark Mode',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.chevron_right,
                                color: Colors.white.withValues(alpha: 0.3),
                                size: 20,
                              ),
                            ],
                          ),
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRouter.appearanceSettings,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // SUPPORT
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'SUPPORT',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: const Color(0xFF1A1D28),
                    ),
                    child: Column(
                      children: <Widget>[
                        _buildMenuItem(
                          icon: Icons.help_outline,
                          title: 'Help Center',
                          trailing: Icon(
                            Icons.open_in_new,
                            color: Colors.white.withValues(alpha: 0.3),
                            size: 18,
                          ),
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRouter.helpSupport,
                          ),
                        ),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.white.withValues(alpha: 0.05),
                          indent: 60,
                        ),
                        _buildMenuItem(
                          icon: Icons.description_outlined,
                          title: 'About SecureVote',
                          onTap: () =>
                              Navigator.pushNamed(context, AppRouter.about),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sign Out
                  InkWell(
                    onTap: () async {
                      // Logout
                      await StorageService.logout();
                      if (!context.mounted) return;
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRouter.welcome,
                        (route) => false,
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xFF3A1F2A),
                        border: Border.all(
                          color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.logout,
                            color: Color(0xFFFF6B6B),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'SIGN OUT',
                            style: TextStyle(
                              color: Color(0xFFFF6B6B),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const PremiumBottomNav(currentIndex: 4),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: <Widget>[
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: <Widget>[
            Icon(icon, color: const Color(0xFFB9C3FF), size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            if (trailing != null)
              trailing
            else
              Icon(
                Icons.chevron_right,
                color: Colors.white.withValues(alpha: 0.3),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle(bool isOn) {
    return Container(
      width: 48,
      height: 28,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isOn ? const Color(0xFFB9C3FF) : const Color(0xFF2A2E3A),
      ),
      padding: const EdgeInsets.all(3),
      child: Align(
        alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
